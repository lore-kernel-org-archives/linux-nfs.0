Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:28800 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751813Ab3FZSJs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Jun 2013 14:09:48 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Improve legacy idmapping fallback
Date: Wed, 26 Jun 2013 14:09:46 -0400
Message-Id: <1372270186-576-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

Fallback should happen only when the request_key() call fails, because
this indicates that there was a problem running the nfsidmap program.
We shouldn't call the legacy code if the error was elsewhere.

Signed-off-by: Bryan Schumaker <bjschuma@netappp.com>
---
 fs/nfs/idmap.c | 56 ++++++++++++++++++++++++++------------------------------
 1 file changed, 26 insertions(+), 30 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index c516da5..c2c4163 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -262,29 +262,42 @@ static ssize_t nfs_idmap_get_desc(const char *name, size_t namelen,
 	return desclen;
 }
 
-static ssize_t nfs_idmap_request_key(struct key_type *key_type,
-				     const char *name, size_t namelen,
-				     const char *type, void *data,
-				     size_t data_size, struct idmap *idmap)
+static struct key *nfs_idmap_request_key(const char *name, size_t namelen,
+					 const char *type, struct idmap *idmap)
 {
-	const struct cred *saved_cred;
-	struct key *rkey;
 	char *desc;
-	struct user_key_payload *payload;
+	struct key *rkey;
 	ssize_t ret;
 
 	ret = nfs_idmap_get_desc(name, namelen, type, strlen(type), &desc);
 	if (ret <= 0)
-		goto out;
+		return ERR_PTR(ret);
+
+	rkey = request_key(&key_type_id_resolver, desc, "");
+	if (IS_ERR(rkey)) {
+		mutex_lock(&idmap->idmap_mutex);
+		rkey = request_key_with_auxdata(&key_type_id_resolver_legacy,
+						desc, "", 0, idmap);
+		mutex_unlock(&idmap->idmap_mutex);
+	}
+
+	kfree(desc);
+	return rkey;
+}
+
+static ssize_t nfs_idmap_get_key(const char *name, size_t namelen,
+				 const char *type, void *data,
+				 size_t data_size, struct idmap *idmap)
+{
+	const struct cred *saved_cred;
+	struct key *rkey;
+	struct user_key_payload *payload;
+	ssize_t ret;
 
 	saved_cred = override_creds(id_resolver_cache);
-	if (idmap)
-		rkey = request_key_with_auxdata(key_type, desc, "", 0, idmap);
-	else
-		rkey = request_key(&key_type_id_resolver, desc, "");
+	rkey = nfs_idmap_request_key(name, namelen, type, idmap);
 	revert_creds(saved_cred);
 
-	kfree(desc);
 	if (IS_ERR(rkey)) {
 		ret = PTR_ERR(rkey);
 		goto out;
@@ -316,23 +329,6 @@ out:
 	return ret;
 }
 
-static ssize_t nfs_idmap_get_key(const char *name, size_t namelen,
-				 const char *type, void *data,
-				 size_t data_size, struct idmap *idmap)
-{
-	ssize_t ret = nfs_idmap_request_key(&key_type_id_resolver,
-					    name, namelen, type, data,
-					    data_size, NULL);
-	if (ret < 0) {
-		mutex_lock(&idmap->idmap_mutex);
-		ret = nfs_idmap_request_key(&key_type_id_resolver_legacy,
-					    name, namelen, type, data,
-					    data_size, idmap);
-		mutex_unlock(&idmap->idmap_mutex);
-	}
-	return ret;
-}
-
 /* ID -> Name */
 static ssize_t nfs_idmap_lookup_name(__u32 id, const char *type, char *buf,
 				     size_t buflen, struct idmap *idmap)
-- 
1.8.3.1

