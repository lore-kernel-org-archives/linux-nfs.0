From: NeilBrown <neilb@suse.de>
Subject: [PATCH 001 of 16] knfsd: locks: flag NFSv4-owned locks
Date: Mon, 3 Apr 2006 15:18:06 +1000
Message-ID: <1060403051806.1723@suse.de>
References: <20060403151452.1567.patches@notabene>
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FQHTq-0005Nx-4O
	for nfs@lists.sourceforge.net; Sun, 02 Apr 2006 22:19:58 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FQHTp-0004HV-BL
	for nfs@lists.sourceforge.net; Sun, 02 Apr 2006 22:19:58 -0700
To: Andrew Morton <akpm@osdl.org>
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


Use the fl_lmops field to identify which locks are ours, instead of trying
to look them up in our private hash.  This is safer and more efficient.

Earlier versions of this patch used a lock flag instead, but Trond pointed
out that adding a new flag for each lock manager wasn't going to scale
well, and suggested this approach instead; a separate patch converts lockd
to using fl_lmops in the same way.

In the NFSv4 case this looks like a bit of a hack, since the NFSv4 server
isn't currently actually defining a lock_manager_operations struct, so we
end up defining one *just* to serve as a cookie to identify our locks.

But it works, and we actually do expect to start using the
lock_manager_operations at some point anyway.

Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   38 ++++++++++++++++----------------------
 1 file changed, 16 insertions(+), 22 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2006-04-03 15:12:03.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2006-04-03 15:12:03.000000000 +1000
@@ -2495,36 +2495,27 @@ nfs4_transform_lock_offset(struct file_l
 		lock->fl_end = OFFSET_MAX;
 }
 
-static int
-nfs4_verify_lock_stateowner(struct nfs4_stateowner *sop, unsigned int hashval)
-{
-	struct nfs4_stateowner *local = NULL;
-	int status = 0;
-			        
-	if (hashval >= LOCK_HASH_SIZE)
-		goto out;
-	list_for_each_entry(local, &lock_ownerid_hashtbl[hashval], so_idhash) {
-		if (local == sop) {
-			status = 1;
-			goto out;
-		}
-	}
-out:
-	return status;
-}
-
+/* Hack!: For now, we're defining this just so we can use a pointer to it
+ * as a unique cookie to identify our (NFSv4's) posix locks. */
+struct lock_manager_operations nfsd_posix_mng_ops  = {
+};
 
 static inline void
 nfs4_set_lock_denied(struct file_lock *fl, struct nfsd4_lock_denied *deny)
 {
-	struct nfs4_stateowner *sop = (struct nfs4_stateowner *) fl->fl_owner;
-	unsigned int hval = lockownerid_hashval(sop->so_id);
+	struct nfs4_stateowner *sop;
+	unsigned int hval;
 
-	deny->ld_sop = NULL;
-	if (nfs4_verify_lock_stateowner(sop, hval)) {
+	if (fl->fl_lmops == &nfsd_posix_mng_ops) {
+		sop = (struct nfs4_stateowner *) fl->fl_owner;
+		hval = lockownerid_hashval(sop->so_id);
 		kref_get(&sop->so_ref);
 		deny->ld_sop = sop;
 		deny->ld_clientid = sop->so_client->cl_clientid;
+	} else {
+		deny->ld_sop = NULL;
+		deny->ld_clientid.cl_boot = 0;
+		deny->ld_clientid.cl_id = 0;
 	}
 	deny->ld_start = fl->fl_start;
 	deny->ld_length = ~(u64)0;
@@ -2736,6 +2727,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struc
 	file_lock.fl_pid = current->tgid;
 	file_lock.fl_file = filp;
 	file_lock.fl_flags = FL_POSIX;
+	file_lock.fl_lmops = &nfsd_posix_mng_ops;
 
 	file_lock.fl_start = lock->lk_offset;
 	if ((lock->lk_length == ~(u64)0) || 
@@ -2841,6 +2833,7 @@ nfsd4_lockt(struct svc_rqst *rqstp, stru
 		file_lock.fl_owner = (fl_owner_t)lockt->lt_stateowner;
 	file_lock.fl_pid = current->tgid;
 	file_lock.fl_flags = FL_POSIX;
+	file_lock.fl_lmops = &nfsd_posix_mng_ops;
 
 	file_lock.fl_start = lockt->lt_offset;
 	if ((lockt->lt_length == ~(u64)0) || LOFF_OVERFLOW(lockt->lt_offset, lockt->lt_length))
@@ -2900,6 +2893,7 @@ nfsd4_locku(struct svc_rqst *rqstp, stru
 	file_lock.fl_pid = current->tgid;
 	file_lock.fl_file = filp;
 	file_lock.fl_flags = FL_POSIX; 
+	file_lock.fl_lmops = &nfsd_posix_mng_ops;
 	file_lock.fl_start = locku->lu_offset;
 
 	if ((locku->lu_length == ~(u64)0) || LOFF_OVERFLOW(locku->lu_offset, locku->lu_length))


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
