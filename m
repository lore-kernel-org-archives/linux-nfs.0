Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:25726 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756920Ab2BHLEG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Feb 2012 06:04:06 -0500
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 7/9] KEYS: Permit in-place link replacement in keyring list
To: steved@redhat.com, jmorris@namei.org
Cc: keyrings@linux-nfs.org, linux-nfs@vger.kernel.org,
        linux-security-module@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Wed, 08 Feb 2012 11:04:00 +0000
Message-ID: <20120208110400.4050.11565.stgit@warthog.procyon.org.uk>
In-Reply-To: <20120208110254.4050.8856.stgit@warthog.procyon.org.uk>
References: <20120208110254.4050.8856.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make use of the previous patch that makes the garbage collector perform RCU
synchronisation before destroying defunct keys.  Key pointers can now be
replaced in-place without creating a new keyring payload and replacing the
whole thing as the discarded keys will not be destroyed until all currently
held RCU read locks are released.

If the keyring payload space needs to be expanded or contracted, then a
replacement will still need allocating, and the original will still have to be
freed by RCU.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/keys/keyring-type.h |    2 -
 security/keys/gc.c          |    2 -
 security/keys/keyring.c     |   95 +++++++++++++++++++++++++------------------
 3 files changed, 58 insertions(+), 41 deletions(-)

diff --git a/include/keys/keyring-type.h b/include/keys/keyring-type.h
index 843f872..cf49159 100644
--- a/include/keys/keyring-type.h
+++ b/include/keys/keyring-type.h
@@ -24,7 +24,7 @@ struct keyring_list {
 	unsigned short	maxkeys;	/* max keys this list can hold */
 	unsigned short	nkeys;		/* number of keys currently held */
 	unsigned short	delkey;		/* key to be unlinked by RCU */
-	struct key	*keys[0];
+	struct key __rcu *keys[0];
 };
 
 
diff --git a/security/keys/gc.c b/security/keys/gc.c
index 27610bf..adddaa2 100644
--- a/security/keys/gc.c
+++ b/security/keys/gc.c
@@ -148,7 +148,7 @@ static void key_gc_keyring(struct key *keyring, time_t limit)
 	loop = klist->nkeys;
 	smp_rmb();
 	for (loop--; loop >= 0; loop--) {
-		key = klist->keys[loop];
+		key = rcu_dereference(klist->keys[loop]);
 		if (test_bit(KEY_FLAG_DEAD, &key->flags) ||
 		    (key->expiry > 0 && key->expiry <= limit))
 			goto do_gc;
diff --git a/security/keys/keyring.c b/security/keys/keyring.c
index d605f75..459b3cc 100644
--- a/security/keys/keyring.c
+++ b/security/keys/keyring.c
@@ -25,6 +25,11 @@
 		(keyring)->payload.subscriptions,			\
 		rwsem_is_locked((struct rw_semaphore *)&(keyring)->sem)))
 
+#define rcu_deref_link_locked(klist, index, keyring)			\
+	(rcu_dereference_protected(					\
+		(klist)->keys[index],					\
+		rwsem_is_locked((struct rw_semaphore *)&(keyring)->sem)))
+
 #define KEY_LINK_FIXQUOTA 1UL
 
 /*
@@ -138,6 +143,11 @@ static int keyring_match(const struct key *keyring, const void *description)
 /*
  * Clean up a keyring when it is destroyed.  Unpublish its name if it had one
  * and dispose of its data.
+ *
+ * The garbage collector detects the final key_put(), removes the keyring from
+ * the serial number tree and then does RCU synchronisation before coming here,
+ * so we shouldn't need to worry about code poking around here with the RCU
+ * readlock held by this time.
  */
 static void keyring_destroy(struct key *keyring)
 {
@@ -154,11 +164,10 @@ static void keyring_destroy(struct key *keyring)
 		write_unlock(&keyring_name_lock);
 	}
 
-	klist = rcu_dereference_check(keyring->payload.subscriptions,
-				      atomic_read(&keyring->usage) == 0);
+	klist = rcu_access_pointer(keyring->payload.subscriptions);
 	if (klist) {
 		for (loop = klist->nkeys - 1; loop >= 0; loop--)
-			key_put(klist->keys[loop]);
+			key_put(rcu_access_pointer(klist->keys[loop]));
 		kfree(klist);
 	}
 }
