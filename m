Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56805 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752764Ab1ACSbB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Jan 2011 13:31:01 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 5/5] nfsd4: remove some unnecessary dropit handling
Date: Mon,  3 Jan 2011 13:30:54 -0500
Message-Id: <1294079454-17891-6-git-send-email-bfields@redhat.com>
In-Reply-To: <1294079454-17891-1-git-send-email-bfields@redhat.com>
References: <1294079454-17891-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

We no longer need a few of these special cases.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c  |    4 ----
 fs/nfsd/nfs4state.c |    2 --
 fs/nfsd/nfs4xdr.c   |    2 --
 fs/nfsd/vfs.c       |    4 ----
 4 files changed, 0 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index f80c399..fd6694b 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1156,10 +1156,6 @@ encode_op:
 
 		nfsd4_increment_op_stats(op->opnum);
 	}
-	if (!rqstp->rq_usedeferral && status == nfserr_dropit) {
-		dprintk("%s Dropit - send NFS4ERR_DELAY\n", __func__);
-		status = nfserr_jukebox;
-	}
 
 	resp->cstate.status = status;
 	fh_put(&resp->cstate.current_fh);
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 73adcfb..b82e368 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2509,8 +2509,6 @@ static __be32 nfs4_get_vfs_file(struct svc_rqst *rqstp, struct nfs4_file
 	if (!fp->fi_fds[oflag]) {
 		status = nfsd_open(rqstp, cur_fh, S_IFREG, access,
 			&fp->fi_fds[oflag]);
-		if (status == nfserr_dropit)
-			status = nfserr_jukebox;
 		if (status)
 			return status;
 	}
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 437b462..364aae7 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2328,8 +2328,6 @@ nfsd4_encode_dirent(void *ccdv, const char *name, int namlen,
 	case nfserr_resource:
 		nfserr = nfserr_toosmall;
 		goto fail;
-	case nfserr_dropit:
-		goto fail;
 	case nfserr_noent:
 		goto skip_entry;
 	default:
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 184938f..6a3af2f 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -380,8 +380,6 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
 		 * we need to break all leases.
 		 */
 		host_err = break_lease(inode, O_WRONLY | O_NONBLOCK);
-		if (host_err == -EWOULDBLOCK)
-			host_err = -ETIMEDOUT;
 		if (host_err) /* ENOMEM or EWOULDBLOCK */
 			goto out_nfserr;
 
@@ -752,8 +750,6 @@ nfsd_open(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
 	 */
 	if (!(access & NFSD_MAY_NOT_BREAK_LEASE))
 		host_err = break_lease(inode, O_NONBLOCK | ((access & NFSD_MAY_WRITE) ? O_WRONLY : 0));
-	if (host_err == -EWOULDBLOCK)
-		host_err = -ETIMEDOUT;
 	if (host_err) /* NOMEM or WOULDBLOCK */
 		goto out_nfserr;
 
-- 
1.7.1

