public with sharing class BT_StudentControllerLWC {

    @AuraEnabled
    public static void upsertStudent(HocSinh__c student){
        if(student != null){
            upsert student;
        }
    }

    @AuraEnabled(cacheable = true)
    public static List<HocSinh__c> getStudents(String searchName, String searchLop, Date searchDateFrom, Date searchDateTo, Boolean sortByName){
        
        List<HocSinh__c> students = new List<HocSinh__c>();

        String query = 'SELECT Id,Ho_hoc_sinh__c, Ten_hoc_sinh__c, gioi_tinh__c, Ngay_sinh__c, Diem1__c, Diem2__c, '+
            'Diem3__c, DiemTB__c, Tinh_Trang__c, Xep_loai__c, Lop__r.name FROM HocSinh__c';
        
        if(!String.isBlank(searchName) && !String.isBlank(searchLop)){
            //String.escapeSingleQuotes check ky tu dac biet
            query+= ' WHERE Ten_hoc_sinh__c LIKE \'%' + String.escapeSingleQuotes(searchName) + '%\' AND Lop__r.name LIKE \'%' + String.escapeSingleQuotes(searchLop) + '%\'';
        }else if(!String.isBlank(searchLop)){
            query+= ' WHERE Lop__r.name LIKE \'%' + String.escapeSingleQuotes(searchLop) + '%\'';
        }else if(!String.isBlank(searchName) ){
            query+= ' WHERE Ten_hoc_sinh__c LIKE \'%' + String.escapeSingleQuotes(searchName) + '%\'';
        }
        
        List<String> dateOfBirthRange = new List<String>();
        String searchDateHS = 'Ngay_sinh__c >= :searchDateFrom AND Ngay_sinh__c <= :searchDateTo';
        dateOfBirthRange.add(searchDateHS);
        if(searchDateFrom != null && searchDateTo != null){
            if(String.isBlank(searchName) && String.isBlank(searchLop)){
                query+= ' WHERE ' + String.join(dateOfBirthRange, ' AND ');
            }else{
                query+= ' AND ' + String.join(dateOfBirthRange, ' AND ');
            }
        }
        
        if(sortByName){
            query += ' ORDER BY Ten_hoc_sinh__c';
        }else {
            query += ' ORDER BY Ten_hoc_sinh__c desc';
        }
        
        students = Database.query(query);
        
        return students;
    }

    @AuraEnabled(cacheable=true)
    public static List<Lop__c> selectedLop(){
        return [SELECT Id, Name FROM Lop__c];
    }

    @AuraEnabled(cacheable=true)
    public static List<Lop__c> selectedLopSearch(){
        return [SELECT Id, Name FROM Lop__c];
    }

    @AuraEnabled(cacheable=true)
    public static HocSinh__c showStudent(String studentID){
        return [SELECT Id,Ho_hoc_sinh__c, Ten_hoc_sinh__c, gioi_tinh__c, Ngay_sinh__c, Diem1__c, Diem2__c, 
        Diem3__c, DiemTB__c, Tinh_Trang__c, Xep_loai__c, Lop__r.name FROM HocSinh__c WHERE Id = :studentID];
    }

    @AuraEnabled
    public static void deleteObject(String studentId) {
        System.debug(studentId);
        try {
            if(studentId != ''){
                HocSinh__c student = [SELECT Id FROM HocSinh__c WHERE Id = :studentId];
                if (student != null) {
                    delete student;
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error deleting the object: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void deleteSelectedID(List<String> recordIds) {
        System.debug(recordIds);
        if (recordIds != null) {
            Database.delete(recordIds);
        }
    }

    @AuraEnabled
    public static void deleteStudent(String studentId) {
        System.debug(studentId);
        try {
            if(studentId != ''){
                HocSinh__c student = [SELECT Id FROM HocSinh__c WHERE Id = :studentId];
                if (student != null) {
                    delete student;
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error deleting the object: ' + e.getMessage());
        }
    }
}