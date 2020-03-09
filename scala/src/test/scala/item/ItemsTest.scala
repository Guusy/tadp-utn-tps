package item

import excepciones.NoSePuedeUsarException
import heroe.Heroe
import items.{cascoVikingo, palitoMagico}
import org.scalatest.{FreeSpec, Matchers}
import trabajo.{guerrero, ladron, mago}

class ItemsTest extends FreeSpec with Matchers {

  "Casco Vikingo" - {
    "cuando  un heroe con menos de 30 de fuerza le pregunta si puede usar" - {
      val heroeDebil: Heroe = new Heroe(20, 5, 20, 10)
      "se lanza un error" in {
        assertThrows[NoSePuedeUsarException] {
          cascoVikingo.puedeSePuestoPor(heroeDebil)
        }
      }
    }
    "cuando un heroe con mas de 30 de fuerza  le pregunta si puede usar" - {
      val heroeFuerte: Heroe = new Heroe(20, 50, 20, 10)
      "NO se lanza un error" in {
        expectNoException(() => cascoVikingo.puedeSePuestoPor(heroeFuerte))
      }
    }
  }

  // sólo lo pueden usar magos (o ladrones con más de 30 de inteligencia base). Una mano.

  "Palito magico" - {
    "cuando un mago le pregunta si puede usar" - {
      val heroeMago: Heroe = new Heroe(20, 5, 20, 10)
      heroeMago.trabajo = mago
      "NO se lanza un error" in {
        expectNoException(() => palitoMagico.puedeSePuestoPor(heroeMago))
      }
    }
    "cuando un ladron con menos de 30 de inteligencia le pregunta si puede usar" - {
      val heroeLadronTonto: Heroe = new Heroe(20, 5, 20, 10)
      heroeLadronTonto.trabajo = ladron
      "se lanza un error" in {
        assertThrows[NoSePuedeUsarException] {
          palitoMagico.puedeSePuestoPor(heroeLadronTonto)
        }
      }
    }

    "cuando un ladron con mas de 30 de inteligencia le pregunta si puede usar" - {
      val heroeLadronInteligente: Heroe = new Heroe(20, 5, 20, 40)
      heroeLadronInteligente.trabajo = mago
      "NO se lanza un error" in {
        expectNoException(() => palitoMagico.puedeSePuestoPor(heroeLadronInteligente))
      }
    }

    "cuando cualquier otro tipo de heroe  con un trabajo que no sea ni mago ni ladron le pregunta si se puede usar" - {
      val heroeGuerrero: Heroe = new Heroe(20, 5, 20, 40)
      heroeGuerrero.trabajo = guerrero
      "se lanza un error" in {
        assertThrows[NoSePuedeUsarException] {
          palitoMagico.puedeSePuestoPor(heroeGuerrero)
        }
      }
    }
  }

  def expectNoException(funcion: () => Unit): Any = {
    try {
      funcion.apply()
    } catch {
      case e: NoSePuedeUsarException => {
        fail("No se tendria que haber tirado una excepcion")
      }
    }
  }

}

