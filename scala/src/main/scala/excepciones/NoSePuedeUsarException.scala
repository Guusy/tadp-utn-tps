package excepciones

case class NoSePuedeUsarException(smth:String)  extends Exception(smth)

