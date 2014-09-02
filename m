Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f181.google.com ([209.85.192.181]:50031 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753522AbaIBOOA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Sep 2014 10:14:00 -0400
Received: by mail-pd0-f181.google.com with SMTP id fp1so8792245pdb.12
        for <linux-nfs@vger.kernel.org>; Tue, 02 Sep 2014 07:14:00 -0700 (PDT)
Message-ID: <5405D08C.8060609@gmail.com>
Date: Tue, 02 Sep 2014 22:13:32 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH 4/6] NFSD: Fix bad using of return value from qword_get
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4idmap.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index a0ab0a8..dc948f6 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -368,7 +368,7 @@ nametoid_parse(struct cache_detail *cd, char *buf, int buflen)
 {
 	struct ent ent, *res;
 	char *buf1;
-	int error = -EINVAL;
+	int len, error = -EINVAL;
 
 	if (buf[buflen - 1] != '\n')
 		return (-EINVAL);
@@ -392,8 +392,8 @@ nametoid_parse(struct cache_detail *cd, char *buf, int buflen)
 		IDMAP_TYPE_USER : IDMAP_TYPE_GROUP;
 
 	/* Name */
-	error = qword_get(&buf, buf1, PAGE_SIZE);
-	if (error <= 0 || error >= IDMAP_NAMESZ)
+	len = qword_get(&buf, buf1, PAGE_SIZE);
+	if (len <= 0 || len >= IDMAP_NAMESZ)
 		goto out;
 	memcpy(ent.name, buf1, sizeof(ent.name));
 
-- 
1.9.3

