Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:63928 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756976Ab2BHLER (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Feb 2012 06:04:17 -0500
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 8/9] KEYS: Do LRU discard in full keyrings
To: steved@redhat.com, jmorris@namei.org
Cc: keyrings@linux-nfs.org, linux-nfs@vger.kernel.org,
        linux-security-module@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Wed, 08 Feb 2012 11:04:11 +0000
Message-ID: <20120208110411.4050.73783.stgit@warthog.procyon.org.uk>
In-Reply-To: <20120208110254.4050.8856.stgit@warthog.procyon.org.uk>
References: <20120208110254.4050.8856.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Do an LRU discard in keyrings that are full rather than returning ENFILE.  To
perform this, a time_t is added to the key struct and updated by the creation
of a link to a key and by a key being found as the result of a search.  At the
completion of a successful search, the keyrings in the path between the root of
the search and the first found link to it also have their last-used times
updated.

Note that discarding a link to a key from a keyring does not necessarily
destroy the key as there may be references held by other places.

An alternate discard method that might suffice is to perform FIFO discard from
the keyring, using the spare 2-byte hole in the keylist header as the index of
the next link to be discarded.

This is useful when using a keyring as a cache for DNS results or foreign
filesystem IDs.


This can be tested by the following.  As root do:

	echo 1000 >/proc/sys/kernel/keys/root_maxkeys

	kr=`keyctl newring foo @s`
	for ((i=0; i<2000; i++)); do keyctl add user a$i a $kr; done

Without this patch ENFILE should be reported when the keyring fills up.  With
this patch, the keyring discards keys in an LRU fashion.  Note that the stored
LRU time has a granularity of 1s.

After doing this, /proc/key-users can be observed and should show that most of
the 2000 keys have been discarded:

	[root@andromeda ~]# cat /proc/key-users
	    0:   517 516/516 513/1000 5249/20000

The "513/1000" here is the number of quota-accounted keys present for this user
out of the maximum permitted.

In /proc/keys, the keyring shows the number of keys it has and the number of
slots it has allocated:

	[root@andromeda ~]# grep foo /proc/keys
	200c64c4 I--Q--     1 perm 3b3f0000     0     0 keyring   foo: 509/509

The maximum is (PAGE_SIZE - header) / key pointer size.  That's typically 509
on a 64-bit system and 1020 on a 32-bit system.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/linux/key.h          |    1 +
 security/keys/keyring.c      |   47 ++++++++++++++++++++++++++++++++++++------
 security/keys/process_keys.c |    2 ++
 3 files changed, 43 insertions(+), 7 deletions(-)

diff --git a/include/linux/key.h b/include/linux/key.h
index 9832399..3ed27b7 100644
--- a/include/linux/key.h
+++ b/include/linux/key.h
@@ -136,6 +136,7 @@ struct key {
 		time_t		expiry;		/* time at which key expires (or 0) */
 		time_t		revoked_at;	/* time at which key was revoked */
 	};
+	time_t			last_used_at;	/* last time used for LRU keyring discard */
 	uid_t			uid;
 	gid_t			gid;
 	key_perm_t		perm;		/* access permissions */
diff --git a/security/keys/keyring.c b/security/keys/keyring.c
index 459b3cc..89d02cf 100644
--- a/security/keys/keyring.c
+++ b/security/keys/keyring.c
@@ -30,6 +30,10 @@
 		(klist)->keys[index],					\
 		rwsem_is_locked((struct rw_semaphore *)&(keyring)->sem)))
 
+#define MAX_KEYRING_LINKS						\
+	min_t(size_t, USHRT_MAX - 1,					\
+	      ((PAGE_SIZE - sizeof(struct keyring_list)) / sizeof(struct key *)))
+
 #define KEY_LINK_FIXQUOTA 1UL
 
 /*
@@ -319,6 +323,8 @@ key_ref_t keyring_search_aux(key_ref_t keyring_ref,
 			     bool no_state_check)
 {
 	struct {
+		/* Need a separate keylist pointer for RCU purposes */
+		struct key *keyring;
 		struct keyring_list *keylist;
 		int kix;
 	} stack[KEYRING_SEARCH_MAX_DEPTH];
@@ -451,6 +457,7 @@ ascend:
 			continue;
 
 		/* stack the current position */
+		stack[sp].keyring = keyring;
 		stack[sp].keylist = keylist;
 		stack[sp].kix = kix;
 		sp++;
