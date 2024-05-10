module rpg{
    import basicSpells.* from "/spells/basicSpells"
    import rareSpells.* from "/spells/rareSpells"

    type CharacterClasses = Mage | Cleric | Barbarian


    type PokemonType = Water | Fire | Grass | Electric
    type RoleTypes = CharacterMage| CharacterCleric | CharacterBarbarian | Monster
    type StatusTypes = Normal | Immune | Paralized | Taunt

    //Não sei se essa é uma boa forma de definir as criaturas, personagens e monstros
    type Creature = {
        name: str,
        hp: int,
        initiative: int,
        role: RoleTypes,
        team: str,
        status: StatusTypes
    }

    pure val Creatures = Set(
        {name: "Boris", hp: 150, initiative: 0, role: CharacterBarbarian, status: Normal},
        {name: "Billy", hp: 20, initiative: 0, role: CharacterCleric, status: Normal},
        {name: "Belle", hp: 20, initiative: 0, role: CharacterMage, status: Normal},
        {name: "Monstro", hp: 100, initiative: 0, role: Monster, status: Normal}
    )

    val round = 0
    var creatures: str -> Creature

    pure def damage(c: Creature, d: int): Creature = {
        { ...c, hp: c.hp - d }
    }

    pure def paralize(c: Creature, r: Creature): Creature = {
        { ...r, status: Paralized  }
    }

    //acho q ta errado
    action basicAttack(attacker: Creature, receiver: Creature): bool = all{
        if (attacker.role == Monster){
            if (round == 0){
                creatures' = creatures.setBy(receiver.name, c => c.damage(10))
            } else{
                creatures' = creatures.setBy(receiver.name, c => c.damage(20))
            } 
        } else{
            creatures' = creatures.setBy(receiver.name, c => c.damage(10))
        }
    }

    action attack(attacker: Creature, receiver: Creature): bool = {
        all {
            attacker != receiver,
            attacker.hp > 0,
            receiver.hp > 0,
            attacker.basicAttack(receiver)
        }
    }
    
   
    
}
