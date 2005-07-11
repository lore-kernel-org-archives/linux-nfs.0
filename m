From: Olaf Kirch <okir@suse.de>
Subject: [PATCH fs/locks 2 of 3] Use proper tgid in locks_remove_posix
Date: Mon, 11 Jul 2005 12:32:50 +0200
Message-ID: <20050711103250.GH27163@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Drvao-0002g3-9z
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 03:32:54 -0700
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.44)
	id 1Drvan-00012f-NT
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 03:32:54 -0700
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

# Subject: [NFS] Use proper tgid in locks_remove_posix
# 
# This patch fixes a problem with lost unlock calls in multithreaded
# applications. locks_remove_posix would send a single unlock call with
# the task group ID of the current process, which may not be the same as
# the tgid of the lock. This patch ensures that we send separate unlock
# calls for different fl_pid values.
# 
# Signed-off-by: Olaf Kirch <okir@suse.de>

Index: linux-2.6.12/fs/locks.c
===================================================================
--- linux-2.6.12.orig/fs/locks.c	2005-07-11 12:16:41.000000000 +0200
+++ linux-2.6.12/fs/locks.c	2005-07-11 12:17:15.000000000 +0200
@@ -1811,47 +1811,60 @@ out:
 void locks_remove_posix(struct file *filp, fl_owner_t owner)
 {
 	struct file_lock lock, **before;
+	pid_t tgid;
+	int more;
 
-	/*
-	 * If there are no locks held on this file, we don't need to call
-	 * posix_lock_file().  Another process could be setting a lock on this
-	 * file at the same time, but we wouldn't remove that lock anyway.
-	 */
-	before = &filp->f_dentry->d_inode->i_flock;
-	if (*before == NULL)
-		return;
-
-	lock.fl_type = F_UNLCK;
-	lock.fl_flags = FL_POSIX;
-	lock.fl_start = 0;
-	lock.fl_end = OFFSET_MAX;
-	lock.fl_owner = owner;
-	lock.fl_pid = current->tgid;
-	lock.fl_file = filp;
-	lock.fl_ops = NULL;
-	lock.fl_lmops = NULL;
-
-	if (filp->f_op && filp->f_op->lock != NULL) {
-		filp->f_op->lock(filp, F_SETLK, &lock);
-		goto out;
-	}
+	do {
+		/*
+		 * If there are no locks held on this file, we don't need to call
+		 * posix_lock_file().  Another process could be setting a lock on this
+		 * file at the same time, but we wouldn't remove that lock anyway.
+		 */
+		before = &filp->f_dentry->d_inode->i_flock;
+		if (*before == NULL)
+			return;
+
+		more = 0;
+		tgid = 0;
+
+		/* Can't use posix_lock_file here; we need to remove it no matter
+		 * which pid we have.
+		 */
+		lock_kernel();
+		while (*before != NULL) {
+			struct file_lock *fl = *before;
+			if (IS_POSIX(fl) && posix_same_owner(fl, &lock)) {
+				if (tgid == 0 || tgid == fl->fl_pid) {
+					tgid = fl->fl_pid;
+					locks_delete_lock(before);
+					continue;
+				}
+				/* We have locks owned by a different tgid.
+				 * Need to come back. */
+				more = 1;
+			}
+			before = &fl->fl_next;
+		}
+		unlock_kernel();
 
-	/* Can't use posix_lock_file here; we need to remove it no matter
-	 * which pid we have.
-	 */
-	lock_kernel();
-	while (*before != NULL) {
-		struct file_lock *fl = *before;
-		if (IS_POSIX(fl) && posix_same_owner(fl, &lock)) {
-			locks_delete_lock(before);
-			continue;
+		if (tgid != 0) {
+			lock.fl_type = F_UNLCK;
+			lock.fl_flags = FL_POSIX;
+			lock.fl_start = 0;
+			lock.fl_end = OFFSET_MAX;
+			lock.fl_owner = owner;
+			lock.fl_pid = tgid;
+			lock.fl_file = filp;
+			lock.fl_ops = NULL;
+			lock.fl_lmops = NULL;
+
+			if (filp->f_op && filp->f_op->lock != NULL) {
+				filp->f_op->lock(filp, F_SETLK, &lock);
+				if (lock.fl_ops && lock.fl_ops->fl_release_private)
+					lock.fl_ops->fl_release_private(&lock);
+			}
 		}
-		before = &fl->fl_next;
-	}
-	unlock_kernel();
-out:
-	if (lock.fl_ops && lock.fl_ops->fl_release_private)
-		lock.fl_ops->fl_release_private(&lock);
+	} while (more);
 }
 
 EXPORT_SYMBOL(locks_remove_posix);

-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax


-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
