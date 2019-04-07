/*
 * Created by Дмитро on 27.03.2019.
 */

trigger TerritoryTrigger on Territory__c (before insert, before update, after insert, after update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            TerritoryTriggerHandler.beforeUpdate(Trigger.new);
        }
        if (Trigger.isUpdate) {
            TerritoryTriggerHandler.beforeUpdate(Trigger.new);
        }
    }
}