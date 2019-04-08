/*
 * Created by Дмитро on 04.04.2019.
 */
public class TerrUserTriggerHandler {
	public static void afterInsert(List<SObject> newTerritory){
		insert TerritoryUserService.shareAccessToUser(newTerritory);
	}

	public static void afterDelete(List<SObject> oldTerritory) {
		delete  TerritoryUserService.deleteShareAccessToUser(oldTerritory);
	}

}