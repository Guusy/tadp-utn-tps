package trabajo

abstract class Trabajo {
  val HP: Int
  val fuerza: Int
  val velocidad: Int
  val inteligencia: Int

  def statPrincipal: Int

  def getStats : Stats
}

object guerrero extends Trabajo {
  override val HP: Int = 10
  override val fuerza: Int = 15
  override val velocidad: Int = 0
  override val inteligencia: Int = -10

  override def statPrincipal: Int = fuerza
}

object mago extends Trabajo {
  override val HP: Int = 20
  override val fuerza: Int = -20
  override val velocidad: Int = 0
  override val inteligencia: Int = 0

  override def statPrincipal: Int = inteligencia
}

object ladron extends Trabajo {
  override val HP: Int = -5
  override val fuerza: Int = 0
  override val velocidad: Int = 10
  override val inteligencia: Int = 0

  override def statPrincipal: Int = velocidad
}
