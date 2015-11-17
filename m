Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:33262 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752901AbbKQLxs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Nov 2015 06:53:48 -0500
Received: by qgea14 with SMTP id a14so3420872qge.0
        for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2015 03:53:47 -0800 (PST)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org, trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Eric Paris <eparis@parisplace.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org
Subject: [PATCH v1 29/38] nfsd: retry once in nfsd_open on an -EOPENSTALE return
Date: Tue, 17 Nov 2015 06:52:51 -0500
Message-Id: <1447761180-4250-30-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
References: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we get back -EOPENSTALE from an NFSv4 open, then we either got some
unhandled error or the inode we got back was not the same as the one
associated with the dentry.

We really have no recourse in that situation other than to retry the
open, and if it fails to just return nfserr_stale back to the client.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/nfsproc.c |  1 +
 fs/nfsd/vfs.c     | 12 ++++++++++--
 2 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 5a82d20a50b4..697fc0b9ba09 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -795,6 +795,7 @@ nfserrno (int errno)
 		{ nfserr_serverfault, -ESERVERFAULT },
 		{ nfserr_serverfault, -ENFILE },
 		{ nfserr_io, -EREMOTEIO },
+		{ nfserr_stale, -EOPENSTALE },
 	};
 	int	i;
 
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 9bf194be2b8e..5293cba6b8f8 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -622,9 +622,9 @@ __nfsd_open(struct svc_rqst *rqstp, struct svc_fh *fhp, umode_t type,
 	int		flags = O_RDONLY|O_LARGEFILE;
 	__be32		err;
 	int		host_err = 0;
+	bool		retried = false;
 
-	BUG_ON(!fhp->fh_dentry);
-
+retry:
 	path.mnt = fhp->fh_export->ex_path.mnt;
 	path.dentry = fhp->fh_dentry;
 	inode = d_inode(path.dentry);
@@ -659,6 +659,14 @@ __nfsd_open(struct svc_rqst *rqstp, struct svc_fh *fhp, umode_t type,
 
 	file = dentry_open(&path, flags, current_cred());
 	if (IS_ERR(file)) {
+		if (file == ERR_PTR(-EOPENSTALE) && !retried) {
+			retried = true;
+			fh_put(fhp);
+			err = fh_verify(rqstp, fhp, type, may_flags);
+			if (err)
+				goto out;
+			goto retry;
+		}
 		host_err = PTR_ERR(file);
 		goto out_nfserr;
 	}
-- 
2.4.3

