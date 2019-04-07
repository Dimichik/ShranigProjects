trigger TerrUserTrigger on TerrUser__c (after insert, after update) {
	if (Trigger.isAfter) {
		if (Trigger.isInsert) {
			TerrUserTriggerHandler.afterInsert(Trigger.new);
		}
		if (Trigger.isUpdate) {
			TerrUserTriggerHandler.afterUpdate(Trigger.new);
		}
		if (Trigger.isDelete) {
			TerrUserTriggerHandler.afterDelete(Trigger.old);
		}
	}
}