From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 9 of 34 - NFSdV4 fixes for replaying open requests.
Date: Tue, 24 Feb 2004 10:49:41 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1AvPpV-0006I1-00@notabene>
References: <20040224104820.23884.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvPqH-0006tW-FZ
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:50:29 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.30)
	id 1AvPeI-0002LQ-Q8
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:38:06 -0800
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


Since the open op changes the current filehandle, we can't correctly replay
compounds containing opens unless we save the filehandle resulting from the
open as well as the encoded reply.

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4proc.c         |   19 +++++++++++++++++++
 ./fs/nfsd/nfs4xdr.c          |    1 +
 ./include/linux/nfsd/state.h |    2 ++
 3 files changed, 22 insertions(+)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2004-02-24 10:42:31.000000000 +1100
+++ ./fs/nfsd/nfs4proc.c	2004-02-24 10:42:31.000000000 +1100
@@ -89,6 +89,12 @@ do_open_lookup(struct svc_rqst *rqstp, s
 	if (!status) {
 		set_change_info(&open->op_cinfo, current_fh);
 		fh_dup2(current_fh, &resfh);
+		/* XXXJBF: keep a saved svc_fh struct instead?? */
+		open->op_stateowner->so_replay.rp_openfh_len =
+			resfh.fh_handle.fh_size;
+		memcpy(open->op_stateowner->so_replay.rp_openfh,
+				&resfh.fh_handle.fh_base,
+				resfh.fh_handle.fh_size);
 
 		accmode = MAY_NOP;
 		if (open->op_share_access & NFS4_SHARE_ACCESS_READ)
@@ -116,6 +122,19 @@ nfsd4_open(struct svc_rqst *rqstp, struc
 
 	/* check seqid for replay. set nfs4_owner */
 	status = nfsd4_process_open1(open);
+	if (status == NFSERR_REPLAY_ME) {
+		struct nfs4_replay *rp = &open->op_stateowner->so_replay;
+		fh_put(current_fh);
+		current_fh->fh_handle.fh_size = rp->rp_openfh_len;
+		memcpy(&current_fh->fh_handle.fh_base, rp->rp_openfh,
+				rp->rp_openfh_len);
+		status = fh_verify(rqstp, current_fh, 0, MAY_NOP);
+		if (status)
+			dprintk("nfsd4_open: replay failed"
+				" restoring previous filehandle\n");
+		else
+			status = NFSERR_REPLAY_ME;
+	}
 	if (status)
 		return status;
 	/*

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2004-02-24 10:42:31.000000000 +1100
+++ ./fs/nfsd/nfs4xdr.c	2004-02-24 10:42:31.000000000 +1100
@@ -1913,6 +1913,7 @@ nfsd4_encode_open(struct nfsd4_compoundr
 	default:
 		BUG();
 	}
+	/* XXX save filehandle here */
 
 	ENCODE_SEQID_OP_TAIL(open->op_stateowner);
 }

diff ./include/linux/nfsd/state.h~current~ ./include/linux/nfsd/state.h
--- ./include/linux/nfsd/state.h~current~	2004-02-24 10:40:23.000000000 +1100
+++ ./include/linux/nfsd/state.h	2004-02-24 10:42:31.000000000 +1100
@@ -113,6 +113,8 @@ struct nfs4_replay {
 	unsigned int		rp_buflen;
 	char			*rp_buf;
 	unsigned		intrp_allocated;
+	int			rp_openfh_len;
+	char			rp_openfh[NFS4_FHSIZE];
 	char			rp_ibuf[NFSD4_REPLAY_ISIZE];
 };
 


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
