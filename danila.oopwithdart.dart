import 'dart:developer';
import 'dart:io';

class Library with searchIndex, mainMenuProcesses{
  var allBooks, lentBooks, bookList=[], userList=[];
  List genres=["Computer Science", "Philosophy", "Pure Science", "Art and Recreation", "History"];

  //For each instance of Library, this constructor sets the number of books to 0 and the number of lent books to 0.
  Library(){
    allBooks=0;
    lentBooks=0;
  }

  //return number of books in library's ownership including those lent out
  int numOfBooks(){
    return allBooks;
  }

  //return number of lent out books
  int numOfLent(){
    return lentBooks;
  }

  //add book to the collection
  //used this method than directly creating a new object of Books in main to ensure that a new Books object will be created only if there is a Library object
  void addBook(String title, String author, String genre, String ISBN){
    var book=new Books(title, author, genre, ISBN);
    bookList.add(book);
    allBooks++;
  }

  //lending a book to the user
  void lendBook(int userIndex){
    //loop does not end until user selects the finish adding option
    for(var doAddBook='1';doAddBook!='2';){

      //1 means add book, 2 means finish adding books
      stdout.write("\n(1)Add book ISBN\n(2)Finish adding\nType choice:");
      doAddBook=stdin.readLineSync()!;

      if(doAddBook=='1'){
        //loop does not end until user inputs correct ISBN
        for(int bookIndex=-1;bookIndex==-1;){
          stdout.write("\nEnter book ISBN: ");
          String ISBNbyUser=stdin.readLineSync()!;
          bookIndex=findBookIndex(bookList, ISBNbyUser);

          //function findBookIndex returns -1 if ISBN does not match any record in the library's books collection
          if(bookIndex==-1)
            print("Book not found. Please enter ISBN again.");
          else if(bookList[bookIndex].status==0)
            print("Book is currently borrowed by someone else.");
          else{
            //book is added to the user's borrowed books list
            //book's status in the library is changed to unavailable
            //library's count of lent books increments
            userList[userIndex].borrowedBooks.add(bookList[bookIndex]);
            bookList[bookIndex].status=0;
            lentBooks++;
          }
        }
      }
      else if(doAddBook=='2')
        print("\nBooks added to borrow list.\n");
      else
        print("Invalid choice. Please try again.");
    }
  }

  //library accepts returned books from user
  //all books in user's borrow list will be returned
  void acceptReturn(int userIndex){
    print("\nReturned books: ");
    if(userList[userIndex].borrowedBooks.length!=0){
      for(int i=0;i<userList[userIndex].borrowedBooks.length;){
        int bookIndex=findBookIndex(bookList, userList[userIndex].borrowedBooks[i].ISBN);
        userList[userIndex].borrowedBooks.removeAt(0);
        bookList[bookIndex].status=1;
        lentBooks--;
        print("\t${bookList[bookIndex].title} by ${bookList[bookIndex].author}");
      }
    }
    else
      print("\nNo borrowed books in your record.");
  }
  
  //adding new user
  //this method is used rather than creating an object in main method to ensure that a new User object will be created only if there is an existing Library object
  void newUser(String fullName, String address){
    var user=new User(fullName, address);
    userList.add(user);
  }
}

//class for books containing necessary attributes
class Books{
  late String title;
  late String author;
  late String genre;
  late String ISBN;
  late int status; //0=borrowed, 1=available
  var booksBorrowed=[];

  //constructor to set values of attributes for every book instance
  Books(title, author, genre, ISBN){
    this.title=title;
    this.author=author;
    this.genre=genre;
    this.ISBN=ISBN;
    status=1; //status is immediately given value of 1 since it is available once added to collection
  }
}

//class for users containing necessary attributes
class User{
  late String fullName;
  late String address;
  var borrowedBooks=[];
  User(String fullName, String address){
    this.fullName=fullName;
    this.address=address;
  }
}

//mixin for index searching algorithms for books and users
mixin searchIndex{
  //method for finding certain book's index in library's users list
  //book is searched based on matching ISBN
  int findBookIndex(var listOfBooks, String ISBN){
    for(int i=0;i<listOfBooks.length;i++){
      if(listOfBooks[i].ISBN==ISBN)
        return i;
    }
    return -1;
  }

  //method for finding certain user's index in library's users list
  //user is searched based on matching full name and address
  int findUserIndex(var listOfUsers, String fullName, String address){
    for(int i=0;i<listOfUsers.length;i++){
      if(listOfUsers[i].fullName==fullName && listOfUsers[i].address==address)
        return i;
    }
    return -1;
  }
}

