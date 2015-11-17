Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f49.google.com ([209.85.192.49]:34692 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752901AbbKQLxf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Nov 2015 06:53:35 -0500
Received: by qgeb1 with SMTP id b1so3410576qge.1
        for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2015 03:53:34 -0800 (PST)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org, trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Eric Paris <eparis@parisplace.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org
Subject: [PATCH v1 16/38] nfsd: hook up nfsd_read to the nfsd_file cache
Date: Tue, 17 Nov 2015 06:52:38 -0500
Message-Id: <1447761180-4250-17-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
References: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/vfs.c | 28 ++++++++++------------------
 1 file changed, 10 insertions(+), 18 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 0f31af897d4c..0873c1355bb1 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1003,27 +1003,19 @@ out_nfserr:
 __be32 nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	loff_t offset, struct kvec *vec, int vlen, unsigned long *count)
 {
-	struct file *file;
-	struct raparms	*ra;
-	__be32 err;
+	__be32			err;
+	struct nfsd_file	*nf;
 
 	trace_read_start(rqstp, fhp, offset, vlen);
-	err = nfsd_open(rqstp, fhp, S_IFREG, NFSD_MAY_READ, &file);
-	if (err)
-		return err;
-
-	ra = nfsd_init_raparms(file);
-
-	trace_read_opened(rqstp, fhp, offset, vlen);
-	err = nfsd_vfs_read(rqstp, file, offset, vec, vlen, count);
-	trace_read_io_done(rqstp, fhp, offset, vlen);
-
-	if (ra)
-		nfsd_put_raparams(file, ra);
-	fput(file);
-
+	err = nfsd_file_acquire(rqstp, fhp, NFSD_MAY_READ, &nf);
+	if (err == nfs_ok) {
+		trace_read_opened(rqstp, fhp, offset, vlen);
+		err = nfsd_vfs_read(rqstp, nf->nf_file, offset, vec, vlen,
+					count);
+		trace_read_io_done(rqstp, fhp, offset, vlen);
+		nfsd_file_put(nf);
+	}
 	trace_read_done(rqstp, fhp, offset, vlen);
-
 	return err;
 }
 
-- 
2.4.3

