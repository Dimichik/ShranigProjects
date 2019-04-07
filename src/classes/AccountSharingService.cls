/*
 * Created by Дмитро on 05.04.2019.
 */
public class AccountSharingService {

	public static List<AccountShare> shareAccessToAccount(List<Account> accounts, Id userId) {
		List<AccountShare> accountShares = new List<AccountShare>();
		for (Account account : accounts) {
			AccountShare accountShare = new AccountShare();
			accountShare.AccountId = account.Id;
			accountShare.UserOrGroupId = userId;
			accountShare.AccountAccessLevel = 'Edit';
			accountShare.CaseAccessLevel = 'None';
			accountShare.OpportunityAccessLevel = 'None';
			accountShares.add(accountShare);
		}
		return accountShares;
	}

	public static List<AccountShare> deleteAccessToAccount(List<Account> accounts, Id userId) {
		List<AccountShare> accountShares = [
				SELECT id
				FROM AccountShare
				WHERE UserOrGroupId = :userId AND AccountId IN :accounts
		];
		return accountShares;
	}

	public static void deleteAll() {
		List<AccountShare> accountShare = [SELECT Id FROM AccountShare WHERE UserOrGroupId ='0051i000000dvkVAAQ'];
		List<Contact__Share> contactShare = [SELECT Id FROM Contact__Share WHERE UserOrGroupId='0051i000000dvkVAAQ'];
		delete contactShare;
		delete accountShare;
	}
}