Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43304 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751096Ab1AEB57 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jan 2011 20:57:59 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v4 2/5] NFSv4: Send unmapped uid/gids to the server if the idmapper fails
Date: Tue,  4 Jan 2011 20:57:48 -0500
Message-Id: <1294192671-18864-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1294192671-18864-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1294192671-18864-1-git-send-email-Trond.Myklebust@netapp.com>
 <1294192671-18864-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/idmap.c |   30 ++++++++++++++++++++++++++----
 1 files changed, 26 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index cbe6e2f..8518573 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -52,6 +52,11 @@ static int nfs_map_string_to_numeric(const char *name, size_t namelen, __u32 *re
 	return 1;
 }
 
+static int nfs_map_numeric_to_string(__u32 id, char *buf, size_t buflen)
+{
+	return snprintf(buf, buflen, "%u", id);
+}
+
 #ifdef CONFIG_NFS_USE_NEW_IDMAPPER
 
 #include <linux/slab.h>
@@ -252,11 +257,20 @@ int nfs_map_group_to_gid(struct nfs_client *clp, const char *name, size_t namele
 
 int nfs_map_uid_to_name(struct nfs_client *clp, __u32 uid, char *buf, size_t buflen)
 {
-	return nfs_idmap_lookup_name(uid, "user", buf, buflen);
+	int ret;
+	ret = nfs_idmap_lookup_name(uid, "user", buf, buflen);
+	if (ret < 0)
+		ret = nfs_map_numeric_to_string(uid, buf, buflen);
+	return ret;
 }
 int nfs_map_gid_to_group(struct nfs_client *clp, __u32 gid, char *buf, size_t buflen)
 {
-	return nfs_idmap_lookup_name(gid, "group", buf, buflen);
+	int ret;
+
+	ret = nfs_idmap_lookup_name(gid, "group", buf, buflen);
+	if (ret < 0)
+		ret = nfs_map_numeric_to_string(gid, buf, buflen);
+	return ret;
 }
 
 #else  /* CONFIG_NFS_USE_NEW_IDMAPPER not defined */
@@ -736,14 +750,22 @@ int nfs_map_group_to_gid(struct nfs_client *clp, const char *name, size_t namele
 int nfs_map_uid_to_name(struct nfs_client *clp, __u32 uid, char *buf, size_t buflen)
 {
 	struct idmap *idmap = clp->cl_idmap;
+	int ret;
 
-	return nfs_idmap_name(idmap, &idmap->idmap_user_hash, uid, buf);
+	ret = nfs_idmap_name(idmap, &idmap->idmap_user_hash, uid, buf);
+	if (ret < 0)
+		ret = nfs_map_numeric_to_string(uid, buf, buflen);
+	return ret;
 }
 int nfs_map_gid_to_group(struct nfs_client *clp, __u32 uid, char *buf, size_t buflen)
 {
 	struct idmap *idmap = clp->cl_idmap;
+	int ret;
 
-	return nfs_idmap_name(idmap, &idmap->idmap_group_hash, uid, buf);
+	ret = nfs_idmap_name(idmap, &idmap->idmap_group_hash, uid, buf);
+	if (ret < 0)
+		ret = nfs_map_numeric_to_string(uid, buf, buflen);
+	return ret;
 }
 
 #endif /* CONFIG_NFS_USE_NEW_IDMAPPER */
-- 
1.7.3.4

