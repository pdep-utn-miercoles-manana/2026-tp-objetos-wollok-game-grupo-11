import wollok.game.*
import armas.*
import humanos.*

// ! HUD
object hud {
    method position() = game.at(0, game.height() - 1)
    method textColor() = "FFFFFF"
    method text() = "Vida: " + heroe.vida() + "  |  Poder: " + heroe.poder() + "%  |  " +
        heroe.arma().nombre() + " Nv." + heroe.arma().nivel() +
        "  |  Mejoras: " + heroe.mejoras() +
        "  |  Oleada " + juego.oleada() + "/" + juego.totalOleadas()
}

// ! Objeto Juego
object juego {
    const property enemigos = []       
    const property proyectiles = []   
    var property pendientes = []      
    var property oleada = 0
    var property ticks = 0
    var property esperando = false
    var property terminado = false

    method totalOleadas() = 5
    method oleada() = oleada
    method filaMaxima() = game.height() - 2   

    method configurar() {
        game.title("Resident Evil: Wollok Edition")
        game.width(40)
        game.height(15)
        game.cellSize(50)

        game.addVisual(heroe)
        game.addVisual(hud)

        keyboard.up().onPressDo({ heroe.subir() })
        keyboard.down().onPressDo({ heroe.bajar() })
        keyboard.left().onPressDo({ heroe.izquierda() })
        keyboard.right().onPressDo({ heroe.derecha() })
        keyboard.w().onPressDo({ heroe.subir() })
        keyboard.s().onPressDo({ heroe.bajar() })
        keyboard.a().onPressDo({ heroe.izquierda() })
        keyboard.d().onPressDo({ heroe.derecha() })
        keyboard.space().onPressDo({ heroe.disparar() })

        keyboard.num1().onPressDo({ heroe.equiparPistola() })
        keyboard.num2().onPressDo({ heroe.equiparRifle() })
        keyboard.num3().onPressDo({ heroe.equiparEscopeta() })
        keyboard.m().onPressDo({ heroe.mejorarArma() })
    }

    method iniciar() {
        game.onTick(100, "buclePrincipal", { self.actualizar() })
        self.siguienteOleada()
    }

    method entrada(fila) = game.at(game.width() - 1, fila)


    method zombieComun() = { fila => new ZombieComun(position = self.entrada(fila)) }
    method zombieRapido() = { fila => new ZombieRapido(position = self.entrada(fila)) }
    method licker() = { fila => new Licker(position = self.entrada(fila)) }
    method ballestero() = { fila => new ZombieBallestero(position = self.entrada(fila)) }
    method jefe() = { fila => new JefeNemesis(position = self.entrada(fila)) }


    method composicion(n) {
        if (n == 1) {
            return [self.zombieComun(), self.zombieComun(), self.zombieComun(), self.zombieComun()]
        }
        if (n == 2) {
            return [self.zombieComun(), self.zombieRapido(), self.zombieComun(), self.ballestero(), self.zombieRapido()]
        }
        if (n == 3) {
            return [self.zombieComun(), self.licker(), self.ballestero(), self.zombieRapido(), self.licker()]
        }
        if (n == 4) {
            return [self.licker(), self.ballestero(), self.zombieRapido(), self.licker(), self.ballestero(), self.zombieComun()]
        }
        return [self.zombieComun(), self.licker(), self.ballestero(), self.jefe(), self.zombieRapido()]
    }


    method siguienteOleada() {
        oleada += 1
        pendientes = self.composicion(oleada)
        esperando = false
        game.say(heroe, "¡Oleada " + oleada + "!")
    }


    method actualizar() {
        if (!terminado) {
            ticks += 1
            heroe.actualizar()
            self.actualizarProyectiles()
            enemigos.copy().forEach({ e => e.actualizar() })
            self.generarEnemigos()
            self.verificarFinDeOleada()
        }
    }


    method filaAlAzar() = 0.randomUpTo(self.filaMaxima() + 1).floor()


    method generarEnemigos() {
        if (!pendientes.isEmpty() && ticks % 15 == 0) { 
            const receta = pendientes.first()
            pendientes.remove(receta)
            const enemigo = receta.apply(self.filaAlAzar()) 
            enemigos.add(enemigo)
            game.addVisual(enemigo)
        }
    }


    method agregarProyectil(proyectil) {
        proyectiles.add(proyectil)
        game.addVisual(proyectil)
    }


    method tieneProyectil(proyectil) = proyectiles.contains(proyectil)


    method removerProyectil(proyectil) {
        if (self.tieneProyectil(proyectil)) {
            proyectiles.remove(proyectil)
            game.removeVisual(proyectil)
        }
    }


    method actualizarProyectiles() {
        proyectiles.copy().forEach({ p => p.actualizar() })
    }


    method mismaCelda(a, b) = a.x() == b.x() && a.y() == b.y()


    method verificarImpactoBala(bala) {
        const golpeados = enemigos.filter({ e => self.mismaCelda(e.position(), bala.position()) }) 
        if (!golpeados.isEmpty()) {
            self.removerProyectil(bala)
            golpeados.first().recibirAtaque(bala.danio())
        } else if (bala.position().x() >= game.width()) {
            self.removerProyectil(bala)
        }
    }


    method enemigoDerrotado(enemigo) {
        if (enemigos.contains(enemigo)) {
            enemigos.remove(enemigo)
            game.removeVisual(enemigo)
        }
    }

    method verificarFinDeOleada() {
        if (!esperando && pendientes.isEmpty() && enemigos.isEmpty()) {
            esperando = true
            if (oleada == self.totalOleadas()) {
                self.ganar()
            } else {
                self.recompensaDeOleada()
                game.schedule(3000, { self.siguienteOleada() })
            }
        }
    }


    method recompensaDeOleada() {
        var mensaje = "¡Sobreviviste! M = mejorar el arma equipada"
        heroe.recuperarPoder()
        heroe.ganarMejora()
        if (oleada == 1) {
            heroe.desbloquearRifle()
            mensaje = "¡Rifle desbloqueado! (tecla 2)  M = mejorar arma"
        } else if (oleada == 2) {
            heroe.desbloquearEscopeta()
            mensaje = "¡Escopeta desbloqueada! (tecla 3)  M = mejorar arma"
        }
        game.say(heroe, mensaje)
    }


    method ganar() {
        if (!terminado) {
            terminado = true
            game.say(heroe, "ACABASTE CON TODOS LOS ZOMBIES ¡GANASTE!")
            game.schedule(3000, { game.stop() })
        }
    }


    method perder() {
        if (!terminado) {
            terminado = true
            game.say(heroe, "TE CONVERTISTE EN ZOMBIE... GAME OVER")
            game.schedule(3000, { game.stop() })
        }
    }
}
