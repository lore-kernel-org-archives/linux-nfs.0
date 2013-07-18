Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:51404 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758922Ab3GRNSg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Jul 2013 09:18:36 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1374094436.1949.109.camel@joe-AO722>
References: <1374094436.1949.109.camel@joe-AO722> <20130717204314.8591.52892.stgit@warthog.procyon.org.uk> <20130717204330.8591.39362.stgit@warthog.procyon.org.uk>
To: Joe Perches <joe@perches.com>, "George Spelvin" <linux@horizon.com>
Cc: dhowells@redhat.com, keyrings@linux-nfs.org,
        linux-security-module@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH] Assoc_array: Drop leaf-type concept
Date: Thu, 18 Jul 2013 14:18:24 +0100
Message-ID: <21160.1374153504@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi Joe, George,

How about the attached changes?  I've dropped support for multiple leaf types
in the assoc_array API (leaving that to the caller).  The array still uses bit
0 of the object pointer to mark an internal metadata pointer if set (and then
uses bit 1 to specify the subtype internally).

It makes assoc_array.o about 250 bytes smaller too, whereas keyrings.o grows
by about 150 - so a net gain.

David
---
 Documentation/assoc_array.txt    |   45 +++++++------------
 include/linux/assoc_array.h      |   10 +---
 include/linux/assoc_array_priv.h |   85 ++++++++++++++++++++++--------------
 lib/assoc_array.c                |   87 +++++++++++++++++-------------------
 security/keys/gc.c               |    2 
 security/keys/internal.h         |    2 
 security/keys/keyring.c          |   92 +++++++++++++++++++++++++--------------
 7 files changed, 179 insertions(+), 144 deletions(-)

diff --git a/Documentation/assoc_array.txt b/Documentation/assoc_array.txt
index 91ea88e..f4faec0 100644
--- a/Documentation/assoc_array.txt
+++ b/Documentation/assoc_array.txt
@@ -31,41 +31,36 @@ properties:
  (1) Objects are opaque pointers.  The implementation does not care where they
      point (if anywhere) or what they point to (if anything).
 
-     [!] NOTE: Pointers to objects _must_ be zero in the two least significant
-     	       bits.
+     [!] NOTE: Pointers to objects _must_ be zero in the least significant bit.
 
  (2) Objects do not need to contain linkage blocks for use by the array.  This
      permits an object to be located in multiple arrays simultaneously.
      Rather, the array is made up of metadata blocks that point to objects.
 
- (3) Objects are labelled as being one of two types (the type is a bool value).
-     This information is stored in the array, but has no consequence to the
-     array itself or its algorithms.
+ (3) Objects require index keys to locate them within the array.
 
- (4) Objects require index keys to locate them within the array.
-
- (5) Index keys must be unique.  Inserting an object with the same key as one
+ (4) Index keys must be unique.  Inserting an object with the same key as one
      already in the array will replace the old object.
 
- (6) Index keys can be of any length and can be of different lengths.
+ (5) Index keys can be of any length and can be of different lengths.
 
- (7) Index keys should encode the length early on, before any variation due to
+ (6) Index keys should encode the length early on, before any variation due to
      length is seen.
 
- (8) Index keys can include a hash to scatter objects throughout the array.
+ (7) Index keys can include a hash to scatter objects throughout the array.
 
- (9) The array can iterated over.  The objects will not necessarily come out in
+ (8) The array can iterated over.  The objects will not necessarily come out in
      key order.
 
-(10) The array can be iterated over whilst it is being modified, provided the
+ (9) The array can be iterated over whilst it is being modified, provided the
      RCU readlock is being held by the iterator.  Note, however, under these
      circumstances, some objects may be seen more than once.  If this is a
      problem, the iterator should lock against modification.  Objects will not
      be missed, however, unless deleted.
 
-(11) Objects in the array can be looked up by means of their index key.
+(10) Objects in the array can be looked up by means of their index key.
 
-(12) Objects can be looked up whilst the array is being modified, provided the
+(11) Objects can be looked up whilst the array is being modified, provided the
      RCU readlock is being held by the thread doing the look up.
 
 The implementation uses a tree of 16-pointer nodes internally that are indexed
@@ -203,12 +198,11 @@ There are a number of functions for manipulating an associative array:
 	assoc_array_insert(struct assoc_array *array,
 			   const struct assoc_array_ops *ops,
 			   const void *index_key,
-			   void *object, bool type);
+			   void *object);
 
      This inserts the given object into the array.  Note that the least
-     significant two bits of the pointer must be zero as they're used to
-     type-mark pointers internally.  The type argument is an arbitrary
-     two-value type retained by the array but not used by the algorithms.
+     significant bit of the pointer must be zero as it's used to type-mark
+     pointers internally.
 
      If an object already exists for that key then it will be replaced with the
      new object and the old one will be freed automatically.
