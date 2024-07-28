//
//  RedBlackTree.swift
//  RedBlackTree
//
//  Created by Don McBrien on 25/05/2019.
//  Copyright © 2019 thru 2024  Don McBrien. All rights reserved.
//

import Foundation

//MARK: - RED-BLACK BINARY TREE
/// A data structure used to store objects (herein called records) in an
/// order determined by its `redBlackTreeKey` member.
///
/// The tree must conform to `RedBlackTreeRecordProtocol` which simply
/// requires that it has a member (usually a computed variable provided in
/// an extension to the record object) which acts as the key to determine
/// ordering. The key must conform to the `RedBlackTreeKeyProtocol`
/// which requires that it defines the `⊰` operator which determines ordering
/// and an enum to decide whether keys must be unique or not and whether
/// they are stored in FIFO or LIFO order.

public indirect enum RedBlackTree<R: RedBlackTreeRecordProtocol, K>
where K == R.RedBlackTreeKey {
   case empty
   case node(_ colour: NodeColour,
             _ record: R,
             _ left: RedBlackTree<R,K>,
             _ right: RedBlackTree<R,K>)
   
   public init() { self = .empty }
}

//MARK: - PROTOCOLS

/// Protocol adopted by records to be stored in an `RedBlackTree`.
///
/// Defines the key used by records stored in a RedBlackTree. They must
/// conform to the `RedBlackTreeOrderingProtocol`.
public protocol RedBlackTreeRecordProtocol {
   associatedtype RedBlackTreeKey: RedBlackTreeKeyProtocol
   var redBlackTreeKey: RedBlackTreeKey { get }
}

/// Protocol adopted by the keys of records stored in an `RedBlackTree`.
///
/// Defines the `⊰` operator used to determine the order of keys and
/// an enum property to set whether keys must be unique or not and
/// whether they are stored in FIFO or LIFO order.
public protocol RedBlackTreeKeyProtocol {
   /// Comparison operator for ordering a RedBlackTree. Used to
   /// select which branch to follow when navigating a `RedBlackTree`
   /// by comparing the key sought with the key at the current
   /// position in the tree.
   ///
   /// Beware: records are stored in the tree based on the evaluation of `⊰`
   /// at the moment of insertion. If this evaluation can change the
   /// position in the tree will not change unless the object is explicitly
   /// removed from the tree before its position would change and reinserted
   /// after. This behaviour is intentional to support managing a list based
   /// on dynamic keys.
   static func ⊰(lhs: Self,rhs: Self) -> RedBlackTreeComparator
   /// Indicates whether the RedBlackTree can have duplicate entries and,
   /// if so, how they are sorted.
   ///
   /// - Defaults to `refused` meaning duplicate entries should be ignored on insertion.
   /// - Should be overridden to `useFIFO` or `useLIFO` if duplicates are permitted. FIFO
   ///   means that new duplicate entries are stored before (to the left of) all existing
   ///   duplicates and LIFO means they are stored after (to the right of) all existing
   ///   duplicates. All other operations operate on the rightmost duplicate first.
   static var duplicates: Duplicates { get }
}

extension RedBlackTreeKeyProtocol {
   /// Default implementation. If true, duplicate entries should be ignored
   /// when inserting records in the tree.
   static var duplicates: Duplicates { return .refused }
}

//MARK: - Contains/Neighbours.  Examine the Tree without changing it.

extension RedBlackTree {
   
   /// Recursively checks if `RedBlackTree` contains `key`?
   ///
   /// - Parameter key: key part of desired record
   /// - Returns: `true` or `false`
   public func contains(_ key: K) -> Bool {
      switch self {
         case .empty: return false
         case let .node(_, record, left, right):
            switch key ⊰ record.redBlackTreeKey {
               case .matching: return true
               case .leftTree: return left.contains(key)
               case .rightTree: return right.contains(key)
            }
      }
   }
   
