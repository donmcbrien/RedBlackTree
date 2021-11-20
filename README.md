# RedBlackTree

### Declaration
    public enum RedBlackTree<R: RedBlackTreeRecordProtocol, K> where K == R.RedBlackTreeKey
    
### Overview
Red-Black Trees are binary search trees with particular characteristics that assist them in remaining balanced (in the sense that all paths to leaves are of roughly equal length).
The following are invariant properties designed to achieve this:

- Height-balance means that every vertical path has the same number of black (<b>) nodes giving all paths an equal basic length.
- Red-balance means that no vertical path has two adjacent red (<r>) nodes so that path lengths may differ but never exceed twice the <b> height. Maximum height is therefore 2log2(n-1) for a tree containing n entries
- The root node of the entire tree is always black <b>
- Empty nodes (<e>) are always counted as black.

A tree is a recursive structure in that every tree is composed of sub-trees and every sub-tree is a tree which obeys all the invariant rules (except that a sub-tree may have a <r> root). Key tree-maintenance operations are insert and delete. During these operations the invariants may be disturbed but they must be restored before the operation is completed.

You use red-black trees as data structures to provide rapid access to data. The data stored must conform to the RedBlackTreeRecordProtocol which essentially means it should contain a property which conforms to the RedBlackTreeKeyProtocol. This latter protocol is not unlike the Comparable protocol in that it shows how records should be ordered in the tree but it also governs the treatment of duplicate records.

### Insertion and Removal
A newly initialised red-black tree is always empty. Records can be added singly or in collections using one of the following methods:

    public mutating func insert(_ record: R) -> Bool
// adds one record if permitted (i.e. if duplicates allowed) 
   
    public mutating func insert(_ arrayOfRecords: [R]) -> [R]
// adds multiple record and returns array of records which were rejected

Records can be removed singly or in collections using one of the following methods:

    public mutating func remove(_ key: K) -> R?
// removes the first record, if any, containing the key

    public mutating func removeAll(_ key: K) -> [R]
// only relevant where duplicates are permitted, this method removes all records, if any,
// containg the key, and sorted by the rule in the RedBlackTreeKeyProtocol

### Record Inspection
A number of methods can be used to examing records in the tree without changing the tree:

    public func contains(_ key: K) -> Bool 
// reports whether a record containing the key is present

    public var minimum: R?
// Find the leftmost record

    public var maximum: R?
