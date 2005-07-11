From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH fs/locks 3 of 3] Fix race conditions with file lock
 vs close
Date: Mon, 11 Jul 2005 08:32:05 -0400
Message-ID: <42D266C5.4010203@redhat.com>
References: <20050711103254.GI27163@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050908010900080207060308"
Cc: nfs@lists.sourceforge.net, akpm@osdl.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DrxT7-00080C-JE
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 05:33:05 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.44)
	id 1DrxT7-0003jU-23
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 05:33:05 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20050711103254.GI27163@suse.de>
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

This is a multi-part message in MIME format.
--------------050908010900080207060308
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Olaf Kirch wrote:

># Subject: Fix race conditions with file lock vs close
># 
># When a multithreaded application tries to obtain a lock on a remote
># file server (NFS or other), while another thread closes the file, we
># risk oopsing or running into a BUG(). This can happen if the close
># happens inbetween sys_fcntl() grabbing the file pointer, and before
># the call to __posix_lock_file.
># 
># The fix is to change fcntl_setlk* and make them check if the file
># is still open after the lock has been obtained.
># 
># Signed-off-by: Olaf Kirch <okir@suse.de>
>

A different patch was submitted upstream already to address the fcntl/close
race.  It was accepted into the '-mm' kernel on June 28'th.  That patch is
attached.

    Thanx...

       ps

--------------050908010900080207060308
Content-Type: text/plain;
 name="devel"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="devel"

--- ./fs/locks.c.org	2005-06-27 08:54:55.000000000 -0400
+++ ./fs/locks.c	2005-06-27 13:24:38.447157408 -0400
@@ -1589,7 +1589,8 @@ out:
 /* Apply the lock described by l to an open file descriptor.
  * This implements both the F_SETLK and F_SETLKW commands of fcntl().
  */
