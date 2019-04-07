/*
 * Created by Дмитро on 07.04.2019.
 */
public class AccountTriggerService {
	public static List<Account> changedTerritory(List<Account> newAccounts){
		System.debug('newAccounts = ' + newAccounts);
		List<Account> deletedSharesToAccount = new List<Account>();
		List<Account> currentAccounts = [SELECT Id, Territory__c FROM Account WHERE Id IN :getSetFromList(newAccounts, 'Id')];
		System.debug('currentAccounts = ' + currentAccounts);
		for (Account newAccount: newAccounts) {
			for(Account currentAccount: currentAccounts){
				System.debug('newAccount.Territory__c = ' + newAccount.Territory__c);
				System.debug('currentAccount.Territory__c = ' + currentAccount.Territory__c);
				System.debug('newAccount.Id = ' + newAccount.Id);
				System.debug('currentAccount.Id = ' + currentAccount.Id);
				if(newAccount.Territory__c != currentAccount.Territory__c && newAccount.Id == currentAccount.Id){
					deletedSharesToAccount.add(currentAccount);
				}
			}
		}
		System.debug('deletedSharesToAccount = ' + deletedSharesToAccount);
		return deletedSharesToAccount;
	}

	private static Set<Id> getSetFromList(List<sObject> listObjs, String searchField) {
		Set<Id> result = new Set<Id>();
		for (sObject currentSO : listObjs) {
			result.add((Id) currentSO.get(searchField));
		}
		return result;
	}

	public static List<AccountShare> deleteSharesAccount(List<Account> accounts){
		List<AccountShare> deleteAccount = [SELECT Id FROM AccountShare WHERE Account.Id IN :accounts];
		return deleteAccount;
	}
}