@@ -214,7 +223,8 @@ static long keyring_read(const struct key *keyring,
 			ret = -EFAULT;
 
 			for (loop = 0; loop < klist->nkeys; loop++) {
-				key = klist->keys[loop];
+				key = rcu_deref_link_locked(klist, loop,
+							    keyring);
 
 				tmp = sizeof(key_serial_t);
 				if (tmp > buflen)
@@ -383,7 +393,7 @@ descend:
 	nkeys = keylist->nkeys;
 	smp_rmb();
 	for (kix = 0; kix < nkeys; kix++) {
-		key = keylist->keys[kix];
+		key = rcu_dereference(keylist->keys[kix]);
 		kflags = key->flags;
 
 		/* ignore keys not of this type */
@@ -426,7 +436,7 @@ ascend:
 	nkeys = keylist->nkeys;
 	smp_rmb();
 	for (; kix < nkeys; kix++) {
-		key = keylist->keys[kix];
+		key = rcu_dereference(keylist->keys[kix]);
 		if (key->type != &key_type_keyring)
 			continue;
 
@@ -531,8 +541,7 @@ key_ref_t __keyring_search_one(key_ref_t keyring_ref,
 		nkeys = klist->nkeys;
 		smp_rmb();
 		for (loop = 0; loop < nkeys ; loop++) {
-			key = klist->keys[loop];
-
+			key = rcu_dereference(klist->keys[loop]);
 			if (key->type == ktype &&
 			    (!key->type->match ||
 			     key->type->match(key, description)) &&
@@ -654,7 +663,7 @@ ascend:
 	nkeys = keylist->nkeys;
 	smp_rmb();
 	for (; kix < nkeys; kix++) {
-		key = keylist->keys[kix];
+		key = rcu_dereference(keylist->keys[kix]);
 
 		if (key == A)
 			goto cycle_detected;
@@ -711,7 +720,7 @@ static void keyring_unlink_rcu_disposal(struct rcu_head *rcu)
 		container_of(rcu, struct keyring_list, rcu);
 
 	if (klist->delkey != USHRT_MAX)
-		key_put(klist->keys[klist->delkey]);
+		key_put(rcu_access_pointer(klist->keys[klist->delkey]));
 	kfree(klist);
 }
 
@@ -749,24 +758,16 @@ int __key_link_begin(struct key *keyring, const struct key_type *type,
 	/* see if there's a matching key we can displace */
 	if (klist && klist->nkeys > 0) {
 		for (loop = klist->nkeys - 1; loop >= 0; loop--) {
-			if (klist->keys[loop]->type == type &&
-			    strcmp(klist->keys[loop]->description,
-				   description) == 0
-			    ) {
-				/* found a match - we'll replace this one with
-				 * the new key */
-				size = sizeof(struct key *) * klist->maxkeys;
-				size += sizeof(*klist);
-				BUG_ON(size > PAGE_SIZE);
-
-				ret = -ENOMEM;
-				nklist = kmemdup(klist, size, GFP_KERNEL);
-				if (!nklist)
-					goto error_sem;
-
-				/* note replacement slot */
-				klist->delkey = nklist->delkey = loop;
-				prealloc = (unsigned long)nklist;
+			struct key *key = rcu_deref_link_locked(klist, loop,
+								keyring);
+			if (key->type == type &&
+			    strcmp(key->description, description) == 0) {
+				/* Found a match - we'll replace the link with
+				 * one to the new key.  We record the slot
+				 * position.
+				 */
+				klist->delkey = loop;
+				prealloc = 0;
 				goto done;
 			}
 		}
@@ -780,7 +781,7 @@ int __key_link_begin(struct key *keyring, const struct key_type *type,
 
 	if (klist && klist->nkeys < klist->maxkeys) {
 		/* there's sufficient slack space to append directly */
-		nklist = NULL;
+		klist->delkey = klist->nkeys;
 		prealloc = KEY_LINK_FIXQUOTA;
 	} else {
 		/* grow the key list */
@@ -813,10 +814,10 @@ int __key_link_begin(struct key *keyring, const struct key_type *type,
 		}
 
 		/* add the key into the new space */
-		nklist->keys[nklist->delkey] = NULL;
+		RCU_INIT_POINTER(nklist->keys[nklist->delkey], NULL);
+		prealloc = (unsigned long)nklist | KEY_LINK_FIXQUOTA;
 	}
 
-	prealloc = (unsigned long)nklist | KEY_LINK_FIXQUOTA;
 done:
 	*_prealloc = prealloc;
 	kleave(" = 0");
@@ -862,6 +863,7 @@ void __key_link(struct key *keyring, struct key *key,
 		unsigned long *_prealloc)
 {
 	struct keyring_list *klist, *nklist;
+	struct key *discard;
 
 	nklist = (struct keyring_list *)(*_prealloc & ~KEY_LINK_FIXQUOTA);
 	*_prealloc = 0;
@@ -875,10 +877,10 @@ void __key_link(struct key *keyring, struct key *key,
 	/* there's a matching key we can displace or an empty slot in a newly
 	 * allocated list we can fill */
 	if (nklist) {
-		kdebug("replace %hu/%hu/%hu",
+		kdebug("reissue %hu/%hu/%hu",
 		       nklist->delkey, nklist->nkeys, nklist->maxkeys);
 
-		nklist->keys[nklist->delkey] = key;
+		RCU_INIT_POINTER(nklist->keys[nklist->delkey], key);
 
 		rcu_assign_pointer(keyring->payload.subscriptions, nklist);
 
@@ -889,9 +891,23 @@ void __key_link(struct key *keyring, struct key *key,
 			       klist->delkey, klist->nkeys, klist->maxkeys);
 			call_rcu(&klist->rcu, keyring_unlink_rcu_disposal);
 		}
+	} else if (klist->delkey < klist->nkeys) {
+		kdebug("replace %hu/%hu/%hu",
+		       klist->delkey, klist->nkeys, klist->maxkeys);
+
+		discard = rcu_dereference_protected(
+			klist->keys[klist->delkey],
+			rwsem_is_locked(&keyring->sem));
+		rcu_assign_pointer(klist->keys[klist->delkey], key);
+		/* The garbage collector will take care of RCU
+		 * synchronisation */
+		key_put(discard);
 	} else {
 		/* there's sufficient slack space to append directly */
-		klist->keys[klist->nkeys] = key;
+		kdebug("append %hu/%hu/%hu",
+		       klist->delkey, klist->nkeys, klist->maxkeys);
+
+		RCU_INIT_POINTER(klist->keys[klist->delkey], key);
 		smp_wmb();
 		klist->nkeys++;
 	}
@@ -998,7 +1014,7 @@ int key_unlink(struct key *keyring, struct key *key)
 	if (klist) {
 		/* search the keyring for the key */
 		for (loop = 0; loop < klist->nkeys; loop++)
-			if (klist->keys[loop] == key)
+			if (rcu_access_pointer(klist->keys[loop]) == key)
 				goto key_is_present;
 	}
 
@@ -1061,7 +1077,7 @@ static void keyring_clear_rcu_disposal(struct rcu_head *rcu)
 	klist = container_of(rcu, struct keyring_list, rcu);
 
 	for (loop = klist->nkeys - 1; loop >= 0; loop--)
-		key_put(klist->keys[loop]);
+		key_put(rcu_access_pointer(klist->keys[loop]));
 
 	kfree(klist);
 }
@@ -1161,7 +1177,8 @@ void keyring_gc(struct key *keyring, time_t limit)
 	/* work out how many subscriptions we're keeping */
 	keep = 0;
 	for (loop = klist->nkeys - 1; loop >= 0; loop--)
-		if (!key_is_dead(klist->keys[loop], limit))
+		if (!key_is_dead(rcu_deref_link_locked(klist, loop, keyring),
+				 limit))
 			keep++;
 
 	if (keep == klist->nkeys)
@@ -1182,11 +1199,11 @@ void keyring_gc(struct key *keyring, time_t limit)
 	 */
 	keep = 0;
 	for (loop = klist->nkeys - 1; loop >= 0; loop--) {
-		key = klist->keys[loop];
+		key = rcu_deref_link_locked(klist, loop, keyring);
 		if (!key_is_dead(key, limit)) {
 			if (keep >= max)
 				goto discard_new;
-			new->keys[keep++] = key_get(key);
+			RCU_INIT_POINTER(new->keys[keep++], key_get(key));
 		}
 	}
 	new->nkeys = keep;

