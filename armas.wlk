import wollok.game.*
import humanos.*
import juego.*

// ! Clase Arma
class Arma {
    var nivel = 1
    var property desbloqueada = false

    method nombre()
    method danioBase()
    method incrementoPorNivel()
    method cadencia()      

    method nivelMaximo() = 3
    method nivel() = nivel
    method danio() = self.danioBase() + (nivel - 1) * self.incrementoPorNivel() 
    method puedeMejorar() = nivel < self.nivelMaximo()

    method mejorar() {
        if (self.puedeMejorar()) {
            nivel += 1
        }
    }
}

class Pistola inherits Arma {
    override method nombre() = "Pistola"
    override method danioBase() = 12
    override method incrementoPorNivel() = 4
    override method cadencia() = 5
}

class Rifle inherits Arma {
    override method nombre() = "Rifle"
    override method danioBase() = 10
    override method incrementoPorNivel() = 4
    override method cadencia() = 3
}

class Escopeta inherits Arma {
    override method nombre() = "Escopeta"
    override method danioBase() = 35
    override method incrementoPorNivel() = 10
    override method cadencia() = 8
}

// ! Clase Proyectil
class Proyectil {
    var property position
    const property danio


    method avanzar()
    method verificarImpacto()


    method actualizar() {
        self.verificarImpacto()
        if (juego.tieneProyectil(self)) {   
            self.avanzar()
            self.verificarImpacto()
        }
    }
}

class Bala inherits Proyectil {
    method image() = "bala.png"


    override method avanzar() {
        position = position.right(1)
    }


    override method verificarImpacto() {
        juego.verificarImpactoBala(self)
    }
}

class FlechaDeFuego inherits Proyectil {
    method image() = "flecha_fuego.png"


    override method avanzar() {
        position = position.left(1)
    }


    override method verificarImpacto() {
        if (juego.mismaCelda(position, heroe.position())) {
            juego.removerProyectil(self)
            heroe.recibirAtaque(danio)
        } else if (position.x() < 0) {
            juego.removerProyectil(self)
        }
    }
}