// Find the rightmost record

    public func fetch(_ key: K) -> R? {
// fetches a copy of the only record (or first when duplicates permitted), if any, containing the key

    public func fetchAll(_ key: K) -> [R]
// only relevant where duplicates are permitted, this method fetches copies of all records, if any,
// containing the key, and sorted by the rule in the RedBlackTreeKeyProtocol

    public func neighboursOf(_ key: K) -> (R?,R?)?
// fetches the immediate neighbours, left and right, of the record containing the key (but only 
    // if such a record) is present in the tree. Duplicates of key are ignored.

    public func neighboursFor(_ key: K, leftRecord: R? = nil, rightRecord: R? = nil) -> (R?,R?)
// fetches the immediate neighbours, left and right, of where a record containing the key would be
// (whether or not such a record is present). Duplicates of key are ignored.

### Tree Inspection
Finally a number of methods can be used to examine the tree in its entirety:

    public var isEmpty: Bool
// is the tree empty?
    
    public var count: Int
// how many records are in the tree?
    
    public var height: Int
// What is the longest path from root to leaf in the tree?

Note also that a printable graphic of the tree can be obtained in the following property:

    public var description: String


### Usage
To use a tree, make your record type conform to RedBlackTreeRecordProtocol by adding an extension with a computable property called redBlackTreeKey which conforms to RedBlackTreeKeyProtocol and make your key type conform to RedBlackTreeKeyProtocol by adding the two required computable variables governing duplicates and a method to describe ordering:

    extension MyRecordType: RedBlackTreeRecordProtocol {
       public typealias RedBlackTreeKey = MyKeyType
       public var redBlackTreeKey: RedBlackTreeKey { return self.myKey }
    }

    extension MyKeyType: RedBlackTreeKeyProtocol {
       public static var duplicatesAllowed: Bool { return false }
       public static var duplicatesUseFIFO: Bool { return false }

       public static func ⊰(lhs: MyKeyType, rhs: MyKeyType) -> RedBlackTreeComparator {
          if lhs.myKey > rhs.myKey { return .leftTree }
          if lhs.myKey == rhs.myKey { return .matching }
          return .rightTree
       }
    }

Now you can declare and use a RedBlackTree 

    var myRedBlackTree = RedBlackTree<MyRecordType, MyKeyType>()

### Simple Example

    import Foundation
    import RedBlackTree

    struct Foo {
       var id: Int
       var contents: Double
    }

    extension Foo: RedBlackTreeRecordProtocol {
       public typealias RedBlackTreeKey = Int
       public var redBlackTreeKey: RedBlackTreeKey { return self.id }
    }

    extension Foo: CustomStringConvertible {
       var description: String { return String(format: "%3d:  %7.2f", id, contents) }
    }

    extension Int: RedBlackTreeKeyProtocol {
       public static var duplicatesAllowed: Bool { return false }
       public static var duplicatesUseFIFO: Bool { return false }

   // descending order
       public static func ⊰(lhs: Int, rhs: Int) -> RedBlackTreeComparator {
          if lhs > rhs { return .leftTree }
          if lhs == rhs { return .matching }
          return .rightTree
       }
    }

    var myTree = RedBlackTree<Foo,Int>()

    for _ in 0..<100 {
       let key = Int.random(in: 1...1000)
       let record = Foo(id: key, contents: Double.random(in: -1000.0...1000.0))
       if !myTree.insert(record) {
          print(record)
       }
    }

    print(myTree.count)
    print(myTree)

### Output

Five duplicates were refused insertion and 95 were accepted.
Tree is printed "top to bottom" = "left to right"

/*

684  -605.08
770  -379.98
289   379.09
861  -767.19
685  -125.93
95

# RedBlackTree

### Declaration
    public enum RedBlackTree<R: RedBlackTreeRecordProtocol, K> where K == R.RedBlackTreeKey
    
### Overview
Red-Black Trees are binary search trees with particular characteristics that assist them in remaining balanced (in the sense that all paths to leaves are of roughly equal length).
The following are invariant properties designed to achieve this:

- Height-balance means that every vertical path has the same number of black (<b>) nodes giving all paths an equal basic length.
- Red-balance means that no vertical path has two adjacent red (<r>) nodes so that path lengths may differ but never exceed twice the <b> height. Maximum height is therefore 2log2(n-1) for a tree containing n entries
- The root node of the entire tree is always black <b>
- Empty nodes (<e>) are always counted as black.

A tree is a recursive structure in that every tree is composed of sub-trees and every sub-tree is a tree which obeys all the invariant rules (except that a sub-tree may have a <r> root). Key tree-maintenance operations are insert and delete. During these operations the invariants may be disturbed but they must be restored before the operation is completed.

You use red-black trees as data structures to provide rapid access to data. The data stored must conform to the RedBlackTreeRecordProtocol which essentially means it should contain a property which conforms to the RedBlackTreeKeyProtocol. This latter protocol is not unlike the Comparable protocol in that it shows how records should be ordered in the tree but it also governs the treatment of duplicate records.

### Insertion and Removal
A newly initialised red-black tree is always empty. Records can be added singly or in collections using one of the following methods:

    public mutating func insert(_ record: R) -> Bool
// adds one record if permitted (i.e. if duplicates allowed) 
   
    public mutating func insert(_ arrayOfRecords: [R]) -> [R]
// adds multiple record and returns array of records which were rejected

Records can be removed singly or in collections using one of the following methods:

    public mutating func remove(_ key: K) -> R?
// removes the first record, if any, containing the key

    public mutating func removeAll(_ key: K) -> [R]
// only relevant where duplicates are permitted, this method removes all records, if any,
// containg the key, and sorted by the rule in the RedBlackTreeKeyProtocol

### Record Inspection
A number of methods can be used to examing records in the tree without changing the tree:

    public func contains(_ key: K) -> Bool 
// reports whether a record containing the key is present

    public var minimum: R?
// Find the leftmost record

    public var maximum: R?
// Find the rightmost record

    public func fetch(_ key: K) -> R? {
// fetches a copy of the only record (or first when duplicates permitted), if any, containing the key

    public func fetchAll(_ key: K) -> [R]
// only relevant where duplicates are permitted, this method fetches copies of all records, if any,
// containing the key, and sorted by the rule in the RedBlackTreeKeyProtocol

    public func neighboursOf(_ key: K) -> (R?,R?)?
// fetches the immediate neighbours, left and right, of the record containing the key (but only 
    // if such a record) is present in the tree. Duplicates of key are ignored.

    public func neighboursFor(_ key: K, leftRecord: R? = nil, rightRecord: R? = nil) -> (R?,R?)
// fetches the immediate neighbours, left and right, of where a record containing the key would be
// (whether or not such a record is present). Duplicates of key are ignored.

### Tree Inspection
Finally a number of methods can be used to examine the tree in its entirety:

    public var isEmpty: Bool
// is the tree empty?
    
    public var count: Int
// how many records are in the tree?
    
    public var height: Int
// What is the longest path from root to leaf in the tree?

Note also that a printable graphic of the tree can be obtained in the following property:

    public var description: String


### Usage
To use a tree, make your record type conform to RedBlackTreeRecordProtocol by adding an extension with a computable property called redBlackTreeKey which conforms to RedBlackTreeKeyProtocol and make your key type conform to RedBlackTreeKeyProtocol by adding the two required computable variables governing duplicates and a method to describe ordering:

    extension MyRecordType: RedBlackTreeRecordProtocol {
       public typealias RedBlackTreeKey = MyKeyType
       public var redBlackTreeKey: RedBlackTreeKey { return self.myKey }
    }

    extension MyKeyType: RedBlackTreeKeyProtocol {
       public static var duplicatesAllowed: Bool { return false }
       public static var duplicatesUseFIFO: Bool { return false }

       public static func ⊰(lhs: MyKeyType, rhs: MyKeyType) -> RedBlackTreeComparator {
          if lhs.myKey > rhs.myKey { return .leftTree }
          if lhs.myKey == rhs.myKey { return .matching }
          return .rightTree
       }
    }

Now you can declare and use a RedBlackTree 

    var myRedBlackTree = RedBlackTree<MyRecordType, MyKeyType>()

### Simple Example

    import Foundation
    import RedBlackTree

    struct Foo {
       var id: Int
       var contents: Double
    }

    extension Foo: RedBlackTreeRecordProtocol {
       public typealias RedBlackTreeKey = Int
       public var redBlackTreeKey: RedBlackTreeKey { return self.id }
    }

    extension Foo: CustomStringConvertible {
       var description: String { return String(format: "%3d:  %7.2f", id, contents) }
    }

    extension Int: RedBlackTreeKeyProtocol {
       public static var duplicatesAllowed: Bool { return false }
       public static var duplicatesUseFIFO: Bool { return false }

   // descending order
       public static func ⊰(lhs: Int, rhs: Int) -> RedBlackTreeComparator {
          if lhs > rhs { return .leftTree }
          if lhs == rhs { return .matching }
          return .rightTree
       }
    }

    var myTree = RedBlackTree<Foo,Int>()

    for _ in 0..<100 {
       let key = Int.random(in: 1...1000)
       let record = Foo(id: key, contents: Double.random(in: -1000.0...1000.0))
       if !myTree.insert(record) {
          print(record)
       }
    }

    print(myTree.count)
    print(myTree)

### Output

Five duplicates were refused insertion and 95 were accepted.
Tree is printed "top to bottom" = "left to right"

/*

684  -605.08
770  -379.98
289   379.09
861  -767.19
685  -125.93
95
                ┌───◻︎  7  -490.17
            ┌───◻︎ 16  -316.57
            │   │   ┌───◻︎ 45   -32.80
            │   └───◼︎ 49   347.54
            │       └───◻︎ 55  -237.58
        ┌───◼︎ 75   -93.81
        │   │   ┌───◻︎ 86   773.80
        │   └───◻︎ 94  -730.25
        │       │   ┌───◼︎110  -309.37
        │       └───◻︎136  -127.54
        │           └───◦
    ┌───◻︎151  -328.75
    │   │       ┌───◼︎154    -3.91
    │   │   ┌───◻︎171   -60.95
    │   │   │   └───◼︎183   656.81
    │   └───◻︎204  -637.49
    │       │   ┌───◻︎206  -469.18
    │       └───◼︎210   725.77
    │           └───◻︎220  -738.13
┌───◻︎231   205.40
│   │           ┌───◻︎243  -830.37
│   │       ┌───◻︎245  -906.03
│   │       │   └───◻︎246   870.95
│   │   ┌───◼︎251   239.92
│   │   │   │   ┌───◻︎268   745.28
│   │   │   └───◻︎284  -404.26
│   │   │       │   ┌───◼︎287   858.79
│   │   │       └───◻︎289  -638.12
│   │   │           └───◼︎306  -954.18
│   └───◻︎345   923.54
│       │           ┌───◼︎350   178.61
│       │       ┌───◻︎354   242.89
│       │       │   └───◦
│       │   ┌───◼︎358  -121.32
│       │   │   └───◻︎359   348.81
│       └───◻︎362   387.23
│           │       ┌───◼︎364  -766.78
│           │   ┌───◻︎368   548.29
│           │   │   └───◦
│           └───◼︎377  -510.35
│               └───◻︎400   -77.98
◻︎406   303.80
│           ┌───◻︎435   983.34
│       ┌───◻︎440   858.41
│       │   │   ┌───◼︎444  -659.25
│       │   └───◻︎457   295.84
│       │       └───◦
│   ┌───◻︎470  -735.36
│   │   │       ┌───◻︎497   815.52
│   │   │   ┌───◻︎500   973.98
│   │   │   │   │   ┌───◼︎566  -803.21
│   │   │   │   └───◻︎599   354.61
│   │   │   │       └───◼︎617  -895.66
│   │   └───◼︎621  -659.48
│   │       │   ┌───◻︎624  -940.57
│   │       └───◻︎643   920.29
│   │           │   ┌───◻︎644   210.54
│   │           └───◼︎650  -213.20
│   │               └───◻︎654    46.37
└───◻︎661  -461.00
    │               ┌───◼︎664   310.86
    │           ┌───◻︎678   291.73
    │           │   └───◦
    │       ┌───◻︎679   413.10
    │       │   │   ┌───◻︎684  -474.42
    │       │   └───◼︎685   444.54
    │       │       │   ┌───◼︎690  -826.06
    │       │       └───◻︎691   251.06
    │       │           └───◦
    │   ┌───◻︎693    80.39
    │   │   │               ┌───◦
    │   │   │           ┌───◻︎710   904.43
    │   │   │           │   └───◼︎721   370.74
    │   │   │       ┌───◼︎729   776.43
    │   │   │       │   │   ┌───◼︎730  -970.31
    │   │   │       │   └───◻︎737  -875.22
    │   │   │       │       └───◦
    │   │   │   ┌───◻︎766  -988.59
    │   │   │   │   │   ┌───◦
    │   │   │   │   └───◻︎768   800.67
    │   │   │   │       └───◼︎770  -503.26
    │   │   └───◼︎801   383.65
    │   │       │       ┌───◼︎816  -979.69
    │   │       │   ┌───◻︎817   157.92
    │   │       │   │   └───◦
    │   │       └───◻︎822  -231.69
    │   │           │   ┌───◼︎838  -921.51
    │   │           └───◻︎839  -151.46
    │   │               └───◼︎844   227.04
    └───◼︎861  -903.68
        │           ┌───◦
        │       ┌───◻︎864  -942.86
        │       │   └───◼︎876   797.52
        │   ┌───◻︎877  -408.21
        │   │   │       ┌───◼︎880  -676.90
        │   │   │   ┌───◻︎884   626.01
        │   │   │   │   └───◦
        │   │   └───◼︎906  -470.50
        │   │       └───◻︎915  -382.25
        └───◻︎920   643.62
            │       ┌───◻︎927  -812.96
            │   ┌───◼︎935    13.52
            │   │   └───◻︎948  -994.79
            └───◻︎978   232.51
                │   ┌───◻︎980  -270.61
                └───◼︎991   459.81
                    └───◻︎995  -676.96

Program ended with exit code: 0

*/                     

*/
