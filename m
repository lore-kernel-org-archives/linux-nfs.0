From: Neil Brown <neilb@suse.de>
Subject: Re: NLM lock reclaim failure
Date: Fri, 13 Oct 2006 17:08:39 +1000
Message-ID: <17711.15223.857652.522180@cse.unsw.edu.au>
References: <452F277A.3060607@almaden.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GYHA6-0007Pt-KC
	for nfs@lists.sourceforge.net; Fri, 13 Oct 2006 00:08:54 -0700
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GYHA5-0004jh-Ks
	for nfs@lists.sourceforge.net; Fri, 13 Oct 2006 00:08:55 -0700
To: Marc Eshel <eshel@almaden.ibm.com>
In-Reply-To: message from Marc Eshel on Thursday October 12
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thursday October 12, eshel@almaden.ibm.com wrote:
> Hi Trond,
> Attached is a tested patch for the bug I posted in the following mail
> Marc.

Thanks for this patch, for the discovering/understanding the bug.

There are a couple of aspects of that patch that I don't really like.

One is adding the nlmsvc_dispatch function just to gain a little bit
of functionality that the sunrpc layer should probably provide
directly.

The other is that blurring of nfsd and nlm error codes.

The following patch addresses these issues and is essentially a
rewrite of you patch.

Would you be able to review/test it?

It fixed nfsv2 as well which needed and extra little fix.

Thanks a lot,
NeilBrown

------------------
Allow lockd to drop replys as appropriate.

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/lockd/svc4proc.c             |   12 ++++++------
 ./fs/lockd/svcproc.c              |   16 +++++++++-------
 ./fs/lockd/svcsubs.c              |    5 ++++-
 ./fs/nfsd/lockd.c                 |    3 +++
 ./include/linux/lockd/xdr.h       |    2 ++
 ./include/linux/sunrpc/msg_prot.h |    4 +++-
 ./include/linux/sunrpc/xdr.h      |    1 +
 ./net/sunrpc/svc.c                |    5 +++++
 8 files changed, 33 insertions(+), 15 deletions(-)

diff .prev/fs/lockd/svc4proc.c ./fs/lockd/svc4proc.c
--- .prev/fs/lockd/svc4proc.c	2006-10-13 17:01:33.000000000 +1000
+++ ./fs/lockd/svc4proc.c	2006-10-13 17:02:43.000000000 +1000
@@ -96,7 +96,7 @@ nlm4svc_proc_test(struct svc_rqst *rqstp
 
 	/* Obtain client and file */
 	if ((resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file)))
-		return rpc_success;
+		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
 
 	/* Now check for conflicting locks */
 	resp->status = nlmsvc_testlock(file, &argp->lock, &resp->lock);
@@ -126,7 +126,7 @@ nlm4svc_proc_lock(struct svc_rqst *rqstp
 
 	/* Obtain client and file */
 	if ((resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file)))
-		return rpc_success;
+		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
 
 #if 0
 	/* If supplied state doesn't match current state, we assume it's
@@ -169,7 +169,7 @@ nlm4svc_proc_cancel(struct svc_rqst *rqs
 
 	/* Obtain client and file */
 	if ((resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file)))
-		return rpc_success;
+		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
 
 	/* Try to cancel request. */
 	resp->status = nlmsvc_cancel_blocked(file, &argp->lock);
@@ -202,7 +202,7 @@ nlm4svc_proc_unlock(struct svc_rqst *rqs
 
 	/* Obtain client and file */
 	if ((resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file)))
-		return rpc_success;
+		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
 
 	/* Now try to remove the lock */
 	resp->status = nlmsvc_unlock(file, &argp->lock);
@@ -339,7 +339,7 @@ nlm4svc_proc_share(struct svc_rqst *rqst
 
 	/* Obtain client and file */
 	if ((resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file)))
-		return rpc_success;
+		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
 
 	/* Now try to create the share */
 	resp->status = nlmsvc_share_file(host, file, argp);
@@ -372,7 +372,7 @@ nlm4svc_proc_unshare(struct svc_rqst *rq
 
 	/* Obtain client and file */
 	if ((resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file)))