-int fcntl_setlk(struct file *filp, unsigned int cmd, struct flock __user *l)
+int fcntl_setlk(unsigned int fd, struct file *filp, unsigned int cmd,
+		struct flock __user *l)
 {
 	struct file_lock *file_lock = locks_alloc_lock();
 	struct flock flock;
@@ -1618,6 +1619,7 @@ int fcntl_setlk(struct file *filp, unsig
 		goto out;
 	}
 
+again:
 	error = flock_to_posix_lock(filp, file_lock, &flock);
 	if (error)
 		goto out;
@@ -1646,25 +1648,34 @@ int fcntl_setlk(struct file *filp, unsig
 	if (error)
 		goto out;
 
-	if (filp->f_op && filp->f_op->lock != NULL) {
+	if (filp->f_op && filp->f_op->lock != NULL)
 		error = filp->f_op->lock(filp, cmd, file_lock);
-		goto out;
-	}
-
-	for (;;) {
-		error = __posix_lock_file(inode, file_lock);
-		if ((error != -EAGAIN) || (cmd == F_SETLK))
+	else {
+		for (;;) {
+			error = __posix_lock_file(inode, file_lock);
+			if ((error != -EAGAIN) || (cmd == F_SETLK))
+				break;
+			error = wait_event_interruptible(file_lock->fl_wait,
+					!file_lock->fl_next);
+			if (!error)
+				continue;
+	
+			locks_delete_block(file_lock);
 			break;
-		error = wait_event_interruptible(file_lock->fl_wait,
-				!file_lock->fl_next);
-		if (!error)
-			continue;
+		}
+	}
 
-		locks_delete_block(file_lock);
-		break;
+	/*
+	 * Attempt to detect a close/fcntl race and recover by
+	 * releasing the lock that was just acquired.
+	 */
+	if (!error &&
+	    cmd != F_UNLCK && fcheck(fd) != filp && flock.l_type != F_UNLCK) {
+		flock.l_type = F_UNLCK;
+		goto again;
 	}
 
- out:
+out:
 	locks_free_lock(file_lock);
 	return error;
 }
@@ -1722,7 +1733,8 @@ out:
 /* Apply the lock described by l to an open file descriptor.
  * This implements both the F_SETLK and F_SETLKW commands of fcntl().
  */
-int fcntl_setlk64(struct file *filp, unsigned int cmd, struct flock64 __user *l)
+int fcntl_setlk64(unsigned int fd, struct file *filp, unsigned int cmd,
+		struct flock64 __user *l)
 {
 	struct file_lock *file_lock = locks_alloc_lock();
 	struct flock64 flock;
@@ -1751,6 +1763,7 @@ int fcntl_setlk64(struct file *filp, uns
 		goto out;
 	}
 
+again:
 	error = flock64_to_posix_lock(filp, file_lock, &flock);
 	if (error)
 		goto out;
@@ -1779,22 +1792,31 @@ int fcntl_setlk64(struct file *filp, uns
 	if (error)
 		goto out;
 
-	if (filp->f_op && filp->f_op->lock != NULL) {
+	if (filp->f_op && filp->f_op->lock != NULL)
 		error = filp->f_op->lock(filp, cmd, file_lock);
-		goto out;
-	}
-
-	for (;;) {
-		error = __posix_lock_file(inode, file_lock);
-		if ((error != -EAGAIN) || (cmd == F_SETLK64))
+	else {
+		for (;;) {
+			error = __posix_lock_file(inode, file_lock);
+			if ((error != -EAGAIN) || (cmd == F_SETLK64))
+				break;
+			error = wait_event_interruptible(file_lock->fl_wait,
+					!file_lock->fl_next);
+			if (!error)
+				continue;
+	
+			locks_delete_block(file_lock);
 			break;
-		error = wait_event_interruptible(file_lock->fl_wait,
-				!file_lock->fl_next);
-		if (!error)
-			continue;
+		}
+	}
 
-		locks_delete_block(file_lock);
-		break;
+	/*
+	 * Attempt to detect a close/fcntl race and recover by
+	 * releasing the lock that was just acquired.
+	 */
+	if (!error &&
+	    cmd != F_UNLCK && fcheck(fd) != filp && flock.l_type != F_UNLCK) {
+		flock.l_type = F_UNLCK;
+		goto again;
 	}
 
 out:
@@ -1886,12 +1908,7 @@ void locks_remove_flock(struct file *fil
 
 	while ((fl = *before) != NULL) {
 		if (fl->fl_file == filp) {
-			/*
-			 * We might have a POSIX lock that was created at the same time
-			 * the filp was closed for the last time. Just remove that too,
-			 * regardless of ownership, since nobody can own it.
-			 */
-			if (IS_FLOCK(fl) || IS_POSIX(fl)) {
+			if (IS_FLOCK(fl)) {
 				locks_delete_lock(before);
 				continue;
 			}
--- ./fs/fcntl.c.org	2005-06-27 08:54:57.000000000 -0400
+++ ./fs/fcntl.c	2005-06-27 13:24:38.471153760 -0400
@@ -290,7 +290,7 @@ static long do_fcntl(int fd, unsigned in
 		break;
 	case F_SETLK:
 	case F_SETLKW:
-		err = fcntl_setlk(filp, cmd, (struct flock __user *) arg);
+		err = fcntl_setlk(fd, filp, cmd, (struct flock __user *) arg);
 		break;
 	case F_GETOWN:
 		/*
@@ -378,7 +378,8 @@ asmlinkage long sys_fcntl64(unsigned int
 			break;
 		case F_SETLK64:
 		case F_SETLKW64:
-			err = fcntl_setlk64(filp, cmd, (struct flock64 __user *) arg);
+			err = fcntl_setlk64(fd, filp, cmd,
+					(struct flock64 __user *) arg);
 			break;
 		default:
 			err = do_fcntl(fd, cmd, arg, filp);
--- ./include/linux/fs.h.org	2005-06-27 08:54:57.000000000 -0400
+++ ./include/linux/fs.h	2005-06-27 13:24:38.444157864 -0400
@@ -691,11 +691,13 @@ extern struct list_head file_lock_list;
 #include <linux/fcntl.h>
 
 extern int fcntl_getlk(struct file *, struct flock __user *);
-extern int fcntl_setlk(struct file *, unsigned int, struct flock __user *);
+extern int fcntl_setlk(unsigned int, struct file *, unsigned int,
+			struct flock __user *);
 
 #if BITS_PER_LONG == 32
 extern int fcntl_getlk64(struct file *, struct flock64 __user *);
-extern int fcntl_setlk64(struct file *, unsigned int, struct flock64 __user *);
+extern int fcntl_setlk64(unsigned int, struct file *, unsigned int,
+			struct flock64 __user *);
 #endif
 
 extern void send_sigio(struct fown_struct *fown, int fd, int band);

--------------050908010900080207060308--


-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
