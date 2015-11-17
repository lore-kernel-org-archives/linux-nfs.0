Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:35724 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753172AbbKQLxf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Nov 2015 06:53:35 -0500
Received: by qgec40 with SMTP id c40so3392320qge.2
        for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2015 03:53:35 -0800 (PST)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org, trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Eric Paris <eparis@parisplace.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org
Subject: [PATCH v1 17/38] nfsd: hook nfsd_commit up to the nfsd_file cache
Date: Tue, 17 Nov 2015 06:52:39 -0500
Message-Id: <1447761180-4250-18-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
References: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use cached filps if possible instead of opening a new one every time.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/vfs.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 0873c1355bb1..62e6194d58f8 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1058,9 +1058,9 @@ __be32
 nfsd_commit(struct svc_rqst *rqstp, struct svc_fh *fhp,
                loff_t offset, unsigned long count)
 {
-	struct file	*file;
-	loff_t		end = LLONG_MAX;
-	__be32		err = nfserr_inval;
+	struct nfsd_file	*nf;
+	loff_t			end = LLONG_MAX;
+	__be32			err = nfserr_inval;
 
 	if (offset < 0)
 		goto out;
@@ -1070,12 +1070,12 @@ nfsd_commit(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			goto out;
 	}
 
-	err = nfsd_open(rqstp, fhp, S_IFREG,
-			NFSD_MAY_WRITE|NFSD_MAY_NOT_BREAK_LEASE, &file);
+	err = nfsd_file_acquire(rqstp, fhp,
+			NFSD_MAY_WRITE|NFSD_MAY_NOT_BREAK_LEASE, &nf);
 	if (err)
 		goto out;
 	if (EX_ISSYNC(fhp->fh_export)) {
-		int err2 = vfs_fsync_range(file, offset, end, 0);
+		int err2 = vfs_fsync_range(nf->nf_file, offset, end, 0);
 
 		if (err2 != -EINVAL)
 			err = nfserrno(err2);
@@ -1083,7 +1083,7 @@ nfsd_commit(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			err = nfserr_notsupp;
 	}
 
-	fput(file);
+	nfsd_file_put(nf);
 out:
 	return err;
 }
-- 
2.4.3

