import wollok.game.*
import arma.*
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
}

// tira error ya que no terminamos los métodos para el héroe 