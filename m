From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 3 of 5 - Fix handling of error code in NFSv4 replies
Date: Tue, 11 Feb 2003 15:37:24 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18iSAe-0008HU-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18iSAz-0005vO-00
	for <nfs@lists.sourceforge.net>; Mon, 10 Feb 2003 20:37:46 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Tue, 11 Feb 2003 15:37:33 +1100
To: Linus Torvalds <torvalds@transmeta.com>
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


### Comments for ChangeSet

As nfsv4 does some reply encoding while processing
requests, the code which tries to put the overall status
at the head of the reply fails.

With this patch, we take the address for the overall
status very early so NFSv4's encoding wont confuse us.

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4proc.c |    6 +++---
 ./fs/nfsd/nfssvc.c   |   14 +++++++++++---
 2 files changed, 14 insertions(+), 6 deletions(-)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2003-02-11 14:25:38.000000000 +1100
+++ ./fs/nfsd/nfs4proc.c	2003-02-11 14:25:38.000000000 +1100
@@ -568,9 +568,9 @@ nfsd4_proc_compound(struct svc_rqst *rqs
 
 	resp->xbuf = &rqstp->rq_res;
 	resp->p = rqstp->rq_res.head[0].iov_base + rqstp->rq_res.head[0].iov_len;
-	resp->tagp = resp->p + 1; /* skip over status */
-	/* reserve space for: status, taglen, tag, and opcnt */
-	resp->p += 3 + XDR_QUADLEN(args->taglen);
+	resp->tagp = resp->p;
+	/* reserve space for: taglen, tag, and opcnt */
+	resp->p += 2 + XDR_QUADLEN(args->taglen);
 	resp->end = rqstp->rq_res.head[0].iov_base + PAGE_SIZE;
 	resp->taglen = args->taglen;
 	resp->tag = args->tag;

diff ./fs/nfsd/nfssvc.c~current~ ./fs/nfsd/nfssvc.c
--- ./fs/nfsd/nfssvc.c~current~	2003-02-11 14:25:38.000000000 +1100
+++ ./fs/nfsd/nfssvc.c	2003-02-11 14:25:38.000000000 +1100
@@ -265,6 +265,7 @@ nfsd_dispatch(struct svc_rqst *rqstp, u3
 	struct svc_procedure	*proc;
 	kxdrproc_t		xdr;
 	u32			nfserr;
+	u32			*nfserrp;
 
 	dprintk("nfsd_dispatch: vers %d proc %d\n",
 				rqstp->rq_vers, rqstp->rq_proc);
@@ -291,6 +292,13 @@ nfsd_dispatch(struct svc_rqst *rqstp, u3
 		return 1;
 	}
 
+	/* need to grab the location to store the status, as
+	 * nfsv4 does some encoding while processing 
+	 */
+	nfserrp = rqstp->rq_res.head[0].iov_base
+		+ rqstp->rq_res.head[0].iov_len;
+	rqstp->rq_res.head[0].iov_len += sizeof(u32);
+
 	/* Now call the procedure handler, and encode NFS status. */
 	nfserr = proc->pc_func(rqstp, rqstp->rq_argp, rqstp->rq_resp);
 	if (nfserr == nfserr_dropit) {
@@ -298,16 +306,16 @@ nfsd_dispatch(struct svc_rqst *rqstp, u3
 		nfsd_cache_update(rqstp, RC_NOCACHE, NULL);
 		return 0;
 	}
-		
+
 	if (rqstp->rq_proc != 0)
-		svc_putu32(&rqstp->rq_res.head[0], nfserr);
+		*nfserrp++ = nfserr;
 
 	/* Encode result.
 	 * For NFSv2, additional info is never returned in case of an error.
 	 */
 	if (!(nfserr && rqstp->rq_vers == 2)) {
 		xdr = proc->pc_encode;
-		if (xdr && !xdr(rqstp, (u32*)(rqstp->rq_res.head[0].iov_base+rqstp->rq_res.head[0].iov_len),
+		if (xdr && !xdr(rqstp, nfserrp,
 				rqstp->rq_resp)) {
 			/* Failed to encode result. Release cache entry */
 			dprintk("nfsd: failed to encode result!\n");


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
