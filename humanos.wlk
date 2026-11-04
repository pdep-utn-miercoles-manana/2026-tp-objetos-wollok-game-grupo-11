// humanos.wlk
// humanos.wlk
// humanos.wlk
// humanos.wlk
import wollok.game.*
import armas.*
import juego.*

// ! Clase Personaje
class Personaje {
	var property position
	var danioRecibido = 0
    
    var property mirandoIzquierda = false

	method vidaMaxima()

	method vida() = (self.vidaMaxima() - danioRecibido).max(0)
	method estaVivo() = self.vida() > 0

	method recibirAtaque(danio) {
		danioRecibido += danio
	}
}

// ! Clase Héroe 
class Heroe inherits Personaje {
	var property poder = 100
	var property mejoras = 0
	var property ticksDesdeDisparo = 100
	const pistola = new Pistola(desbloqueada = true)
	const property rifle = new Rifle()
	const property escopeta = new Escopeta()
	var property arma = pistola
    var property  debilitamiento = 0
    

	override method vidaMaxima() = 100
	method poderMinimo() = 30

	method image() {
        if (arma == pistola) {
            if(mirandoIzquierda){
                return "assets/heroe_pistola_l.png"
            }
            return "assets/heroe_pistola.png"    
        }
        else if (arma == rifle) {
            if(mirandoIzquierda){
                return "assets/heroe_rifle_l.png"        
            }
            return "assets/heroe_rifle.png"
        }
        else {
            if(mirandoIzquierda) {
                return "assets/heroe_escopeta_l.png"
            }
            return "assets/heroe_escopeta.png"
        } 
    }
	method poder() = poder
	method arma() = arma
	method mejoras() = mejoras
	
    method subir() {
        if (position.y() < juego.filaMaxima()) {
            position = position.up(1)
        }
    }


    method bajar() {
        if (position.y() > 0) {
            position = position.down(1)
        }
    }


    method izquierda() {
        mirandoIzquierda = true
        if (position.x() > 0) {
            position = position.left(1)
        }
    }


    method derecha() {
        mirandoIzquierda = false
        if (position.x() < game.width() - 2) {
            position = position.right(1)
        }
    }


    method actualizar() {
        ticksDesdeDisparo += 1
    }


    method danioEfectivo() = (arma.danio() * self.poderActual() / 100).max(1)

    method debilitar(cantidad, milisegundos) {
        debilitamiento += cantidad
        game.schedule(milisegundos, { debilitamiento -= cantidad })
    }

    method disparar() {
        if (ticksDesdeDisparo >= arma.cadencia()) {
            ticksDesdeDisparo = 0
            if(mirandoIzquierda){
            juego.agregarProyectil(new Bala(position = position.left(1), danio = self.danioEfectivo(),direccion= -1))
            }else
            juego.agregarProyectil(new Bala(position = position.right(1), danio = self.danioEfectivo(),direccion= 1))
        }
    }


    override method recibirAtaque(danio) {
        super(danio)
        if (!self.estaVivo()) {
            juego.perder()
        }
    }


    method poderActual() = (poder - debilitamiento).max(self.poderMinimo())



    method equipar(unArma) {
        if (unArma.desbloqueada()) {
            arma = unArma
            game.say(self, "Cambio a " + unArma.nombre())
        } else {
            game.say(self, unArma.nombre() + " bloqueada")
        }
    }

    method equiparPistola() { self.equipar(pistola) }
    method equiparRifle() { self.equipar(rifle) }
    method equiparEscopeta() { self.equipar(escopeta) }

    method desbloquearRifle() { rifle.desbloqueada(true) }
    method desbloquearEscopeta() { escopeta.desbloqueada(true) }

    method ganarMejora() {
        mejoras += 1
    }


    method mejorarArma() {
        if (mejoras > 0 && arma.puedeMejorar()) {
            arma.mejorar()
            mejoras -= 1
            game.say(self, arma.nombre() + " subió de nivel!")
        }
    }
    method desangrar(cantidadPorTick, duracionMs){ 
    game.schedule(1000, { self.recibirAtaque(cantidadPorTick) })
    game.schedule(2000, { self.recibirAtaque(cantidadPorTick) })
    game.schedule(3000, { self.recibirAtaque(cantidadPorTick) })
    }//ULTIMO
}// ! CLase Enemigo
class Enemigo inherits Personaje {
    var ticks = 0

    method image()
    method danio()
    method ritmoMovimiento()   
    method ritmoAtaque()       

    method distanciaX() = position.x() - heroe.position().x()
    method distanciaY() = heroe.position().y() - position.y()

    method estaEnContacto() = self.distanciaY() == 0 && self.distanciaX().abs() <= 1


