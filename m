Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f42.google.com ([209.85.220.42]:39072 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751413AbaFYLD3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jun 2014 07:03:29 -0400
Received: by mail-pa0-f42.google.com with SMTP id lj1so1597909pab.29
        for <linux-nfs@vger.kernel.org>; Wed, 25 Jun 2014 04:03:29 -0700 (PDT)
Message-ID: <53AAAC63.5040307@gmail.com>
Date: Wed, 25 Jun 2014 19:02:59 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, kinglongmee@gmail.com
Subject: [PATCH 4/4] NFSD: Add missing checking of authentication name
Content-Type: text/plain; charset=ISO-8859-1
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

