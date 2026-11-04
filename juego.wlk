// juego.wlk
// juego.wlk
// juego.wlk
// juego.wlk
// juego.wlk
import wollok.game.*
import armas.*
import humanos.*

// ! HUD
object hudVida {
    method position() = game.at(2, game.height() - 1)
    method textColor() = "FFFFFF"
    method text() = "Vida: " + heroe.vida()
}

object hudArma {
    method position() = game.at(8, game.height() - 1)
    method textColor() = "FFFFFF"
    method text() = heroe.arma().nombre() + " Nv." + heroe.arma().nivel() + "   Mejoras: " + heroe.mejoras() + "  Poder: " + heroe.poderActual()
}

object hudOleada {
    method position() = game.at(14, game.height() - 1)
    method textColor() = "FFFFFF"
    method text() = "Oleada " + juego.oleada() + "/" + juego.totalOleadas()
}

// ! Menú
class TextoMenu {
    var property position
    const property text
    const property textColor = "FFFFFF"
}

object menu {
    const textos = [
        new TextoMenu(position = game.at(4, 7), text = "Resident Evil: Wollok Edition", textColor = "FF0000"),
        new TextoMenu(position = game.at(4, 6), text = "Presioná ENTER para jugar"),
        new TextoMenu(position = game.at(4, 5), text = "WASD / flechas: moverse"),
        new TextoMenu(position = game.at(4, 4), text = "ESPACIO: disparar"),
        new TextoMenu(position = game.at(4, 3), text = "1 / 2 / 3: cambiar de arma"),
        new TextoMenu(position = game.at(4, 2), text = "M: mejorar el arma")
    ]

    method mostrar() {
        textos.forEach({ t => game.addVisual(t) })
    }

    method ocultar() {
        textos.forEach({ t => game.removeVisual(t) })
    }
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
    var partidaEnCurso = false

    method totalOleadas() = 5
    method oleada() = oleada
    method filaMaxima() = game.height() - 2   

method configurar() {
    game.title("Resident Evil: Wollok Edition")
    game.width(16)
    game.height(9)
    game.cellSize(40)

    menu.mostrar()
    keyboard.enter().onPressDo({ self.empezar() })
}

method empezar() {
    if (!partidaEnCurso) {
        partidaEnCurso = true
        menu.ocultar()
        self.prepararPartida()
        self.iniciar()
    }
}

method prepararPartida() {
    game.addVisual(heroe)
    game.addVisual(hudVida)
    game.addVisual(hudArma)
    game.addVisual(hudOleada)

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
    method regenerador() = { fila => new Regenerador(position = self.entrada(fila)) }
    method ballestero() = { fila => new ZombieBallestero(position = self.entrada(fila)) }
    method jefe() = { fila => new JefeSaddler(position = self.entrada(fila)) }
    method mercenario() = {fila => new JefeKrauser(position = self.entrada(fila))}

    method composicion(n) {
        if (n == 1) {
            return [self.zombieComun(), self.zombieComun(), self.zombieComun(), self.zombieComun()]
        }
        if (n == 2) {
            return [self.zombieComun(), self.zombieRapido(), self.zombieComun(), self.ballestero(), self.zombieRapido(), self.zombieComun(), self.ballestero()]
        }
        if (n == 3) {
            return [self.zombieComun(), self.regenerador(), self.ballestero(), self.zombieRapido(), self.regenerador(), self.ballestero(), self.zombieComun(), self.zombieComun(), self.zombieRapido(), self.zombieComun()]
        }
        if (n == 4) {
            return [self.regenerador(), self.ballestero(), self.zombieRapido(), self.regenerador(), self.ballestero(), self.zombieComun(), self.ballestero(), self.regenerador(), self.ballestero(), self.zombieComun(), self.zombieComun(),self.mercenario()]
        }
        return [self.zombieComun(), self.ballestero(), self.regenerador(), self.regenerador() , self.jefe(), self.zombieRapido(), self.zombieComun(), self.ballestero(), self.zombieComun(), self.ballestero(), self.ballestero(), self.regenerador(), self.zombieRapido(), self.zombieComun()]
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
            game.say(heroe, "Acabaste con todos los zombies, misión cumplida!")
            game.schedule(3000, { game.stop() })
        }
    }


    method perder() {
        if (!terminado) {
            terminado = true
            game.say(heroe, "Te convertiste en un zombie... Game over")
            game.schedule(3000, { game.stop() })
        }
    }
}
