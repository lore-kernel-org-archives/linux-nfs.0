Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:29721 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757339Ab1LOMRe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Dec 2011 07:17:34 -0500
From: David Howells <dhowells@redhat.com>
Subject: [PATCH] [RFC] KEYS: Add invalidation support
To: keyrings@linux-nfs.org, linux-nfs@vger.kernel.org,
        linux-security-module@vger.kernel.org
Cc: dhowells@redhat.com
Date: Thu, 15 Dec 2011 12:17:24 +0000
Message-ID: <20111215121723.18382.99996.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add support for invalidating a key - which renders it immediately invisible to
further searches and causes the garbage collector to immediately wake up,
remove it from keyrings and then destroy it when it's no longer referenced.

Also add specific invalidation permission bits that grant possessor, user,
group or other invalidation permissions without the requiring the grant of
SETATTR or WRITE permission - either of which might provide too much access.

WRITE permission, for example, may allow the key's content to be changed and
SETATTR would allow the permissions mask and ownership to be altered.

It's better not to do this with keyctl_revoke() as that marks the key to start
returning -EKEYREVOKED to searches when what is actually desired is to have the
key refetched.

The primary use for this is to evict keys that are cached in special keyrings,
such as the DNS resolver or an ID mapper.


Questions for consideration:

Do I actually need to add a new permission bit for this?  Or would it be
sufficient to pick one or more of the following criteria?

 (1) The invalidator has SEARCH permission on the key.

 (2) The invalidator is the owner (uid match).

 (3) The invalidator has CAP_SYS_ADMIN.

Should all keys be invalidatable?  Or should it be possible to set a flag on a
key (or key type) to say whether it can be invalidated?  Should this be
alterable by userspace?  Should such a flag be set by request_key() but not
add_key()?

Invalidation is basically an operation to eject a key from all keyrings - even
ones that you can't 'write' - and cause the key to be 'refetched'.

To-be-Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/linux/key.h        |   15 +++++++++++----
 include/linux/keyctl.h     |    1 +
 security/keys/compat.c     |    3 +++
 security/keys/gc.c         |   23 ++++++++++++++---------
 security/keys/internal.h   |   18 ++++++++++++++++--
 security/keys/key.c        |   23 +++++++++++++++++++++++
 security/keys/keyctl.c     |   34 ++++++++++++++++++++++++++++++++++
 security/keys/keyring.c    |   25 +++++++++++--------------
 security/keys/permission.c |   15 ++++++++++-----
 security/keys/proc.c       |    3 ++-
 10 files changed, 125 insertions(+), 35 deletions(-)

diff --git a/include/linux/key.h b/include/linux/key.h
index 3ac4128..e22195f 100644
--- a/include/linux/key.h
+++ b/include/linux/key.h
@@ -43,7 +43,8 @@ struct key;
 #define KEY_POS_SEARCH	0x08000000	/* possessor can find a key in search / search a keyring */
 #define KEY_POS_LINK	0x10000000	/* possessor can create a link to a key/keyring */
 #define KEY_POS_SETATTR	0x20000000	/* possessor can set key attributes */
-#define KEY_POS_ALL	0x3f000000
+#define KEY_POS_INVAL	0x40000000	/* possessor can invalidate a key */
+#define KEY_POS_ALL	0x7f000000
 
 #define KEY_USR_VIEW	0x00010000	/* user permissions... */
 #define KEY_USR_READ	0x00020000
@@ -51,7 +52,8 @@ struct key;
 #define KEY_USR_SEARCH	0x00080000
 #define KEY_USR_LINK	0x00100000
 #define KEY_USR_SETATTR	0x00200000
-#define KEY_USR_ALL	0x003f0000
+#define KEY_USR_INVAL	0x00400000
+#define KEY_USR_ALL	0x007f0000
 
 #define KEY_GRP_VIEW	0x00000100	/* group permissions... */
 #define KEY_GRP_READ	0x00000200
@@ -59,7 +61,8 @@ struct key;
 #define KEY_GRP_SEARCH	0x00000800
 #define KEY_GRP_LINK	0x00001000
 #define KEY_GRP_SETATTR	0x00002000
-#define KEY_GRP_ALL	0x00003f00
+#define KEY_GRP_INVAL	0x00004000
+#define KEY_GRP_ALL	0x00007f00
 
 #define KEY_OTH_VIEW	0x00000001	/* third party permissions... */
 #define KEY_OTH_READ	0x00000002
@@ -67,7 +70,8 @@ struct key;
 #define KEY_OTH_SEARCH	0x00000008
 #define KEY_OTH_LINK	0x00000010
 #define KEY_OTH_SETATTR	0x00000020
-#define KEY_OTH_ALL	0x0000003f
+#define KEY_OTH_INVAL	0x00000040
+#define KEY_OTH_ALL	0x0000007f
 
 #define KEY_PERM_UNDEF	0xffffffff
 
