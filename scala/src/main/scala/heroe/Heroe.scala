package heroe

import com.sun.net.httpserver.Authenticator.Success
import excepciones.NoSePuedeUsarException
import items.Item
import trabajo.Trabajo

import scala.util.{Failure, Success, Try}

case class Heroe(_HP: Int,
                 _fuerza: Int,
                 _velocidad: Int,
                 _inteligencia: Int,
                 var trabajo: Option[Trabajo] = None,
                 var cabeza: Option[Item] = None
                ) {


  def agregarItem(item: Item): Heroe = {
    item.puedeSePuestoPor(this)
    copy(cabeza = Some.apply(item))
    return this
  }

  def HP: Int = {
    var statFinal: Int = _HP
    if (cabeza != null) {
      statFinal = cabeza.map( internalCabeza => internalCabeza.buildStat(this)).get
    }
    trabajo.map(t => t.getStats(this))
    if (trabajo != null) {
      val resultado: Int = _HP + trabajo.HP
      statFinal = if (resultado > 0) resultado else 1
    }
    statFinal
  }

  def fuerza: Int = {
    var statFinal: Int = _fuerza
    if (trabajo != null) {
      val resultado: Int = _fuerza + trabajo.fuerza
      statFinal = if (resultado > 0) resultado else 1
    }
    statFinal
  }

  def velocidad: Int = {
    var statFinal: Int = _velocidad
    if (trabajo != null) {
      val resultado: Int = _velocidad + trabajo.velocidad
      statFinal = if (resultado > 0) resultado else 1
    }
    statFinal
  }

  def inteligencia: Int = {
    var statFinal: Int = _inteligencia
    if (trabajo != null) {
      val resultado: Int = _inteligencia + trabajo.inteligencia
      statFinal = if (resultado > 0) resultado else 1
    }
    statFinal
  }

  // stats negativos === 1 ? ¡( stats finales)-???
}
