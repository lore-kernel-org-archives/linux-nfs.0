Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f41.google.com ([209.85.220.41]:40728 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751413AbaFYLCU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jun 2014 07:02:20 -0400
Received: by mail-pa0-f41.google.com with SMTP id fb1so1590177pad.28
        for <linux-nfs@vger.kernel.org>; Wed, 25 Jun 2014 04:02:20 -0700 (PDT)
Message-ID: <53AAAC23.90201@gmail.com>
Date: Wed, 25 Jun 2014 19:01:55 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, kinglongmee@gmail.com
Subject: [PATCH 3/4] NFSD: Fix bad using of return value from qword_get
Content-Type: text/plain; charset=ISO-8859-1
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