//mixin for processing of library's main menu
//chose to use mixin than defining these methods in the Library class for readability
mixin mainMenuProcesses{

  //method for browse books menu
  void mainBrowseBooks(var testLib){
    print("\n\n--BROWSE BOOKS--\n");
    //loop does not end until user inputs correct option
    for(;;){
      stdout.write("(1)View all\n(2)View by genre\nType option: ");
      var viewBooks=stdin.readLineSync();

      //view all books regardless of genre
      if(viewBooks=='1'){
        print("\nAll available books in the collection...\n");
        for(int i=0;i<testLib.bookList.length;i++){
          if(testLib.bookList[i].status==1){
            print("Title: ${testLib.bookList[i].title}");
            print("Author: ${testLib.bookList[i].author}");
            print("Genre: ${testLib.bookList[i].genre}");
            print("ISBN: ${testLib.bookList[i].ISBN}\n");
          }
        }
        break;
      }

      //view books based on a certain genre
      else if(viewBooks=='2'){
        stdout.write("\nGenres available...\n(1)Computer Science\n(2)Philosophy\n(3)Pure Science\n(4)Art and Recreation\n(5)History\nType option: ");
        int? viewGenres=int.tryParse(stdin.readLineSync()!);

        if(viewGenres!=null && ( viewGenres>0 || viewGenres<6)){
          print("\nAvailable books in ${testLib.genres[viewGenres-1]} genre...\n");
          int c=0;

          //finding and printing books under the genre selected by user
          for(int i=0;i<testLib.bookList.length;i++){
            if(testLib.genres[viewGenres-1]==testLib.bookList[i].genre && testLib.bookList[i].status==1){
              print("Title: ${testLib.bookList[i].title}");
              print("Author: ${testLib.bookList[i].author}");
              print("ISBN: ${testLib.bookList[i].ISBN}\n");
              c++; //counter to track number of books in a certain genre
            }
          }
          if(c==0)
            print("The library has no books in that genre.\n");
          break;
        }
        else
          print("Invalid choice. Please try again.\n");
      }
      else
        print("Invalid choice. Please try again.\n");
    }
    print("Redirecting to main menu...\n");
    print("---------------------------------------------------------------\n");
  }

  //method for borrow books menu
  void mainBorrowBooks(testLib){
    print("\n\n--BORROW BOOK/S--");
    //loop does not end until user inputs correct option
    for(;;){
      stdout.write("\n(1)New User\n(2)Old User\nType option: "); //1 for new user, 2 for old user
      var userStat=stdin.readLineSync();
      late int userIndex;

      if(userStat!='1' && userStat!='2')
        print("Invalid choice. Please try again.\n");
      else{
        //prompting user to input full name and address
        stdout.write("\nFull name: ");
        String fullName=stdin.readLineSync()!;
        stdout.write("Address: ");
        String address=stdin.readLineSync()!;

        //adding new user and taking index of last element in user list
        if(userStat=='1'){
          testLib.newUser(fullName, address);
          userIndex=testLib.userList.length-1;
          testLib.lendBook(userIndex);
          break;
        }
        //finding existing user and saving the index in userIndex
        else if(userStat=='2'){
          userIndex=testLib.findUserIndex(testLib.userList, fullName, address);
          if(userIndex==-1)
            print("Invalid selection. You are not an existing user. Select New User instead.");
          else{
            testLib.lendBook(userIndex);
            break;
          }
        }
      }
    }
    print("Redirecting to main menu...\n");
    print("---------------------------------------------------------------\n");
  }

  //method for returning of books menu
  void mainReturnBooks(var testLib){
    print("\n\n--RETURN BOOK/S--");

    //loop does not end until user inputs correct option
    for(;;){
      stdout.write("\n(1)New User\n(2)Old User\nType option: "); //1 for new user, 2 for old user
      var userStat=stdin.readLineSync();

      if(userStat!='1' && userStat!='2')
        print("Invalid choice. Please try again.");
      else{
        //prompting user to input full name and address
        stdout.write("\nFull name: ");
        String fullName=stdin.readLineSync()!;
        stdout.write("Address: ");
        String address=stdin.readLineSync()!;
        
        //adding new user to library's list of users
        if(userStat=='1'){
          testLib.newUser(fullName, address);
          print("\nNo books in your cart.\n");
          break;
        }
        //finding user in library's user list and storing the user's index in userIndex
        else if(userStat=='2'){
          int userIndex=testLib.findUserIndex(testLib.userList, fullName, address);

          //findUserIndex returns -1 if user is not found
          if(userIndex!=-1){
            testLib.acceptReturn(userIndex);
            break;
          }
          else
            print("We cannot find your name or address. Please enter those again.");
        }
      }
    }
    print("\nRedirecting to main menu...\n");
    print("---------------------------------------------------------------\n");
  }

  //method for view cart menu
  void mainViewCart(testLib){
    print("\n\n--VIEW BOOKS IN CART--");

    //loop does not end until user inputs the correct choice
    for(;;){
      stdout.write("\n(1)New User\n(2)Old User\nType option: "); //1 for new user, 2 for old user
      var userStat=stdin.readLineSync()!;

      if(userStat!='1' && userStat!='2')
        print("Invalid choice. Please try again.");
      else{
        //prompting user to input full name and address
        stdout.write("\nFull name: ");
        String fullName=stdin.readLineSync()!;
        stdout.write("Address: ");
        String address=stdin.readLineSync()!;

        //adding new user
        if(userStat=='1'){
          testLib.newUser(fullName, address);
          print("\nNo books in your cart.\n");
          break;
        }
        //finding existing user in the library's list of users
        else if(userStat=='2'){
          int userIndex=testLib.findUserIndex(testLib.userList, fullName, address);
          if(userIndex!=-1){
            print("\nBook/s in your cart: ");

            //printing all books in borrow list of user
            for(int i=0;i<testLib.userList[userIndex].borrowedBooks.length;i++){
              print("\t${testLib.userList[userIndex].borrowedBooks[i].title} by ${testLib.userList[userIndex].borrowedBooks[i].author}");
            }
            break;
          }
          else
            print("Are you sure you are an old user? We cannot find your name or address. Please enter again.");
        }
      }
    }
    print("Redirecting to main menu...\n");
    print("---------------------------------------------------------------\n");
  }
}

