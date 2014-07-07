module Data.PhoneBook where

import Data.List
import Data.Maybe

type Entry = { firstName :: String, lastName :: String, phone :: String }

type PhoneBook = List Entry

showEntry :: Entry -> String
showEntry entry = entry.lastName ++ ", " ++ entry.firstName ++ ": " ++ entry.phone

emptyBook :: PhoneBook
emptyBook = empty

insertEntry :: Entry -> PhoneBook -> PhoneBook
insertEntry entry book = insertBy compareEntries entry book
  where
  compareEntries :: Entry -> Entry -> Ordering
  compareEntries e1 e2 | e1.lastName < e2.lastName = LT
  compareEntries e1 e2 | e1.lastName > e2.lastName = GT
  compareEntries e1 e2 = compare e1.firstName e2.firstName
 
findEntry :: String -> String -> PhoneBook -> Maybe Entry
findEntry firstName lastName = head <<< filter filterEntry
  where
  filterEntry :: Entry -> Boolean
  filterEntry entry = entry.firstName == firstName && entry.lastName == lastName