@@ -156,6 +160,7 @@ struct key {
 #define KEY_FLAG_USER_CONSTRUCT	4	/* set if key is being constructed in userspace */
 #define KEY_FLAG_NEGATIVE	5	/* set if key is negative */
 #define KEY_FLAG_ROOT_CAN_CLEAR	6	/* set if key can be cleared by root without permission */
+#define KEY_FLAG_INVALIDATED	7	/* set if key has been invalidated */
 
 	/* the description string
 	 * - this is used to match a key against search criteria
@@ -199,6 +204,7 @@ extern struct key *key_alloc(struct key_type *type,
 #define KEY_ALLOC_NOT_IN_QUOTA	0x0002	/* not in quota */
 
 extern void key_revoke(struct key *key);
+extern void key_invalidate(struct key *key);
 extern void key_put(struct key *key);
 
 static inline struct key *key_get(struct key *key)
@@ -314,6 +320,7 @@ extern void key_init(void);
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
index bf4d8da..4c7c99e 100644
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
@@ -145,12 +153,9 @@ static void key_gc_keyring(struct key *keyring, time_t limit)
 	if (!klist)
 		goto unlock_dont_gc;
 
-	for (loop = klist->nkeys - 1; loop >= 0; loop--) {
-		key = klist->keys[loop];
-		if (test_bit(KEY_FLAG_DEAD, &key->flags) ||
-		    (key->expiry > 0 && key->expiry <= limit))
+	for (loop = klist->nkeys - 1; loop >= 0; loop--)
+		if (key_is_dead(klist->keys[loop], limit))
 			goto do_gc;
-	}
 
 unlock_dont_gc:
 	rcu_read_unlock();
diff --git a/security/keys/internal.h b/security/keys/internal.h
index c7a7cae..9c3c2d2 100644
--- a/security/keys/internal.h
+++ b/security/keys/internal.h
@@ -151,7 +151,8 @@ extern long join_session_keyring(const char *name);
 extern struct work_struct key_gc_work;
 extern unsigned key_gc_delay;
 extern void keyring_gc(struct key *keyring, time_t limit);
-extern void key_schedule_gc(time_t expiry_at);
+extern void key_schedule_gc(time_t gc_at);
+extern void key_schedule_gc_links(void);
 extern void key_gc_keytype(struct key_type *ktype);
 
 extern int key_task_permission(const key_ref_t key_ref,
@@ -173,7 +174,8 @@ static inline int key_permission(const key_ref_t key_ref, key_perm_t perm)
 #define	KEY_SEARCH	0x08	/* require permission to search (keyring) or find (key) */
 #define	KEY_LINK	0x10	/* require permission to link */
 #define	KEY_SETATTR	0x20	/* require permission to change attributes */
-#define	KEY_ALL		0x3f	/* all the above permissions */
+#define	KEY_INVAL	0x40	/* require permission to invalidate a key */
+#define	KEY_ALL		0x7f	/* all the above permissions */
 
 /*
  * Authorisation record for request_key().
@@ -196,6 +198,17 @@ extern struct key *request_key_auth_new(struct key *target,
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
@@ -224,6 +237,7 @@ extern long keyctl_reject_key(key_serial_t, unsigned, unsigned, key_serial_t);
 extern long keyctl_instantiate_key_iov(key_serial_t,
 				       const struct iovec __user *,
 				       unsigned, key_serial_t);
+extern long keyctl_invalidate_key(key_serial_t);
 
 extern long keyctl_instantiate_key_common(key_serial_t,
 					  const struct iovec __user *,
diff --git a/security/keys/key.c b/security/keys/key.c
index 4f64c72..a57a0a4 100644
--- a/security/keys/key.c
+++ b/security/keys/key.c
@@ -807,6 +807,7 @@ key_ref_t key_create_or_update(key_ref_t keyring_ref,
 	if (perm == KEY_PERM_UNDEF) {
 		perm = KEY_POS_VIEW | KEY_POS_SEARCH | KEY_POS_LINK | KEY_POS_SETATTR;
 		perm |= KEY_USR_VIEW | KEY_USR_SEARCH | KEY_USR_LINK | KEY_USR_SETATTR;
+		perm |= KEY_USR_INVAL;
 
 		if (ktype->read)
 			perm |= KEY_POS_READ | KEY_USR_READ;
@@ -935,6 +936,28 @@ void key_revoke(struct key *key)
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
index 6523599..53c9bce 100644
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
+	key_ref = lookup_user_key(id, 0, KEY_INVAL);
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
index 37a7f3b..ce02adc 100644
--- a/security/keys/keyring.c
+++ b/security/keys/keyring.c
@@ -366,13 +366,17 @@ key_ref_t keyring_search_aux(key_ref_t keyring_ref,
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
@@ -388,9 +392,10 @@ descend:
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
@@ -532,7 +537,8 @@ key_ref_t __keyring_search_one(key_ref_t keyring_ref,
 			     key->type->match(key, description)) &&
 			    key_permission(make_key_ref(key, possessed),
 					   perm) == 0 &&
-			    !test_bit(KEY_FLAG_REVOKED, &key->flags)
+			    !(key->flags & ((1 << KEY_FLAG_INVALIDATED) |
+					    (1 << KEY_FLAG_REVOKED)))
 			    )
 				goto found;
 		}
@@ -1120,15 +1126,6 @@ static void keyring_revoke(struct key *keyring)
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

