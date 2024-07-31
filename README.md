# RedBlackTree

### Declaration
    public enum RedBlackTree<R: RedBlackTreeRecordProtocol, K> where K == R.RedBlackTreeKey
    
### Overview
Red Black Trees are binary search trees with particular characteristics that assist them in remaining balanced (in the sense that all paths to leaves are of roughly equal length).
The following are invariant properties designed to achieve this:

- Height-balance means that every vertical path has the same number of black (<b>) nodes giving all paths an equal basic length.
- Red-balance means that no vertical path has two adjacent red (<r>) nodes so that path lengths may differ but never exceed twice the <b> height. Maximum height is therefore 2log2(n+1) for a tree containing n entries
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

    public var leftmost: R?
    // Find the first/leftmost record

    public var rightmost: R?
    // Find the last/rightmost record

    public func fetch(_ key: K) -> R? {
    // fetches a copy of the only record (or first when duplicates permitted), if any, containing the key

    public func fetchAll(_ key: K) -> [R]
    // only relevant where duplicates are permitted, this method fetches copies of all records, if any,
    // containing the key, and sorted according to the rule in the RedBlackTreeKeyProtocol

    public func neighboursOf(_ key: K) -> (R?,R?)?
    // fetches the immediate neighbours, left and right, of the record containing the key (but only 
    // if such a record) is present in the tree. Duplicates of key are ignored.

    public func neighboursFor(_ key: K, leftRecord: R? = nil, rightRecord: R? = nil) -> (R?,R?)
    // fetches the immediate neighbours, left and right, of where a record containing the key would be
    // (whether or not such a record is present). Duplicates of key are ignored.

### Map -> Array
    public func map<T>(_ transform:(R) -> T) -> [T]
    // produces an array by transforming a record using a closure

### Tree Inspection
Finally a number of methods can be used to examine the tree in its entirety:

    public var isEmpty: Bool
    // is the tree empty?
    
    public var count: Int
    // how many records are in the tree?
    
    public var height: Int
    // What is the longest path from root to leaf in the tree?

   public var blackNodesPerPath: Int
   // How many black nodes on each path from root to leaf in the tree?

Note also that a printable graphic of the tree can be obtained in the following property:

    public var description: String
    // display like a tree

### Usage
To use a tree, make your record type conform to RedBlackTreeRecordProtocol by adding an extension with a computable property called redBlackTreeKey which conforms to RedBlackTreeKeyProtocol and make your key type conform to RedBlackTreeKeyProtocol by adding the required computable variable governing duplicates and a method to describe ordering:

    extension MyRecordType: RedBlackTreeRecordProtocol {
       public typealias RedBlackTreeKey = MyKeyType
       public var redBlackTreeKey: RedBlackTreeKey { return self.myKey }
    }

    extension MyKeyType: RedBlackTreeKeyProtocol {
       public static var duplicates: Duplicate { return .refused }

       public static func ⊰(lhs: MyKeyType, rhs: MyKeyType) -> RedBlackTreeComparator {
           // in descending order
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
        public static var duplicates: Duplicates { return .refused }
     
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

These 6 records were refused insertion because their keys were already in use:

     386:   709.28
     300:  -596.11
     445:   137.53
      20:  -823.35
     282:   -67.44
     386:    48.41
          
The tree accepted 94 insertions shown in descending order as required:

                          ┌───◼︎995:  -197.91 (key: 995)
                      ┌───◼︎987:    56.72 (key: 987)
                      │   └───◼︎968:  -466.42 (key: 968)
                  ┌───◻︎947:   532.92 (key: 947)
                  │   │       ┌───◼︎946:   994.28 (key: 946)
                  │   │   ┌───◻︎944:  -594.07 (key: 944)
                  │   │   │   └───◼︎938:  -648.48 (key: 938)
                  │   └───◼︎935:    15.14 (key: 935)
                  │       └───◼︎931:   360.38 (key: 931)
              ┌───◼︎925:   918.26 (key: 925)
              │   │   ┌───◼︎918:   798.22 (key: 918)
              │   └───◼︎907:   582.47 (key: 907)
              │       │   ┌───◻︎898:   711.78 (key: 898)
              │       └───◼︎897:   251.73 (key: 897)
              │           └───•
          ┌───◻︎894:  -398.19 (key: 894)
          │   │           ┌───◻︎889:   443.88 (key: 889)
          │   │       ┌───◼︎865:   999.27 (key: 865)
          │   │       │   └───•
          │   │   ┌───◼︎851:   927.38 (key: 851)
          │   │   │   └───◼︎836:  -596.74 (key: 836)
          │   └───◼︎833:   690.30 (key: 833)
          │       │       ┌───◼︎815:   228.53 (key: 815)
          │       │   ┌───◻︎813:    -1.03 (key: 813)
          │       │   │   └───◼︎808:  -993.76 (key: 808)
          │       └───◼︎788:  -243.71 (key: 788)
          │           │   ┌───•
          │           └───◼︎784:   951.92 (key: 784)
          │               └───◻︎769:  -603.63 (key: 769)
      ┌───◼︎754:   -45.41 (key: 754)
      │   │               ┌───◼︎750:   845.04 (key: 750)
      │   │           ┌───◼︎743:   238.54 (key: 743)
      │   │           │   └───◼︎728:  -693.84 (key: 728)
      │   │       ┌───◻︎727:  -873.62 (key: 727)
      │   │       │   │       ┌───•
      │   │       │   │   ┌───◼︎725:   186.37 (key: 725)
      │   │       │   │   │   └───◻︎714:  -465.34 (key: 714)
      │   │       │   └───◼︎709:  -877.99 (key: 709)
      │   │       │       │   ┌───◼︎689:   963.06 (key: 689)
      │   │       │       └───◻︎680:  -376.42 (key: 680)
      │   │       │           │   ┌───•
      │   │       │           └───◼︎669:  -481.20 (key: 669)
      │   │       │               └───◻︎657:   280.85 (key: 657)
      │   │   ┌───◼︎644:  -659.26 (key: 644)
      │   │   │   │           ┌───◻︎638:   311.84 (key: 638)
      │   │   │   │       ┌───◼︎624:   164.04 (key: 624)
      │   │   │   │       │   └───◻︎575:  -695.80 (key: 575)
      │   │   │   │   ┌───◻︎558:   719.17 (key: 558)
      │   │   │   │   │   │   ┌───•
      │   │   │   │   │   └───◼︎556:   774.74 (key: 556)
      │   │   │   │   │       └───◻︎494:   264.27 (key: 494)
      │   │   │   └───◼︎482:  -130.76 (key: 482)
      │   │   │       └───◼︎469:   447.85 (key: 469)
      │   └───◻︎468:  -627.72 (key: 468)
      │       │       ┌───◼︎456:   347.73 (key: 456)
      │       │   ┌───◼︎447:     8.29 (key: 447)
      │       │   │   └───◼︎445:   -71.57 (key: 445)
      │       └───◼︎431:   417.79 (key: 431)
      │           │       ┌───•
      │           │   ┌───◼︎422:  -574.63 (key: 422)
      │           │   │   └───◻︎399:  -831.89 (key: 399)
      │           └───◼︎386:   823.99 (key: 386)
      │               │   ┌───◼︎379:   904.34 (key: 379)
      │               └───◻︎369:    58.54 (key: 369)
      │                   └───◼︎363:  -508.25 (key: 363)
      ◼︎327:    24.63 (key: 327)
      │                   ┌───◼︎320:  -500.18 (key: 320)
      │               ┌───◻︎306:   728.63 (key: 306)
      │               │   │   ┌───•
      │               │   └───◼︎300:   153.83 (key: 300)
      │               │       └───◻︎285:  -767.35 (key: 285)
      │           ┌───◼︎283:   401.83 (key: 283)
      │           │   └───◼︎282:  -803.43 (key: 282)
      │       ┌───◻︎263:  -133.82 (key: 263)
      │       │   │           ┌───•
      │       │   │       ┌───◼︎252:  -868.20 (key: 252)
      │       │   │       │   └───◻︎251:   502.95 (key: 251)
      │       │   │   ┌───◻︎226:  -578.34 (key: 226)
      │       │   │   │   └───◼︎218:   585.39 (key: 218)
      │       │   └───◼︎216:   249.65 (key: 216)
      │       │       │   ┌───◻︎181:  -281.22 (key: 181)
      │       │       └───◼︎174:   555.64 (key: 174)
      │       │           └───•
      │   ┌───◼︎166:  -899.79 (key: 166)
      │   │   │       ┌───◻︎158:   857.83 (key: 158)
      │   │   │   ┌───◼︎156:  -774.49 (key: 156)
      │   │   │   │   └───•
      │   │   └───◼︎149:  -705.35 (key: 149)
      │   │       │   ┌───•
      │   │       └───◼︎143:   550.85 (key: 143)
      │   │           └───◻︎134:  -688.87 (key: 134)
      └───◼︎128:   226.58 (key: 128)
          │           ┌───◻︎ 85:  -149.89 (key: 85)
          │       ┌───◼︎ 82:   167.45 (key: 82)
          │       │   └───◻︎ 79:   515.17 (key: 79)
          │   ┌───◼︎ 77:   206.16 (key: 77)
          │   │   │   ┌───◻︎ 73:  -135.19 (key: 73)
          │   │   └───◼︎ 63:   788.58 (key: 63)
          │   │       └───◻︎ 54:   270.13 (key: 54)
          └───◼︎ 52:  -136.49 (key: 52)
              │       ┌───◻︎ 39:   -94.06 (key: 39)
              │   ┌───◼︎ 33:  -722.10 (key: 33)
              │   │   └───•
              └───◼︎ 32:  -491.40 (key: 32)
                  │   ┌───◻︎ 29:  -407.77 (key: 29)
                  └───◼︎ 26:  -903.29 (key: 26)
                      └───◻︎ 20:   876.85 (key: 20)


      Note that empty leaf pairs such as those attached to key 158:

             ┌───◻︎158:   857.83 (key: 158)
         ┌───◼︎156:  -774.49 (key: 156)
         │   └───•

      are excluded from the printout to improve readibility, but remember to count them as black. Key 156 shows it's empty right node.
