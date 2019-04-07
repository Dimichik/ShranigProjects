trigger TerrUserTrigger on TerrUser__c (after insert, after update, after delete) {
	if (Trigger.isAfter) {
		if (Trigger.isInsert) {
			TerrUserTriggerHandler.afterInsert(Trigger.new);
		}
		if (Trigger.isDelete) {
			TerrUserTriggerHandler.afterDelete(Trigger.old);
		}
	}
}