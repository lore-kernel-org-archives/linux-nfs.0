From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 18 of 34 - check lock length, return appropriate error
Date: Tue, 24 Feb 2004 10:49:41 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1AvPpV-0006JK-00@notabene>
References: <20040224104820.23884.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvPr3-0006xO-1R
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:51:17 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1AvPqd-0005hV-FL
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:50:51 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Tue, 24 Feb 2004 10:49:42 +1100
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


 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4state.c |   17 +++++++++++++++++
 1 files changed, 17 insertions(+)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-02-24 10:42:33.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2004-02-24 10:42:33.000000000 +1100
@@ -1783,6 +1783,13 @@ out:
 	return stp;
 }
 
+int
+check_lock_length(u64 offset, u64 length)
+{
+	return ((length == 0)  || ((length != ~(u64)0) && 
+ 	     LOFF_OVERFLOW(offset, length)));
+}
+
 /*
  *  LOCK operation 
  */
@@ -1801,6 +1808,9 @@ nfsd4_lock(struct svc_rqst *rqstp, struc
 		(long long) lock->lk_offset,
 		(long long) lock->lk_length);
 
+	if (check_lock_length(lock->lk_offset, lock->lk_length))
+		 return nfserr_inval;
+
 	lock->lk_stateowner = NULL;
 	nfs4_lock_state();
 
@@ -1962,6 +1972,9 @@ nfsd4_lockt(struct svc_rqst *rqstp, stru
 	unsigned int strhashval;
 	int status;
 
+	if (check_lock_length(lockt->lt_offset, lockt->lt_length))
+		 return nfserr_inval;
+
 	lockt->lt_stateowner = NULL;
 	nfs4_lock_state();
 
@@ -2048,6 +2061,10 @@ nfsd4_locku(struct svc_rqst *rqstp, stru
 	dprintk("NFSD: nfsd4_locku: start=%Ld length=%Ld\n",
 		(long long) locku->lu_offset,
 		(long long) locku->lu_length);
+
+	if (check_lock_length(locku->lu_offset, locku->lu_length))
+		 return nfserr_inval;
+
 	nfs4_lock_state();
 									        
 	if ((status = nfs4_preprocess_seqid_op(current_fh, 


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
