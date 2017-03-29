Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:35952 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932562AbdC2WFg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Mar 2017 18:05:36 -0400
Received: by mail-pg0-f42.google.com with SMTP id g2so19327166pge.3
        for <linux-nfs@vger.kernel.org>; Wed, 29 Mar 2017 15:05:35 -0700 (PDT)
From: Eric Biggers <ebiggers@google.com>
To: keyrings@vger.kernel.org
Cc: David Howells <dhowells@redhat.com>, linux-api@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-fscrypt@vger.kernel.org,
        linux-nfs@vger.kernel.org, Gwendal Grignou <gwendal@chromium.org>,
        Jaegeuk Kim <jaegeuk@kernel.org>,
        Richard Weinberger <richard@nod.at>,
        Theodore Ts'o <tytso@mit.edu>, stable@vger.kernel.org
Subject: [PATCH] KEYS: make keyctl_invalidate() also require Setattr permission
Date: Wed, 29 Mar 2017 15:01:01 -0700
Message-Id: <20170329220101.26067-1-ebiggers@google.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, a process only needs Search permission on a key to invalidate
it with keyctl_invalidate(), which has an effect similar to unlinking it
from all keyrings.  Unfortunately, this significantly compromises the
keys permission system because as a result, there is no way to grant
read-only access to keys without also granting de-facto "delete" access.
Even worse, processes may invalidate entire _keyrings_, given only
permission to "search" them.

Key invalidation seems to have intended for cases where keyrings are
used as caches, and keys can be re-requested at any time by an upcall to
/sbin/request-key.  However, keyrings are not always used in this way.
For example, users of ext4, f2fs, and ubifs encryption may wish to grant
many differently-privileged processes access to the same keys, set up in
a shared keyring ahead of time.  Permitting everyone to invalidate keys
in this scenario enables a trivial denial-of-service.  And even users of
keyrings as "just caches" may wish to restrict invalidation because it
may require significant work or user interaction to regenerate keys.

This patch fixes the flaw by requiring both Search and Setattr
permission to invalidate a key rather than just Search permission.
Requiring Setattr permission is appropriate because Setattr permission
also allows revoking (via keyctl_revoke()) or expiring (via
keyctl_set_timeout()) the key, which also make the key inaccessible
regardless of how many keyrings it is in.  Continuing to require Search
permission ensures we do not decrease the level of permissions required.

The problem could also be solved by requiring Write permission, but this
would arguably be less relevant because Write is supposed to deal with
the key payload, not the key itself.  A new "Invalidate" permission
would also work but would require keyctl_setperm() users to start
including a new permission which never existed before.

This is a user-visible API change.  But we don't seem to have much
choice, and any breakage will be limited to users who override the
default key permissions using keyctl_setperm() to remove Setattr
permission, then later call keyctl_invalidate().  There are probably not
many such users, possibly even none at all.  In fact, the only user of
keyctl_invalidate() I could find is nfsidmap, which will be unaffected
because it relies on the "root is permitted to invalidate certain
special keys" exception rather than the actual key permissions.

Cc: linux-api@vger.kernel.org
Cc: linux-cifs@vger.kernel.org
Cc: linux-fscrypt@vger.kernel.org
Cc: linux-nfs@vger.kernel.org
Cc: Gwendal Grignou <gwendal@chromium.org>
Cc: Jaegeuk Kim <jaegeuk@kernel.org>
Cc: Richard Weinberger <richard@nod.at>
Cc: Theodore Ts'o <tytso@mit.edu>
Cc: stable@vger.kernel.org # v3.5+
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 Documentation/security/keys.txt | 4 ++--
 security/keys/keyctl.c          | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/Documentation/security/keys.txt b/Documentation/security/keys.txt
index 0e03baf271bd..b167f352c043 100644
--- a/Documentation/security/keys.txt
+++ b/Documentation/security/keys.txt
@@ -820,8 +820,8 @@ The keyctl syscall functions are:
      immediately, though they are still visible in /proc/keys until deleted
      (they're marked with an 'i' flag).
 
-     A process must have search permission on the key for this function to be
-     successful.
+     A process must have Search and Setattr permission on the key for this
+     function to be successful.
 
  (*) Compute a Diffie-Hellman shared secret or public key
 
diff --git a/security/keys/keyctl.c b/security/keys/keyctl.c
index 52c34532c785..c58674710251 100644
--- a/security/keys/keyctl.c
+++ b/security/keys/keyctl.c
@@ -397,7 +397,7 @@ long keyctl_revoke_key(key_serial_t id)
 /*
  * Invalidate a key.
  *
- * The key must be grant the caller Invalidate permission for this to work.
+ * The key must grant the caller Search and Setattr permission for this to work.
  * The key and any links to the key will be automatically garbage collected
  * immediately.
  *
@@ -413,7 +413,7 @@ long keyctl_invalidate_key(key_serial_t id)
 
 	kenter("%d", id);
 
-	key_ref = lookup_user_key(id, 0, KEY_NEED_SEARCH);
+	key_ref = lookup_user_key(id, 0, KEY_NEED_SEARCH | KEY_NEED_SETATTR);
 	if (IS_ERR(key_ref)) {
 		ret = PTR_ERR(key_ref);
 
-- 
2.12.2.564.g063fe858b8-goog

