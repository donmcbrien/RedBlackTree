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