   /// Fetches the next record containing `key` (or, if duplicates are permitted,
   /// the leftmost if the tree uses FIFO, the rightmost if it doesn't).
   ///
   /// Different from `contains(_:)` as it returns the record. The tree is unchanged.
   ///
   /// See also: `contains(_:) -> Bool`, `remove(_:) -> R?`
   /// - Parameter key: key part of desired record
   /// - Returns: the corresponding record or `nil` if not found
   public func fetch(_ key: K) -> R? {
      switch self {
         case .empty: return nil
         case let .node(_, record, left, right):
            switch (key ⊰ record.redBlackTreeKey, K.duplicates) {
               case (.matching, .refused): return record
               case (.matching, _):
                  let e = left.fetch(key)
                  if e == nil { return record }
                  else { return e }
               case (.leftTree, _): return left.fetch(key)
               case (.rightTree, _): return right.fetch(key)
            }
      }
   }
   
   /// Fetches all records containing `key` (in the order corresponding to the
   /// the order of deletion according to the usesFIFO rule).
   ///
   /// The tree is unchanged.
   ///
   /// See also: `removeAll() -> [R]`
   /// - Parameter key: key part of desired record
   /// - Returns: an array of records; may be empty.
   public func fetchAll(_ key: K) -> [R] {
      var result = [R]()
      switch self {
         case .empty:
            return result
         case let .node(_, record, left, right):
            switch (key ⊰ record.redBlackTreeKey, K.duplicates) {
               case (.matching, .refused):
                  result.append(record)
               case (.matching, _):
                  result.append(contentsOf: left.fetchAll(key))
                  result.append(record)
                  result.append(contentsOf: right.fetchAll(key))
               case (.leftTree, _):
                  result.append(contentsOf: left.fetchAll(key))
               case (.rightTree, _):
                  result.append(contentsOf: right.fetchAll(key))
            }
      }
      return result
   }

   /// Find the elements immediately preceeding and immediately following
   /// `key`, only if `key` itself is in the tree or else returns `nil`.
   /// Returns the rightmost element to the left of `key` and the leftmost
   /// element to the right of `key`.
   public func neighboursOf(_ key: K) -> (R?,R?)? {
      guard contains(key) else { return nil }
      return neighboursFor(key)
   }
   
   /// Find the records which would immediately preceed and follow `key`, whether
   /// or not `key` itself is in the tree. Returns the rightmost record to the
   /// left of `key` and the leftmost record to the right of `key`.
   /// Duplicate keys are not neighbours.
   public func neighboursFor(_ key: K, leftRecord: R? = nil, rightRecord: R? = nil) -> (R?,R?) {
      return (leftNeighbour(key), rightNeighbour(key))
   }

   /// Find the record which would immediately preceed `key`, whether
   /// or not `key` itself is in the tree. Returns the rightmost record to the
   /// left of `key`.
   /// Duplicates of `key` are not neighbours.
   public func leftNeighbour(_ key: K, leftRecord: R? = nil) -> R? {
      switch self {
         case .empty:
            return leftRecord
         case let .node(_, record, left, right):
            switch (key ⊰ record.redBlackTreeKey, K.duplicates) {
               case (.matching, .refused): return left.rightmost ?? leftRecord
               case (.matching, _):
                  // search further to eliminate duplicates on left
                  var l: R?
                  if left.contains(key) { // look deeper
                     l = left.leftNeighbour(key, leftRecord: leftRecord)
                  } else { l = left.rightmost ?? leftRecord }
                  return l
               case (.leftTree, _): return left.leftNeighbour(key, leftRecord: leftRecord)
               case (.rightTree, _): return right.leftNeighbour(key, leftRecord: record)
            }
      }
   }
   
