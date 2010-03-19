Return-Path: <nfsv4-bounces@linux-nfs.org>
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Subject: [PATCH] nfsd: don't break lease while servicing a COMMIT call (try #2)
Date: Fri, 19 Mar 2010 08:06:28 -0400
Message-Id: <1269000388-5543-1-git-send-email-jlayton@redhat.com>
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

This is the second attempt to fix the problem whereby a COMMIT call
causes a lease break and triggers a possible deadlock.

The problem is that nfsd attempts to break a lease on a COMMIT call.
This triggers a delegation recall if the lease is held for a delegation.
If the client is the one holding the delegation and it's the same one on
which it's issuing the COMMIT, then it can't return that delegation
until the COMMIT is complete. But, nfsd won't complete the COMMIT until
the delegation is returned. The client and server are essentially
deadlocked until the state is marked bad (due to the client not
responding on the callback channel).

The first patch attempted to deal with this by eliminating the open of
the file altogether and simply had nfsd_commit pass a NULL file pointer
to the vfs_fsync_range. That would conflict with some work in progress
by Christoph Hellwig to clean up the fsync interface, so this patch
takes a different approach.

This declares a new NFSD_MAY_NOT_BREAK_LEASE access flag that indicates
to nfsd_open that it should not break any leases when opening the file,
and has nfsd_commit set that flag on the nfsd_open call.

For now, this patch leaves nfsd_commit opening the file with write
access since I'm not clear on what sort of access would be more
appropriate.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/vfs.c |    8 +++++---
 fs/nfsd/vfs.h |    1 +
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index a11b0e8..c2dcb4c 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -723,7 +723,7 @@ nfsd_open(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
 	struct inode	*inode;
 	int		flags = O_RDONLY|O_LARGEFILE;
 	__be32		err;
-	int		host_err;
+	int		host_err = 0;
 
 	validate_process_creds();
 
@@ -760,7 +760,8 @@ nfsd_open(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
 	 * Check to see if there are any leases on this file.
 	 * This may block while leases are broken.
 	 */
-	host_err = break_lease(inode, O_NONBLOCK | ((access & NFSD_MAY_WRITE) ? O_WRONLY : 0));
+	if (!(access & NFSD_MAY_NOT_BREAK_LEASE))
+		host_err = break_lease(inode, O_NONBLOCK | ((access & NFSD_MAY_WRITE) ? O_WRONLY : 0));
 	if (host_err == -EWOULDBLOCK)
 		host_err = -ETIMEDOUT;
 	if (host_err) /* NOMEM or WOULDBLOCK */
@@ -1168,7 +1169,8 @@ nfsd_commit(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			goto out;
 	}
 
-	err = nfsd_open(rqstp, fhp, S_IFREG, NFSD_MAY_WRITE, &file);
+	err = nfsd_open(rqstp, fhp, S_IFREG,
+			NFSD_MAY_WRITE|NFSD_MAY_NOT_BREAK_LEASE, &file);
 	if (err)
 		goto out;
 	if (EX_ISSYNC(fhp->fh_export)) {
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 4b1de0a..217a62c 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -20,6 +20,7 @@
 #define NFSD_MAY_OWNER_OVERRIDE	64
 #define NFSD_MAY_LOCAL_ACCESS	128 /* IRIX doing local access check on device special file*/
 #define NFSD_MAY_BYPASS_GSS_ON_ROOT 256
+#define NFSD_MAY_NOT_BREAK_LEASE 512
 
 #define NFSD_MAY_CREATE		(NFSD_MAY_EXEC|NFSD_MAY_WRITE)
 #define NFSD_MAY_REMOVE		(NFSD_MAY_EXEC|NFSD_MAY_WRITE|NFSD_MAY_TRUNC)
-- 
1.6.6.1

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
