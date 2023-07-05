public class BT_StudentControllerLC{
    public static List<HocSinh__c> students = new List<HocSinh__c>();
    
    @AuraEnabled
    public static List<Lop__c> getLopOptions() {
        List<Lop__c> lopList = [SELECT Id, Name FROM Lop__c];
        return lopList;
    }

    @AuraEnabled
    public static List<HocSinh__c> getStudents(String searchName, String searchLop, Date searchDateFrom, Date searchDateTo, Boolean sortByName){
        String query = 'SELECT Id,Ho_hoc_sinh__c, Ten_hoc_sinh__c, gioi_tinh__c, Ngay_sinh__c, Diem1__c, Diem2__c, '+
            'Diem3__c, DiemTB__c, Tinh_trang__c, Xep_loai__c, Lop__r.name FROM HocSinh__c';
        
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
    
    @AuraEnabled
    public static HocSinh__c showStudent(Id studentId){
        return [SELECT Id,Ho_hoc_sinh__c, Ten_hoc_sinh__c, gioi_tinh__c, Ngay_sinh__c, Diem1__c, Diem2__c, 
                Diem3__c, DiemTB__c, Tinh_trang__c, Xep_loai__c, Lop__r.name FROM HocSinh__c where Id = :studentId];
    }
    
    @AuraEnabled
    public static void deleteStudent(Id studentId){
        HocSinh__c student = [SELECT Id FROM HocSinh__c WHERE Id = :studentId];
        if(student != null){
            Database.delete(student);
        }
    }
    
    @AuraEnabled
    public static void deleteOneStudent(Id studentId){
        HocSinh__c student = [SELECT Id FROM HocSinh__c WHERE Id = :studentId];
        if(student != null){
            Database.delete(student);
        }
    }
    
    @AuraEnabled
    public static void deleteRecordIds(List<String> recordIds) {
        List<HocSinh__c> students = [SELECT Id FROM HocSinh__c WHERE Id IN :recordIds];
        Database.delete(students);
    }
    
    @AuraEnabled
    public static void saveStudent(HocSinh__c student){
        student.Name = student.Ten_hoc_sinh__c;
        if(student != null){
            upsert student;
        }
    }
}