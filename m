From: Daniel Forrest <forrest@lmcg.wisc.edu>
Subject: Re: deadlock in lockd
Date: Thu, 10 Mar 2005 15:49:44 -0600
Message-ID: <20050310154944.A14369@rda07.lmcg.wisc.edu>
References: <20050310204416.GC3424@suse.de>
Reply-To: Daniel Forrest <forrest@lmcg.wisc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, Sebastian Hetze <s.hetze@linux-ag.de>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D9VXZ-0001PZ-Cj
	for nfs@lists.sourceforge.net; Thu, 10 Mar 2005 13:49:57 -0800
Received: from mail.lmcg.wisc.edu ([144.92.101.145])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D9VXV-0007e8-Fa
	for nfs@lists.sourceforge.net; Thu, 10 Mar 2005 13:49:57 -0800
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20050310204416.GC3424@suse.de>; from okir@suse.de on Thu, Mar 10, 2005 at 09:44:16PM +0100
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

Olaf,

> Hi all,
> 
> I just debugged a deadlock in lockd in SLES8 (i.e 2.4.21), but
> I think the same problem exists in 2.6.

I found this ages ago.

Neil Brown submitted a patch on 12 Mar 2003:

Subject: [NFS] [PATCH] kNFSd - 3 of 6 - Fix deadlock problem in lockd.

Which fixes this.  Apparently this made it into 2.5, but not 2.4.

He submitted the same patch on 29 Oct 2003:

Subject: [NFS] [PATCH]  Fix deadlock problem in lockd.

With the comment: "(This was fixed in 2.5 8 months ago)".

You may want to check if this ever made it into the 2.4 source.

Here is that e-mail:

---

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

-- 
Daniel K. Forrest	Laboratory for Molecular and
forrest@lmcg.wisc.edu	Computational Genomics
			University of Wisconsin, Madison


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
