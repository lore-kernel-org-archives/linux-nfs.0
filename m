Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f44.google.com ([209.85.219.44]:49225 "EHLO
	mail-oa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151AbaEXD1J (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 May 2014 23:27:09 -0400
Received: by mail-oa0-f44.google.com with SMTP id o6so6446533oag.3
        for <linux-nfs@vger.kernel.org>; Fri, 23 May 2014 20:27:09 -0700 (PDT)
Message-ID: <53801179.8080502@gmail.com>
Date: Sat, 24 May 2014 11:26:49 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, kinglongmee@gmail.com
Subject: [PATCH] NFSD: Using type of uint32_t for ex_nflavors instead of int
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

ex_nflavors can't be negative number, just defined by uint32_t.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/export.c | 7 ++++---
 fs/nfsd/export.h | 2 +-
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 8513c59..9343ae2 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -437,13 +437,14 @@ out_free_all:
 
 static int secinfo_parse(char **mesg, char *buf, struct svc_export *exp)
 {
-	int listsize, err;
 	struct exp_flavor_info *f;
+	u32 listsize;
+	int err;
 
-	err = get_int(mesg, &listsize);
+	err = get_uint(mesg, &listsize);
 	if (err)
 		return err;
-	if (listsize < 0 || listsize > MAX_SECINFO_LIST)
+	if (listsize > MAX_SECINFO_LIST)
 		return -EINVAL;
 
 	for (f = exp->ex_flavors; f < exp->ex_flavors + listsize; f++) {
diff --git a/fs/nfsd/export.h b/fs/nfsd/export.h
index d7939a6..11d03b9 100644
--- a/fs/nfsd/export.h
+++ b/fs/nfsd/export.h
@@ -53,7 +53,7 @@ struct svc_export {
 	int			ex_fsid;
 	unsigned char *		ex_uuid; /* 16 byte fsid */
 	struct nfsd4_fs_locations ex_fslocs;
-	int			ex_nflavors;
+	uint32_t		ex_nflavors;
 	struct exp_flavor_info	ex_flavors[MAX_SECINFO_LIST];
 	struct cache_detail	*cd;
 };
-- 
1.9.3

