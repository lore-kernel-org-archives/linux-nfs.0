From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 2/14] locks: factor out generic/filesystem switch from
	test_lock
Date: Sat,  3 Feb 2007 00:33:58 -0500
Message-ID: <35070.0812800371$1170480902@news.gmane.org>
References: 11704806552464-git-send-email- <11704808501171-git-send-email->
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Marc Eshel <eshel@almaden.ibm.com>
To: linux-fsdevel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HDDXR-0001HM-NV
	for nfs@lists.sourceforge.net; Fri, 02 Feb 2007 21:34:15 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HDDXS-0001Bc-5C
	for nfs@lists.sourceforge.net; Fri, 02 Feb 2007 21:34:15 -0800
In-Reply-To: <11704808501171-git-send-email->
Message-Id: <5cdd83858bf5c75e14742bbd03b462f5ec4997fe.1170479265.git.bfields@citi.umich.edu>
In-Reply-To: <ad8373acbb12f165b625f6065bc0ca86f3982b7f.1170479265.git.bfields@citi.umich.edu>
References: <ad8373acbb12f165b625f6065bc0ca86f3982b7f.1170479265.git.bfields@citi.umich.edu>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

From: J. Bruce Fields <bfields@snoopy.citi.umich.edu> - unquoted

Factor out the code that switches between generic and filesystem-specific lock
methods; eventually we want to call this from lock managers (lockd and nfsd)
too; currently they only call the generic methods.

This patch does that for test_lock.

Note that this hasn't been necessary until recently, because the few
filesystems that define ->lock() (nfs, cifs...) aren't exportable via NFS.
However GFS (and, in the future, other cluster filesystems) need to implement
their own locking to get cluster-coherent locking, and also want to be able to
export locking to NFS (lockd and NFSv4).

So we accomplish this by factoring out code such as this and exporting it for
the use of lockd and nfsd.

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
---
 fs/locks.c                 |   59 ++++++++++++++++++++++++++-----------------
 include/linux/lockd/bind.h |    2 +
 2 files changed, 38 insertions(+), 23 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 4390a95..95246dc 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1611,6 +1611,33 @@ asmlinkage long sys_flock(unsigned int fd, unsigned int cmd)
 	return error;
 }
 
+/**
+ * vfs_test_lock - test file byte range lock
+ * @filp: The file to test lock for
+ * @fl: The lock to test
+ * @conf: Place to return a copy of the conflicting lock, if found
+ *
+ * Returns -ERRNO on failure.  Indicates presence of conflicting lock by
+ * setting conf->fl_type to something other than F_UNLCK.
+ */
+int vfs_test_lock(struct file *filp, struct file_lock *fl, struct file_lock *conf)
+{
+	int error;
+
+	conf->fl_type = F_UNLCK;
+	if (filp->f_op && filp->f_op->lock) {
+		__locks_copy_lock(conf, fl);
+		error = filp->f_op->lock(filp, F_GETLK, conf);
+		if (conf->fl_ops && conf->fl_ops->fl_release_private)
+			conf->fl_ops->fl_release_private(conf);
+		return error;
+	} else {
+		posix_test_lock(filp, fl, conf);
+		return 0;
+	}
+}
+EXPORT_SYMBOL(vfs_test_lock);
+
 /* Report the first existing lock that would conflict with l.
  * This implements the F_GETLK command of fcntl().
  */
@@ -1631,17 +1658,10 @@ int fcntl_getlk(struct file *filp, struct flock __user *l)
 	if (error)
 		goto out;
 
-	if (filp->f_op && filp->f_op->lock) {
-		error = filp->f_op->lock(filp, F_GETLK, &file_lock);
-		if (file_lock.fl_ops && file_lock.fl_ops->fl_release_private)
-			file_lock.fl_ops->fl_release_private(&file_lock);
-		if (error < 0)
-			goto out;
-		else
-		  fl = (file_lock.fl_type == F_UNLCK ? NULL : &file_lock);
-	} else {
-		fl = (posix_test_lock(filp, &file_lock, &cfl) ? &cfl : NULL);
-	}
+	error = vfs_test_lock(filp, &file_lock, &cfl);
+	if (error)
+		goto out;
+	fl = (cfl.fl_type == F_UNLCK ? NULL : &cfl);
  
 	flock.l_type = F_UNLCK;
 	if (fl != NULL) {
@@ -1785,18 +1805,11 @@ int fcntl_getlk64(struct file *filp, struct flock64 __user *l)
 	if (error)
 		goto out;
 
-	if (filp->f_op && filp->f_op->lock) {
-		error = filp->f_op->lock(filp, F_GETLK, &file_lock);
-		if (file_lock.fl_ops && file_lock.fl_ops->fl_release_private)
-			file_lock.fl_ops->fl_release_private(&file_lock);
-		if (error < 0)
-			goto out;
-		else
-		  fl = (file_lock.fl_type == F_UNLCK ? NULL : &file_lock);
-	} else {
-		fl = (posix_test_lock(filp, &file_lock, &cfl) ? &cfl : NULL);
-	}
- 
+	error = vfs_test_lock(filp, &file_lock, &cfl);
+	if (error)
+		goto out;
+	fl = (cfl.fl_type == F_UNLCK ? NULL : &cfl);
+
 	flock.l_type = F_UNLCK;
 	if (fl != NULL) {
 		flock.l_pid = fl->fl_pid;
diff --git a/include/linux/lockd/bind.h b/include/linux/lockd/bind.h
index 246de1d..f78b24a 100644
--- a/include/linux/lockd/bind.h
+++ b/include/linux/lockd/bind.h
@@ -38,4 +38,6 @@ extern int	nlmclnt_proc(struct inode *, int, struct file_lock *);
 extern int	lockd_up(int proto);
 extern void	lockd_down(void);
 
+extern int vfs_test_lock(struct file *, struct file_lock *, struct file_lock *);
+
 #endif /* LINUX_LOCKD_BIND_H */
-- 
1.5.0.rc1.g72fe


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
