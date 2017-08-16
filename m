Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:38876 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752105AbdHPVRR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Aug 2017 17:17:17 -0400
From: Eric Biggers <ebiggers3@gmail.com>
To: keyrings@vger.kernel.org
Cc: David Howells <dhowells@redhat.com>, linux-api@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-fscrypt@vger.kernel.org,
        linux-nfs@vger.kernel.org, Gwendal Grignou <gwendal@chromium.org>,
        Jaegeuk Kim <jaegeuk@kernel.org>,
        Paul Crowley <paulcrowley@google.com>,
        Richard Weinberger <richard@nod.at>,
        Ryo Hashimoto <hashimoto@google.com>,
        Tyler Hicks <tyhicks@canonical.com>, stable@vger.kernel.org
Subject: [PATCH v2] KEYS: make keyctl_invalidate() also require Setattr permission
Date: Wed, 16 Aug 2017 14:14:03 -0700
Message-Id: <20170816211403.121920-1-ebiggers3@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Currently, a process only needs Search permission on a key to invalidate
it with keyctl_invalidate(), which has an effect similar to unlinking it
from all keyrings.  Unfortunately, this significantly compromises the
keys permission system because as a result, there is no way to grant
read-only access to keys without also granting de-facto "delete" access.
Even worse, processes may invalidate entire _keyrings_, given only
permission to "search" them.  It is not even possible to block this
using SELinux, because SELinux is likewise only asked for Search
permission, which needs to be allowed for read-only access.

Key invalidation seems to have intended for cases where keyrings are
used as caches, and keys can be re-requested at any time by an upcall to
/sbin/request-key.  However, keyrings are not always used in this way.
For example, users of filesystem-level encryption (EXT4, F2FS, and/or
UBIFS encryption) usually wish to grant many differently-privileged
processes access to the same keys, set up in a shared keyring ahead of
time.  Permitting everyone to invalidate keys in this scenario enables a
trivial denial-of-service.  And even users of keyrings as "just caches"
may wish to restrict invalidation because it may require significant
work or user interaction to regenerate keys.

This patch fixes the flaw by requiring both Search and Setattr
permission to invalidate a key rather than just Search permission.
Requiring Setattr permission is appropriate because Setattr permission
also allows revoking (via keyctl_revoke()) or expiring (via
keyctl_set_timeout()) the key, which also make the key inaccessible
regardless of how many keyrings it is in.  Continuing to require Search
permission ensures we do not decrease the level of permissions required.

Alternatively, the problem could be solved by requiring Write
permission.  However, that would be less appropriate because Write
permission is ostensibly meant to deal with the key payload, not the key
itself.  A new "Invalidate" permission would also work, but that would
require keyctl_setperm() users to start including a new permission which
never existed before, which would be much more likely to break users of
keyctl_invalidate().  Finally, we could only allow invalidating keys
which the kernel has explicitly marked as invalidatible, e.g. the
"id_resolver" keys created for NFSv4 ID mapping.  However, that likewise
would be much more likely to break users.

This is a user-visible API change.  But we don't seem to have much
choice, and any breakage will be limited to users who override the
default key permissions using keyctl_setperm() to remove Setattr
permission, then later call keyctl_invalidate().  There are probably not
many such users, possibly even none at all.  In fact, the only users of
keyctl_invalidate() I could find are nfsidmap and the Chromium OS
cryptohome daemon.  nfsidmap will be unaffected because it runs as root
and actually relies on the "root is permitted to invalidate certain
special keys" exception (KEY_FLAG_ROOT_CAN_INVAL) rather than the actual
key permissions.  cryptohomed will be unaffected because it already owns
the keys and sets KEY_USR_SETATTR permission on them.

Cc: linux-api@vger.kernel.org
Cc: linux-cifs@vger.kernel.org
Cc: linux-fscrypt@vger.kernel.org
Cc: linux-nfs@vger.kernel.org
Cc: Gwendal Grignou <gwendal@chromium.org>
Cc: Jaegeuk Kim <jaegeuk@kernel.org>
Cc: Paul Crowley <paulcrowley@google.com>
Cc: Richard Weinberger <richard@nod.at>
Cc: Ryo Hashimoto <hashimoto@google.com>
Cc: Tyler Hicks <tyhicks@canonical.com>
Cc: stable@vger.kernel.org # v3.5+
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 Documentation/security/keys/core.rst | 4 ++--
 security/keys/keyctl.c               | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/Documentation/security/keys/core.rst b/Documentation/security/keys/core.rst
index 1648fa80b3bf..c8030f628810 100644
--- a/Documentation/security/keys/core.rst
+++ b/Documentation/security/keys/core.rst
@@ -815,8 +815,8 @@ The keyctl syscall functions are:
      immediately, though they are still visible in /proc/keys until deleted
      (they're marked with an 'i' flag).
 
-     A process must have search permission on the key for this function to be
-     successful.
+     A process must have Search and Setattr permission on the key for this
+     function to be successful.
 
   *  Compute a Diffie-Hellman shared secret or public key::
 
diff --git a/security/keys/keyctl.c b/security/keys/keyctl.c
index ab0b337c84b4..0739e7934e74 100644
--- a/security/keys/keyctl.c
+++ b/security/keys/keyctl.c
@@ -400,7 +400,7 @@ long keyctl_revoke_key(key_serial_t id)
 /*
  * Invalidate a key.
  *
- * The key must be grant the caller Invalidate permission for this to work.
+ * The key must grant the caller Search and Setattr permission for this to work.
  * The key and any links to the key will be automatically garbage collected
  * immediately.
  *
@@ -416,7 +416,7 @@ long keyctl_invalidate_key(key_serial_t id)
 
 	kenter("%d", id);
 
-	key_ref = lookup_user_key(id, 0, KEY_NEED_SEARCH);
+	key_ref = lookup_user_key(id, 0, KEY_NEED_SEARCH | KEY_NEED_SETATTR);
 	if (IS_ERR(key_ref)) {
 		ret = PTR_ERR(key_ref);
 
-- 
2.14.1.480.gb18f417b89-goog