   /// Find the record which would immediately follow `key`, whether
   /// or not `key` itself is in the tree. Returns the leftmost record to the
   /// right of `key`.
   /// Duplicates of `key` are not neighbours.
   public func rightNeighbour(_ key: K, rightRecord: R? = nil) -> R? {
      switch self {
         case .empty:
            return rightRecord
         case let .node(_, record, left, right):
            switch (key ⊰ record.redBlackTreeKey, K.duplicates) {
               case (.matching, .refused): return right.leftmost ?? rightRecord
               case (.matching, _):
                  // search further to eliminate duplicates right
                  var r: R?
                  if right.contains(key) { // look deeper
                     r = right.rightNeighbour(key, rightRecord: rightRecord)
                  } else { r = right.leftmost ?? rightRecord }
                  return r
               case (.leftTree, _): return left.rightNeighbour(key, rightRecord: record)
               case (.rightTree, _): return right.rightNeighbour(key, rightRecord: rightRecord)
            }
      }
   }

}

//MARK: - Utilities
extension RedBlackTree {
   public var isEmpty: Bool {
      switch self {
         case .empty: return true
         default: return false
      }
   }
   
   /// Fetch the first element in a `RedBlackTree`.
   /// Returns leftmost record or nil if the tree is empty. Tree is unchanged.
   public var leftmost: R? {
      switch self {
         case .empty:
            return nil
         case let .node(_, record, left, _):
            if left.leftmost == nil { return record }
            return left.leftmost
      }
   }
   
   /// Fetch the last element in a `RedBlackTree`.
   /// Returns rightmost record or nil if the tree is empty. Tree is unchanged.
   public var rightmost: R? {
      switch self {
         case .empty:
            return nil
         case let .node(_, record, _, right):
            if right.rightmost == nil { return record }
            return right.rightmost
      }
   }
   
   /// Counts records in a `RedBlackTree`.
   /// Tree is unchanged.
   public var count: Int {
      switch self {
         case .empty:
            return 0
         case let .node(_, _, left, right):
            return left.count + 1 + right.count
      }
   }
   
   /// Measures the longest path from root to leaf in a `RedBlackTree`.
   /// Tree is unchanged.
   public var height: Int {
      switch self {
         case .empty:
            return 0
         case let .node(_, _, left, right):
            return 1 + max(left.height, right.height)
      }
   }
}

//MARK: - Map<T>
extension RedBlackTree {
   public func map<T>(_ transform:(R) -> T) -> [T] {
      switch self {
         case .empty: return [T]()
         case let .node(_, record, left, right):
            return left.map(transform) + [transform(record)] + right.map(transform)
      }
   }
}

//MARK: - CustomStringConvertible Conformance
/// Produces graphic description of a `RedBlackTree`
extension RedBlackTree: CustomStringConvertible {
   private func diagram(_ top: String = "",
                        _ centre: String = "",
                        _ bottom: String = "") -> String {
      switch self {
         case .empty:
            return centre + "•\n"
         case let .node(colour, record, .empty, .empty):
            return centre + "\(colour)\(record) (key: \(record.redBlackTreeKey))\n"
         case let .node(colour, record, left, right):
            return left.diagram(top + "    ", top + "┌───", top + "│   ")
            + centre + "\(colour)\(record) (key: \(record.redBlackTreeKey))\n"
            + right.diagram(bottom + "│   ", bottom + "└───", bottom + "    ")
      }
   }
   
   public var description: String {
      return "Warning:\nEmpty leaf pairs excluded for readibility,\nbut remember to count them as black\n" + diagram()
   }
}

//MARK: - Insertion
extension RedBlackTree {
   /// Inserts an array of elements into a `RedBlackTree`.
   ///
   /// Elements are sorted in the tree according to the rule used by the ⊰
   /// operator in the `RedBlackTreeKeyProtocol` which produces an
   /// implicit sort key. Elements which obtain duplicate keys using this
   /// operator will be excluded from the tree and returned in an array
   /// unless the `duplicatesAllowed` flag in the `RedBlackTreeOrderingProtocol`
   /// is set to true. When permitted, duplicates are added to the tree in the
   /// order in which they were included in the input array as determined
   /// by the `duplicatesUseFIFO` flag on the key.
   ///
   /// - Parameter array: An array containing records to be inserted in the tree.
   /// - Returns: An array containing only those records which failed to
   ///   be inserted in the tree because records with the same keys were
   ///   already in the tree and the `duplicatesAllowed` flag was set to false.
   /// - Complexity: O(*m*log*n*) _base 2_, where *n* is the number of elements
   ///   already in the tree and *m* is the size of `array`.
   @discardableResult
   public mutating func insert(_ array:[R]) -> [R] {
      var fails = [R]()
      for record in array {
         let success = self.insert(record)
         if !success { fails.append(record) }
      }
      return fails
   }
   
