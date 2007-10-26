From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 18/27] NFS: Prevent nfs_getattr() hang during heavy
	write	workloads
Date: Fri, 26 Oct 2007 13:32:13 -0400
Message-ID: <20071026173213.31475.72792.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IlT35-0007LK-JQ
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:32:45 -0700
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]
	helo=flpi185.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IlT2v-0006QR-AL
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:32:35 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

POSIX requires that ctime and mtime, as reported by the stat(2) call,
reflect the activity of the most recent write(2).  To that end, nfs_getattr()
flushes pending dirty writes to a file before doing a GETATTR to allow the
NFS server to set the file's size, ctime, and mtime properly.

However, nfs_getattr() can be starved when a constant stream of application
writes to a file prevents nfs_wb_nocommit() from completing.  This usually
results in hangs of programs doing a stat against an NFS file that is being
written.  "ls -l" is a common victim of this behavior.

To prevent starvation, hold the file's i_mutex in nfs_getattr() to
freeze applications writes temporarily so the client can more quickly obtain
clean values for a file's size, mtime, and ctime.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/inode.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index cd0e57f..cc3a09d 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -461,9 +461,18 @@ int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
 	int need_atime = NFS_I(inode)->cache_validity & NFS_INO_INVALID_ATIME;
 	int err;
 
-	/* Flush out writes to the server in order to update c/mtime */
-	if (S_ISREG(inode->i_mode))
+	/*
+	 * Flush out writes to the server in order to update c/mtime.
+	 *
+	 * Hold the i_mutex to suspend application writes temporarily;
+	 * this prevents long-running writing applications from blocking
+	 * nfs_wb_nocommit.
+	 */
+	if (S_ISREG(inode->i_mode)) {
+		mutex_lock(&inode->i_mutex);
 		nfs_wb_nocommit(inode);
+		mutex_unlock(&inode->i_mutex);
+	}
 
 	/*
 	 * We may force a getattr if the user cares about atime.


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
