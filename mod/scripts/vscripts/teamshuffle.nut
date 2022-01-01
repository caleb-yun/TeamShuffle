global function TeamShuffle_Init

array<string> disabledGamemodes = ["private_match", "inf", "hs", "ffa"]
array<string> disabledMaps = ["mp_lobby"]

void function TeamShuffle_Init()
{
	AddCallback_GameStateEnter(eGameState.Prematch, shuffleTeams);
	//AddCallback_EntitiesDidLoad(shuffleTeams);
}


void function shuffleTeams()
{
	// Check if the gamemode or map are on the blacklist
	bool gamemodeDisable = disabledGamemodes.find(GAMETYPE) > -1;
	bool mapDisable = disabledMaps.find(GetMapName()) > -1;

	array<entity> players = GetPlayerArray();
	int playerCount = players.len();

	printt("[TEAMSHUFFLE] " + playerCount + " players"); // DEBUG

	// Only run the code if the blacklists were passed
	if ( playerCount > 0 && !(gamemodeDisable || mapDisable) ) {

		// set all players team to TEAM_UNASSIGNED temporarily
		foreach (player in players) {
			SetTeam(player, TEAM_UNASSIGNED);
		}

		// flip a coin for each players until a team is full
		int maxTeamSize = playerCount / 2 + (playerCount % 2);
		while (GetPlayerArrayOfTeam(TEAM_UNASSIGNED).len() > 0) {

			entity player = GetPlayerArrayOfTeam(TEAM_UNASSIGNED)[0];

			int team = TEAM_UNASSIGNED;
			int imcCount = GetPlayerArrayOfTeam(TEAM_IMC).len();
			int militiaCount = GetPlayerArrayOfTeam(TEAM_MILITIA).len();
			if (imcCount >= maxTeamSize) {
				team = TEAM_MILITIA;
				printt("[TEAMSHUFFLE] Setting " + player.GetPlayerName() + "'s team to " + team);
			} else if (militiaCount >= maxTeamSize) {
				team = TEAM_IMC;
				printt("[TEAMSHUFFLE] Setting " + player.GetPlayerName() + "'s team to " + team);
			} else {
				// TEAM_IMC = 2, TEAM_MILITIA = 3
				team = RandomIntRange(TEAM_IMC, TEAM_MILITIA + 1);
				printt("[TEAMSHUFFLE] Randomly setting " + player.GetPlayerName() + "'s team to " + team); // DEBUG
			}
			try {
				SetTeam(player, team);
			} catch (e) {
				printt("[TEAMSHUFFLE] Unable to set " + player.GetPlayerName() + "'s team.");
			}
		}

	}

}
