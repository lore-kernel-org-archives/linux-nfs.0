Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:36204 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753054AbbJTReL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Oct 2015 13:34:11 -0400
Received: by qgad10 with SMTP id d10so21645344qga.3
        for <linux-nfs@vger.kernel.org>; Tue, 20 Oct 2015 10:34:10 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH v6 13/19] nfsd: hook up nfsd_read to the nfsd_file cache
Date: Tue, 20 Oct 2015 13:33:46 -0400
Message-Id: <1445362432-18869-14-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1445362432-18869-1-git-send-email-jeff.layton@primarydata.com>
References: <1445362432-18869-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/vfs.c | 21 ++++++++-------------
 1 file changed, 8 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index cb1ab146246b..050db266ef80 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1008,20 +1008,15 @@ out_nfserr:
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
+	if (err == nfs_ok) {
+		err = nfsd_vfs_read(rqstp, nf->nf_file, offset, vec, vlen,
+					count);
+		nfsd_file_put(nf);
+	}
 	return err;
 }
 
-- 
2.4.3