    method pasoVertical() {
        if (self.distanciaY() > 0) {
            position = position.up(1)
        } else {
            position = position.down(1)
        }
    }


    method acercarse() {
        if (self.distanciaX() > 1) {
            position = position.left(1)
        } else if (self.distanciaX() < -1) {
            position = position.right(1)
        } else {
            self.pasoVertical()
        }
    }


    method actualizar() {
        ticks += 1
        if (self.estaEnContacto()) {
            if (ticks % self.ritmoAtaque() == 0) {
                self.atacar(heroe)
            }
        } else if (ticks % self.ritmoMovimiento() == 0) {
            self.acercarse()
        }
    }


    method atacar(objetivo) {
        objetivo.recibirAtaque(self.danio())
    }


    override method recibirAtaque(danio) {
        super(danio)
        if (!self.estaVivo()) {
            juego.enemigoDerrotado(self)
        }
    }
}


class ZombieComun inherits Enemigo {
    override method vidaMaxima() = 40
    override method danio() = 8
    override method ritmoMovimiento() = 8
    override method ritmoAtaque() = 10
    override method image() = "assets/zombie_comun.png"
}


class ZombieRapido inherits Enemigo {
    override method vidaMaxima() = 20
    override method danio() = 5
    override method ritmoMovimiento() = 3
    override method ritmoAtaque() = 6
    override method image() = "assets/zombie_rapido.png"
}


class Regenerador inherits Enemigo {
    override method vidaMaxima() = 120
    override method danio() = 15
    override method ritmoMovimiento() = 12
    override method ritmoAtaque() = 14
    override method image() = "assets/regenerador.png"
}


class ZombieBallestero inherits Enemigo {
    override method vidaMaxima() = 35
    override method danio() = 0
    override method ritmoMovimiento() = 9
    override method ritmoAtaque() = 10
    override method image() = "assets/zombie_ballestero.png"
    method reduccionDeDanio() = 10


    method distanciaDeDisparo() = 5


    override method atacar(objetivo) {
        juego.agregarProyectil(new FlechaDeFuego(position = position.left(1), danio = self.reduccionDeDanio()))
    }


    override method actualizar() {
        ticks += 1
        const alineado = self.distanciaY() == 0
        if (alineado && self.distanciaX() > 0 && ticks % self.ritmoAtaque() == 0) {
            self.atacar(heroe)
        }
        if (ticks % self.ritmoMovimiento() == 0) {
            if (!alineado) {
                self.pasoVertical()
            } else if (self.distanciaX() > self.distanciaDeDisparo()) {
                position = position.left(1)
            }
        }
    }
}


class JefeSaddler inherits Enemigo {
    var ataques = 0
    const frases = [
        "No saldrás vivo de aquí...",
        "Tu esfuerzo es inútil, Leon.",
        "Ríndete."
    ]

    override method vidaMaxima() = 600
    override method danio() = 20
    override method ritmoMovimiento() = 10
    override method ritmoAtaque() = 12
    override method image() = "assets/saddler.png"




    override method atacar(objetivo) {
        ataques += 1
        if (ataques % 3 == 0) {
            game.say(self, "Ha llegado la hora, Leon")
            objetivo.recibirAtaque(self.danio() * 2)
        } else {
            super(objetivo)
        }
    }

        override method actualizar() {
        super()
        if (ticks % 60 == 0) {
            game.say(self, frases.anyOne())
        }
    }
}

class JefeKrauser inherits Enemigo{
    var ataques = 0
    var modoVeloz = false
    var ticksPropios = 0

    const frases = [
        "Que es eso que te motiva, camarada.",
        "Pensaste que estaba muerto?, Leon.",
        "¡Tienes que dejar de vivir en el pasado!.",
        "No te entrené lo suficiente, Leon"
        
    ]
    override method vidaMaxima() = 500
    override method danio() = 10
    override method ritmoMovimiento() = if(modoVeloz) 6 else 13 //duplica su velocidad en modo veloz
    override method ritmoAtaque() = 8
    override method image() = "assets/krauser.png"

    method curar(cantidad) {
    danioRecibido = (danioRecibido - cantidad).max(0)
}

    override method atacar(objetivo) {
        super(objetivo)
        objetivo.desangrar(5, 3000)
        self.curar(10) //se cura
        game.say(self,frases )
    }
   

    override method actualizar() {
    super()
    ticksPropios += 1
    if (ticksPropios % 50 == 0) {
        modoVeloz = !modoVeloz
        if (modoVeloz) {
            game.say(self, "¡Demasiado lento, Leon!")
        }
    }
}

}





const heroe = new Heroe(position = game.at(1, 2))
