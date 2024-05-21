module rpg{
    import basicSpells.* from "/spells/basicSpells"
    import rareSpells.* from "/spells/rareSpells"

    type RoleTypes = CharacterMage| CharacterCleric | CharacterBarbarian | Monster
    type StatusTypes = Immune | Paralized | Taunt

    type Creature = {
        name: str,
        hp: int,
        initiative: int,
        role: RoleTypes,
        team: str,
        Immune: bool,
        Paralized: bool,
        Taunt: bool
    }

    pure val Creatures = Set(
        {name: "Boris", hp: 150, initiative: 0, role: CharacterBarbarian, team: "Characters", Immune: false, Paralized: false, Taunt: false},
        {name: "Billy", hp: 20, initiative: 0, role: CharacterCleric,team: "Characters", Immune: false, Paralized: false, Taunt: false},
        {name: "Belle", hp: 20, initiative: 0, role: CharacterMage,team: "Characters", Immune: false, Paralized: false, Taunt: false},
        {name: "Monstro", hp: 100, initiative: 0, role: Monster,team: "Monster", Immune: false, Paralized: false, Taunt: false}
    )

    var round: int
    var creatures: str -> Creature



    pure def damage(c: Creature, d: int): Creature = {
        { ...c, hp: c.hp - d }
    }

    pure def paralizing(c: Creature): Creature = {
        { ...c, Paralized: true  }
    }

    pure def unparalizing(c: Creature): Creature = {
        { ...c, Paralized: false  }
    }

    pure def putInitiative(c: Creature, i: int): Creature = {
        {...c, initiative: i}
    }

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
            attacker.Paralized == false,
            attacker != receiver,
            attacker.team != receiver.team,
            attacker.hp > 0,
            receiver.hp > 0,
            basicAttack(attacker, receiver)
        }
    }
    
    action paralize(caster: Creature, receiver: Creature): bool = all{
        creatures' = creatures.setBy(receiver.name, c => c.paralizing())
    }
    
    action removeParalize(caster: Creature, receiver: Creature): bool = all{
        creatures' = creatures.setBy(receiver.name, c => c.unparalizing())     
    }


    action init = all{
        round' = 0,
        nondet D20_mage = (1.to(20)).oneOf()
        nondet D20_barbarian = (1.to(20)).oneOf()
        nondet D20_cleric = (1.to(20)).oneOf()
        nondet D20_monster = (1.to(20)).oneOf()
        creatures' = Map(
            "Boris" -> {name: "Boris", hp: 150, initiative: D20_barbarian, role: CharacterBarbarian, team: "Characters", Immune: false, Paralized: false, Taunt: false},
            "Billy" -> {name: "Billy", hp: 20, initiative: D20_cleric, role: CharacterCleric, team: "Characters", Immune: false, Paralized: false, Taunt: false},
            "Belle" ->{name: "Belle", hp: 20, initiative: D20_mage, role: CharacterMage, team: "Characters",Immune: false, Paralized: false, Taunt: false},
            "Monster" -> {name: "Monstro", hp: 100, initiative: D20_monster, role: Monster, team: "Monsters", Immune: false, Paralized: false, Taunt: false}
        )
    }       
    

    action step = {
        val attackers_by_initiative = creatures.values().toList((c1, c2) => intCompare(c2.initiative, c1.initiative))
        val attacker = attackers_by_initiative[round % creatures.keys().size()]
        nondet receiver = creatures.values().filter(c => attacker != c).oneOf()
        all {
            attack(attacker, receiver),
            round' = round + 1,
        }
    }

    val inv = creatures.values().exists(c => c.hp > 0)

}