@@ -466,6 +473,7 @@ not_this_keyring:
 	if (sp > 0) {
 		/* resume the processing of a keyring higher up in the tree */
 		sp--;
+		keyring = stack[sp].keyring;
 		keylist = stack[sp].keylist;
 		kix = stack[sp].kix + 1;
 		goto ascend;
@@ -477,6 +485,10 @@ not_this_keyring:
 	/* we found a viable match */
 found:
 	atomic_inc(&key->usage);
+	key->last_used_at = now.tv_sec;
+	keyring->last_used_at = now.tv_sec;
+	while (sp > 0)
+		stack[--sp].keyring->last_used_at = now.tv_sec;
 	key_check(key);
 	key_ref = make_key_ref(key, possessed);
 error_2:
@@ -558,6 +570,8 @@ key_ref_t __keyring_search_one(key_ref_t keyring_ref,
 
 found:
 	atomic_inc(&key->usage);
+	keyring->last_used_at = key->last_used_at =
+		current_kernel_time().tv_sec;
 	rcu_read_unlock();
 	return make_key_ref(key, possessed);
 }
@@ -611,6 +625,7 @@ struct key *find_keyring_by_name(const char *name, bool skip_perm_check)
 			 * (ie. it has a zero usage count) */
 			if (!atomic_inc_not_zero(&keyring->usage))
 				continue;
+			keyring->last_used_at = current_kernel_time().tv_sec;
 			goto out;
 		}
 	}
@@ -734,8 +749,9 @@ int __key_link_begin(struct key *keyring, const struct key_type *type,
 	struct keyring_list *klist, *nklist;
 	unsigned long prealloc;
 	unsigned max;
+	time_t lowest_lru;
 	size_t size;
-	int loop, ret;
+	int loop, lru, ret;
 
 	kenter("%d,%s,%s,", key_serial(keyring), type->name, description);
 
@@ -756,7 +772,9 @@ int __key_link_begin(struct key *keyring, const struct key_type *type,
 	klist = rcu_dereference_locked_keyring(keyring);
 
 	/* see if there's a matching key we can displace */
+	lru = -1;
 	if (klist && klist->nkeys > 0) {
+		lowest_lru = TIME_T_MAX;
 		for (loop = klist->nkeys - 1; loop >= 0; loop--) {
 			struct key *key = rcu_deref_link_locked(klist, loop,
 								keyring);
@@ -770,9 +788,23 @@ int __key_link_begin(struct key *keyring, const struct key_type *type,
 				prealloc = 0;
 				goto done;
 			}
+			if (key->last_used_at < lowest_lru) {
+				lowest_lru = key->last_used_at;
+				lru = loop;
+			}
 		}
 	}
 
+	/* If the keyring is full then do an LRU discard */
+	if (klist &&
+	    klist->nkeys == klist->maxkeys &&
+	    klist->maxkeys >= MAX_KEYRING_LINKS) {
+		kdebug("LRU discard %d\n", lru);
+		klist->delkey = lru;
+		prealloc = 0;
+		goto done;
+	}
+
 	/* check that we aren't going to overrun the user's quota */
 	ret = key_payload_reserve(keyring,
 				  keyring->datalen + KEYQUOTA_LINK_BYTES);
@@ -786,15 +818,14 @@ int __key_link_begin(struct key *keyring, const struct key_type *type,
 	} else {
 		/* grow the key list */
 		max = 4;
-		if (klist)
+		if (klist) {
 			max += klist->maxkeys;
+			if (max > MAX_KEYRING_LINKS)
+				max = MAX_KEYRING_LINKS;
+			BUG_ON(max <= klist->maxkeys);
+		}
 
-		ret = -ENFILE;
-		if (max > USHRT_MAX - 1)
-			goto error_quota;
 		size = sizeof(*klist) + sizeof(struct key *) * max;
-		if (size > PAGE_SIZE)
-			goto error_quota;
 
 		ret = -ENOMEM;
 		nklist = kmalloc(size, GFP_KERNEL);
@@ -873,6 +904,8 @@ void __key_link(struct key *keyring, struct key *key,
 	klist = rcu_dereference_locked_keyring(keyring);
 
 	atomic_inc(&key->usage);
+	keyring->last_used_at = key->last_used_at =
+		current_kernel_time().tv_sec;
 
 	/* there's a matching key we can displace or an empty slot in a newly
 	 * allocated list we can fill */
diff --git a/security/keys/process_keys.c b/security/keys/process_keys.c
index 1068cb1..b1cdb56 100644
--- a/security/keys/process_keys.c
+++ b/security/keys/process_keys.c
@@ -731,6 +731,8 @@ try_again:
 	if (ret < 0)
 		goto invalid_key;
 
+	key->last_used_at = current_kernel_time().tv_sec;
+
 error:
 	put_cred(cred);
 	return key_ref;

