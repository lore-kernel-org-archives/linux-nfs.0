From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 14 of 34 - Fix for lookup-parent at pseudo root
Date: Tue, 24 Feb 2004 10:49:41 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1AvPpV-0006Ik-00@notabene>
References: <20040224104820.23884.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvPq4-0006rr-KM
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:50:16 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.30)
	id 1AvPe5-0002JD-W9
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:37:54 -0800
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


tests if current_fh is the pseudo root for the client and returns nfserr_noent
if so. need to call exp_pseudoroot because different clients can have
different pseudo filesystems.

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4proc.c |   20 ++++++++++++--------
 1 files changed, 12 insertions(+), 8 deletions(-)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2004-02-24 10:42:32.000000000 +1100
+++ ./fs/nfsd/nfs4proc.c	2004-02-24 10:42:32.000000000 +1100
@@ -349,14 +349,18 @@ nfsd4_link(struct svc_rqst *rqstp, struc
 static inline int
 nfsd4_lookupp(struct svc_rqst *rqstp, struct svc_fh *current_fh)
 {
-	/*
-	 * XXX: We currently violate the spec in one small respect
-	 * here.  If LOOKUPP is done at the root of the pseudofs,
-	 * the spec requires us to return NFSERR_NOENT.  Personally,
-	 * I think that leaving the filehandle unchanged is more
-	 * logical, but this is an academic question anyway, since
-	 * no clients actually use LOOKUPP.
-	 */
+	struct svc_fh tmp_fh;
+	int ret;
+
+	fh_init(&tmp_fh, NFS4_FHSIZE);
+	if((ret = exp_pseudoroot(rqstp->rq_client, &tmp_fh,
+			      &rqstp->rq_chandle)) != 0)
+		return ret;
+	if (tmp_fh.fh_dentry == current_fh->fh_dentry) {
+		fh_put(&tmp_fh);
+		return nfserr_noent;
+	}
+	fh_put(&tmp_fh);
 	return nfsd_lookup(rqstp, current_fh, "..", 2, current_fh);
 }
 


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
