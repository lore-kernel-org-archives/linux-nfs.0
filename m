From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] locks: provide a file lease method enabling
	cluster-coherent leases
Date: Thu, 31 May 2007 17:40:23 -0400
Message-ID: <11806476252913-git-send-email-bfields@fieldses.org>
References: <1180647624483-git-send-email-bfields@fieldses.org>
	<11806476252240-git-send-email-bfields@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	David Teigland <teigland@redhat.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	nfs@lists.sourceforge.net, Marc Eshel <eshel@almaden.ibm.com>
To: linux-fsdevel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HtsNh-0000Ty-Vu
	for nfs@lists.sourceforge.net; Thu, 31 May 2007 14:40:30 -0700
Received: from pear.citi.umich.edu ([141.211.133.128])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HtsNk-0006Fg-Pw
	for nfs@lists.sourceforge.net; Thu, 31 May 2007 14:40:33 -0700
In-Reply-To: <11806476252240-git-send-email-bfields@fieldses.org>
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

From: J. Bruce Fields <bfields@fieldses.org>

Currently leases are only kept locally, so there's no way for a distributed
filesystem to enforce them against multiple clients.  We're particularly
interested in the case of nfsd exporting a cluster filesystem, in which
case nfsd needs cluster-coherent leases in order to implement delegations
correctly.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/locks.c         |    5 ++++-
 include/linux/fs.h |    4 ++++
 2 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 3f366e1..40a7f39 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1444,7 +1444,10 @@ int setlease(struct file *filp, long arg, struct file_lock **lease)
 		return error;
 
 	lock_kernel();
-	error = __setlease(filp, arg, lease);
+	if (filp->f_op && filp->f_op->set_lease)
+		error = filp->f_op->set_lease(filp, arg, lease);
+        else
+		error = __setlease(filp, arg, lease);
 	unlock_kernel();
 
 	return error;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 7cf0c54..09aefb4 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1112,6 +1112,7 @@ struct file_operations {
 	int (*flock) (struct file *, int, struct file_lock *);
 	ssize_t (*splice_write)(struct pipe_inode_info *, struct file *, loff_t *, size_t, unsigned int);
 	ssize_t (*splice_read)(struct file *, loff_t *, struct pipe_inode_info *, size_t, unsigned int);
+	int (*set_lease)(struct file *, long, struct file_lock **);
 };
 
 struct inode_operations {
@@ -1137,6 +1138,7 @@ struct inode_operations {
 	ssize_t (*listxattr) (struct dentry *, char *, size_t);
 	int (*removexattr) (struct dentry *, const char *);
 	void (*truncate_range)(struct inode *, loff_t, loff_t);
+	int (*break_lease)(struct inode *, unsigned int);
 };
 
 struct seq_file;
@@ -1463,6 +1465,8 @@ static inline int locks_verify_truncate(struct inode *inode,
 
 static inline int break_lease(struct inode *inode, unsigned int mode)
 {
+	if (inode->i_op && inode->i_op->break_lease)
+		return inode->i_op->break_lease(inode, mode);
 	if (inode->i_flock)
 		return __break_lease(inode, mode);
 	return 0;
-- 
1.5.2.rc3


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