@@ -278,8 +272,7 @@ There are a number of functions for manipulating an associative array:
 
 	int assoc_array_gc(struct assoc_array *array,
 			   const struct assoc_array_ops *ops,
-			   bool (*iterator)(void *object, bool type,
-					    void *iterator_data),
+			   bool (*iterator)(void *object, void *iterator_data),
 			   void *iterator_data);
 
      This iterates over the objects in an associative array and passes each one
@@ -310,7 +303,7 @@ There are two functions for accessing an associative array:
  (1) Iterate over all the objects in an associative array.
 
 	int assoc_array_iterate(const struct assoc_array *array,
-				int (*iterator)(const void *object, bool type,
+				int (*iterator)(const void *object,
 						void *iterator_data),
 				void *iterator_data);
 
@@ -333,12 +326,10 @@ There are two functions for accessing an associative array:
 
 	void *assoc_array_find(const struct assoc_array *array,
 			       const struct assoc_array_ops *ops,
-			       const void *index_key,
-			       bool *_type);
+			       const void *index_key);
 
      This walks through the array's internal tree directly to the object
-     specified by the index key.  If the object is present then a pointer to it
-     is returned and the type is stored in *_type.
+     specified by the index key..
 
      This may be used on an array at the same time as the array is being
      modified, provided the RCU read lock is held.
@@ -384,7 +375,7 @@ A node is an array of slots.  Each slot can contain one of four things:
 
  (*) A NULL pointer, indicating that the slot is empty.
 
- (*) A pointer to one of two types of object (leaves).
+ (*) A pointer to an object (a leaf).
 
  (*) A pointer to a node at the next level.
 
