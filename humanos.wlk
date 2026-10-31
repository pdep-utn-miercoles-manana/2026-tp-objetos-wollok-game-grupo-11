import wollok.game.*
import armas.*
import juego.*

// ! Clase Personaje
class Personaje {
	var property position
	var danioRecibido = 0

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

	override method vidaMaxima() = 100
	method poderMinimo() = 30

	method image() = "heroe.png"
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
        if (position.x() > 0) {
            position = position.left(1)
        }
    }


    method derecha() {
        if (position.x() < game.width() - 2) {
            position = position.right(1)
        }
    }


    method actualizar() {
        ticksDesdeDisparo += 1
    }


    method danioEfectivo() = (arma.danio() * poder / 100).max(1)


    method disparar() {
        if (ticksDesdeDisparo >= arma.cadencia()) {
            ticksDesdeDisparo = 0
            juego.agregarProyectil(new Bala(position = position.right(1), danio = self.danioEfectivo()))
        }
    }


    override method recibirAtaque(danio) {
        super(danio)
        poder = (poder - danio).max(self.poderMinimo())
        if (!self.estaVivo()) {
            juego.perder()
        }
    }


    method recuperarPoder() {
        poder = (poder + 25).min(100)
    }


    method equipar(unArma) {
        if (unArma.desbloqueada()) {
            arma = unArma
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
        }
    }
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
    override method image() = "zombie_comun.png"
}


class ZombieRapido inherits Enemigo {
    override method vidaMaxima() = 20
    override method danio() = 5
    override method ritmoMovimiento() = 3
    override method ritmoAtaque() = 6
    override method image() = "zombie_rapido.png"
}


class Licker inherits Enemigo {
    override method vidaMaxima() = 120
    override method danio() = 15
    override method ritmoMovimiento() = 12
    override method ritmoAtaque() = 14
    override method image() = "licker.png"
}


class ZombieBallestero inherits Enemigo {
    override method vidaMaxima() = 35
    override method danio() = 12
    override method ritmoMovimiento() = 9
    override method ritmoAtaque() = 10
    override method image() = "zombie_ballestero.png"


    method distanciaDeDisparo() = 5


    override method atacar(objetivo) {
        juego.agregarProyectil(new FlechaDeFuego(position = position.left(1), danio = self.danio()))
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


class JefeNemesis inherits Enemigo {
    var ataques = 0


    override method vidaMaxima() = 400
    override method danio() = 20
    override method ritmoMovimiento() = 10
    override method ritmoAtaque() = 12
    override method image() = "nemesis.png"


    override method atacar(objetivo) {
        ataques += 1
        if (ataques % 3 == 0) {
            game.say(self, "¡STARS!")
            objetivo.recibirAtaque(self.danio() * 2)
        } else {
            super(objetivo)
        }
    }
}

const heroe = new Heroe(position = game.at(1, 2))
