From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 3 of 6 - Fix deadlock problem in lockd.
Date: Wed, 12 Mar 2003 16:35:28 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18sytk-0005Qy-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18sytt-0000Di-00
	for <nfs@lists.sourceforge.net>; Tue, 11 Mar 2003 21:35:37 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Wed, 12 Mar 2003 16:35:28 +1100
To: Linus Torvalds <torvalds@transmeta.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


### Comments for ChangeSet

nlmsvc_lock calls nlmsvc_create_block with file->f_sema
held.
nlmsvc_create_block calls nlmclnt_lookup_host which might
call nlm_gc_hosts which might, eventually, try to claim
file->f_sema for the same file -> deadlock.

nlmsvc_create_block does not need any protection under
any lock as lockd is single-threaded and _create_block
only plays with internal data structures.

So we release the f_sema before calling in, and make sure
it gets claimed again afterwards.

 ----------- Diffstat output ------------
 ./fs/lockd/svclock.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff ./fs/lockd/svclock.c~current~ ./fs/lockd/svclock.c
--- ./fs/lockd/svclock.c~current~	2003-03-12 15:03:18.000000000 +1100
+++ ./fs/lockd/svclock.c	2003-03-12 15:03:18.000000000 +1100
@@ -305,8 +305,6 @@ nlmsvc_lock(struct svc_rqst *rqstp, stru
 				(long long)lock->fl.fl_end,
 				wait);
 
-	/* Lock file against concurrent access */
-	down(&file->f_sema);
 
 	/* Get existing block (in case client is busy-waiting) */
 	block = nlmsvc_lookup_block(file, lock, 0);
@@ -314,6 +312,9 @@ nlmsvc_lock(struct svc_rqst *rqstp, stru
 	lock->fl.fl_flags |= FL_LOCKD;
 
 again:
+	/* Lock file against concurrent access */
+	down(&file->f_sema);
+
 	if (!(conflock = posix_test_lock(&file->f_file, &lock->fl))) {
 		error = posix_lock_file(&file->f_file, &lock->fl);
 
@@ -346,7 +347,10 @@ again:
 
 	/* If we don't have a block, create and initialize it. Then
 	 * retry because we may have slept in kmalloc. */
+	/* We have to release f_sema as nlmsvc_create_block may try to
+	 * to claim it while doing host garbage collection */
 	if (block == NULL) {
+		up(&file->f_sema);
 		dprintk("lockd: blocking on this lock (allocating).\n");
 		if (!(block = nlmsvc_create_block(rqstp, file, lock, cookie)))
 			return nlm_lck_denied_nolocks;


-------------------------------------------------------
This SF.net email is sponsored by:Crypto Challenge is now open! 
Get cracking and register here for some mind boggling fun and 
the chance of winning an Apple iPod:
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0031en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
