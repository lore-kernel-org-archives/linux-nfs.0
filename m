Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:9760 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753798Ab2BPSGh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Feb 2012 13:06:37 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: dhowells@redhat.com, linux-nfs@vger.kernel.org,
        Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 1/2] Created a function for setting timeouts on keys
Date: Thu, 16 Feb 2012 13:06:32 -0500
Message-Id: <1329415593-12270-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

The keyctl_set_timeout function isn't exported to other parts of the
kernel, but I want to use it for the NFS idmapper.  I already have the
key, but I wanted a generic way to set the timeout.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
David - Is there a better way to set the key rather than creating a new
function?  Should I have created the set_key_timeout() function in a
different place?

 include/linux/key.h    |    2 ++
 security/keys/key.c    |   20 ++++++++++++++++++++
 security/keys/keyctl.c |   18 ++----------------
 3 files changed, 24 insertions(+), 16 deletions(-)

diff --git a/include/linux/key.h b/include/linux/key.h
index 5253471..72c75a4 100644
--- a/include/linux/key.h
+++ b/include/linux/key.h
@@ -276,6 +276,8 @@ static inline key_serial_t key_serial(const struct key *key)
 	return key ? key->serial : 0;
 }
 
+extern void set_key_timeout(struct key *, unsigned);
+
 /**
  * key_is_instantiated - Determine if a key has been positively instantiated
  * @key: The key to check.
diff --git a/security/keys/key.c b/security/keys/key.c
index 7ada801..5bf4c21 100644
--- a/security/keys/key.c
+++ b/security/keys/key.c
@@ -671,6 +671,26 @@ found_kernel_type:
 	return ktype;
 }
 
+void set_key_timeout(struct key *key, unsigned timeout)
+{
+	struct timespec now;
+	time_t expiry = 0;
+
+	/* make the changes with the locks held to prevent races */
+	down_write(&key->sem);
+
+	if (timeout > 0) {
+		now = current_kernel_time();
+		expiry = now.tv_sec + timeout;
+	}
+
+	key->expiry = expiry;
+	key_schedule_gc(key->expiry + key_gc_delay);
+
+	up_write(&key->sem);
+}
+EXPORT_SYMBOL_GPL(set_key_timeout);
+
 /*
  * Unlock a key type locked by key_type_lookup().
  */
diff --git a/security/keys/keyctl.c b/security/keys/keyctl.c
index 0b3f5d7..894b9a2 100644
--- a/security/keys/keyctl.c
+++ b/security/keys/keyctl.c
@@ -14,6 +14,7 @@
 #include <linux/sched.h>
 #include <linux/slab.h>
 #include <linux/syscalls.h>
+#include <linux/key.h>
 #include <linux/keyctl.h>
 #include <linux/fs.h>
 #include <linux/capability.h>
@@ -1244,10 +1245,8 @@ error:
  */
 long keyctl_set_timeout(key_serial_t id, unsigned timeout)
 {
-	struct timespec now;
 	struct key *key, *instkey;
 	key_ref_t key_ref;
-	time_t expiry;
 	long ret;
 
 	key_ref = lookup_user_key(id, KEY_LOOKUP_CREATE | KEY_LOOKUP_PARTIAL,
@@ -1273,20 +1272,7 @@ long keyctl_set_timeout(key_serial_t id, unsigned timeout)
 
 okay:
 	key = key_ref_to_ptr(key_ref);
-
-	/* make the changes with the locks held to prevent races */
-	down_write(&key->sem);
-
-	expiry = 0;
-	if (timeout > 0) {
-		now = current_kernel_time();
-		expiry = now.tv_sec + timeout;
-	}
-
-	key->expiry = expiry;
-	key_schedule_gc(key->expiry + key_gc_delay);
-
-	up_write(&key->sem);
+	set_key_timeout(key, timeout);
 	key_put(key);
 
 	ret = 0;
-- 
1.7.9

