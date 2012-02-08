Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:13094 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756130Ab2BHLDD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Feb 2012 06:03:03 -0500
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 1/9] KEYS: Allow special keyrings to be cleared
To: steved@redhat.com, jmorris@namei.org
Cc: keyrings@linux-nfs.org, linux-nfs@vger.kernel.org,
        linux-security-module@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Wed, 08 Feb 2012 11:02:55 +0000
Message-ID: <20120208110254.4050.8856.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The kernel contains some special internal keyrings, for instance the DNS
resolver keyring :

2a93faf1 I-----     1 perm 1f030000     0     0 keyring   .dns_resolver: empty

It would occasionally be useful to allow the contents of such keyrings to be
flushed by root (cache invalidation).

Allow a flag to be set on a keyring to mark that someone possessing the
sysadmin capability can clear the keyring, even without normal write access to
the keyring.

Set this flag on the special keyrings created by the DNS resolver, the NFS
identity mapper and the CIFS identity mapper.

Signed-off-by: David Howells <dhowells@redhat.com>
Acked-by: Jeff Layton <jlayton@redhat.com>
Acked-by: Steve Dickson <steved@redhat.com>
---

 Documentation/networking/dns_resolver.txt |    4 ++++
 Documentation/security/keys.txt           |    4 ++++
 fs/cifs/cifsacl.c                         |    1 +
 fs/nfs/idmap.c                            |    1 +
 include/linux/key.h                       |    1 +
 net/dns_resolver/dns_key.c                |    1 +
 security/keys/keyctl.c                    |   15 ++++++++++++++-
 7 files changed, 26 insertions(+), 1 deletions(-)

diff --git a/Documentation/networking/dns_resolver.txt b/Documentation/networking/dns_resolver.txt
index 7f531ad..d86adcd 100644
--- a/Documentation/networking/dns_resolver.txt
+++ b/Documentation/networking/dns_resolver.txt
@@ -102,6 +102,10 @@ implemented in the module can be called after doing:
      If _expiry is non-NULL, the expiry time (TTL) of the result will be
      returned also.
 
+The kernel maintains an internal keyring in which it caches looked up keys.
+This can be cleared by any process that has the CAP_SYS_ADMIN capability by
+the use of KEYCTL_KEYRING_CLEAR on the keyring ID.
+
 
 ===============================
 READING DNS KEYS FROM USERSPACE
diff --git a/Documentation/security/keys.txt b/Documentation/security/keys.txt
index 4d75931..713ec23 100644
--- a/Documentation/security/keys.txt
+++ b/Documentation/security/keys.txt
@@ -554,6 +554,10 @@ The keyctl syscall functions are:
      process must have write permission on the keyring, and it must be a
      keyring (or else error ENOTDIR will result).
 
+     This function can also be used to clear special kernel keyrings if they
+     are appropriately marked if the user has CAP_SYS_ADMIN capability.  The
+     DNS resolver cache keyring is an example of this.
+
 
  (*) Link a key into a keyring:
 
diff --git a/fs/cifs/cifsacl.c b/fs/cifs/cifsacl.c
index c1b2544..3cc1b25 100644
--- a/fs/cifs/cifsacl.c
+++ b/fs/cifs/cifsacl.c
@@ -556,6 +556,7 @@ init_cifs_idmap(void)
 
 	/* instruct request_key() to use this special keyring as a cache for
 	 * the results it looks up */
+	set_bit(KEY_FLAG_ROOT_CAN_CLEAR, &keyring->flags);
 	cred->thread_keyring = keyring;
 	cred->jit_keyring = KEY_REQKEY_DEFL_THREAD_KEYRING;
 	root_cred = cred;
diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index 2c05f19..a1bbf77 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -198,6 +198,7 @@ int nfs_idmap_init(void)
 	if (ret < 0)
 		goto failed_put_key;
 
+	set_bit(KEY_FLAG_ROOT_CAN_CLEAR, &keyring->flags);
 	cred->thread_keyring = keyring;
 	cred->jit_keyring = KEY_REQKEY_DEFL_THREAD_KEYRING;
 	id_resolver_cache = cred;
diff --git a/include/linux/key.h b/include/linux/key.h
index 5253471..1600ebf 100644
--- a/include/linux/key.h
+++ b/include/linux/key.h
@@ -155,6 +155,7 @@ struct key {
 #define KEY_FLAG_IN_QUOTA	3	/* set if key consumes quota */
 #define KEY_FLAG_USER_CONSTRUCT	4	/* set if key is being constructed in userspace */
 #define KEY_FLAG_NEGATIVE	5	/* set if key is negative */
+#define KEY_FLAG_ROOT_CAN_CLEAR	6	/* set if key can be cleared by root without permission */
 
 	/* the description string
 	 * - this is used to match a key against search criteria
diff --git a/net/dns_resolver/dns_key.c b/net/dns_resolver/dns_key.c
index fa000d2..c73bba3 100644
--- a/net/dns_resolver/dns_key.c
+++ b/net/dns_resolver/dns_key.c
@@ -281,6 +281,7 @@ static int __init init_dns_resolver(void)
 
 	/* instruct request_key() to use this special keyring as a cache for
 	 * the results it looks up */
+	set_bit(KEY_FLAG_ROOT_CAN_CLEAR, &keyring->flags);
 	cred->thread_keyring = keyring;
 	cred->jit_keyring = KEY_REQKEY_DEFL_THREAD_KEYRING;
 	dns_resolver_cache = cred;
diff --git a/security/keys/keyctl.c b/security/keys/keyctl.c
index 0b3f5d7..6523599 100644
--- a/security/keys/keyctl.c
+++ b/security/keys/keyctl.c
@@ -388,11 +388,24 @@ long keyctl_keyring_clear(key_serial_t ringid)
 	keyring_ref = lookup_user_key(ringid, KEY_LOOKUP_CREATE, KEY_WRITE);
 	if (IS_ERR(keyring_ref)) {
 		ret = PTR_ERR(keyring_ref);
+
+		/* Root is permitted to invalidate certain special keyrings */
+		if (capable(CAP_SYS_ADMIN)) {
+			keyring_ref = lookup_user_key(ringid, 0, 0);
+			if (IS_ERR(keyring_ref))
+				goto error;
+			if (test_bit(KEY_FLAG_ROOT_CAN_CLEAR,
+				     &key_ref_to_ptr(keyring_ref)->flags))
+				goto clear;
+			goto error_put;
+		}
+
 		goto error;
 	}
 
+clear:
 	ret = keyring_clear(key_ref_to_ptr(keyring_ref));
-
+error_put:
 	key_ref_put(keyring_ref);
 error:
 	return ret;

