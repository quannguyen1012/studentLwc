import { LightningElement, api , wire} from 'lwc';

import showStudent from '@salesforce/apex/BT_StudentControllerLWC.showStudent';
import deleteStudent from '@salesforce/apex/BT_StudentControllerLWC.deleteStudent';

export default class BtDetailStudentLwc extends LightningElement {
    @api recordId;

    student;

    updatePage = false;
    detailPage = true;

    @wire(showStudent, { studentID: '$recordId' })
    showData(result) {
        if (result.error) {
            console.log(result.error);
        } else if (result.data) {
            this.student = result.data;
        }
    }

    handleDelete() {
        deleteStudent({ studentId: this.student.Id })
            .then(() => {
                window.location.reload();
                alert("delete successfully!");
            })
            .catch(err => console.log(err));
    }

    handleUpdate(){
        this.updatePage = true;
        this.detailPage = false;
    }
}