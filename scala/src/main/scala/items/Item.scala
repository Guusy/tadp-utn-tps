package items

import excepciones.NoSePuedeUsarException
import heroe.Heroe
import trabajo.Trabajo

abstract class Item {
  def puedeSePuestoPor(heroe: Heroe) : Unit
  def buildStat(heroe: Heroe) : Int
}

object cascoVikingo extends Item {
  override def puedeSePuestoPor(heroe: Heroe): Unit = {
    if(heroe._fuerza < 30){
      throw NoSePuedeUsarException("El heroe tiene que tener una fuerza mayor a 30")
    }
  }

  override def buildStat(heroe: Heroe): Int = {
     heroe._HP + 10
  }
}

object palitoMagico  extends  Item {
  override def puedeSePuestoPor(heroe: Heroe): Unit = {
    throw NoSePuedeUsarException("El heroe tiene que tener una fuerza mayor a 30")
  }

  /*case def internalPuedeSePuestoPor(trabajo: Trabajo) : Unit = {

  }*/
  override def buildStat(heroe: Heroe): Int = {
     1
  }
}

/*
Casco Vikingo: +10 hp, sólo lo pueden usar héroes con fuerza base > 30. Va en la cabeza.
Palito mágico: +20 inteligencia, sólo lo pueden usar magos (o ladrones con más de 30 de inteligencia base). Una mano.
Armadura Elegante-Sport: +30 velocidad, -30 hp. Armadura.
Arco Viejo: +2 fuerza. Ocupa las dos manos.
Escudo Anti-Robo: +20 hp. No pueden equiparlo los ladrones ni nadie con menos de 20 de fuerza base. Una mano.
Talismán de Dedicación: Todos los stats se incrementan 10% del valor del stat principal del trabajo.
Talismán del Minimalismo: +50 hp. -10 hp por cada otro ítem equipado.
Vincha del búfalo de agua: Si el héroe tiene más fuerza que inteligencia, +30 a la inteligencia; de lo contrario +10 a todos los stats menos la inteligencia. Sólo lo pueden equipar los héroes sin trabajo. Sombrero.
Talismán maldito: Todos los stats son 1.
Espada de la Vida: Hace que la fuerza del héroe sea igual a su hp
 */