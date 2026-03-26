/**
 * @description Test class for OpportunityAmountPolicyNewP.
 */
@IsTest
public with sharing class OpportunityAmountPolicyNewPTest {

    @TestSetup
    static void setup() {
        Account acc = new Account(Name = 'Policy Test Account');
        insert acc;
    }

    @IsTest
    static void testInsert_BelowMinimum_Fails() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        System.runAs(u) {
            Account acc = [SELECT Id FROM Account WITH USER_MODE LIMIT 1];
            Opportunity opp = new Opportunity(
                Name = 'Opp Below Min',
                AccountId = acc.Id,
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(10),
                Amount = 100
            );

            OpportunityAmountPolicyNewP.validateBeforeInsert(new List<Opportunity>{ opp });
            System.assertEquals(1, opp.getErrors().size(), 'Expected addError for low amount');
        }
    }

    @IsTest
    static void testInsert_MeetsMinimum_Passes() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        System.runAs(u) {
            Account acc = [SELECT Id FROM Account WITH USER_MODE LIMIT 1];
            Opportunity opp = new Opportunity(
                Name = 'Opp Meets Min',
                AccountId = acc.Id,
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(10),
                Amount = 1500
            );

            OpportunityAmountPolicyNewP.validateBeforeInsert(new List<Opportunity>{ opp });
            System.assertEquals(0, opp.getErrors().size(), 'Expected no errors for valid amount');
        }
    }

    @IsTest
    static void testUpdate_StageChangesBelowMinimum_Fails() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        System.runAs(u) {
            Account acc = [SELECT Id FROM Account WITH USER_MODE LIMIT 1];
            Opportunity oldOpp = new Opportunity(
                Name = 'Opp Stage Change',
                AccountId = acc.Id,
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(10),
                Amount = 1500
            );
            insert oldOpp;

            Opportunity newOpp = oldOpp.clone(false, true, false, false);
            newOpp.Id = oldOpp.Id;
            newOpp.StageName = 'Qualification';
            newOpp.Amount = 2000;

            OpportunityAmountPolicyNewP.validateBeforeUpdate(
                new List<Opportunity>{ newOpp },
                new Map<Id, Opportunity>{ oldOpp.Id => oldOpp }
            );
            System.assertEquals(1, newOpp.getErrors().size(), 'Expected addError for stage change below minimum');
        }
    }

    @IsTest
    static void testUpdate_AmountChangesBelowMinimum_Fails() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        System.runAs(u) {
            Account acc = [SELECT Id FROM Account WITH USER_MODE LIMIT 1];
            Opportunity oldOpp = new Opportunity(
                Name = 'Opp Amount Change',
                AccountId = acc.Id,
                StageName = 'Qualification',
                CloseDate = Date.today().addDays(10),
                Amount = 3000
            );
            insert oldOpp;

            Opportunity newOpp = oldOpp.clone(false, true, false, false);
            newOpp.Id = oldOpp.Id;
            newOpp.Amount = 2000;

            OpportunityAmountPolicyNewP.validateBeforeUpdate(
                new List<Opportunity>{ newOpp },
                new Map<Id, Opportunity>{ oldOpp.Id => oldOpp }
            );
            System.assertEquals(1, newOpp.getErrors().size(), 'Expected addError for amount drop below minimum');
        }
    }

    @IsTest
    static void testUpdate_NoRelevantChanges_NoError() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        System.runAs(u) {
            Account acc = [SELECT Id FROM Account WITH USER_MODE LIMIT 1];
            Opportunity oldOpp = new Opportunity(
                Name = 'Opp No Change',
                AccountId = acc.Id,
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(10),
                Amount = 1500
            );
            insert oldOpp;

            Opportunity newOpp = oldOpp.clone(false, true, false, false);
            newOpp.Id = oldOpp.Id;

            OpportunityAmountPolicyNewP.validateBeforeUpdate(
                new List<Opportunity>{ newOpp },
                new Map<Id, Opportunity>{ oldOpp.Id => oldOpp }
            );
            System.assertEquals(0, newOpp.getErrors().size(), 'Expected no errors when stage/amount unchanged');
        }
    }
}
