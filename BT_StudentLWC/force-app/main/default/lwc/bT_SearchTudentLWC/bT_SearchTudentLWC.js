import { LightningElement, wire, track } from 'lwc';

import getStudents from '@salesforce/apex/BT_StudentControllerLWC.getStudents';
import deleteObject from '@salesforce/apex/BT_StudentControllerLWC.deleteObject';
import selectedLopSearch from '@salesforce/apex/BT_StudentControllerLWC.selectedLopSearch';
import deleteSelectedID from '@salesforce/apex/BT_StudentControllerLWC.deleteSelectedID';

export default class BT_SearchTudentLWC extends LightningElement {


    searchName = '';
    searchLop = '';
    searchDateFrom = null;
    searchDateTo = null;
    sortByName = false;

    
    
    students = [];
    lops = [];


    @track currentPage = 1;
    @track totalPages = 0;
    pageSize = 5;

    @track pageNumbers = [];

    get currentPage() {
        return Math.floor(this.startIndex / this.pageSize) + 1;
    }

    get totalPages() {
        return Math.ceil(this.students.length / this.pageSize);
    }

    upsertPage = false;
    homePage = true;
    detailPage = false;

    recordId = '';
    @track recordIds = [];


    @wire(selectedLopSearch)
    showListLop({ data, error }) {
      if (data) {
        this.lops = data;
      } else if (error) {
        console.error(error);
      }
    }

    get options() {
        let options = [];
        options.push({ label: 'chọn lớp', value: '' });
        for (let i = 0; i < this.lops.length; i++) {
          options.push({ label: this.lops[i].Name, value: this.lops[i].Name });
        }
        return options;
    }
    
    handleNameChange(event) {
        this.searchName = event.target.value;
    }
    handleDateFChange(event) {
        this.searchDateFrom = event.target.value;
    }
    handleDateTChange(event) {
        this.searchDateTo = event.target.value;
    }
    handleLopChange(event) {
        this.searchLop = event.target.value;
    }
    handleSortChange(event) {
        this.sortByName = event.target.checked;
    }

    handleChechDelete(event) {
        var studentID = event.target.value;
        var isChecked = event.target.checked;

        if (isChecked) {
            // Thêm giá trị vào mảng nếu checkbox được chọn
            this.recordIds.push(studentID);
        } else {
            // Xóa giá trị khỏi mảng nếu checkbox bị bỏ chọn
            const index = this.recordIds.indexOf(studentID);
            if (index > -1) {
                this.recordIds.splice(index, 1);
            }
        }
    
        console.log(JSON.stringify(this.recordIds));
    }

    

    isFirstRun = true;

    @wire(getStudents, {searchName: '$searchName' , searchLop: '$searchLop', 
    searchDateFrom: '$searchDateFrom', searchDateTo: '$searchDateTo', sortByName: '$sortByName'})
    showRecorData(result){
        if(result.data){
            this.paging(result.data);
        }
    }

    handleSearch() {
        getStudents({ searchName: this.searchName, searchLop: this.searchLop,
             searchDateFrom: this.searchDateFrom, searchDateTo: this.searchDateTo, 
             sortByName: this.sortByName })
            .then(res => {
                this.paging(res);
            })
            .catch(err => console.log(err));
    }

    paging(records) {
        var startIndex = (this.currentPage - 1) * this.pageSize;
        var endIndex = startIndex + this.pageSize;
        this.students = records.slice(startIndex, endIndex);
        
        var totalRecords = records.length;
        this.totalPages = Math.ceil(totalRecords / this.pageSize);
        var pageNumbersArray = []
        for (var i = 1; i <= this.totalPages; i++) {
            pageNumbersArray.push(i);
        }
        this.pageNumbers = pageNumbersArray;
        console.log('ádsad1',startIndex);
        console.log('dád2',endIndex);
    }

    handleDelete(event) {
        
        this.isDeleteConfirmationOpen = false;

        const value = event.target.value;
        deleteObject({ studentId: value })
            .then(() => {
                alert("delete successfully!");
                this.handleSearch();
            })
            .catch(err => console.log(err));
        
    }

    handleSelectedDelete() {        
        deleteSelectedID({ recordIds: this.recordIds })
            .then(() => {
                alert("delete successfully!");
                this.handleSearch();
            })
            .catch(err => console.log(err));
        
    }

    handleUpsert() {
        const value = event.target.value;
        this.recordId = value;
        this.upsertPage = true;
        this.homePage = false;
        this.detailPage = false;
    }

    handleDetail() {
        const value = event.target.value;
        this.recordId = value;
        this.detailPage = true;
        this.homePage = false;
        this.upsertPage = false;
    }

    back(){
        this.homePage = true;
        this.detailPage = false;
        this.upsertPage = false;
        this.handleSearch();
    }



    goToFirstPage() {
        this.currentPage = 1;
        this.handleSearch();
    }

    goToPreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.handleSearch();
        }
    }

    goToNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
            this.handleSearch();
        }
    }

    goToLastPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage = this.totalPages;
            this.handleSearch();
        }
    }

    setPage(event) {
        const selectedPage = event.target.value;
        this.currentPage = selectedPage;
        console.log(selectedPage);
        this.handleSearch();
    }

}