   /// Inserts an element into a RedBlackTree.
   ///
   /// Elements are placed in the tree in a location determined by the ⊰
   /// operator in the `RedBlackTreeOrderingProtocol` which produces an
   /// implicit sort key. An element which obtains a key which matches an
   /// element already in the tree will be excluded from the tree unless
   /// the `duplicatesAllowed` flag in the `RedBlackTreeOrderingProtocol`
   /// is set to true. When permitted, duplicates are sorted in the order
   /// in which they were added to the tree.
   ///
   /// - Parameter array: An array containing elements to be inserted in the tree.
   /// - Returns: `true` if the element is successfully inserted in the tree.
   /// - Complexity: O(log*n*) _base 2_, where *n* is the number of elements
   ///   already in the tree.
   @discardableResult
   public mutating func insert(_ element: R) -> Bool {
      let (tree, old) = recursiveInsert(element)
      switch tree {
         case .empty: return false
         case let .node(_, record, left, right):
            self = .node(.black, record, left, right)
      }
      return old == nil
   }
   
   /// Recursive helper function for insert(element) which should
   /// not be called directly.
   private func recursiveInsert(_ element: R) -> (tree: RedBlackTree, old: R?) {
      switch self {
         case .empty:
            return (.node(.red, element, .empty, .empty), nil)
         case let .node(colour, record, left, right):
            switch (element.redBlackTreeKey ⊰ record.redBlackTreeKey, K.duplicates) {
               case (.matching, .refused):
                  return (self, record)
               case (.matching, .useLIFO),(.leftTree, _):
                  let (l, old) = left.recursiveInsert(element)
                  if let old = old { return (self, old) }
                  return (RedBlackTree<R,K>.node(colour, record, l, right).redBalanced(), old)
               case (.matching, .useFIFO),(.rightTree, _):
                  let (r, old) = right.recursiveInsert(element)
                  if let old = old { return (self, old) }
                  return (RedBlackTree<R,K>.node(colour, record, left, r).redBalanced(), old)
            }
      }
   }
}

//MARK: - Removal
extension RedBlackTree {
   /// Removes first record found containing key
   ///
   /// See also: `removeAll() -> [R]`
   /// - Parameter key: key part of desired record
   /// - Returns: removed record or nil if none found.
   @discardableResult
   public mutating func remove(_ key: K) -> R? {
      let search = recursiveRemove(key)
      if search.removed != nil {
         switch search.tree {
            case .empty: self = .empty
            case let .node(_, record, left, right):
               self = RedBlackTree<R,K>.node(.black, record, left, right)
         }
      }
      return search.removed
   }

   /// Removes all records containing key
   ///
   /// See also: `remove() -> R?`
   /// - Parameter key: key part of desired record
   /// - Returns: array containing removed records. Empty if none found.
   @discardableResult
   public mutating func removeAll(_ key: K) -> [R] {
      var list = [R]()
      var record = remove(key)
      while record != nil {
         list.append(record!)
         record = remove(key)
      }
      return list
   }
   
