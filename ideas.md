
# Ground combat

## Soldier properties
there could be different types of soldiers (leaders, different species etc) so fundamentally the properties should be able to be applied to different ones if necessary.

Each type should have a dict referencing which traits it can inherit

*items*
- weapons
    - range
    - ammo
    - fire rate
    - weight
    - accuracy (perhaps an angle that grows as target is further away)
    - ease of use: how quick it is to swap out (e.g. a weapon with a strap can be quickly slung onto back)
- armor
    - weight
    - defence types protection
    - body part (different parts provide different defence, e.g. foot defence prevents damage from terrain, head defence prevents critical hits)

*item management*
- capacity: how many items soldier can carry. each weapon counts as item. could also include medkits, other tools
- active item: the weapon or tool currently in soldier's hands
- exchange speed: how many moves it takes to change items
- items weight: more weight = reduced action points

*physical traits*
- action points: how far they can move on map, how long it takes to shoot, how long it takes to perform actions. maybe each type of action has its own track, e.g. shooting doesn't take away from movement potential
- health
- stealthiness

*charateristics*
- marksmanship: improved skill = less movement points spent on using/loading/swapping weapons
- eagle eye: improved accuracy of weapons
- morale

*combat*
- defence: different types, reduce damage taken from different sources when successfully attacked by a source. given by armor, but can also be innate to species, e.g. a species that has higher radiation resistance:
    - physical: protects from impact damage (falls, projectiles, swords etc)
    - energy: protects from energy damage (laser guns)
    - radiation, heat, cold, ...
- dexterity: reduces chance of being hit by a damage source in the first place

## Other combat units
- tank: can transport infantry units
- mech/dragon: large combat unit

## Combat mechanics
Similar to into the breach, on your turn you can choose to activate your units in any order by clicking them (clicking them again to deactivate them). 
Once activated, you have the options of what to do with this specific unit: movement options, attack options, etc
Maybe each unit needs to move before it attacks, or at least making an attack would end its turn

Shooting steps:
1. A shoots at B
2. A's accuracy rating (comes from weapon and character) determines the "angle" of the shot. the distance of B from A, multiplied by the size of B, determines the "angle" of B. the proportion of the shot angle that B takes up determines the chance of A's shot hitting:
    B angular size: 2 * arctan( (0.5 * B_size) / distance )
        (multiplied by 2 as the function only counts one half of the angular size)
        (B_size divided by 0.5 as only working with one half of angular size)
        (working with only half necessary for trigonometry)
    A angular size: weapon accuracy * (1 / soldier accuracy)
        as soldier becomes more accurate, the angle decreases
    chance to hit: B_angular_size / A_angular_size
3. if shot is on target, a dexterity factor gives B an additional chance of dodging (dependent on A's weapon type and B's dexterity)
4. If dexterity fails, shot impacts. damage dealt is based on the damage value of A's weapon plus the defensive properties of B's armor


