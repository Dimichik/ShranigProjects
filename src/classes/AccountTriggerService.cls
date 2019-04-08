/*
 * Created by Дмитро on 07.04.2019.
 */
public class AccountTriggerService {
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

	private static Set<Id> getSetFromList(List<sObject> listObjs, String searchField) {
		Set<Id> result = new Set<Id>();
		for (sObject currentSO : listObjs) {
			result.add((Id) currentSO.get(searchField));
		}
		return result;
	}
}