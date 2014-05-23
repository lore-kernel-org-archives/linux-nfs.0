Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f175.google.com ([209.85.216.175]:58010 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752608AbaEWM4E (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 May 2014 08:56:04 -0400
Received: by mail-qc0-f175.google.com with SMTP id w7so7959265qcr.6
        for <linux-nfs@vger.kernel.org>; Fri, 23 May 2014 05:56:02 -0700 (PDT)
Message-ID: <537F454F.3080006@gmail.com>
Date: Fri, 23 May 2014 20:55:43 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, kinglongmee@gmail.com
Subject: [PATCH 4/5] NFSD: Remove typedef of svc_client and svc_export in
 export.c
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

No need for a typedef wrapper for svc_export or svc_client, remove them.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/export.c | 19 ++++++++-----------
 1 file changed, 8 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 34cabab..39d15ce 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -23,9 +23,6 @@
 
 #define NFSDDBG_FACILITY	NFSDDBG_EXPORT
 
-typedef struct auth_domain	svc_client;
-typedef struct svc_export	svc_export;
-
 /*
  * We have two caches.
  * One maps client+vfsmnt+dentry to export options - the export map
@@ -795,7 +792,7 @@ svc_export_update(struct svc_export *new, struct svc_export *old)
 
 
 static struct svc_expkey *
-exp_find_key(struct cache_detail *cd, svc_client *clp, int fsid_type,
+exp_find_key(struct cache_detail *cd, struct auth_domain *clp, int fsid_type,
 	     u32 *fsidv, struct cache_req *reqp)
 {
 	struct svc_expkey key, *ek;
@@ -817,9 +814,9 @@ exp_find_key(struct cache_detail *cd, svc_client *clp, int fsid_type,
 	return ek;
 }
 
-
-static svc_export *exp_get_by_name(struct cache_detail *cd, svc_client *clp,
-				   const struct path *path, struct cache_req *reqp)
+static struct svc_export *
+exp_get_by_name(struct cache_detail *cd, struct auth_domain *clp,
+		const struct path *path, struct cache_req *reqp)
 {
 	struct svc_export *exp, key;
 	int err;
@@ -843,11 +840,11 @@ static svc_export *exp_get_by_name(struct cache_detail *cd, svc_client *clp,
 /*
  * Find the export entry for a given dentry.
  */
-static struct svc_export *exp_parent(struct cache_detail *cd, svc_client *clp,
-				     struct path *path)
+static struct svc_export *
+exp_parent(struct cache_detail *cd, struct auth_domain *clp, struct path *path)
 {
 	struct dentry *saved = dget(path->dentry);
-	svc_export *exp = exp_get_by_name(cd, clp, path, NULL);
+	struct svc_export *exp = exp_get_by_name(cd, clp, path, NULL);
 
 	while (PTR_ERR(exp) == -ENOENT && !IS_ROOT(path->dentry)) {
 		struct dentry *parent = dget_parent(path->dentry);
@@ -868,7 +865,7 @@ static struct svc_export *exp_parent(struct cache_detail *cd, svc_client *clp,
  * since its harder to fool a kernel module than a user space program.
  */
 int
-exp_rootfh(struct net *net, svc_client *clp, char *name,
+exp_rootfh(struct net *net, struct auth_domain *clp, char *name,
 	   struct knfsd_fh *f, int maxsize)
 {
 	struct svc_export	*exp;
-- 
1.9.3