   private func recursiveRemove(_ key: K) -> (tree: RedBlackTree<R,K>, fixHeight: Bool, removed: R?) {
      switch self {
         case .empty:
            return (self, false, nil)
         case let .node(_, record, _, _):
            switch (key ⊰ record.redBlackTreeKey, K.duplicates) {
               case (.matching, .refused):    // found it!!
                  let s = self.replace()
                  return (s.0, s.1, record)
               case (.matching, _):    // found it!!
                  let e:(tree: RedBlackTree<R,K>, fixHeight: Bool, deleted: R?) = self.leftDelete(key)
                  if e.deleted == nil {
                     let s = self.replace()
                     return (s.0, s.1, record)
                  } else {
                     return (e.tree.redBalanced(), e.fixHeight, e.deleted)
                  }
               case (.leftTree, _):      // Still looking (left)
                  let s = self.leftDelete(key)
                  return (s.tree.redBalanced(), s.fixHeight, s.deleted)
               case (.rightTree, _):     // Still looking (right)
                  let s = self.rightDelete(key)
                  return (s.tree.redBalanced(), s.fixHeight, s.deleted)
            }
      }
   }
   
   private func replace() -> (tree: RedBlackTree<R,K>, fixHeight: Bool) {
      switch self {
         case let .node(.black, _, left, right):
            let s = left.fused(right)
            return (s, true)
         case let .node(.red, _, left, right):
            let s = left.fused(right)
            return (s, false)
         default: return (self, false)
      }
   }
   
   private func leftDelete(_ key: K) -> (tree: RedBlackTree<R,K>, fixHeight: Bool, deleted: R?) {
      switch self {
         case .empty:
            return (self, false, nil)
         case let .node(.red, record, left, right):
            let s = left.recursiveRemove(key)
            if s.fixHeight {
               return (RedBlackTree<R,K>.node(.black, record, s.tree, right).leftBalanced(), false, s.removed)
            } else {
               return (RedBlackTree<R,K>.node(.red, record, s.tree, right), false, s.removed)
            }
         case let .node(.black, record, left, right):
            let s = left.recursiveRemove(key)
            if s.fixHeight {
               return (RedBlackTree<R,K>.node(.black, record, s.tree, right).leftBalanced(), true, s.removed)
            } else {
               return (RedBlackTree<R,K>.node(.black, record, s.tree, right), false, s.removed)
            }
      }
   }
   
   private func rightDelete(_ key: K) -> (tree: RedBlackTree<R,K>, fixHeight: Bool, deleted: R?) {
      switch self {
         case .empty:
            return (self, false, nil)
         case let .node(.red, record, left, right):
            let s = right.recursiveRemove(key)
            if s.fixHeight {
               return (RedBlackTree<R,K>.node(.black, record, left, s.tree).rightBalanced(), false, s.removed)
            } else {
               return (RedBlackTree<R,K>.node(.red, record, left, s.tree), s.fixHeight, s.removed)
            }
         case let .node(.black, record, left, right):
            let s = right.recursiveRemove(key)
            if s.fixHeight {
               return (RedBlackTree<R,K>.node(.black, record, left, s.tree).rightBalanced(), s.fixHeight, s.removed)
            } else {
               return (RedBlackTree<R,K>.node(.black, record, left, s.tree), s.fixHeight, s.removed)
            }
      }
   }
}

//MARK: - Private Insertion/Deletion Helpers
extension RedBlackTree {
   private func fused(_ with: RedBlackTree<R,K>) -> RedBlackTree<R,K> {
      switch (self, with) {
         case (.empty,.empty):
            return .empty
         case let (t1,.empty), let (.empty,t1):
            return t1
         case let (.node(.black, _, _, _), .node(.red, y, t3, t4)):
            return RedBlackTree<R,K>.node(.red, y, self.fused(t3), t4).redBalanced()
         case let (.node(.red, x, t1, t2), .node(.black, _, _, _)):
            return RedBlackTree<R,K>.node(.red, x, t1, t2.fused(with)).redBalanced()
         case let (.node(.red, x, t1, t2),.node(.red, y, t3, t4)):
            let s = t2.fused(t3)
            switch s {
               case let .node(.red, z, s1, s2):
                  return RedBlackTree<R,K>.node(.red, z, .node(.red, x, t1, s1), .node(.red, y, s2, t4)).redBalanced()
               default:
                  return RedBlackTree<R,K>.node(.red, x, t1, .node(.red, y, s, t4)).redBalanced()
            }
         case let (.node(.black, x, t1, t2),.node(.black, y, t3, t4)):
            let s = t2.fused(t3)
            switch s {
               case let .node(.red, z, s1, s2):
                  return RedBlackTree<R,K>.node(.red, z, .node(.black, x, t1, s1), .node(.black, y, s2, t4)).redBalanced()
               default:
                  return RedBlackTree<R,K>.node(.black, x, t1, .node(.red, y, s, t4)).redBalanced()
            }
      }
   }
   
