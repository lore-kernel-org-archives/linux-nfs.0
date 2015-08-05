Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f169.google.com ([209.85.160.169]:36536 "EHLO
	mail-yk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752471AbbHEVNr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Aug 2015 17:13:47 -0400
Received: by ykeo23 with SMTP id o23so46444063yke.3
        for <linux-nfs@vger.kernel.org>; Wed, 05 Aug 2015 14:13:47 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 06/18] nfsd: hook up nfsd_read to the nfsd_file cache
Date: Wed,  5 Aug 2015 17:13:24 -0400
Message-Id: <1438809216-4846-7-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1438809216-4846-1-git-send-email-jeff.layton@primarydata.com>
References: <1438264341-18048-1-git-send-email-jeff.layton@primarydata.com>
 <1438809216-4846-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/vfs.c | 20 +++++++-------------
 1 file changed, 7 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 59234d1d8d8e..fd688c86af66 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -980,20 +980,14 @@ out_nfserr:
 __be32 nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	loff_t offset, struct kvec *vec, int vlen, unsigned long *count)
 {
-	struct file *file;
-	struct raparms	*ra;
-	__be32 err;
-
-	err = nfsd_open(rqstp, fhp, S_IFREG, NFSD_MAY_READ, &file);
-	if (err)
-		return err;
-
-	ra = nfsd_init_raparms(file);
-	err = nfsd_vfs_read(rqstp, file, offset, vec, vlen, count);
-	if (ra)
-		nfsd_put_raparams(file, ra);
-	fput(file);
+	__be32			err;
+	struct nfsd_file	*nf;
 
+	err = nfsd_file_acquire(rqstp, fhp, NFSD_MAY_READ, &nf);
+	if (err == nfs_ok)
+		err = nfsd_vfs_read(rqstp, nf->nf_file, offset, vec, vlen,
+					count);
+	nfsd_file_put(nf);
 	return err;
 }
 
-- 
2.4.3

