From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 9 of 9] Remove redundant initialization in nfsd4_lockt
Date: Fri, 03 Sep 2004 12:34:26 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1C33uE-00043I-MB@notabene.cse.unsw.edu.au>
References: <20040903122815.15453.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C33uN-000055-S9
	for nfs@lists.sourceforge.net; Thu, 02 Sep 2004 19:34:35 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C33uN-0004TQ-3d
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



No need to set fl_owner and fl_pid to 0, since that's already been done by
locks_init_lock.

Signed-off-by: Andy Adamson <andros@umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   12 +++---------
 1 files changed, 3 insertions(+), 9 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-09-03 11:57:34.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2004-09-03 11:57:34.000000000 +1000
@@ -2268,7 +2268,6 @@ int
 nfsd4_lockt(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_lockt *lockt)
 {
 	struct inode *inode;
-	struct nfs4_stateowner *sop;
 	struct file file;
 	struct file_lock file_lock;
 	struct file_lock *conflicting_lock;
@@ -2320,14 +2319,9 @@ nfsd4_lockt(struct svc_rqst *rqstp, stru
 	find_lockstateowner_str(strhashval, &lockt->lt_owner,
 					&lockt->lt_clientid, 
 					&lockt->lt_stateowner);
-	sop = lockt->lt_stateowner;
-	if (sop) {
-		file_lock.fl_owner = (fl_owner_t) sop;
-		file_lock.fl_pid = current->tgid;
-	} else {
-		file_lock.fl_owner = NULL;
-		file_lock.fl_pid = 0;
-	}
+	if (lockt->lt_stateowner)
+		file_lock.fl_owner = (fl_owner_t)lockt->lt_stateowner;
+	file_lock.fl_pid = current->tgid;
 	file_lock.fl_flags = FL_POSIX;
 
 	file_lock.fl_start = lockt->lt_offset;


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
