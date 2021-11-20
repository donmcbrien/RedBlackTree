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
           //descending order
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
     
        public static func ⊰(lhs: Int, rhs: Int) -> RedBlackTreeComparator {
           // descending order
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
           print("    ",record)
        }
     }

     print("    ",myTree)

These 7 records were refused insertion because their keys were already in use:

     817:  -233.86
     982:   958.22
     289:     5.01
     276:   103.60
     408:  -270.96
     144:   239.42
     443:   228.44
     
The tree accepted 93 insertions shown in descending order as required:

                             ┌───◦
                         ┌───◻︎982:   354.64
                         │   └───◼︎976:  -994.05
                     ┌───◻︎894:   585.16
                     │   └───◻︎885:  -153.29
                 ┌───◼︎880:   998.87
                 │   │       ┌───◼︎873:   662.16
                 │   │   ┌───◻︎867:  -171.26
                 │   │   │   └───◦
                 │   └───◻︎856:  -684.05
                 │       │   ┌───◦
                 │       └───◻︎847:  -827.64
                 │           └───◼︎831:  -823.29
             ┌───◻︎827:  -515.68
             │   │   ┌───◻︎822:  -327.00
             │   └───◻︎817:   582.73
             │       └───◻︎810:   965.88
         ┌───◼︎808:  -253.46
         │   │           ┌───◻︎802:  -732.22
         │   │       ┌───◻︎786:   343.39
         │   │       │   └───◻︎778:   -19.69
         │   │   ┌───◼︎760:  -386.97
         │   │   │   │   ┌───◻︎759:  -882.20
         │   │   │   └───◻︎735:  -881.69
         │   │   │       └───◻︎726:  -245.34
         │   └───◻︎719:  -228.05
         │       │           ┌───◼︎685:  -689.12
         │       │       ┌───◻︎682:   593.68
         │       │       │   └───◦
         │       │   ┌───◻︎679:    55.27
         │       │   │   │   ┌───◻︎678:   598.57
         │       │   │   └───◼︎669:   943.42
         │       │   │       └───◻︎631:  -991.21
         │       └───◼︎626:   517.00
         │           │       ┌───◦
         │           │   ┌───◻︎622:   931.63
         │           │   │   └───◼︎614:   139.15
         │           └───◻︎603:   955.66
         │               │   ┌───◻︎602:  -426.36
         │               └───◼︎594:  -621.88
         │                   └───◻︎593:   513.93
     ┌───◻︎548:  -547.15
     │   │           ┌───◼︎529:  -447.35
     │   │       ┌───◻︎527:  -142.95
     │   │       │   └───◦
     │   │   ┌───◻︎522:  -579.74
     │   │   │   │   ┌───◼︎504:  -777.84
     │   │   │   └───◻︎490:  -771.97
     │   │   │       └───◼︎467:   766.01
     │   └───◻︎444:   269.77
     │       │   ┌───◻︎443:   804.97
     │       └───◻︎436:  -818.27
     │           └───◻︎426:  -689.36
     ◻︎425:   640.41
     │           ┌───◻︎422:   413.05
     │       ┌───◻︎408:  -242.73
     │       │   │   ┌───◦
     │       │   └───◻︎404:  -699.06
     │       │       └───◼︎402:  -122.03
     │   ┌───◻︎395:    40.47
     │   │   │       ┌───◻︎375:  -984.12
     │   │   │   ┌───◼︎371:  -243.60
     │   │   │   │   └───◻︎369:  -736.36
     │   │   └───◻︎353:  -646.78
     │   │       │   ┌───◻︎346:   -80.48
     │   │       └───◼︎339:   -55.64
     │   │           │   ┌───◦
     │   │           └───◻︎337:  -996.52
     │   │               └───◼︎331:  -776.84
     └───◻︎324:  -980.52
         │           ┌───◻︎318:  -540.60
         │       ┌───◻︎315:  -799.81
         │       │   └───◻︎308:  -398.32
         │   ┌───◻︎304:   722.83
         │   │   │   ┌───◻︎293:   193.68
         │   │   └───◻︎289:  -834.68
         │   │       └───◻︎276:  -692.00
         └───◼︎273:  -147.07
             │       ┌───◻︎267:   178.06
             │   ┌───◻︎256:   357.48
             │   │   │   ┌───◼︎249:  -313.83
             │   │   └───◻︎246:   759.38
             │   │       └───◦
             └───◻︎231:   998.49
                 │               ┌───◼︎214:   530.86
                 │           ┌───◻︎212:    46.77
                 │           │   └───◦
                 │       ┌───◼︎208:  -718.03
                 │       │   └───◻︎193:   617.38
                 │   ┌───◻︎180:   457.16
                 │   │   │   ┌───◦
                 │   │   └───◻︎179:   484.78
                 │   │       └───◼︎153:   345.63
                 └───◼︎152:  -689.46
                     │       ┌───◻︎144:    -4.99
                     │   ┌───◼︎ 88:   600.10
                     │   │   │   ┌───◼︎ 81:  -685.56
                     │   │   └───◻︎ 79:   235.91
                     │   │       └───◦
                     └───◻︎ 68:   377.95
                         │       ┌───◦
                         │   ┌───◻︎ 56:  -879.63
                         │   │   └───◼︎ 38:   837.06
                         └───◼︎ 17:   931.47
                             │   ┌───◼︎  7:   480.98
                             └───◻︎  1:   412.15
                                 └───◦

*/
