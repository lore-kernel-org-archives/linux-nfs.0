From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 8 of 9] nfsd4: store current->tgid instead of lockowner hash in fl_pid
Date: Fri, 03 Sep 2004 12:34:26 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1C33uE-00043E-KH@notabene.cse.unsw.edu.au>
References: <20040903122815.15453.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C33uN-000054-S3
	for nfs@lists.sourceforge.net; Thu, 02 Sep 2004 19:34:35 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C33uM-0004TL-VC
	for nfs@lists.sourceforge.net; Thu, 02 Sep 2004 19:34:35 -0700
To: Andrew Morton <akpm@osdl.org>
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



The file_lock.fl_pid is no longer used in posix_same_owner() tests.  So just
set it to current->tgid for informational purposes.

Signed-off-by: Andy Adamson <andros@umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-09-03 11:57:34.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2004-09-03 11:57:34.000000000 +1000
@@ -1950,9 +1950,10 @@ static inline void
 nfs4_set_lock_denied(struct file_lock *fl, struct nfsd4_lock_denied *deny)
 {
 	struct nfs4_stateowner *sop = (struct nfs4_stateowner *) fl->fl_owner;
+	unsigned int hval = lockownerid_hashval(sop->so_id);
 
 	deny->ld_sop = NULL;
-	if (nfs4_verify_lock_stateowner(sop, fl->fl_pid))
+	if (nfs4_verify_lock_stateowner(sop, hval))
 		deny->ld_sop = sop;
 	deny->ld_start = fl->fl_start;
 	deny->ld_length = ~(u64)0;
@@ -2196,7 +2197,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struc
 		goto out;
 	}
 	file_lock.fl_owner = (fl_owner_t) lock->lk_stateowner;
-	file_lock.fl_pid = lockownerid_hashval(lock->lk_stateowner->so_id);
+	file_lock.fl_pid = current->tgid;
 	file_lock.fl_file = filp;
 	file_lock.fl_flags = FL_POSIX;
 
@@ -2322,7 +2323,7 @@ nfsd4_lockt(struct svc_rqst *rqstp, stru
 	sop = lockt->lt_stateowner;
 	if (sop) {
 		file_lock.fl_owner = (fl_owner_t) sop;
-		file_lock.fl_pid = lockownerid_hashval(sop->so_id);
+		file_lock.fl_pid = current->tgid;
 	} else {
 		file_lock.fl_owner = NULL;
 		file_lock.fl_pid = 0;
@@ -2386,7 +2387,7 @@ nfsd4_locku(struct svc_rqst *rqstp, stru
 	locks_init_lock(&file_lock);
 	file_lock.fl_type = F_UNLCK;
 	file_lock.fl_owner = (fl_owner_t) locku->lu_stateowner;
-	file_lock.fl_pid = lockownerid_hashval(locku->lu_stateowner->so_id);
+	file_lock.fl_pid = current->tgid;
 	file_lock.fl_file = filp;
 	file_lock.fl_flags = FL_POSIX; 
 	file_lock.fl_start = locku->lu_offset;


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
