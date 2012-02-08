Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:19330 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756951Ab2BHLEa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Feb 2012 06:04:30 -0500
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 9/9] KEYS: Add invalidation support
To: steved@redhat.com, jmorris@namei.org
Cc: keyrings@linux-nfs.org, linux-nfs@vger.kernel.org,
        linux-security-module@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Wed, 08 Feb 2012 11:04:22 +0000
Message-ID: <20120208110422.4050.42825.stgit@warthog.procyon.org.uk>
In-Reply-To: <20120208110254.4050.8856.stgit@warthog.procyon.org.uk>
References: <20120208110254.4050.8856.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add support for invalidating a key - which renders it immediately invisible to
further searches and causes the garbage collector to immediately wake up,
remove it from keyrings and then destroy it when it's no longer referenced.

It's better not to do this with keyctl_revoke() as that marks the key to start
returning -EKEYREVOKED to searches when what is actually desired is to have the
key refetched.

To invalidate a key the caller must be granted SEARCH permission by the key.
This may be too strict.  It may be better to also permit invalidation if the
caller has any of READ, WRITE or SETATTR permission.

The primary use for this is to evict keys that are cached in special keyrings,
such as the DNS resolver or an ID mapper.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 Documentation/security/keys.txt |   17 +++++++++++++++++
 include/linux/key.h             |    3 +++
 include/linux/keyctl.h          |    1 +
 security/keys/compat.c          |    3 +++
 security/keys/gc.c              |   21 ++++++++++++++-------
 security/keys/internal.h        |   15 ++++++++++++++-
 security/keys/key.c             |   22 ++++++++++++++++++++++
 security/keys/keyctl.c          |   34 ++++++++++++++++++++++++++++++++++
 security/keys/keyring.c         |   25 +++++++++++--------------
 security/keys/permission.c      |   15 ++++++++++-----
 security/keys/proc.c            |    3 ++-
 11 files changed, 131 insertions(+), 28 deletions(-)

diff --git a/Documentation/security/keys.txt b/Documentation/security/keys.txt
index be3d229..69d4f48 100644
--- a/Documentation/security/keys.txt
+++ b/Documentation/security/keys.txt
@@ -806,6 +806,23 @@ The keyctl syscall functions are:
      kernel and resumes executing userspace.
 
 
