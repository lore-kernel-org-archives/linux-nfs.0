Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16167 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932130Ab1CCRue (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Mar 2011 12:50:34 -0500
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 1/3] KEYS: Add a new keyctl op to reject a key with a
 specified error code
To: linux-security-module@vger.kernel.org, keyrings@linux-nfs.org
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        David Howells <dhowells@redhat.com>
Date: Thu, 03 Mar 2011 17:50:30 +0000
Message-ID: <20110303175030.21702.31104.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Add a new keyctl op to reject a key with a specified error code.  This works
much the same as negating a key, and so keyctl_negate_key() is made a special
case of keyctl_reject_key().  The difference is that keyctl_negate_key()
selects ENOKEY as the error to be reported.

Typically the key would be rejected with EKEYEXPIRED, EKEYREVOKED or
EKEYREJECTED, but this is not mandatory.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 Documentation/keys-request-key.txt |    9 +++++---
 Documentation/keys.txt             |   10 +++++++--
 include/linux/key-type.h           |   11 +++++++++-
 include/linux/key.h                |    1 +
 include/linux/keyctl.h             |    1 +
 security/keys/compat.c             |    3 +++
 security/keys/internal.h           |    1 +
 security/keys/key.c                |   19 ++++++++++-------
 security/keys/keyctl.c             |   40 ++++++++++++++++++++++++++++++++++--
 security/keys/keyring.c            |    4 ++--
 security/keys/request_key.c        |    2 +-
 11 files changed, 81 insertions(+), 20 deletions(-)

diff --git a/Documentation/keys-request-key.txt b/Documentation/keys-request-key.txt
index 09b55e4..69686ad 100644
--- a/Documentation/keys-request-key.txt
+++ b/Documentation/keys-request-key.txt
@@ -127,14 +127,15 @@ This is because process A's keyrings can't simply be attached to
 of them, and (b) it requires the same UID/GID/Groups all the way through.
 
 
-======================
-NEGATIVE INSTANTIATION
-======================
+====================================
+NEGATIVE INSTANTIATION AND REJECTION
+====================================
 
 Rather than instantiating a key, it is possible for the possessor of an
 authorisation key to negatively instantiate a key that's under construction.
 This is a short duration placeholder that causes any attempt at re-requesting
-the key whilst it exists to fail with error ENOKEY.
+the key whilst it exists to fail with error ENOKEY if negated or the specified
+error if rejected.
 
 This is provided to prevent excessive repeated spawning of /sbin/request-key
 processes for a key that will never be obtainable.
diff --git a/Documentation/keys.txt b/Documentation/keys.txt
index cf68d1f..a6a97fd 100644
--- a/Documentation/keys.txt
+++ b/Documentation/keys.txt
@@ -657,6 +657,8 @@ The keyctl syscall functions are:
 
 	long keyctl(KEYCTL_NEGATE, key_serial_t key,
 		    unsigned timeout, key_serial_t keyring);
+	long keyctl(KEYCTL_REJECT, key_serial_t key,
+		    unsigned timeout, unsigned error, key_serial_t keyring);
 
      If the kernel calls back to userspace to complete the instantiation of a
      key, userspace should use this call mark the key as negative before the
@@ -669,6 +671,10 @@ The keyctl syscall functions are:
      that keyring, however all the constraints applying in KEYCTL_LINK apply in
      this case too.
 
+     If the key is rejected, future searches for it will return the specified
+     error code until the rejected key expires.  Negating the key is the same
+     as rejecting the key with ENOKEY as the error code.
+
 
  (*) Set the default request-key destination keyring.
 
@@ -1240,8 +1246,8 @@ example, the KDE desktop manager).
 The program (or whatever it calls) should finish construction of the key by
 calling KEYCTL_INSTANTIATE, which also permits it to cache the key in one of
 the keyrings (probably the session ring) before returning. Alternatively, the
-key can be marked as negative with KEYCTL_NEGATE; this also permits the key to
-be cached in one of the keyrings.
+key can be marked as negative with KEYCTL_NEGATE or KEYCTL_REJECT; this also
+permits the key to be cached in one of the keyrings.
 
 If it returns with the key remaining in the unconstructed state, the key will
 be marked as being negative, it will be added to the session keyring, and an
diff --git a/include/linux/key-type.h b/include/linux/key-type.h
index fc8525e8..9efd081 100644
--- a/include/linux/key-type.h
+++ b/include/linux/key-type.h
@@ -105,11 +105,20 @@ extern int key_instantiate_and_link(struct key *key,
 				    size_t datalen,
 				    struct key *keyring,
 				    struct key *instkey);
