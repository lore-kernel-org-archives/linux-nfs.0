From: Marc Eshel <eshel@almaden.ibm.com>
Subject: [patch] flock/fcntl bug
Date: Wed, 15 Dec 2004 10:15:41 -0800
Message-ID: <OF05A12F51.B9794B13-ON88256F6B.0062DC68-88256F6B.0064504D@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cedmn-0000Rt-LH
	for nfs@lists.sourceforge.net; Wed, 15 Dec 2004 10:22:05 -0800
Received: from e3.ny.us.ibm.com ([32.97.182.143])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1Cedml-00068v-EK
	for nfs@lists.sourceforge.net; Wed, 15 Dec 2004 10:22:05 -0800
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.12.10/8.12.10) with ESMTP id iBFILsV8032084
	for <nfs@lists.sourceforge.net>; Wed, 15 Dec 2004 13:21:54 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iBFILrSF287190
	for <nfs@lists.sourceforge.net>; Wed, 15 Dec 2004 13:21:54 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.12.11) with ESMTP id iBFILrpm004832
	for <nfs@lists.sourceforge.net>; Wed, 15 Dec 2004 13:21:53 -0500
Received: from d01ml604.pok.ibm.com (d01ml604.pok.ibm.com [9.56.227.90])
	by d01av04.pok.ibm.com (8.12.11/8.12.11) with ESMTP id iBFILrU5004823
	for <nfs@lists.sourceforge.net>; Wed, 15 Dec 2004 13:21:53 -0500
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

To fs/locks.c owner

There is a bug in the unlock of posix locks. If there is an flock held on a
file that is being closed an unneeded call is made to the file system to do
an fcntl unlock. In the case of NFS it will be a call to the NFS server
which is expensive. This patch just checks that it is a posix lock before
calling the file system.

Marc.


--- linux-2.6.10-rc2.orig/fs/locks.c      2004-11-14 17:28:31.000000000
-0800
+++ linux-2.6.10-rc2-locks/fs/locks.c     2004-12-15 09:44:25.857512320
-0800
@@ -1846,11 +1962,6 @@ void locks_remove_posix(struct file *fil
  lock.fl_ops = NULL;
  lock.fl_lmops = NULL;

-     if (filp->f_op && filp->f_op->lock != NULL) {
-           filp->f_op->lock(filp, F_SETLK, &lock);
-           goto out;
-     }
-
  /* Can't use posix_lock_file here; we need to remove it no matter
   * which pid we have.
   */
@@ -1858,6 +1969,11 @@ void locks_remove_posix(struct file *fil
  while (*before != NULL) {
   struct file_lock *fl = *before;
   if (IS_POSIX(fl) && posix_same_owner(fl, &lock)) {
+                 if (filp->f_op && filp->f_op->lock != NULL) {
+                       unlock_kernel();
+                       filp->f_op->lock(filp, F_SETLK, &lock);
+                       goto out;
+                 }
    locks_delete_lock(before);
    continue;
   }



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