//method to test if system keeps track of books count properly
//only call this when you need to test the system
void systemTest(var testLib){
  print("---------------------------------------------------------------");
  print("This is a test.");
  print("Number of Lent Books: ${testLib.numOfLent()}"); 
  print("Number of Books in collection: ${testLib.numOfBooks()}");
  print("---------------------------------------------------------------\n");
}

//method to add mock information to the library
void testAdd(var testLib){
  testLib.addBook("The Philosophy Book", "DK", "Philosophy", "978-1-46545-855-1");
  testLib.addBook("Justice: What's the Right Thing to Do?", "Sandel, Michael J.", "Philosophy", "978-0-37453-250-5");
  testLib.addBook("Socrates, Buddha, Confucius and Jesus", "Jaspers, Karl, Manheim, Ralph", "Philosophy", "978-0-15683-580-0");
  testLib.addBook("The Universe", "Bhatnagar, P. L.", "Pure Science", "978-1-891830-85-3");
  testLib.addBook("Outer Space - Prospects for Man & Society", "Bloomfield, Lincoln P", "Pure Science", "978-1-40315-645-3");
  testLib.addBook("The Politics of Pure Science Second Edition", "Daniel S. Greenberg", "Pure Science", "978-0-22630-631-5");
  testLib.addBook("The Grove Encyclopedia of Islamic Art and Architecture, v. 1 - 3", "Jonathan M. Bloom (Editor); Sheila S. Blair (Editor)", "Art and Recreation", "978-0-19530-991-1");
  testLib.addBook("Great Athletes: Basketball", "Salem Press Editors", "Art and Recreation", "978-1-58765-488-6");
  testLib.addBook("World of Art Series T and H Dictionary of the Italian Renaissance", "J. R. Hale", "Art and Recreation", " 978-0-50020-191-6");
  testLib.addBook("Distributed Computing Pearls (Synthesis Lectures on Distributed Computing Theory)", "Gadi Taubenfeld", "Computer Science", "978-1-68173-350-0");  
  testLib.addBook("Introduction to Artificial Intelligence 1st ed. 2016 Edition", "Mariusz Flasiński", "Computer Science", "978-3-31940-020-4");
  testLib.addBook("Logic, Mathematics, and Computer Science: Modern Foundations with Practical Applications 2nd ed. 2015 Edition", "Yves Nievergelt", "Computer Science", "978-1-49393-222-1"); 
  testLib.addBook("Milestone Documents in American History", "Paul Finkelman (Editor); Bruce A. Lesh (General Editor)", "History", "978-0-97977-580-2");
  testLib.addBook("Historical Dictionary of the Jacksonian Era and Manifest Destiny", "Mark R. Cheathem; Terry Corps", "History", "978-1-44227-319-1");
  testLib.addBook("The Social Atlas of Europe", "Dimitris Ballas; Benjamin Hennig; Danny Dorling", "History", "978-1-44731-353-3");

}

//main function starts here
void main(){
  var testLib=new Library();
  testAdd(testLib); //adding mock information of books and users to the library

  //loop does not end unless user inputs any keys other than 1, 2, 3, and 4
  for(bool doExit=false;!doExit;){
    print("Welcome to the Local Library!");
    stdout.write("(1)Browse collection of Books\n(2)Borrow Book/s\n(3)Return Book/s\n(4)View Book/s in cart\nPress any other key to exit...\nType option: ");
    var mainOption=stdin.readLineSync();
    switch(mainOption){
      case '1':
        //browse books
        testLib.mainBrowseBooks(testLib);        
        break;
      case '2': 
        //borrow books
        testLib.mainBorrowBooks(testLib);
        break;
      case '3':
        //return borrowed books
        testLib.mainReturnBooks(testLib);
        break;
      case '4':
        //view books in cart (cart contains currently borrowed books)
        testLib.mainViewCart(testLib);
        break;
      default:
        doExit=true;
        print("Exiting...");
        
        //next line can be commented out if you do not want to run the system testing for tracking of number of books
        systemTest(testLib);
    }
  }
}