diff --git a/include/linux/assoc_array.h b/include/linux/assoc_array.h
index c3c24da..9a193b8 100644
--- a/include/linux/assoc_array.h
+++ b/include/linux/assoc_array.h
@@ -62,19 +62,18 @@ static inline void assoc_array_init(struct assoc_array *array)
 }
 
 extern int assoc_array_iterate(const struct assoc_array *array,
-			       int (*iterator)(const void *object, bool type,
+			       int (*iterator)(const void *object,
 					       void *iterator_data),
 			       void *iterator_data);
 extern void *assoc_array_find(const struct assoc_array *array,
 			      const struct assoc_array_ops *ops,
-			      const void *index_key,
-			      bool *_type);
+			      const void *index_key);
 extern void assoc_array_destroy(struct assoc_array *array,
 				const struct assoc_array_ops *ops);
 extern struct assoc_array_edit *assoc_array_insert(struct assoc_array *array,
 						   const struct assoc_array_ops *ops,
 						   const void *index_key,
-						   void *object, bool type);
+						   void *object);
 extern void assoc_array_insert_set_object(struct assoc_array_edit *edit,
 					  void *object);
 extern struct assoc_array_edit *assoc_array_delete(struct assoc_array *array,
@@ -86,8 +85,7 @@ extern void assoc_array_apply_edit(struct assoc_array_edit *edit);
 extern void assoc_array_cancel_edit(struct assoc_array_edit *edit);
 extern int assoc_array_gc(struct assoc_array *array,
 			  const struct assoc_array_ops *ops,
-			  bool (*iterator)(void *object, bool type,
-					   void *iterator_data),
+			  bool (*iterator)(void *object, void *iterator_data),
 			  void *iterator_data);
 
 #endif /* CONFIG_ASSOCIATIVE_ARRAY */
diff --git a/include/linux/assoc_array_priv.h b/include/linux/assoc_array_priv.h
index 2890afc..711275e 100644
--- a/include/linux/assoc_array_priv.h
+++ b/include/linux/assoc_array_priv.h
@@ -38,11 +38,11 @@ struct assoc_array_ptr;
  *
  *	(1) Nothing (NULL).
  *
- *	(2) A leaf object (pointer types 0 and 1).
+ *	(2) A leaf object (pointer types 0).
  *
- *	(3) A next-level node (pointer type 2).
+ *	(3) A next-level node (pointer type 1, subtype 0).
  *
- *	(4) A shortcut (pointer type 3).
+ *	(4) A shortcut (pointer type 1, subtype 1).
  *
  * The tree is optimised for search-by-ID, but permits reasonable iteration
  * also.
@@ -102,57 +102,80 @@ struct assoc_array_edit {
 };
 
 /*
- * Internal tree member pointer type annotations and translation functions.
+ * Internal tree member pointers are marked in the bottom one or two bits to
+ * indicate what type they are so that we don't have to look behind every
+ * pointer to see what it points to.
+ *
+ * We provide functions to test type annotations and to create and translate
+ * the annotated pointers.
  */
-enum assoc_array_ptr_type {
-	ASSOC_ARRAY_PTR_LEAF0	= 0x0UL,  /* The pointer points to a type 0 object */
-	ASSOC_ARRAY_PTR_LEAF1	= 0x1UL,  /* The pointer points to a type 1 object */
-	ASSOC_ARRAY_PTR_NODE	= 0x2UL,  /* The pointer points to a node */
-	ASSOC_ARRAY_PTR_SHORTCUT = 0x3UL, /* The pointer points to a shortcut */
-};
-
-#define ASSOC_ARRAY_PTR_TYPE_MASK 0x3UL	/* The bottom bits of the pointer hold type data */
-#define ASSOC_ARRAY_PTR_META	  0x2UL	/* Node and shortcut pointers are metadata */
+#define ASSOC_ARRAY_PTR_TYPE_MASK 0x1UL
+#define ASSOC_ARRAY_PTR_LEAF_TYPE 0x0UL	/* Points to leaf (or nowhere) */
+#define ASSOC_ARRAY_PTR_META_TYPE 0x1UL	/* Points to node or shortcut */
+#define ASSOC_ARRAY_PTR_SUBTYPE_MASK	0x2UL
+#define ASSOC_ARRAY_PTR_NODE_SUBTYPE	0x0UL
+#define ASSOC_ARRAY_PTR_SHORTCUT_SUBTYPE 0x2UL
 
-static inline
-enum assoc_array_ptr_type assoc_array_ptr_type(const struct assoc_array_ptr *x)
+static inline bool assoc_array_ptr_is_meta(const struct assoc_array_ptr *x)
 {
 	return (unsigned long)x & ASSOC_ARRAY_PTR_TYPE_MASK;
 }
-#define assoc_array_ptr_is_leaf0(X)	(assoc_array_ptr_type((X)) == ASSOC_ARRAY_PTR_LEAF0)
-#define assoc_array_ptr_is_leaf1(X)	(assoc_array_ptr_type((X)) == ASSOC_ARRAY_PTR_LEAF1)
-#define assoc_array_ptr_is_node(X)	(assoc_array_ptr_type((X)) == ASSOC_ARRAY_PTR_NODE)
-#define assoc_array_ptr_is_shortcut(X)	(assoc_array_ptr_type((X)) == ASSOC_ARRAY_PTR_SHORTCUT)
-#define assoc_array_ptr_is_leaf(X)	(assoc_array_ptr_type((X)) <  ASSOC_ARRAY_PTR_META)
-#define assoc_array_ptr_is_meta(X)	(assoc_array_ptr_type((X)) >= ASSOC_ARRAY_PTR_META)
+static inline bool assoc_array_ptr_is_leaf(const struct assoc_array_ptr *x)
+{
+	return !assoc_array_ptr_is_meta(x);
+}
+static inline bool assoc_array_ptr_is_shortcut(const struct assoc_array_ptr *x)
+{
+	return (unsigned long)x & ASSOC_ARRAY_PTR_SUBTYPE_MASK;
+}
+static inline bool assoc_array_ptr_is_node(const struct assoc_array_ptr *x)
+{
+	return !assoc_array_ptr_is_shortcut(x);
+}
 
-static inline unsigned long __assoc_array_ptr_to_x(const struct assoc_array_ptr *x)
+static inline void *assoc_array_ptr_to_leaf(const struct assoc_array_ptr *x)
+{
+	return (void *)((unsigned long)x & ~ASSOC_ARRAY_PTR_TYPE_MASK);
+}
+
+static inline
+unsigned long __assoc_array_ptr_to_meta(const struct assoc_array_ptr *x)
+{
+	return (unsigned long)x &
+		~(ASSOC_ARRAY_PTR_SUBTYPE_MASK | ASSOC_ARRAY_PTR_TYPE_MASK);
+}
+static inline
+struct assoc_array_node *assoc_array_ptr_to_node(const struct assoc_array_ptr *x)
+{
+	return (struct assoc_array_node *)__assoc_array_ptr_to_meta(x);
+}
+static inline
+struct assoc_array_shortcut *assoc_array_ptr_to_shortcut(const struct assoc_array_ptr *x)
 {
-	return (unsigned long)x & ~ASSOC_ARRAY_PTR_TYPE_MASK;
+	return (struct assoc_array_shortcut *)__assoc_array_ptr_to_meta(x);
 }
-#define assoc_array_ptr_to_leaf(X)	((void *)__assoc_array_ptr_to_x((X)))
-#define assoc_array_ptr_to_node(X)	((struct assoc_array_node *)__assoc_array_ptr_to_x((X)))
-#define assoc_array_ptr_to_shortcut(X)	((struct assoc_array_shortcut *)__assoc_array_ptr_to_x((X)))
 
 static inline
-struct assoc_array_ptr *__assoc_array_x_to_ptr(const void *p, enum assoc_array_ptr_type t)
+struct assoc_array_ptr *__assoc_array_x_to_ptr(const void *p, unsigned long t)
 {
 	return (struct assoc_array_ptr *)((unsigned long)p | t);
 }
 static inline
-struct assoc_array_ptr *assoc_array_leaf_to_ptr(const void *p, bool type)
+struct assoc_array_ptr *assoc_array_leaf_to_ptr(const void *p)
 {
-	return __assoc_array_x_to_ptr(p, type ? ASSOC_ARRAY_PTR_LEAF1 : ASSOC_ARRAY_PTR_LEAF0);
+	return __assoc_array_x_to_ptr(p, ASSOC_ARRAY_PTR_LEAF_TYPE);
 }
 static inline
 struct assoc_array_ptr *assoc_array_node_to_ptr(const struct assoc_array_node *p)
 {
-	return __assoc_array_x_to_ptr(p, ASSOC_ARRAY_PTR_NODE);
+	return __assoc_array_x_to_ptr(
+		p, ASSOC_ARRAY_PTR_META_TYPE | ASSOC_ARRAY_PTR_NODE_SUBTYPE);
 }
 static inline
 struct assoc_array_ptr *assoc_array_shortcut_to_ptr(const struct assoc_array_shortcut *p)
 {
-	return __assoc_array_x_to_ptr(p, ASSOC_ARRAY_PTR_SHORTCUT);
+	return __assoc_array_x_to_ptr(
+		p, ASSOC_ARRAY_PTR_META_TYPE | ASSOC_ARRAY_PTR_SHORTCUT_SUBTYPE);
 }
 
 #endif /* CONFIG_ASSOCIATIVE_ARRAY */
diff --git a/lib/assoc_array.c b/lib/assoc_array.c
index e023c05..a095281 100644
--- a/lib/assoc_array.c
+++ b/lib/assoc_array.c
@@ -20,7 +20,7 @@
  */
 static int assoc_array_subtree_iterate(const struct assoc_array_ptr *root,
 				       const struct assoc_array_ptr *stop,
-				       int (*iterator)(const void *leaf, bool type,
+				       int (*iterator)(const void *leaf,
 						       void *iterator_data),
 				       void *iterator_data)
 {
@@ -64,7 +64,6 @@ begin_node:
 
 			/* Invoke the callback */
 			ret = iterator(assoc_array_ptr_to_leaf(ptr),
-				       assoc_array_ptr_type(ptr),
 				       iterator_data);
 			if (ret)
 				return ret;
@@ -79,7 +78,7 @@ begin_node:
 	 * a particular portion of the key space cannot change - and we
 	 * continue at the back pointer + 1.
 	 */
-	if (!(has_meta & ASSOC_ARRAY_PTR_META))
+	if (!(has_meta & ASSOC_ARRAY_PTR_META_TYPE))
 		goto finished_node;
 	slot = 0;
 
@@ -142,7 +141,7 @@ finished_node:
  * modification is possible.
  */
 int assoc_array_iterate(const struct assoc_array *array,
-			int (*iterator)(const void *object, bool type,
+			int (*iterator)(const void *object,
 					void *iterator_data),
 			void *iterator_data)
 {
@@ -221,8 +220,8 @@ consider_node:
 	slot &= ASSOC_ARRAY_FAN_MASK;
 	ptr = ACCESS_ONCE(node->slots[slot]);
 
-	pr_devel("consider slot %x [ix=%d type=%u]\n",
-		 slot, level, assoc_array_ptr_type(ptr));
+	pr_devel("consider slot %x [ix=%d type=%lu]\n",
+		 slot, level, (unsigned long)ptr & 3);
 
 	if (!assoc_array_ptr_is_meta(ptr)) {
 		/* The node doesn't have a node/shortcut pointer in the slot
@@ -308,7 +307,6 @@ follow_shortcut:
  * @array: The associative array to search.
  * @ops: The operations to use.
  * @index_key: The key to the object.
- * @_type: Where the object type will be returned (if found).
  *
  * Find an object in an associative array by walking through the internal tree
  * to the node that should contain the object and then searching the leaves
@@ -318,8 +316,7 @@ follow_shortcut:
  */
 void *assoc_array_find(const struct assoc_array *array,
 		       const struct assoc_array_ops *ops,
-		       const void *index_key,
-		       bool *_type)
+		       const void *index_key)
 {
 	struct assoc_array_walk_result result;
 	const struct assoc_array_node *node;
@@ -346,10 +343,8 @@ void *assoc_array_find(const struct assoc_array *array,
 			 */
 			leaf = assoc_array_ptr_to_leaf(ptr);
 			smp_read_barrier_depends();
-			if (ops->compare_object(leaf, index_key)) {
-				*_type = assoc_array_ptr_type(ptr);
+			if (ops->compare_object(leaf, index_key))
 				return (void *)leaf;
-			}
 		}
 	}
 
@@ -527,8 +522,7 @@ static bool assoc_array_insert_into_terminal_node(struct assoc_array_edit *edit,
 			free_slot = i;
 			continue;
 		}
-		if (assoc_array_ptr_type(ptr) == assoc_array_ptr_type(edit->leaf) &&
-		    ops->compare_object(assoc_array_ptr_to_leaf(ptr), index_key)) {
+		if (ops->compare_object(assoc_array_ptr_to_leaf(ptr), index_key)) {
 			pr_devel("replace in slot %d\n", i);
 			edit->leaf_p = &node->slots[i];
 			edit->dead_leaf = node->slots[i];
@@ -697,17 +691,13 @@ found_slot_for_multiple_occupancy:
 	for (i = 0; i < ASSOC_ARRAY_FAN_OUT; i++) {
 		if (edit->segment_cache[i] == 0xff) {
 			ptr = node->slots[i];
-			switch (assoc_array_ptr_type(ptr)) {
-			case ASSOC_ARRAY_PTR_NODE:
+			BUG_ON(assoc_array_ptr_is_leaf(ptr));
+			if (assoc_array_ptr_is_node(ptr)) {
 				side = assoc_array_ptr_to_node(ptr);
 				edit->set_backpointers[i] = &side->back_pointer;
-				break;
-			case ASSOC_ARRAY_PTR_SHORTCUT:
+			} else {
 				shortcut = assoc_array_ptr_to_shortcut(ptr);
 				edit->set_backpointers[i] = &shortcut->back_pointer;
-				break;
-			default:
-				BUG();
 			}
 		}
 	}
@@ -986,7 +976,6 @@ static bool assoc_array_insert_mid_shortcut(struct assoc_array_edit *edit,
  * @ops: The operations to use.
  * @index_key: The key to insert at.
  * @object: The object to insert.
- * @type: The type of the object.
  *
  * Precalculate and preallocate a script for the insertion or replacement of an
  * object in an associative array.  This results in an edit script that can
@@ -1003,24 +992,26 @@ static bool assoc_array_insert_mid_shortcut(struct assoc_array_edit *edit,
 struct assoc_array_edit *assoc_array_insert(struct assoc_array *array,
 					    const struct assoc_array_ops *ops,
 					    const void *index_key,
-					    void *object, bool type)
+					    void *object)
 {
 	struct assoc_array_walk_result result;
 	struct assoc_array_edit *edit;
 
 	pr_devel("-->%s()\n", __func__);
 
-	/* The leaf pointer we're given must not have the bottom two bits set
-	 * as we use those for type-marking the pointer.
+	/* The leaf pointer we're given must not have the bottom bit set as we
+	 * use those for type-marking the pointer.  NULL pointers are also not
+	 * allowed as they indicate an empty slot but we have to allow them
+	 * here as they can be updated later.
 	 */
-	BUG_ON(assoc_array_ptr_type(object) != 0);
+	BUG_ON(assoc_array_ptr_is_meta(object));
 
 	edit = kzalloc(sizeof(struct assoc_array_edit), GFP_KERNEL);
 	if (!edit)
 		return ERR_PTR(-ENOMEM);
 	edit->array = array;
 	edit->ops = ops;
-	edit->leaf = assoc_array_leaf_to_ptr(object, type);
+	edit->leaf = assoc_array_leaf_to_ptr(object);
 	edit->adjust_count_by = 1;
 
 	switch (assoc_array_walk(array, ops, index_key, &result)) {
@@ -1058,12 +1049,17 @@ enomem:
 
 /**
  * assoc_array_insert_set_object - Set the new object pointer in an edit script
+ * @edit: The edit script to modify.
+ * @object: The object pointer to set.
+ *
+ * Change the object to be inserted in an edit script.  The object pointed to
+ * by the old object is not freed.  This must be done prior to applying the
+ * script.
  */
 void assoc_array_insert_set_object(struct assoc_array_edit *edit, void *object)
 {
-	bool type = assoc_array_ptr_is_leaf1(edit->leaf);
-
-	edit->leaf = assoc_array_leaf_to_ptr(object, type);
+	BUG_ON(!object);
+	edit->leaf = assoc_array_leaf_to_ptr(object);
 }
 
 struct assoc_array_delete_collapse_context {
@@ -1075,7 +1071,7 @@ struct assoc_array_delete_collapse_context {
 /*
  * Subtree collapse to node iterator.
  */
-static int assoc_array_delete_collapse_iterator(const void *leaf, bool type,
+static int assoc_array_delete_collapse_iterator(const void *leaf,
 						void *iterator_data)
 {
 	struct assoc_array_delete_collapse_context *collapse = iterator_data;
@@ -1085,8 +1081,7 @@ static int assoc_array_delete_collapse_iterator(const void *leaf, bool type,
 
 	BUG_ON(collapse->slot >= ASSOC_ARRAY_FAN_OUT);
 
-	collapse->node->slots[collapse->slot++] =
-		assoc_array_leaf_to_ptr(leaf, type);
+	collapse->node->slots[collapse->slot++] = assoc_array_leaf_to_ptr(leaf);
 	return 0;
 }
 
@@ -1261,6 +1256,8 @@ found_leaf:
 
 			if (!node->back_pointer) {
 				edit->set[1].ptr = &array->root;
+			} else if (assoc_array_ptr_is_leaf(node->back_pointer)) {
+				BUG();
 			} else if (assoc_array_ptr_is_node(node->back_pointer)) {
 				struct assoc_array_node *p =
 					assoc_array_ptr_to_node(node->back_pointer);
@@ -1269,8 +1266,6 @@ found_leaf:
 				struct assoc_array_shortcut *s =
 					assoc_array_ptr_to_shortcut(node->back_pointer);
 				edit->set[1].ptr = &s->next_node;
-			} else {
-				BUG();
 			}
 			edit->set[1].to = assoc_array_node_to_ptr(new_n0);
 			edit->excised_subtree = assoc_array_node_to_ptr(node);
@@ -1345,16 +1340,15 @@ static void assoc_array_rcu_cleanup(struct rcu_head *head)
 			kfree(assoc_array_ptr_to_node(edit->excised_meta[i]));
 
 	if (edit->excised_subtree) {
+		BUG_ON(assoc_array_ptr_is_leaf(edit->excised_subtree));
 		if (assoc_array_ptr_is_node(edit->excised_subtree)) {
 			struct assoc_array_node *n =
 				assoc_array_ptr_to_node(edit->excised_subtree);
 			n->back_pointer = NULL;
-		} else if (assoc_array_ptr_is_shortcut(edit->excised_subtree)) {
+		} else {
 			struct assoc_array_shortcut *s =
 				assoc_array_ptr_to_shortcut(edit->excised_subtree);
 			s->back_pointer = NULL;
-		} else {
-			BUG();
 		}
 		assoc_array_destroy_subtree(edit->excised_subtree,
 					    edit->ops_for_excised_subtree);
@@ -1450,10 +1444,12 @@ void assoc_array_cancel_edit(struct assoc_array_edit *edit)
 	/* Clean up after an out of memory error */
 	for (i = 0; i < ARRAY_SIZE(edit->new_meta); i++) {
 		ptr = edit->new_meta[i];
-		if (assoc_array_ptr_is_node(ptr))
-			kfree(assoc_array_ptr_to_node(ptr));
-		else
-			kfree(assoc_array_ptr_to_shortcut(ptr));
+		if (ptr) {
+			if (assoc_array_ptr_is_node(ptr))
+				kfree(assoc_array_ptr_to_node(ptr));
+			else
+				kfree(assoc_array_ptr_to_shortcut(ptr));
+		}
 	}
 	kfree(edit);
 }
@@ -1484,8 +1480,7 @@ void assoc_array_cancel_edit(struct assoc_array_edit *edit)
  */
 int assoc_array_gc(struct assoc_array *array,
 		   const struct assoc_array_ops *ops,
-		   bool (*iterator)(void *object, bool type,
-				    void *iterator_data),
+		   bool (*iterator)(void *object, void *iterator_data),
 		   void *iterator_data)
 {
 	struct assoc_array_shortcut *shortcut, *new_s;
@@ -1557,7 +1552,6 @@ continue_node:
 
 		if (assoc_array_ptr_is_leaf(ptr)) {
 			if (iterator(assoc_array_ptr_to_leaf(ptr),
-				     assoc_array_ptr_is_leaf1(ptr),
 				     iterator_data))
 				/* The iterator will have done any reference
 				 * counting on the object for us.
@@ -1650,7 +1644,8 @@ continue_node:
 			if ((ptr = new_n->slots[slot]))
 				break;
 
-		if (assoc_array_ptr_is_shortcut(ptr)) {
+		if (assoc_array_ptr_is_meta(ptr) &&
+		    assoc_array_ptr_is_shortcut(ptr)) {
 			pr_devel("excise node %p with 1 shortcut\n", new_n);
 			new_s = assoc_array_ptr_to_shortcut(ptr);
 			new_parent = new_n->back_pointer;
diff --git a/security/keys/gc.c b/security/keys/gc.c
index 5af99b8..627bdd06 100644
--- a/security/keys/gc.c
+++ b/security/keys/gc.c
@@ -130,7 +130,7 @@ void key_gc_keytype(struct key_type *ktype)
 	kleave("");
 }
 
-static int key_gc_keyring_func(const void *object, bool type, void *iterator_data)
+static int key_gc_keyring_func(const void *object, void *iterator_data)
 {
 	const struct key *key = object;
 	time_t *limit = iterator_data;
diff --git a/security/keys/internal.h b/security/keys/internal.h
index 2a8d624..581c6f6 100644
--- a/security/keys/internal.h
+++ b/security/keys/internal.h
@@ -122,7 +122,7 @@ struct keyring_search_context {
 #define KEYRING_SEARCH_NO_CHECK_PERM	0x0010	/* Don't check permissions */
 #define KEYRING_SEARCH_DETECT_TOO_DEEP	0x0020	/* Give an error on excessive depth */
 
-	int (*iterator)(const void *object, bool type, void *iterator_data);
+	int (*iterator)(const void *object, void *iterator_data);
 
 	/* Internal stuff */
 	int			skipped_ret;
diff --git a/security/keys/keyring.c b/security/keys/keyring.c
index 8b7ec48..8ce680d 100644
--- a/security/keys/keyring.c
+++ b/security/keys/keyring.c
@@ -33,8 +33,27 @@
  */
 #define KEYRING_NAME_HASH_SIZE	(1 << 5)
 
-#define assoc_array_ptr_is_key(X)	(assoc_array_ptr_is_leaf0(X))
-#define assoc_array_ptr_is_keyring(X)	(assoc_array_ptr_is_leaf1(X))
+/*
+ * We mark pointers we pass to the associative array with bit 1 set if
+ * they're keyrings and clear otherwise.
+ */
+#define KEYRING_PTR_SUBTYPE	0x2UL
+
+static inline bool keyring_ptr_is_keyring(const struct assoc_array_ptr *x)
+{
+	return (unsigned long)x & KEYRING_PTR_SUBTYPE;
+}
+static inline struct key *keyring_ptr_to_key(const struct assoc_array_ptr *x)
+{
+	void *object = assoc_array_ptr_to_leaf(x);
+	return (struct key *)((unsigned long)object & ~KEYRING_PTR_SUBTYPE);
+}
+static inline void *keyring_key_to_ptr(struct key *key)
+{
+	if (key->type == &key_type_keyring)
+		return (void *)((unsigned long)key | KEYRING_PTR_SUBTYPE);
+	return key;
+}
 
 static struct list_head	keyring_name_hash[KEYRING_NAME_HASH_SIZE];
 static DEFINE_RWLOCK(keyring_name_lock);
@@ -239,14 +258,14 @@ static unsigned long keyring_get_key_chunk(const void *data, int level)
 
 static unsigned long keyring_get_object_key_chunk(const void *object, int level)
 {
-	const struct key *key = object;
+	const struct key *key = keyring_ptr_to_key(object);
 	return keyring_get_key_chunk(&key->index_key, level);
 }
 
 static bool keyring_compare_object(const void *object, const void *data)
 {
 	const struct keyring_index_key *index_key = data;
-	const struct key *key = object;
+	const struct key *key = keyring_ptr_to_key(object);
 
 	return key->index_key.type == index_key->type &&
 		key->index_key.desc_len == index_key->desc_len &&
@@ -260,7 +279,8 @@ static bool keyring_compare_object(const void *object, const void *data)
  */
 static int keyring_diff_objects(const void *_a, const void *_b)
 {
-	const struct key *key_a = _a, *key_b = _b;
+	const struct key *key_a = keyring_ptr_to_key(_a);
+	const struct key *key_b = keyring_ptr_to_key(_b);
 	const struct keyring_index_key *a = &key_a->index_key;
 	const struct keyring_index_key *b = &key_b->index_key;
 	unsigned long seg_a, seg_b;
@@ -319,6 +339,14 @@ differ:
 }
 
 /*
+ * Free an object after stripping the keyring flag off of the pointer.
+ */
+static void keyring_free_object(void *object)
+{
+	key_put(keyring_ptr_to_key(object));
+}
+
+/*
  * Operations for keyring management by the index-tree routines.
  */
 static const struct assoc_array_ops keyring_assoc_array_ops = {
@@ -326,7 +354,7 @@ static const struct assoc_array_ops keyring_assoc_array_ops = {
 	.get_object_key_chunk	= keyring_get_object_key_chunk,
 	.compare_object		= keyring_compare_object,
 	.diff_objects		= keyring_diff_objects,
-	.free_object		= (void (*)(void *))key_put,
+	.free_object		= keyring_free_object,
 };
 
 /*
@@ -377,10 +405,10 @@ struct keyring_read_iterator_context {
 	key_serial_t __user	*buffer;
 };
 
-static int keyring_read_iterator(const void *object, bool type, void *data)
+static int keyring_read_iterator(const void *object, void *data)
 {
 	struct keyring_read_iterator_context *ctx = data;
-	const struct key *key = object;
+	const struct key *key = keyring_ptr_to_key(object);
 	int ret;
 
 	kenter("{%s,%d},,{%zu/%zu}",
@@ -469,11 +497,10 @@ EXPORT_SYMBOL(keyring_alloc);
 /*
  * Iteration function to consider each key found.
  */
-static int keyring_search_iterator(const void *object, bool type,
-				   void *iterator_data)
+static int keyring_search_iterator(const void *object, void *iterator_data)
 {
 	struct keyring_search_context *ctx = iterator_data;
-	const struct key *key = object;
+	const struct key *key = keyring_ptr_to_key(object);
 	unsigned long kflags = key->flags;
 
 	kenter("{%d}", key->serial);
@@ -542,13 +569,12 @@ static int search_keyring(struct key *keyring, struct keyring_search_context *ct
 {
 	if ((ctx->flags & KEYRING_SEARCH_LOOKUP_TYPE) ==
 	    KEYRING_SEARCH_LOOKUP_DIRECT) {
-		struct key *key;
-		bool type;
+		const void *object;
 
-		key = assoc_array_find(&keyring->keys,
-				       &keyring_assoc_array_ops,
-				       &ctx->index_key, &type);
-		return key ? ctx->iterator(key, type, ctx) : 0;
+		object = assoc_array_find(&keyring->keys,
+					  &keyring_assoc_array_ops,
+					  &ctx->index_key);
+		return object ? ctx->iterator(object, ctx) : 0;
 	}
 	return assoc_array_iterate(&keyring->keys, ctx->iterator, ctx);
 }
@@ -587,7 +613,7 @@ static bool search_nested_keyrings(struct key *keyring,
 	    keyring_compare_object(keyring, &ctx->index_key)) {
 		ctx->skipped_ret = 2;
 		ctx->flags |= KEYRING_SEARCH_DO_STATE_CHECK;
-		switch (ctx->iterator(keyring, true, ctx)) {
+		switch (ctx->iterator(keyring_key_to_ptr(keyring), ctx)) {
 		case 1:
 			goto found;
 		case 2:
@@ -673,10 +699,10 @@ ascend_to_node:
 		if (assoc_array_ptr_is_meta(ptr) && node->back_pointer)
 			goto descend_to_node;
 
-		if (!assoc_array_ptr_is_keyring(ptr))
+		if (!keyring_ptr_is_keyring(ptr))
 			continue;
 
-		key = assoc_array_ptr_to_leaf(ptr);
+		key = keyring_ptr_to_key(ptr);
 
 		if (sp >= KEYRING_SEARCH_MAX_DEPTH) {
 			if (ctx->flags & KEYRING_SEARCH_DETECT_TOO_DEEP) {
@@ -709,7 +735,7 @@ ascend_to_node:
 	ptr = ACCESS_ONCE(node->back_pointer);
 	slot = node->parent_slot;
 
-	if (assoc_array_ptr_is_shortcut(ptr)) {
+	if (ptr && assoc_array_ptr_is_shortcut(ptr)) {
 		shortcut = assoc_array_ptr_to_shortcut(ptr);
 		smp_read_barrier_depends();
 		ptr = ACCESS_ONCE(shortcut->back_pointer);
@@ -872,23 +898,24 @@ key_ref_t find_key_to_update(key_ref_t keyring_ref,
 			     const struct keyring_index_key *index_key)
 {
 	struct key *keyring, *key;
-	bool type;
+	const void *object;
 
 	keyring = key_ref_to_ptr(keyring_ref);
 
 	kenter("{%d},{%s,%s}",
 	       keyring->serial, index_key->type->name, index_key->description);
 
-	key = assoc_array_find(&keyring->keys, &keyring_assoc_array_ops,
-			       index_key, &type);
+	object = assoc_array_find(&keyring->keys, &keyring_assoc_array_ops,
+				  index_key);
 
-	if (key)
+	if (object)
 		goto found;
 
 	kleave(" = NULL");
 	return NULL;
 
 found:
+	key = keyring_ptr_to_key(object);
 	if (key->flags & ((1 << KEY_FLAG_INVALIDATED) |
 			  (1 << KEY_FLAG_REVOKED))) {
 		kleave(" = NULL [x]");
@@ -959,11 +986,11 @@ out:
 	return keyring;
 }
 
-static int keyring_detect_cycle_iterator(const void *object, bool type,
+static int keyring_detect_cycle_iterator(const void *object,
 					 void *iterator_data)
 {
 	struct keyring_search_context *ctx = iterator_data;
-	const struct key *key = object;
+	const struct key *key = keyring_ptr_to_key(object);
 
 	kenter("{%d}", key->serial);
 
@@ -1038,9 +1065,10 @@ int __key_link_begin(struct key *keyring,
 	/* Create an edit script that will insert/replace the key in the
 	 * keyring tree.
 	 */
-	edit = assoc_array_insert(&keyring->keys, &keyring_assoc_array_ops,
+	edit = assoc_array_insert(&keyring->keys,
+				  &keyring_assoc_array_ops,
 				  index_key,
-				  NULL, index_key->type == &key_type_keyring);
+				  NULL);
 	if (IS_ERR(edit)) {
 		ret = PTR_ERR(edit);
 		goto error_quota;
@@ -1089,7 +1117,7 @@ int __key_link_check_live_key(struct key *keyring, struct key *key)
 void __key_link(struct key *key, struct assoc_array_edit **_edit)
 {
 	__key_get(key);
-	assoc_array_insert_set_object(*_edit, key);
+	assoc_array_insert_set_object(*_edit, keyring_key_to_ptr(key));
 	assoc_array_apply_edit(*_edit);
 	*_edit = NULL;
 }
@@ -1262,9 +1290,9 @@ static void keyring_revoke(struct key *keyring)
 	}
 }
 
-static bool gc_iterator(void *object, bool type, void *iterator_data)
+static bool gc_iterator(void *object, void *iterator_data)
 {
-	struct key *key = object;
+	struct key *key = keyring_ptr_to_key(object);
 	time_t *limit = iterator_data;
 
 	if (key_is_dead(key, *limit))
