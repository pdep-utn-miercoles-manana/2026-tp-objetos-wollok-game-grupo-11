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
}