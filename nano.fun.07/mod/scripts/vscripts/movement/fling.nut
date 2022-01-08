global function FlingEnt

void function FlingEnt( entity target )
{
   int currentVel = target.GetVelocity()
   target.SetVelocity(currentVel*10)
}
