package heroe

import items.cascoVikingo
import org.scalatest.{FreeSpec, Matchers}
import trabajo.guerrero

class HeroeTest extends FreeSpec with Matchers {
  "Cuando a un heroe sin trabajo " - {
    val heroeSinTrabajo: Heroe = new Heroe(10, 11, 12, 20)
    "y se le pregunta por sus stats" - {
      "responde con sus valores base" in {
        assert(heroeSinTrabajo.HP == 10)
        assert(heroeSinTrabajo.fuerza == 11)
        assert(heroeSinTrabajo.velocidad == 12)
        assert(heroeSinTrabajo.inteligencia == 20)
      }
    }
  }

  "Cuando a un heroe con trabajo " - {
    val heroeGuerrero: Heroe = new Heroe(10, 11, 12, 5, Some(guerrero))
    "y se le pregunta por sus stats" - {
      "responde con sus valores base" in {
        assert(heroeGuerrero.HP == 20)
        assert(heroeGuerrero.fuerza == 26)
        assert(heroeGuerrero.velocidad == 12)
        assert(heroeGuerrero.inteligencia == 1)
      }
    }
  }

  "Cuando a un heroe con un item en la cabeza" - {
    "y se le pregunta por sus stats" - {
      val heroeCascudo: Heroe = new Heroe(10, 40, 12, 5)
      "responde con sus valores base + los de casco" in {
        assert(heroeCascudo.agregarItem(cascoVikingo).HP == 20)
      }
    }
  }
}
