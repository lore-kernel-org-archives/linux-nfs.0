From: Olaf Kirch <okir@suse.de>
Subject: [PATCH fs/locks 3 of 3] Fix race conditions with file lock vs close
Date: Mon, 11 Jul 2005 12:32:54 +0200
Message-ID: <20050711103254.GI27163@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Drvas-0002gA-Ks
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 03:32:58 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.44)
	id 1Drvas-0002Ps-2L
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 03:32:58 -0700
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

# Subject: Fix race conditions with file lock vs close
# 
# When a multithreaded application tries to obtain a lock on a remote
# file server (NFS or other), while another thread closes the file, we
# risk oopsing or running into a BUG(). This can happen if the close
# happens inbetween sys_fcntl() grabbing the file pointer, and before
# the call to __posix_lock_file.
# 
# The fix is to change fcntl_setlk* and make them check if the file
# is still open after the lock has been obtained.
# 
# Signed-off-by: Olaf Kirch <okir@suse.de>

Index: linux-2.6.12/fs/fcntl.c
===================================================================
--- linux-2.6.12.orig/fs/fcntl.c	2005-07-08 11:45:17.000000000 +0200
+++ linux-2.6.12/fs/fcntl.c	2005-07-11 12:17:31.000000000 +0200
@@ -288,7 +288,7 @@ static long do_fcntl(int fd, unsigned in
 		break;
 	case F_SETLK:
 	case F_SETLKW:
-		err = fcntl_setlk(filp, cmd, (struct flock __user *) arg);
+		err = fcntl_setlk(filp, cmd, (struct flock __user *) arg, fd);
 		break;
 	case F_GETOWN:
 		/*
@@ -376,7 +376,7 @@ asmlinkage long sys_fcntl64(unsigned int
 			break;
 		case F_SETLK64:
 		case F_SETLKW64:
-			err = fcntl_setlk64(filp, cmd, (struct flock64 __user *) arg);
+			err = fcntl_setlk64(filp, cmd, (struct flock64 __user *) arg, fd);
 			break;
 		default:
 			err = do_fcntl(fd, cmd, arg, filp);
Index: linux-2.6.12/fs/locks.c
===================================================================
--- linux-2.6.12.orig/fs/locks.c	2005-07-11 12:17:15.000000000 +0200
+++ linux-2.6.12/fs/locks.c	2005-07-11 12:17:31.000000000 +0200
@@ -1591,7 +1591,7 @@ out:
 /* Apply the lock described by l to an open file descriptor.
  * This implements both the F_SETLK and F_SETLKW commands of fcntl().
  */
-int fcntl_setlk(struct file *filp, unsigned int cmd, struct flock __user *l)
+int fcntl_setlk(struct file *filp, unsigned int cmd, struct flock __user *l, int fd)
 {
 	struct file_lock *file_lock = locks_alloc_lock();
 	struct flock flock;
@@ -1666,6 +1666,18 @@ int fcntl_setlk(struct file *filp, unsig
 		break;
 	}
 
+	/* Make sure the file is still open, otherwise we need
+	 * to release the lock we just claimed. */
+	spin_lock(&current->files->file_lock);
+	if (current->files->fd[fd] != filp) {
+		/* Darn - someone closed the file in the meanwhile. */
+		spin_unlock(&current->files->file_lock);
+		locks_remove_posix(filp, current->files);
+		error = -EBADF;
+	} else {
+		spin_unlock(&current->files->file_lock);
+	}
+
  out:
 	locks_free_lock(file_lock);
 	return error;
@@ -1722,7 +1734,7 @@ out:
 /* Apply the lock described by l to an open file descriptor.
  * This implements both the F_SETLK and F_SETLKW commands of fcntl().
  */
-int fcntl_setlk64(struct file *filp, unsigned int cmd, struct flock64 __user *l)
+int fcntl_setlk64(struct file *filp, unsigned int cmd, struct flock64 __user *l, int fd)
 {
 	struct file_lock *file_lock = locks_alloc_lock();
 	struct flock64 flock;
@@ -1797,6 +1809,18 @@ int fcntl_setlk64(struct file *filp, uns
 		break;
 	}
 
+	/* Make sure the file is still open, otherwise we need
+	 * to release the lock we just claimed. */
+	spin_lock(&current->files->file_lock);
+	if (current->files->fd[fd] != filp) {
+		/* Darn - someone closed the file in the meanwhile. */
+		spin_unlock(&current->files->file_lock);
+		locks_remove_posix(filp, current->files);
+		error = -EBADF;
+	} else {
+		spin_unlock(&current->files->file_lock);
+	}
+
 out:
 	locks_free_lock(file_lock);
 	return error;
Index: linux-2.6.12/include/linux/fs.h
===================================================================
--- linux-2.6.12.orig/include/linux/fs.h	2005-07-08 11:45:21.000000000 +0200
+++ linux-2.6.12/include/linux/fs.h	2005-07-11 12:17:31.000000000 +0200
@@ -689,11 +689,11 @@ extern struct list_head file_lock_list;
 #include <linux/fcntl.h>
 
 extern int fcntl_getlk(struct file *, struct flock __user *);
-extern int fcntl_setlk(struct file *, unsigned int, struct flock __user *);
+extern int fcntl_setlk(struct file *, unsigned int, struct flock __user *, int);
 
 #if BITS_PER_LONG == 32
 extern int fcntl_getlk64(struct file *, struct flock64 __user *);
-extern int fcntl_setlk64(struct file *, unsigned int, struct flock64 __user *);
+extern int fcntl_setlk64(struct file *, unsigned int, struct flock64 __user *, int);
 #endif
 
 extern void send_sigio(struct fown_struct *fown, int fd, int band);

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
