From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH]  Fix deadlock problem in lockd.
Date: Wed, 29 Oct 2003 09:09:55 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1AEc2F-0005mL-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AEcc4-0004zN-00
	for <nfs@lists.sourceforge.net>; Tue, 28 Oct 2003 14:46:56 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.24)
	id 1AEcY0-0003p7-6A
	for nfs@lists.sourceforge.net; Tue, 28 Oct 2003 14:42:44 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <marcelo.tosatti@cyclades.com.br>)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Wed, 29 Oct 2003 09:42:30 +1100
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com.br>
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

(This was fixed in 2.5 8 months ago)


diff ./fs/lockd/svclock.c~current~ ./fs/lockd/svclock.c
--- ./fs/lockd/svclock.c~current~	2003-10-29 09:07:10.000000000 +1100
+++ ./fs/lockd/svclock.c	2003-10-29 09:07:10.000000000 +1100
@@ -317,8 +317,6 @@ nlmsvc_lock(struct svc_rqst *rqstp, stru
 				(long long)lock->fl.fl_end,
 				wait);
 
-	/* Lock file against concurrent access */
-	down(&file->f_sema);
 
 	/* Get existing block (in case client is busy-waiting) */
 	block = nlmsvc_lookup_block(file, lock, 0);
@@ -326,6 +324,9 @@ nlmsvc_lock(struct svc_rqst *rqstp, stru
 	lock->fl.fl_flags |= FL_LOCKD;
 
 again:
+	/* Lock file against concurrent access */
+	down(&file->f_sema);
+
 	if (!(conflock = posix_test_lock(&file->f_file, &lock->fl))) {
 		error = posix_lock_file(&file->f_file, &lock->fl, 0);
 
@@ -358,7 +359,10 @@ again:
 
 	/* If we don't have a block, create and initialize it. Then
 	 * retry because we may have slept in kmalloc. */
+	/* We have to release f_sema as nlmsvc_create_block may try to
+	 * claim it while doing host garbage collection */
 	if (block == NULL) {
+		up(&file->f_sema);
 		dprintk("lockd: blocking on this lock (allocating).\n");
 		if (!(block = nlmsvc_create_block(rqstp, file, lock, cookie)))
 			return nlm_lck_denied_nolocks;


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?   SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
