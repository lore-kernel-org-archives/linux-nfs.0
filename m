From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 5 of 34 - NFSv4 locking state fix
Date: Tue, 24 Feb 2004 10:49:41 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1AvPpV-0006HR-00@notabene>
References: <20040224104820.23884.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvPqI-0006tl-DG
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:50:30 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1AvPpx-0005bv-JD
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:50:09 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Tue, 24 Feb 2004 10:49:41 +1100
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


It's OK for the find_lockstateowner_str to fail; that just means we haven't
seen the lockowner, and will compare the request range to all locks on the 
file.

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4state.c |    8 ++------
 1 files changed, 2 insertions(+), 6 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-02-24 10:42:30.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2004-02-24 10:42:31.000000000 +1100
@@ -1993,13 +1993,9 @@ nfsd4_lockt(struct svc_rqst *rqstp, stru
 	strhashval = lock_ownerstr_hashval(inode, 
 			lockt->lt_clientid.cl_id, lockt->lt_owner);
 
-	if (find_lockstateowner_str(strhashval, &lockt->lt_owner, 
+	find_lockstateowner_str(strhashval, &lockt->lt_owner, 
 					&lockt->lt_clientid, 
-					&lockt->lt_stateowner)) {
-		printk("NFSD: nsfd4_lockt: lookup_lockowner() failed!\n");
-		goto out;
-	}
-
+					&lockt->lt_stateowner);
 	sop = lockt->lt_stateowner;
 	if (sop) {
 		file_lock.fl_owner = (fl_owner_t) sop;


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