+ (*) Invalidate a key.
+
+	long keyctl(KEYCTL_INVALIDATE, key_serial_t key);
+
+     This function marks a key as being invalidated and then wakes up the
+     garbage collector.  The garbage collector immediately removes invalidated
+     keys from all keyrings and deletes the key when its reference count
+     reaches zero.
+
+     Keys that are marked invalidated become invisible to normal key operations
+     immediately, though they are still visible in /proc/keys until deleted
+     (they're marked with an 'i' flag).
+
+     A process must have search permission on the key for this function to be
+     successful.
+
+
 ===============
 KERNEL SERVICES
 ===============
diff --git a/include/linux/key.h b/include/linux/key.h
index 3ed27b7..30dbf81 100644
--- a/include/linux/key.h
+++ b/include/linux/key.h
@@ -160,6 +160,7 @@ struct key {
 #define KEY_FLAG_USER_CONSTRUCT	4	/* set if key is being constructed in userspace */
 #define KEY_FLAG_NEGATIVE	5	/* set if key is negative */
 #define KEY_FLAG_ROOT_CAN_CLEAR	6	/* set if key can be cleared by root without permission */
+#define KEY_FLAG_INVALIDATED	7	/* set if key has been invalidated */
 
 	/* the description string
 	 * - this is used to match a key against search criteria
@@ -203,6 +204,7 @@ extern struct key *key_alloc(struct key_type *type,
 #define KEY_ALLOC_NOT_IN_QUOTA	0x0002	/* not in quota */
 
 extern void key_revoke(struct key *key);
+extern void key_invalidate(struct key *key);
 extern void key_put(struct key *key);
 
 static inline struct key *key_get(struct key *key)
@@ -321,6 +323,7 @@ extern void key_init(void);
 #define key_serial(k)			0
 #define key_get(k) 			({ NULL; })
 #define key_revoke(k)			do { } while(0)
+#define key_invalidate(k)		do { } while(0)
 #define key_put(k)			do { } while(0)
 #define key_ref_put(k)			do { } while(0)
 #define make_key_ref(k, p)		NULL
diff --git a/include/linux/keyctl.h b/include/linux/keyctl.h
index 9b0b865..c9b7f4fa 100644
--- a/include/linux/keyctl.h
+++ b/include/linux/keyctl.h
@@ -55,5 +55,6 @@
 #define KEYCTL_SESSION_TO_PARENT	18	/* apply session keyring to parent process */
 #define KEYCTL_REJECT			19	/* reject a partially constructed key */
 #define KEYCTL_INSTANTIATE_IOV		20	/* instantiate a partially constructed key */
+#define KEYCTL_INVALIDATE		21	/* invalidate a key */
 
 #endif /*  _LINUX_KEYCTL_H */
diff --git a/security/keys/compat.c b/security/keys/compat.c
index 4c48e13..fab4f8d 100644
--- a/security/keys/compat.c
+++ b/security/keys/compat.c
@@ -135,6 +135,9 @@ asmlinkage long compat_sys_keyctl(u32 option,
 		return compat_keyctl_instantiate_key_iov(
 			arg2, compat_ptr(arg3), arg4, arg5);
 
+	case KEYCTL_INVALIDATE:
+		return keyctl_invalidate_key(arg2);
+
 	default:
 		return -EOPNOTSUPP;
 	}
diff --git a/security/keys/gc.c b/security/keys/gc.c
index adddaa2..61ab7c8 100644
--- a/security/keys/gc.c
+++ b/security/keys/gc.c
@@ -72,6 +72,15 @@ void key_schedule_gc(time_t gc_at)
 }
 
 /*
+ * Schedule a dead links collection run.
+ */
+void key_schedule_gc_links(void)
+{
+	set_bit(KEY_GC_KEY_EXPIRED, &key_gc_flags);
+	queue_work(system_nrt_wq, &key_gc_work);
+}
+
+/*
  * Some key's cleanup time was met after it expired, so we need to get the
  * reaper to go through a cycle finding expired keys.
  */
@@ -79,8 +88,7 @@ static void key_gc_timer_func(unsigned long data)
 {
 	kenter("");
 	key_gc_next_run = LONG_MAX;
-	set_bit(KEY_GC_KEY_EXPIRED, &key_gc_flags);
-	queue_work(system_nrt_wq, &key_gc_work);
+	key_schedule_gc_links();
 }
 
 /*
@@ -131,12 +139,12 @@ void key_gc_keytype(struct key_type *ktype)
 static void key_gc_keyring(struct key *keyring, time_t limit)
 {
 	struct keyring_list *klist;
-	struct key *key;
 	int loop;
 
 	kenter("%x", key_serial(keyring));
 
-	if (test_bit(KEY_FLAG_REVOKED, &keyring->flags))
+	if (keyring->flags & ((1 << KEY_FLAG_INVALIDATED) |
+			      (1 << KEY_FLAG_REVOKED)))
 		goto dont_gc;
 
 	/* scan the keyring looking for dead keys */
@@ -148,9 +156,8 @@ static void key_gc_keyring(struct key *keyring, time_t limit)
 	loop = klist->nkeys;
 	smp_rmb();
 	for (loop--; loop >= 0; loop--) {
-		key = rcu_dereference(klist->keys[loop]);
-		if (test_bit(KEY_FLAG_DEAD, &key->flags) ||
-		    (key->expiry > 0 && key->expiry <= limit))
+		struct key *key = rcu_dereference(klist->keys[loop]);
+		if (key_is_dead(key, limit))
 			goto do_gc;
 	}
 
diff --git a/security/keys/internal.h b/security/keys/internal.h
index 65647f8..f711b09 100644
--- a/security/keys/internal.h
+++ b/security/keys/internal.h
@@ -152,7 +152,8 @@ extern long join_session_keyring(const char *name);
 extern struct work_struct key_gc_work;
 extern unsigned key_gc_delay;
 extern void keyring_gc(struct key *keyring, time_t limit);
-extern void key_schedule_gc(time_t expiry_at);
+extern void key_schedule_gc(time_t gc_at);
+extern void key_schedule_gc_links(void);
 extern void key_gc_keytype(struct key_type *ktype);
 
 extern int key_task_permission(const key_ref_t key_ref,
@@ -197,6 +198,17 @@ extern struct key *request_key_auth_new(struct key *target,
 extern struct key *key_get_instantiation_authkey(key_serial_t target_id);
 
 /*
+ * Determine whether a key is dead.
+ */
+static inline bool key_is_dead(struct key *key, time_t limit)
+{
+	return
+		key->flags & ((1 << KEY_FLAG_DEAD) |
+			      (1 << KEY_FLAG_INVALIDATED)) ||
+		(key->expiry > 0 && key->expiry <= limit);
+}
+
+/*
  * keyctl() functions
  */
 extern long keyctl_get_keyring_ID(key_serial_t, int);
@@ -225,6 +237,7 @@ extern long keyctl_reject_key(key_serial_t, unsigned, unsigned, key_serial_t);
 extern long keyctl_instantiate_key_iov(key_serial_t,
 				       const struct iovec __user *,
 				       unsigned, key_serial_t);
+extern long keyctl_invalidate_key(key_serial_t);
 
 extern long keyctl_instantiate_key_common(key_serial_t,
 					  const struct iovec __user *,
diff --git a/security/keys/key.c b/security/keys/key.c
index 9173253..3f409f6 100644
--- a/security/keys/key.c
+++ b/security/keys/key.c
@@ -935,6 +935,28 @@ void key_revoke(struct key *key)
 EXPORT_SYMBOL(key_revoke);
 
 /**
+ * key_invalidate - Invalidate a key.
+ * @key: The key to be invalidated.
+ *
+ * Mark a key as being invalidated and have it cleaned up immediately.  The key
+ * is ignored by all searches and other operations from this point.
+ */
+void key_invalidate(struct key *key)
+{
+	kenter("%d", key_serial(key));
+
+	key_check(key);
+
+	if (!test_bit(KEY_FLAG_INVALIDATED, &key->flags)) {
+		down_write_nested(&key->sem, 1);
+		if (!test_and_set_bit(KEY_FLAG_INVALIDATED, &key->flags))
+			key_schedule_gc_links();
+		up_write(&key->sem);
+	}
+}
+EXPORT_SYMBOL(key_invalidate);
+
+/**
  * register_key_type - Register a type of key.
  * @ktype: The new key type.
  *
diff --git a/security/keys/keyctl.c b/security/keys/keyctl.c
index 6523599..477201f 100644
--- a/security/keys/keyctl.c
+++ b/security/keys/keyctl.c
@@ -374,6 +374,37 @@ error:
 }
 
 /*
+ * Invalidate a key.
+ *
+ * The key must be grant the caller Invalidate permission for this to work.
+ * The key and any links to the key will be automatically garbage collected
+ * immediately.
+ *
+ * If successful, 0 is returned.
+ */
+long keyctl_invalidate_key(key_serial_t id)
+{
+	key_ref_t key_ref;
+	long ret;
+
+	kenter("%d", id);
+
+	key_ref = lookup_user_key(id, 0, KEY_SEARCH);
+	if (IS_ERR(key_ref)) {
+		ret = PTR_ERR(key_ref);
+		goto error;
+	}
+
+	key_invalidate(key_ref_to_ptr(key_ref));
+	ret = 0;
+
+	key_ref_put(key_ref);
+error:
+	kleave(" = %ld", ret);
+	return ret;
+}
+
+/*
  * Clear the specified keyring, creating an empty process keyring if one of the
  * special keyring IDs is used.
  *
@@ -1636,6 +1667,9 @@ SYSCALL_DEFINE5(keyctl, int, option, unsigned long, arg2, unsigned long, arg3,
 			(unsigned) arg4,
 			(key_serial_t) arg5);
 
+	case KEYCTL_INVALIDATE:
+		return keyctl_invalidate_key((key_serial_t) arg2);
+
 	default:
 		return -EOPNOTSUPP;
 	}
diff --git a/security/keys/keyring.c b/security/keys/keyring.c
index 89d02cf..7445875 100644
--- a/security/keys/keyring.c
+++ b/security/keys/keyring.c
@@ -382,13 +382,17 @@ key_ref_t keyring_search_aux(key_ref_t keyring_ref,
 	/* otherwise, the top keyring must not be revoked, expired, or
 	 * negatively instantiated if we are to search it */
 	key_ref = ERR_PTR(-EAGAIN);
-	if (kflags & ((1 << KEY_FLAG_REVOKED) | (1 << KEY_FLAG_NEGATIVE)) ||
+	if (kflags & ((1 << KEY_FLAG_INVALIDATED) |
+		      (1 << KEY_FLAG_REVOKED) |
+		      (1 << KEY_FLAG_NEGATIVE)) ||
 	    (keyring->expiry && now.tv_sec >= keyring->expiry))
 		goto error_2;
 
 	/* start processing a new keyring */
 descend:
-	if (test_bit(KEY_FLAG_REVOKED, &keyring->flags))
+	kflags = keyring->flags;
+	if (kflags & ((1 << KEY_FLAG_INVALIDATED) |
+		      (1 << KEY_FLAG_REVOKED)))
 		goto not_this_keyring;
 
 	keylist = rcu_dereference(keyring->payload.subscriptions);
@@ -406,9 +410,10 @@ descend:
 		if (key->type != type)
 			continue;
 
-		/* skip revoked keys and expired keys */
+		/* skip invalidated, revoked and expired keys */
 		if (!no_state_check) {
-			if (kflags & (1 << KEY_FLAG_REVOKED))
+			if (kflags & ((1 << KEY_FLAG_INVALIDATED) |
+				      (1 << KEY_FLAG_REVOKED)))
 				continue;
 
 			if (key->expiry && now.tv_sec >= key->expiry)
@@ -559,7 +564,8 @@ key_ref_t __keyring_search_one(key_ref_t keyring_ref,
 			     key->type->match(key, description)) &&
 			    key_permission(make_key_ref(key, possessed),
 					   perm) == 0 &&
-			    !test_bit(KEY_FLAG_REVOKED, &key->flags)
+			    !(key->flags & ((1 << KEY_FLAG_INVALIDATED) |
+					    (1 << KEY_FLAG_REVOKED)))
 			    )
 				goto found;
 		}
@@ -1177,15 +1183,6 @@ static void keyring_revoke(struct key *keyring)
 }
 
 /*
- * Determine whether a key is dead.
- */
-static bool key_is_dead(struct key *key, time_t limit)
-{
-	return test_bit(KEY_FLAG_DEAD, &key->flags) ||
-		(key->expiry > 0 && key->expiry <= limit);
-}
-
-/*
  * Collect garbage from the contents of a keyring, replacing the old list with
  * a new one with the pointers all shuffled down.
  *
diff --git a/security/keys/permission.c b/security/keys/permission.c
index c35b522..5f4c00c 100644
--- a/security/keys/permission.c
+++ b/security/keys/permission.c
@@ -87,20 +87,25 @@ EXPORT_SYMBOL(key_task_permission);
  * key_validate - Validate a key.
  * @key: The key to be validated.
  *
- * Check that a key is valid, returning 0 if the key is okay, -EKEYREVOKED if
- * the key's type has been removed or if the key has been revoked or
- * -EKEYEXPIRED if the key has expired.
+ * Check that a key is valid, returning 0 if the key is okay, -ENOKEY if the
+ * key is invalidated, -EKEYREVOKED if the key's type has been removed or if
+ * the key has been revoked or -EKEYEXPIRED if the key has expired.
  */
 int key_validate(struct key *key)
 {
 	struct timespec now;
+	unsigned long flags = key->flags;
 	int ret = 0;
 
 	if (key) {
+		ret = -ENOKEY;
+		if (flags & (1 << KEY_FLAG_INVALIDATED))
+			goto error;
+
 		/* check it's still accessible */
 		ret = -EKEYREVOKED;
-		if (test_bit(KEY_FLAG_REVOKED, &key->flags) ||
-		    test_bit(KEY_FLAG_DEAD, &key->flags))
+		if (flags & ((1 << KEY_FLAG_REVOKED) |
+			     (1 << KEY_FLAG_DEAD)))
 			goto error;
 
 		/* check it hasn't expired */
diff --git a/security/keys/proc.c b/security/keys/proc.c
index 49bbc97..30d1ddf 100644
--- a/security/keys/proc.c
+++ b/security/keys/proc.c
@@ -242,7 +242,7 @@ static int proc_keys_show(struct seq_file *m, void *v)
 #define showflag(KEY, LETTER, FLAG) \
 	(test_bit(FLAG,	&(KEY)->flags) ? LETTER : '-')
 
-	seq_printf(m, "%08x %c%c%c%c%c%c %5d %4s %08x %5d %5d %-9.9s ",
+	seq_printf(m, "%08x %c%c%c%c%c%c%c %5d %4s %08x %5d %5d %-9.9s ",
 		   key->serial,
 		   showflag(key, 'I', KEY_FLAG_INSTANTIATED),
 		   showflag(key, 'R', KEY_FLAG_REVOKED),
@@ -250,6 +250,7 @@ static int proc_keys_show(struct seq_file *m, void *v)
 		   showflag(key, 'Q', KEY_FLAG_IN_QUOTA),
 		   showflag(key, 'U', KEY_FLAG_USER_CONSTRUCT),
 		   showflag(key, 'N', KEY_FLAG_NEGATIVE),
+		   showflag(key, 'i', KEY_FLAG_INVALIDATED),
 		   atomic_read(&key->usage),
 		   xbuf,
 		   key->perm,

