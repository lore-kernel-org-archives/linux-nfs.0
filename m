Return-Path: <nfsv4-bounces@linux-nfs.org>
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Subject: [PATCH] nfsd: no need to open the file on a COMMIT call
Date: Thu, 18 Mar 2010 15:34:47 -0400
Message-Id: <1268940887-8556-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

There's no need to call nfsd_open when a COMMIT call comes in over the
wire. It doesn't really buy us anything to pass a filp into
vfs_fsync_range. Trond also pointed out that the write access check
for the open is wrong as well.

It's also problematic to do so. If the client doing the COMMIT call is
holding a delegation on the file, then that causes the server to recall
the delegation before it will proceed. The client (correctly) won't
return the delegation until the COMMIT succeeds. This leads to a
deadlock of sorts that can cause the client and server to stall out
and end up in state renewal.

The gory details of this situation are written up here:

    https://bugzilla.redhat.com/show_bug.cgi?id=551028#c10

Fix this by not opening the file on a COMMIT call and simply pass
a NULL file pointer to vfs_fsync_range.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/vfs.c |    8 +-------
 1 files changed, 1 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index a11b0e8..2cdd9c0 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1156,7 +1156,6 @@ __be32
 nfsd_commit(struct svc_rqst *rqstp, struct svc_fh *fhp,
                loff_t offset, unsigned long count)
 {
-	struct file	*file;
 	loff_t		end = LLONG_MAX;
 	__be32		err = nfserr_inval;
 
@@ -1168,11 +1167,8 @@ nfsd_commit(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			goto out;
 	}
 
-	err = nfsd_open(rqstp, fhp, S_IFREG, NFSD_MAY_WRITE, &file);
-	if (err)
-		goto out;
 	if (EX_ISSYNC(fhp->fh_export)) {
-		int err2 = vfs_fsync_range(file, file->f_path.dentry,
+		int err2 = vfs_fsync_range(NULL, fhp->fh_dentry,
 				offset, end, 0);
 
 		if (err2 != -EINVAL)
@@ -1180,8 +1176,6 @@ nfsd_commit(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		else
 			err = nfserr_notsupp;
 	}
-
-	nfsd_close(file);
 out:
 	return err;
 }
-- 
1.6.6.1

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