-		return rpc_success;
+		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
 
 	/* Now try to lock the file */
 	resp->status = nlmsvc_unshare_file(host, file, argp);

diff .prev/fs/lockd/svcproc.c ./fs/lockd/svcproc.c
--- .prev/fs/lockd/svcproc.c	2006-10-13 17:01:33.000000000 +1000
+++ ./fs/lockd/svcproc.c	2006-10-13 17:02:43.000000000 +1000
@@ -59,7 +59,7 @@ nlmsvc_retrieve_args(struct svc_rqst *rq
 	struct nlm_host		*host = NULL;
 	struct nlm_file		*file = NULL;
 	struct nlm_lock		*lock = &argp->lock;
-	u32			error;
+	u32			error = 0;
 
 	/* nfsd callbacks must have been installed for this procedure */
 	if (!nlmsvc_ops)
@@ -88,6 +88,8 @@ nlmsvc_retrieve_args(struct svc_rqst *rq
 no_locks:
 	if (host)
 		nlm_release_host(host);
+	if (error)
+		return error;
 	return nlm_lck_denied_nolocks;
 }
 
@@ -122,7 +124,7 @@ nlmsvc_proc_test(struct svc_rqst *rqstp,
 
 	/* Obtain client and file */
 	if ((resp->status = nlmsvc_retrieve_args(rqstp, argp, &host, &file)))
-		return rpc_success;
+		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
 
 	/* Now check for conflicting locks */
 	resp->status = cast_status(nlmsvc_testlock(file, &argp->lock, &resp->lock));
@@ -153,7 +155,7 @@ nlmsvc_proc_lock(struct svc_rqst *rqstp,
 
 	/* Obtain client and file */
 	if ((resp->status = nlmsvc_retrieve_args(rqstp, argp, &host, &file)))
-		return rpc_success;
+		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
 
 #if 0
 	/* If supplied state doesn't match current state, we assume it's
@@ -196,7 +198,7 @@ nlmsvc_proc_cancel(struct svc_rqst *rqst
 
 	/* Obtain client and file */
 	if ((resp->status = nlmsvc_retrieve_args(rqstp, argp, &host, &file)))
-		return rpc_success;
+		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
 
 	/* Try to cancel request. */
 	resp->status = cast_status(nlmsvc_cancel_blocked(file, &argp->lock));
@@ -229,7 +231,7 @@ nlmsvc_proc_unlock(struct svc_rqst *rqst
 
 	/* Obtain client and file */
 	if ((resp->status = nlmsvc_retrieve_args(rqstp, argp, &host, &file)))
-		return rpc_success;
+		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
 
 	/* Now try to remove the lock */
 	resp->status = cast_status(nlmsvc_unlock(file, &argp->lock));
@@ -368,7 +370,7 @@ nlmsvc_proc_share(struct svc_rqst *rqstp
 
 	/* Obtain client and file */
 	if ((resp->status = nlmsvc_retrieve_args(rqstp, argp, &host, &file)))
-		return rpc_success;
+		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
 
 	/* Now try to create the share */
 	resp->status = cast_status(nlmsvc_share_file(host, file, argp));
@@ -401,7 +403,7 @@ nlmsvc_proc_unshare(struct svc_rqst *rqs
 
 	/* Obtain client and file */
 	if ((resp->status = nlmsvc_retrieve_args(rqstp, argp, &host, &file)))
-		return rpc_success;
+		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
 
 	/* Now try to unshare the file */
 	resp->status = cast_status(nlmsvc_unshare_file(host, file, argp));

diff .prev/fs/lockd/svcsubs.c ./fs/lockd/svcsubs.c
--- .prev/fs/lockd/svcsubs.c	2006-10-13 17:02:07.000000000 +1000
+++ ./fs/lockd/svcsubs.c	2006-10-13 17:02:43.000000000 +1000
@@ -140,7 +140,10 @@ out_free:
 		nfserr = nlm4_stale_fh;
 	else
 #endif
-	nfserr = nlm_lck_denied;
+	if (nfserr == 3)
+		nfserr = nlm_drop_reply;
+	else
+		nfserr = nlm_lck_denied;
 	goto out_unlock;
 }
 

diff .prev/fs/nfsd/lockd.c ./fs/nfsd/lockd.c
--- .prev/fs/nfsd/lockd.c	2006-10-13 17:01:33.000000000 +1000
+++ ./fs/nfsd/lockd.c	2006-10-13 17:02:43.000000000 +1000
@@ -43,12 +43,15 @@ nlm_fopen(struct svc_rqst *rqstp, struct
 	 * we invent: 0 = no error
 	 *            1 = stale file handle
 	 *	      2 = other error
+	 *	      3 = try again later
 	 */
 	switch (nfserr) {
 	case nfs_ok:
 		return 0;
 	case nfserr_stale:
 		return 1;
+	case nfserr_dropit:
+		return 3;
 	default:
 		return 2;
 	}

diff .prev/include/linux/lockd/xdr.h ./include/linux/lockd/xdr.h
--- .prev/include/linux/lockd/xdr.h	2006-10-13 17:01:33.000000000 +1000
+++ ./include/linux/lockd/xdr.h	2006-10-13 17:02:43.000000000 +1000
@@ -22,6 +22,8 @@
 #define	nlm_lck_blocked		__constant_htonl(NLM_LCK_BLOCKED)
 #define	nlm_lck_denied_grace_period	__constant_htonl(NLM_LCK_DENIED_GRACE_PERIOD)
 
+#define nlm_drop_reply		__constant_htonl(30000)
+
 /* Lock info passed via NLM */
 struct nlm_lock {
 	char *			caller;

diff .prev/include/linux/sunrpc/msg_prot.h ./include/linux/sunrpc/msg_prot.h
--- .prev/include/linux/sunrpc/msg_prot.h	2006-10-13 17:01:33.000000000 +1000
+++ ./include/linux/sunrpc/msg_prot.h	2006-10-13 17:02:43.000000000 +1000
@@ -56,7 +56,9 @@ enum rpc_accept_stat {
 	RPC_PROG_MISMATCH = 2,
 	RPC_PROC_UNAVAIL = 3,
 	RPC_GARBAGE_ARGS = 4,
-	RPC_SYSTEM_ERR = 5
+	RPC_SYSTEM_ERR = 5,
+	/* internal use only */
+	RPC_DROP_REPLY = 60000,
 };
 
 enum rpc_reject_stat {

diff .prev/include/linux/sunrpc/xdr.h ./include/linux/sunrpc/xdr.h
--- .prev/include/linux/sunrpc/xdr.h	2006-10-13 17:01:33.000000000 +1000
+++ ./include/linux/sunrpc/xdr.h	2006-10-13 17:02:43.000000000 +1000
@@ -74,6 +74,7 @@ struct xdr_buf {
 #define	rpc_proc_unavail	__constant_htonl(RPC_PROC_UNAVAIL)
 #define	rpc_garbage_args	__constant_htonl(RPC_GARBAGE_ARGS)
 #define	rpc_system_err		__constant_htonl(RPC_SYSTEM_ERR)
+#define	rpc_drop_reply		__constant_htonl(RPC_DROP_REPLY)
 
 #define	rpc_auth_ok		__constant_htonl(RPC_AUTH_OK)
 #define	rpc_autherr_badcred	__constant_htonl(RPC_AUTH_BADCRED)

diff .prev/net/sunrpc/svc.c ./net/sunrpc/svc.c
--- .prev/net/sunrpc/svc.c	2006-10-13 17:01:33.000000000 +1000
+++ ./net/sunrpc/svc.c	2006-10-13 17:02:43.000000000 +1000
@@ -825,6 +825,11 @@ svc_process(struct svc_rqst *rqstp)
 		*statp = procp->pc_func(rqstp, rqstp->rq_argp, rqstp->rq_resp);
 
 		/* Encode reply */
+		if (*statp == rpc_drop_reply) {
+			if (procp->pc_release)
+				procp->pc_release(rqstp, NULL, rqstp->rq_resp);
+			goto dropit;
+		}
 		if (*statp == rpc_success && (xdr = procp->pc_encode)
 		 && !xdr(rqstp, resv->iov_base+resv->iov_len, rqstp->rq_resp)) {
 			dprintk("svc: failed to encode reply\n");

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
