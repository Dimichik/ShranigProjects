/*
 * Created by Дмитро on 07.04.2019.
 */
public class AccountTriggerService {

	private static Set<Territory__c> parentsTerritories = new Set<Territory__c>();

	public static List<Account> changedTerritory(List<Account> newAccounts){
		List<Account> deletedSharesToAccount = new List<Account>();
		List<Account> currentAccounts = [SELECT Id, Territory__c FROM Account WHERE Id IN :getSetFromList(newAccounts, 'Id')];
		for (Account newAccount: newAccounts) {
			for(Account currentAccount: currentAccounts){
				if(newAccount.Territory__c != currentAccount.Territory__c && newAccount.Id == currentAccount.Id){
					deletedSharesToAccount.add(currentAccount);
				}
			}
		}
		return deletedSharesToAccount;
	}

	public static Set<Territory__c> getParentHierarchyTerritories(Territory__c territory) {
		parentsTerritories = new Set<Territory__c>();
		findParentTerritories(territory);
		return parentsTerritories;
	}

	public static Set<Territory__c> findParentTerritories(Territory__c childTerritory) {
		parentsTerritories.add(childTerritory);
		List<Territory__c> territories = [SELECT Id, ParTerritory__c, Name FROM Territory__c WHERE Id =:childTerritory.ParTerritory__c];
		for (Territory__c territory : territories) {
			parentsTerritories.add(territory);
			findParentTerritories(territory);
		}
		return parentsTerritories;
	}

	private static Set<Id> getSetFromList(List<sObject> listObjs, String searchField) {
		Set<Id> result = new Set<Id>();
		for (sObject currentSO : listObjs) {
			result.add((Id) currentSO.get(searchField));
		}
		return result;
	}
}