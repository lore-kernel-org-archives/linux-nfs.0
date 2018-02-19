Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38414 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751000AbeBSFDf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Feb 2018 00:03:35 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Mon, 19 Feb 2018 16:02:28 +1100
Subject: [PATCH 04/23] cred: allow get_cred() and put_cred() to be given
 NULL.
Cc: linux-nfs@vger.kernel.org
Message-ID: <151901654887.17421.3586411951654781069.stgit@noble>
In-Reply-To: <151901634940.17421.7637564368419392071.stgit@noble>
References: <151901634940.17421.7637564368419392071.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It is common practice of helps like this so silently,
accept a NULL pointer.
get_rpccred() and put_rpccred() used by NFS act this way
and using the same interface will ease the conversion
for NFS, and simplify the resulting code.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 include/linux/cred.h |   14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/include/linux/cred.h b/include/linux/cred.h
index 69ed76f7d49f..c9ba3c8747e9 100644
--- a/include/linux/cred.h
+++ b/include/linux/cred.h
@@ -232,7 +232,7 @@ static inline struct cred *get_new_cred(struct cred *cred)
  * @cred: The credentials to reference
  *
  * Get a reference on the specified set of credentials.  The caller must
- * release the reference.
+ * release the reference.  If %NULL is passed, it is returned with no action.
  *
  * This is used to deal with a committed set of credentials.  Although the
  * pointer is const, this will temporarily discard the const and increment the
@@ -243,6 +243,8 @@ static inline struct cred *get_new_cred(struct cred *cred)
 static inline const struct cred *get_cred(const struct cred *cred)
 {
 	struct cred *nonconst_cred = (struct cred *) cred;
+	if (!cred)
+		return cred;
 	validate_creds(cred);
 	return get_new_cred(nonconst_cred);
 }
@@ -263,7 +265,7 @@ static inline const struct cred *get_cred_rcu(const struct cred *cred)
  * @cred: The credentials to release
  *
  * Release a reference to a set of credentials, deleting them when the last ref
- * is released.
+ * is released.  If %NULL is passed, nothing is done.
  *
  * This takes a const pointer to a set of credentials because the credentials
  * on task_struct are attached by const pointers to prevent accidental
@@ -273,9 +275,11 @@ static inline void put_cred(const struct cred *_cred)
 {
 	struct cred *cred = (struct cred *) _cred;
 
-	validate_creds(cred);
-	if (atomic_dec_and_test(&(cred)->usage))
-		__put_cred(cred);
+	if (cred) {
+		validate_creds(cred);
+		if (atomic_dec_and_test(&(cred)->usage))
+			__put_cred(cred);
+	}
 }
 
 /**


