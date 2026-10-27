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

