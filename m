Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f175.google.com ([209.85.192.175]:48455 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753491AbaIBOOu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Sep 2014 10:14:50 -0400
Received: by mail-pd0-f175.google.com with SMTP id ft15so8770323pdb.34
        for <linux-nfs@vger.kernel.org>; Tue, 02 Sep 2014 07:14:49 -0700 (PDT)
Message-ID: <5405D0C7.3080400@gmail.com>
Date: Tue, 02 Sep 2014 22:14:31 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH 5/6] NFSD: Full checking of authentication name
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4idmap.c | 14 +++++---------
 1 file changed, 5 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index dc948f6..e1b3d3d 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -215,7 +215,8 @@ idtoname_parse(struct cache_detail *cd, char *buf, int buflen)
 	memset(&ent, 0, sizeof(ent));
 
 	/* Authentication name */
-	if (qword_get(&buf, buf1, PAGE_SIZE) <= 0)
+	len = qword_get(&buf, buf1, PAGE_SIZE);
+	if (len <= 0 || len >= IDMAP_NAMESZ)
 		goto out;
 	memcpy(ent.authname, buf1, sizeof(ent.authname));
 
@@ -245,12 +246,10 @@ idtoname_parse(struct cache_detail *cd, char *buf, int buflen)
 	/* Name */
 	error = -EINVAL;
 	len = qword_get(&buf, buf1, PAGE_SIZE);
-	if (len < 0)
+	if (len < 0 || len >= IDMAP_NAMESZ)
 		goto out;
 	if (len == 0)
 		set_bit(CACHE_NEGATIVE, &ent.h.flags);
-	else if (len >= IDMAP_NAMESZ)
-		goto out;
 	else
 		memcpy(ent.name, buf1, sizeof(ent.name));
 	error = -ENOMEM;
@@ -259,15 +258,12 @@ idtoname_parse(struct cache_detail *cd, char *buf, int buflen)
 		goto out;
 
 	cache_put(&res->h, cd);
-
 	error = 0;
 out:
 	kfree(buf1);
-
 	return error;
 }
 
-
 static struct ent *
 idtoname_lookup(struct cache_detail *cd, struct ent *item)
 {
@@ -381,7 +377,8 @@ nametoid_parse(struct cache_detail *cd, char *buf, int buflen)
 	memset(&ent, 0, sizeof(ent));
 
 	/* Authentication name */
-	if (qword_get(&buf, buf1, PAGE_SIZE) <= 0)
+	len = qword_get(&buf, buf1, PAGE_SIZE);
+	if (len <= 0 || len >= IDMAP_NAMESZ)
 		goto out;
 	memcpy(ent.authname, buf1, sizeof(ent.authname));
 
@@ -421,7 +418,6 @@ nametoid_parse(struct cache_detail *cd, char *buf, int buflen)
 	error = 0;
 out:
 	kfree(buf1);
-
 	return (error);
 }
 
-- 
1.9.3

