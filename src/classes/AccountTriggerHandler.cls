/*
 * Created by Дмитро on 07.04.2019.
 */
public class AccountTriggerHandler {

	public static void beforeUpdate(List<SObject> newTerritory) {
		List<Account> accountToDelete = AccountTriggerService.changedTerritory(newTerritory);
		List<AccountShare> accSharesToDelete = AccountSharingService.deleteAccessToAccount(accountToDelete);
		List<Contact__Share> contractShares = ContactSharingService.deleteAccessToContact(accountToDelete);
			Database.Delete(accSharesToDelete, false);
		if (!contractShares.isEmpty()) {
			Database.Delete(contractShares, false);
		}
	}

	public static void afterUpdate(List<SObject> changedAccounts) {
		insert AccountTriggerService.shareAccessToNewAccount(changedAccounts);
	}

	public static void beforeDelete(List<SObject> oldAccount) {
		List<Contact__Share> contractShares = ContactSharingService.deleteAccessToContact(oldAccount);
		if (!contractShares.isEmpty()) {
			Database.Delete(contractShares, false);
		}
	}
}