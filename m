From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 31 of 34 - Miscellaneous fixes to stateid-based replay
Date: Tue, 24 Feb 2004 10:49:42 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1AvPpW-0006LD-00@notabene>
References: <20040224104820.23884.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvPr3-0006xh-Oj
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:51:17 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.30)
	id 1AvPf2-0002Q8-B4
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:38:52 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Tue, 24 Feb 2004 10:49:43 +1100
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


Save replays for LOCK operations,
make sure errors are replayed correctly.

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4proc.c |    3 ++-
 ./fs/nfsd/nfs4xdr.c  |    2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2004-02-24 10:42:36.000000000 +1100
+++ ./fs/nfsd/nfs4proc.c	2004-02-24 10:42:36.000000000 +1100
@@ -776,6 +776,7 @@ nfsd4_proc_compound(struct svc_rqst *rqs
 			break;
 		case OP_LOCK:
 			op->status = nfsd4_lock(rqstp, &current_fh, &op->u.lock);
+			op->replay = &op->u.lock.lk_stateowner->so_replay;
 			break;
 		case OP_LOCKT:
 			op->status = nfsd4_lockt(rqstp, &current_fh, &op->u.lockt);
@@ -864,7 +865,7 @@ nfsd4_proc_compound(struct svc_rqst *rqs
 encode_op:
 		if (op->status == NFSERR_REPLAY_ME) {
 			nfsd4_encode_replay(resp, op);
-			status = op->status = NFS_OK;
+			status = op->status = op->replay->rp_status;
 		} else {
 			nfsd4_encode_operation(resp, op);
 			status = op->status;

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2004-02-24 10:42:36.000000000 +1100
+++ ./fs/nfsd/nfs4xdr.c	2004-02-24 10:42:36.000000000 +1100
@@ -2399,7 +2399,7 @@ nfsd4_encode_replay(struct nfsd4_compoun
 
 	RESERVE_SPACE(8);
 	WRITE32(op->opnum);
-	WRITE32(NFS_OK);
+	*p++ = rp->rp_status;  /* already xdr'ed */
 	ADJUST_ARGS();
 
 	RESERVE_SPACE(rp->rp_buflen);


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
