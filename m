From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NFSD: Fill in WCC data for REMOVE, RMDIR, MKNOD, and MKDIR
Date: Tue, 06 Jul 2010 16:53:34 -0400
Message-ID: <20100706204750.2918.92546.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:57458 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755651Ab0GFUxg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jul 2010 16:53:36 -0400
Received: by iwn7 with SMTP id 7so7049027iwn.19
        for <linux-nfs@vger.kernel.org>; Tue, 06 Jul 2010 13:53:36 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Some well-known NFSv3 clients drop their directory entry caches when
they receive replies with no WCC data.  Without this data, they
employ extra READ, LOOKUP, and GETATTR requests to ensure their
directory entry caches are up to date, causing performance to suffer
needlessly.

In order to return WCC data, our server has to have both the pre-op
and the post-op attribute data on hand when a reply is XDR encoded.
The pre-op data is filled in when the incoming fh is locked, and the
post-op data is filled in when the fh is unlocked.

Unfortunately, for REMOVE, RMDIR, MKNOD, and MKDIR, the directory fh
is not unlocked until well after the reply has been XDR encoded.  This
means that encode_wcc_data() does not have wcc_data for the parent
directory, so none is returned to the client after these operations
complete.

By unlocking the parent directory fh immediately after the internal
operations for each NFS procedure is complete, the post-op data is
filled in before XDR encoding starts, so it can be returned to the
client properly.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

Bruce-

This patch seems to go a long way towards fixing the pre-wcc data
problem and related performance issues.  Perhaps this patch is also
appropriate for stable releases, though I haven't tested it with any.


 fs/nfsd/nfs3proc.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 3d68f45..9ae9331 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -271,7 +271,7 @@ nfsd3_proc_mkdir(struct svc_rqst *rqstp, struct nfsd3_createargs *argp,
 	fh_init(&resp->fh, NFS3_FHSIZE);
 	nfserr = nfsd_create(rqstp, &resp->dirfh, argp->name, argp->len,
 				    &argp->attrs, S_IFDIR, 0, &resp->fh);
-
+	fh_unlock(&resp->dirfh);
 	RETURN_STATUS(nfserr);
 }
 
@@ -327,7 +327,7 @@ nfsd3_proc_mknod(struct svc_rqst *rqstp, struct nfsd3_mknodargs *argp,
 	type = nfs3_ftypes[argp->ftype];
 	nfserr = nfsd_create(rqstp, &resp->dirfh, argp->name, argp->len,
 				    &argp->attrs, type, rdev, &resp->fh);
-
+	fh_unlock(&resp->dirfh);
 	RETURN_STATUS(nfserr);
 }
 
@@ -348,6 +348,7 @@ nfsd3_proc_remove(struct svc_rqst *rqstp, struct nfsd3_diropargs *argp,
 	/* Unlink. -S_IFDIR means file must not be a directory */
 	fh_copy(&resp->fh, &argp->fh);
 	nfserr = nfsd_unlink(rqstp, &resp->fh, -S_IFDIR, argp->name, argp->len);
+	fh_unlock(&resp->fh);
 	RETURN_STATUS(nfserr);
 }
 
@@ -367,6 +368,7 @@ nfsd3_proc_rmdir(struct svc_rqst *rqstp, struct nfsd3_diropargs *argp,
 
 	fh_copy(&resp->fh, &argp->fh);
 	nfserr = nfsd_unlink(rqstp, &resp->fh, S_IFDIR, argp->name, argp->len);
+	fh_unlock(&resp->fh);
 	RETURN_STATUS(nfserr);
 }
 

