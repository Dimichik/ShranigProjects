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

	public static List<sObject> shareAccessToNewAccount(List<SObject> changedAccounts) {
		List<sObject> allShares = new List<sObject>();
		List<Account> changedTerritories = AccountTriggerService.changedTerritory(changedAccounts);
		List<Account> accountToRecalculateSharing = new List<Account>();
		for (Account acc : changedTerritories) {
			if (acc.Territory__c != null) {
				accountToRecalculateSharing.add(acc);
			}
		}
		Territory__c territory = [
				SELECT Id, Name, ParTerritory__c
				FROM Territory__c
				WHERE Id IN (SELECT Territory__c
				FROM Account
				WHERE Id IN :accountToRecalculateSharing)
				LIMIT 1
		];
		Set<Territory__c> allParentTerritories = AccountTriggerService.getParentHierarchyTerritories(territory);
		List<User> users = [
				SELECT Id, Name
				FROM User
				WHERE Id IN
				(SELECT User__c
				FROM TerrUser__c
				WHERE Territory__r.Id IN :allParentTerritories)
		];
		for (User user : users) {
			List<Account> accounts = [SELECT Id FROM Account WHERE Territory__c = :territory.Id];
			List<AccountShare> accountsUserShares = AccountSharingService.shareAccessToAccount(accounts, user.Id);
			allShares.addAll(accountsUserShares);
			List<Contact__Share> contactsUserShares = ContactSharingService.shareAccessToContact(accounts, user.Id);
			allShares.addAll(contactsUserShares);
		}
		return allShares;
	}

	private static Set<Territory__c> getParentHierarchyTerritories(Territory__c territory) {
		parentsTerritories = new Set<Territory__c>();
		findParentTerritories(territory);
		return parentsTerritories;
	}

	private static Set<Territory__c> findParentTerritories(Territory__c childTerritory) {
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