From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: [PATCH] NFS nolock broken in 2.6.9-rc4
Date: Fri, 15 Oct 2004 17:13:54 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1097853234.5558.21.camel@lade.trondhjem.org>
References: <20041015095840.GA22992@suse.de>
	 <20041015100703.GA27307@suse.de>
	 <1097851608.5558.15.camel@lade.trondhjem.org>
	 <1097853073.5558.17.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net, Andrew Morton <akpm@osdl.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CITmd-0002SY-LY
	for nfs@lists.sourceforge.net; Fri, 15 Oct 2004 08:14:19 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CITmQ-0008IC-P0
	for nfs@lists.sourceforge.net; Fri, 15 Oct 2004 08:14:19 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <1097853073.5558.17.camel@lade.trondhjem.org>
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

  VFS: Remove remnants of LOCK_USE_CLNT. It should no longer be necessary.

  Signed-off-by: Trond Myklebust <trond.myklebust@fys.uio.no>
---
 fs/locks.c         |    6 ------
 include/linux/fs.h |    5 -----
 2 files changed, 11 deletions(-)

Index: linux-2.6.9-rc4-up/include/linux/fs.h
===================================================================
--- linux-2.6.9-rc4-up.orig/include/linux/fs.h	2004-10-15 12:03:03.000000000 +0200
+++ linux-2.6.9-rc4-up/include/linux/fs.h	2004-10-15 17:04:10.645827518 +0200
@@ -1167,11 +1167,6 @@ extern long do_mount(char *, char *, cha
 
 extern int vfs_statfs(struct super_block *, struct kstatfs *);
 
-/* Return value for VFS lock functions - tells locks.c to lock conventionally
- * REALLY kosha for root NFS and nfs_lock
- */ 
-#define LOCK_USE_CLNT 1
-
 #define FLOCK_VERIFY_READ  1
 #define FLOCK_VERIFY_WRITE 2
 
Index: linux-2.6.9-rc4-up/fs/locks.c
===================================================================
--- linux-2.6.9-rc4-up.orig/fs/locks.c	2004-10-15 12:04:18.000000000 +0200
+++ linux-2.6.9-rc4-up/fs/locks.c	2004-10-15 17:03:16.376966402 +0200
@@ -1435,9 +1435,6 @@ int fcntl_getlk(struct file *filp, struc
 		error = filp->f_op->lock(filp, F_GETLK, &file_lock);
 		if (error < 0)
 			goto out;
-		else if (error == LOCK_USE_CLNT)
-		  /* Bypass for NFS with no locking - 2.0.36 compat */
-		  fl = posix_test_lock(filp, &file_lock);
 		else
 		  fl = (file_lock.fl_type == F_UNLCK ? NULL : &file_lock);
 	} else {
@@ -1580,9 +1577,6 @@ int fcntl_getlk64(struct file *filp, str
 		error = filp->f_op->lock(filp, F_GETLK, &file_lock);
 		if (error < 0)
 			goto out;
-		else if (error == LOCK_USE_CLNT)
-		  /* Bypass for NFS with no locking - 2.0.36 compat */
-		  fl = posix_test_lock(filp, &file_lock);
 		else
 		  fl = (file_lock.fl_type == F_UNLCK ? NULL : &file_lock);
 	} else {




-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
