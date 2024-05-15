module rpg{
    import basicSpells.* from "/spells/basicSpells"
    import rareSpells.* from "/spells/rareSpells"

    type PokemonType = Water | Fire | Grass | Electric
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
        {name: "Boris", hp: 150, initiative: 0, role: CharacterBarbarian, Immune: false, Paralized: false, Taunt: false},
        {name: "Billy", hp: 20, initiative: 0, role: CharacterCleric, Immune: false, Paralized: false, Taunt: false},
        {name: "Belle", hp: 20, initiative: 0, role: CharacterMage, Immune: false, Paralized: false, Taunt: false},
        {name: "Monstro", hp: 100, initiative: 0, role: Monster, Immune: false, Paralized: false, Taunt: false}
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
            attacker.Paralized != false,
            attacker != receiver,
            attacker.hp > 0,
            receiver.hp > 0,
            attacker.basicAttack(receiver)
        }
    }
    
    action paralize(caster: Creature, receiver: Creature): bool = all{
        creatures' = creatures.setBy(receiver.name, c => c.paralizing())
    }
    
    action removeParalize(caster: Creature, receiver: Creature): bool = all{
        creatures' = creatures.setBy(receiver.name, c => c.unparalizing())     
    }

    var x: int
    action x_recebe_algum_valor = {
        nondet valor = Set(1, 2, 3).oneOf()
        x' = valor
    }

    action init = all{
        round' = 0,
        creatures' = creatures,
        nondet D20_mage = (1.to(20)).oneOf()
        x' = D20_mage
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

    
}