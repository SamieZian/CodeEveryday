/**
 * @description Enforces minimum Opportunity Amount by StageName.
 */
public with sharing class OpportunityAmountPolicyNewP {

    /**
     * @description Validates opportunities before insert.
     * @param newRecords New opportunities.
     */
    public static void validateBeforeInsert(List<Opportunity> newRecords) {
        if (newRecords == null || newRecords.isEmpty()) {
            return;
        }
        ensureFieldAccess();
        Map<String, Decimal> minimums = getStageMinimums();
        for (Opportunity opp : newRecords) {
            validateOpportunity(opp, minimums);
        }
    }

    /**
     * @description Validates opportunities before update when stage or amount changes.
     * @param newRecords New opportunities.
     * @param oldMap Map of old opportunities by Id.
     */
    public static void validateBeforeUpdate(List<Opportunity> newRecords, Map<Id, Opportunity> oldMap) {
        if (newRecords == null || newRecords.isEmpty() || oldMap == null || oldMap.isEmpty()) {
            return;
        }
        ensureFieldAccess();
        Map<String, Decimal> minimums = getStageMinimums();
        for (Opportunity opp : newRecords) {
            Opportunity oldOpp = oldMap.get(opp.Id);
            if (oldOpp == null) {
                continue;
            }
            if (shouldValidateOnUpdate(opp, oldOpp)) {
                validateOpportunity(opp, minimums);
            }
        }
    }

    /**
     * @description Determines whether validation should run on update.
     * @param newOpp New opportunity.
     * @param oldOpp Old opportunity.
     * @return True if stage or amount changed.
     */
    public static Boolean shouldValidateOnUpdate(Opportunity newOpp, Opportunity oldOpp) {
        if (newOpp == null || oldOpp == null) {
            return false;
        }
        Boolean stageChanged = newOpp.StageName != oldOpp.StageName;
        Boolean amountChanged = newOpp.Amount != oldOpp.Amount;
        return stageChanged || amountChanged;
    }

    /**
     * @description Validates a single opportunity against minimums map.
     * @param opp Opportunity to validate.
     * @param minimums Map of StageName to minimum amount.
     */
    private static void validateOpportunity(Opportunity opp, Map<String, Decimal> minimums) {
        if (opp == null || minimums == null || minimums.isEmpty()) {
            return;
        }
        if (!minimums.containsKey(opp.StageName)) {
            return;
        }
        Decimal minimum = minimums.get(opp.StageName);
        if (opp.Amount == null || opp.Amount < minimum) {
            String message = 'Amount must be at least ' + String.valueOf(minimum)
                + ' for stage ' + opp.StageName + '.';
            opp.Amount.addError(message);
        }
    }

    /**
     * @description Returns minimum amounts by stage. Update map to change policy.
     * @return Map of StageName to minimum Amount.
     */
    private static Map<String, Decimal> getStageMinimums() {
        Map<String, Decimal> minimums = new Map<String, Decimal>();
        minimums.put('Prospecting', 1000);
        minimums.put('Qualification', 2500);
        minimums.put('Closed Won', 5000);
        return minimums;
    }

    /**
     * @description Ensures required field access is available.
     */
    private static void ensureFieldAccess() {
        if (!Schema.sObjectType.Opportunity.isAccessible()) {
            throw new AuraHandledException('Insufficient access to Opportunity.');
        }
        if (!Schema.sObjectType.Opportunity.fields.StageName.isAccessible()
            || !Schema.sObjectType.Opportunity.fields.Amount.isAccessible()) {
            throw new AuraHandledException('Insufficient access to Opportunity fields.');
        }
    }
}
