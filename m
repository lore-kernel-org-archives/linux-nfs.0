Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:35529 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753060AbbJTReL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Oct 2015 13:34:11 -0400
Received: by qgbb65 with SMTP id b65so21695710qgb.2
        for <linux-nfs@vger.kernel.org>; Tue, 20 Oct 2015 10:34:11 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH v6 14/19] nfsd: hook nfsd_commit up to the nfsd_file cache
Date: Tue, 20 Oct 2015 13:33:47 -0400
Message-Id: <1445362432-18869-15-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1445362432-18869-1-git-send-email-jeff.layton@primarydata.com>
References: <1445362432-18869-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use cached filps if possible instead of opening a new one every time.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/vfs.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 050db266ef80..571f1000e670 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1055,9 +1055,9 @@ __be32
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
@@ -1067,12 +1067,12 @@ nfsd_commit(struct svc_rqst *rqstp, struct svc_fh *fhp,
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
@@ -1080,7 +1080,7 @@ nfsd_commit(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			err = nfserr_notsupp;
 	}
 
-	fput(file);
+	nfsd_file_put(nf);
 out:
 	return err;
 }
-- 
2.4.3