   private func redBalanced() -> RedBlackTree<R,K> {
      switch self {
         case let .node(_, z, .node(.red, y, .node(.red, x, a, b), c), d),
            let .node(_, z, .node(.red, x, a, .node(.red, y, b, c)), d),
            let .node(_, x, a, .node(.red, z, .node(.red, y, b, c), d)),
            let .node(_, x, a, .node(.red, y, b, .node(.red, z, c, d))):
            return .node(.red, y, .node(.black, x, a, b), .node(.black, z, c, d))
         default: return self
      }
   }
   
   private func leftBalanced() -> RedBlackTree<R,K> {
      switch self {
         case let .node(.red, y, t1, .node(.black, k, t2, t3)):
            return RedBlackTree<R,K>.node(.red, y, t1, .node(.red, k, t2, t3)).redBalanced()
         case let .node(.black, y, .node(.red, x, t1, t2), t3):
            return .node(.red, y, .node(.black, x, t1, t2), t3)
         case let .node(.black, y, t1, .node(.black, z, t2, t3)):
            return RedBlackTree<R,K>.node(.black, y, t1, .node(.red, z, t2, t3)).redBalanced()
         case let .node(.black, y, t1, .node(.red, z, .node(.black, u, t2, t3), .node(.black, k, l, r))):
            return .node(.red, u, .node(.black, y, t1, t2), RedBlackTree<R,K>.node(.black, z, t3, .node(.red, k, l, r)).redBalanced())
         default: return self
      }
   }
   
   private func rightBalanced() -> RedBlackTree<R,K> {
      switch self {
         case let .node(.red, y, .node(.black, k, t2, t3), t1):
            return RedBlackTree<R,K>.node(.red, y, .node(.red, k, t2, t3), t1).redBalanced()
         case let .node(.black, y, t1, .node(.red, x, t2, t3)):
            return .node(.red, y, t1, .node(.black, x, t2, t3))
         case let .node(.black, y, .node(.black, z, t1, t2), t3):
            return RedBlackTree<R,K>.node(.black, y, .node(.red, z, t1, t2), t3).redBalanced()
         case let .node(.black, y, .node(.red, z, .node(.black, k, l, r), .node(.black, u, t2, t3)), t4):
            return .node(.red, u, RedBlackTree<R,K>.node(.black, z, .node(.red, k, l, r), t2).redBalanced(), .node(.black, y, t3, t4))
         default: return self
      }
   }
}


//MARK: - ENUMs
/// Operator to choose ordering on `RedBlackTree`
infix operator ⊰: ComparisonPrecedence

// ENUMs
/// Results returned from a comparison using the ⊰ operator
///
/// Case values available are:
/// - .matching: matches this sub-tree
/// - .leftTree: belongs in the left sub-tree
/// - .rightTree: belongs in the right sub-tree
public enum RedBlackTreeComparator {
   case matching
   case leftTree
   case rightTree
}

public enum Duplicates {
   case refused, useFIFO, useLIFO
}

/// Node colour for RedBlackTree object
public enum NodeColour: CustomStringConvertible {
   case black
   case red
   
   public var description: String {
      switch self {
         case .black: return "◼︎"
         case .red: return "◻︎"
      }
   }
}
