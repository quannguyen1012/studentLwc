import { LightningElement , api, wire} from 'lwc';

import upsertStudent from '@salesforce/apex/BT_StudentControllerLWC.upsertStudent';
import selectedLop from '@salesforce/apex/BT_StudentControllerLWC.selectedLop';
import showStudent from '@salesforce/apex/BT_StudentControllerLWC.showStudent';

export default class BtUpsertStudentLwc extends LightningElement {
    @api recordId;

    @wire(selectedLop)
    getLops;

    student = {
        Id: this.recordId,
        Ho_hoc_sinh__c: '',
        Ten_hoc_sinh__c: '',
        Gioi_tinh__c: false,
        Ngay_sinh__c: Date,
        Diem1__c: '',
        Diem2__c: '',
        Diem3__c: '',
        Lop__c: ''
    };
    error;  


    @wire(showStudent, { studentID: '$recordId' })
    showData(result) {
        if (result.error) {
            console.log(result.error);
        } else if (result.data) {
            this.student = result.data;
        }
    }


    handleFieldChange(event) {
        const { name, value } = event.target;
        this.student = { ...this.student, [name]: value };
        this.student.Gioi_tinh__c = event.target.checked;
    }


    handleSaveClick() {
        upsertStudent({student: this.student }) 
            .then(result => {
                // Xử lý phản hồi sau khi tạo mới thành công
                alert('successfully!!')
            })
            .catch(err => console.log(err));
        
    }
}