-extern int key_negate_and_link(struct key *key,
+extern int key_reject_and_link(struct key *key,
 			       unsigned timeout,
+			       unsigned error,
 			       struct key *keyring,
 			       struct key *instkey);
 extern void complete_request_key(struct key_construction *cons, int error);
 
+static inline int key_negate_and_link(struct key *key,
+				      unsigned timeout,
+				      struct key *keyring,
+				      struct key *instkey)
+{
+	return key_reject_and_link(key, timeout, ENOKEY, keyring, instkey);
+}
+
 #endif /* CONFIG_KEYS */
 #endif /* _LINUX_KEY_TYPE_H */
diff --git a/include/linux/key.h b/include/linux/key.h
index a6b1edc..b2bb017 100644
--- a/include/linux/key.h
+++ b/include/linux/key.h
@@ -170,6 +170,7 @@ struct key {
 		struct list_head	link;
 		unsigned long		x[2];
 		void			*p[2];
+		int			reject_error;
 	} type_data;
 
 	/* key data
diff --git a/include/linux/keyctl.h b/include/linux/keyctl.h
index bd383f1..7022974 100644
--- a/include/linux/keyctl.h
+++ b/include/linux/keyctl.h
@@ -53,5 +53,6 @@
 #define KEYCTL_ASSUME_AUTHORITY		16	/* assume request_key() authorisation */
 #define KEYCTL_GET_SECURITY		17	/* get key security label */
 #define KEYCTL_SESSION_TO_PARENT	18	/* apply session keyring to parent process */
+#define KEYCTL_REJECT			19	/* reject a partially constructed key */
 
 #endif /*  _LINUX_KEYCTL_H */
diff --git a/security/keys/compat.c b/security/keys/compat.c
index 07a5f35..17c99d0 100644
--- a/security/keys/compat.c
+++ b/security/keys/compat.c
@@ -85,6 +85,9 @@ asmlinkage long compat_sys_keyctl(u32 option,
 	case KEYCTL_SESSION_TO_PARENT:
 		return keyctl_session_to_parent();
 
+	case KEYCTL_REJECT:
+		return keyctl_reject_key(arg2, arg3, arg4, arg5);
+
 	default:
 		return -EOPNOTSUPP;
 	}
diff --git a/security/keys/internal.h b/security/keys/internal.h
index a52aa7c..286c095 100644
--- a/security/keys/internal.h
+++ b/security/keys/internal.h
@@ -214,6 +214,7 @@ extern long keyctl_assume_authority(key_serial_t);
 extern long keyctl_get_security(key_serial_t keyid, char __user *buffer,
 				size_t buflen);
 extern long keyctl_session_to_parent(void);
+extern long keyctl_reject_key(key_serial_t, unsigned, unsigned, key_serial_t);
 
 /*
  * Debugging key validation
diff --git a/security/keys/key.c b/security/keys/key.c
index 8e315ef..f7f9d93 100644
--- a/security/keys/key.c
+++ b/security/keys/key.c
@@ -511,26 +511,29 @@ int key_instantiate_and_link(struct key *key,
 EXPORT_SYMBOL(key_instantiate_and_link);
 
 /**
- * key_negate_and_link - Negatively instantiate a key and link it into the keyring.
+ * key_reject_and_link - Negatively instantiate a key and link it into the keyring.
  * @key: The key to instantiate.
  * @timeout: The timeout on the negative key.
+ * @error: The error to return when the key is hit.
  * @keyring: Keyring to create a link in on success (or NULL).
  * @authkey: The authorisation token permitting instantiation.
  *
  * Negatively instantiate a key that's in the uninstantiated state and, if
- * successful, set its timeout and link it in to the destination keyring if one
- * is supplied.  The key and any links to the key will be automatically garbage
- * collected after the timeout expires.
+ * successful, set its timeout and stored error and link it in to the
+ * destination keyring if one is supplied.  The key and any links to the key
+ * will be automatically garbage collected after the timeout expires.
  *
  * Negative keys are used to rate limit repeated request_key() calls by causing
- * them to return -ENOKEY until the negative key expires.
+ * them to return the stored error code (typically ENOKEY) until the negative
+ * key expires.
  *
  * If successful, 0 is returned, the authorisation token is revoked and anyone
  * waiting for the key is woken up.  If the key was already instantiated,
  * -EBUSY will be returned.
  */
-int key_negate_and_link(struct key *key,
+int key_reject_and_link(struct key *key,
 			unsigned timeout,
+			unsigned error,
 			struct key *keyring,
 			struct key *authkey)
 {
@@ -556,6 +559,7 @@ int key_negate_and_link(struct key *key,
 		atomic_inc(&key->user->nikeys);
 		set_bit(KEY_FLAG_NEGATIVE, &key->flags);
 		set_bit(KEY_FLAG_INSTANTIATED, &key->flags);
+		key->type_data.reject_error = -error;
 		now = current_kernel_time();
 		key->expiry = now.tv_sec + timeout;
 		key_schedule_gc(key->expiry + key_gc_delay);
@@ -585,8 +589,7 @@ int key_negate_and_link(struct key *key,
 
 	return ret == 0 ? link_ret : ret;
 }
-
-EXPORT_SYMBOL(key_negate_and_link);
+EXPORT_SYMBOL(key_reject_and_link);
 
 /*
  * Garbage collect keys in process context so that we don't have to disable
diff --git a/security/keys/keyctl.c b/security/keys/keyctl.c
index 31a0fd8..0d7b194 100644
--- a/security/keys/keyctl.c
+++ b/security/keys/keyctl.c
@@ -1013,12 +1013,42 @@ error:
  */
 long keyctl_negate_key(key_serial_t id, unsigned timeout, key_serial_t ringid)
 {
+	return keyctl_reject_key(id, timeout, ENOKEY, ringid);
+}
+
+/*
+ * Negatively instantiate the key with the given timeout (in seconds) and error
+ * code and link the key into the destination keyring if one is given.
+ *
+ * The caller must have the appropriate instantiation permit set for this to
+ * work (see keyctl_assume_authority).  No other permissions are required.
+ *
+ * The key and any links to the key will be automatically garbage collected
+ * after the timeout expires.
+ *
+ * Negative keys are used to rate limit repeated request_key() calls by causing
+ * them to return the specified error code until the negative key expires.
+ *
+ * If successful, 0 will be returned.
+ */
+long keyctl_reject_key(key_serial_t id, unsigned timeout, unsigned error,
+		       key_serial_t ringid)
+{
 	const struct cred *cred = current_cred();
 	struct request_key_auth *rka;
 	struct key *instkey, *dest_keyring;
 	long ret;
 
-	kenter("%d,%u,%d", id, timeout, ringid);
+	kenter("%d,%u,%u,%d", id, timeout, error, ringid);
+
+	/* must be a valid error code and mustn't be a kernel special */
+	if (error <= 0 ||
+	    error >= MAX_ERRNO ||
+	    error == ERESTARTSYS ||
+	    error == ERESTARTNOINTR ||
+	    error == ERESTARTNOHAND ||
+	    error == ERESTART_RESTARTBLOCK)
+		return -EINVAL;
 
 	/* the appropriate instantiation authorisation key must have been
 	 * assumed before calling this */
@@ -1038,7 +1068,7 @@ long keyctl_negate_key(key_serial_t id, unsigned timeout, key_serial_t ringid)
 		goto error;
 
 	/* instantiate the key and link it into a keyring */
-	ret = key_negate_and_link(rka->target_key, timeout,
+	ret = key_reject_and_link(rka->target_key, timeout, error,
 				  dest_keyring, instkey);
 
 	key_put(dest_keyring);
@@ -1492,6 +1522,12 @@ SYSCALL_DEFINE5(keyctl, int, option, unsigned long, arg2, unsigned long, arg3,
 	case KEYCTL_SESSION_TO_PARENT:
 		return keyctl_session_to_parent();
 
+	case KEYCTL_REJECT:
+		return keyctl_reject_key((key_serial_t) arg2,
+					 (unsigned) arg3,
+					 (unsigned) arg4,
+					 (key_serial_t) arg5);
+
 	default:
 		return -EOPNOTSUPP;
 	}
diff --git a/security/keys/keyring.c b/security/keys/keyring.c
index 5620f08..cdd2f3f 100644
--- a/security/keys/keyring.c
+++ b/security/keys/keyring.c
@@ -352,7 +352,7 @@ key_ref_t keyring_search_aux(key_ref_t keyring_ref,
 			goto error_2;
 		if (key->expiry && now.tv_sec >= key->expiry)
 			goto error_2;
-		key_ref = ERR_PTR(-ENOKEY);
+		key_ref = ERR_PTR(key->type_data.reject_error);
 		if (kflags & (1 << KEY_FLAG_NEGATIVE))
 			goto error_2;
 		goto found;
@@ -401,7 +401,7 @@ descend:
 
 		/* we set a different error code if we pass a negative key */
 		if (kflags & (1 << KEY_FLAG_NEGATIVE)) {
-			err = -ENOKEY;
+			err = key->type_data.reject_error;
 			continue;
 		}
 
diff --git a/security/keys/request_key.c b/security/keys/request_key.c
index a3dc0d4..df3c041 100644
--- a/security/keys/request_key.c
+++ b/security/keys/request_key.c
@@ -585,7 +585,7 @@ int wait_for_key_construction(struct key *key, bool intr)
 	if (ret < 0)
 		return ret;
 	if (test_bit(KEY_FLAG_NEGATIVE, &key->flags))
-		return -ENOKEY;
+		return key->type_data.reject_error;
 	return key_validate(key);
 }
 EXPORT_SYMBOL(wait_for_key_construction);

