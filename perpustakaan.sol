// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Perpustakaan {
    address public admin=0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    
    struct Book {
        uint256 kodeIsbn;
        string judulBuku;
        uint16 tahun;
        string penulis;
    }
    
    mapping(uint256 => Book) public books;
    uint256 public jumlahBuku;
    bool public isBookUpdatePending;
    Book public pendingBookData;
    
    event BookAdded(uint256 kodeIsbn, string judulBuku, uint16 tahun, string penulis);
    event BookDeleted(uint256 kodeIsbn);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }
    
    constructor() {
        admin = msg.sender;
    }

    function addBook(uint256 _kodeIsbn, string calldata _judul, uint16 _tahun, string calldata _penulis) public onlyAdmin {
        require(_kodeIsbn > 0, "Invalid ISBN code");
        require(bytes(_judul).length > 0, "Title cannot be empty");
        require(_tahun > 0, "Invalid year");
        require(bytes(_penulis).length > 0, "Author cannot be empty");

        // membuat data buku untuk dimasukkan ke daftar pending
        pendingBookData = Book({
            kodeIsbn: _kodeIsbn,
            judulBuku: _judul,
            tahun: _tahun,
            penulis: _penulis
        });

        // menandakan ada data yang pending
        isBookUpdatePending = true;
    }

    function updateBook() public onlyAdmin {
        require(isBookUpdatePending, "No pending book data to update");

        // Simpan data buku yang tertunda ke pemetaan
        books[pendingBookData.kodeIsbn] = pendingBookData;
        jumlahBuku++;

            // Reset data buku yang pending ke nilai awal
        pendingBookData = Book({
            kodeIsbn: 0,
            judulBuku: "",
            tahun: 0,
            penulis: ""
        });

        // Setel ulang data dan tandai buku yang tertunda
        isBookUpdatePending = false;

        emit BookAdded(pendingBookData.kodeIsbn, pendingBookData.judulBuku, pendingBookData.tahun, pendingBookData.penulis);
    }

    function deleteBook(uint256 _kodeIsbn) public onlyAdmin {
        require(books[_kodeIsbn].kodeIsbn != 0, "Book with specified ISBN not found");

        // hapus buku dari mappping
        delete books[_kodeIsbn];

        // pengurangan jumlah buku
        jumlahBuku--;

        emit BookDeleted(_kodeIsbn);
    }
}