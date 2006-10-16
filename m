From: NeilBrown <neilb@suse.de>
Subject: [PATCH 005 of 5] knfsd: Allow lockd to drop replys as
	appropriate.
Date: Tue, 17 Oct 2006 09:30:30 +1000
Message-ID: <1061016233030.11366@suse.de>
References: <20061017092702.11224.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Marc Eshel <eshel@almaden.ibm.com>,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GZbuo-00017g-AF
	for nfs@lists.sourceforge.net; Mon, 16 Oct 2006 16:30:38 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GZbun-00018p-GP
	for nfs@lists.sourceforge.net; Mon, 16 Oct 2006 16:30:39 -0700
To: Andrew Morton <akpm@osdl.org>
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


It is possible for the ->fopen callback from lockd into nfsd to find
that an answer cannot be given straight away (an upcall is needed) and
so the request has to be 'dropped', to be retried later.
That error status is not currently propagated back.

So:
  Change nlm_fopen to return nlm error codes (rather than a private
  protocol) and define a new nlm_drop_reply code.
  Cause nlm_drop_reply to cause the rpc request to get rpc_drop_reply
  when this error comes back.
  Cause svc_process to drop a request which returns a status of
  rpc_drop_reply.

Cc: Marc Eshel <eshel@almaden.ibm.com>

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/lockd/svc4proc.c             |   12 ++++++------
 ./fs/lockd/svcproc.c              |   16 +++++++++-------
 ./fs/lockd/svcsubs.c              |    6 ------
 ./fs/nfsd/lockd.c                 |   14 ++++++++------
 ./include/linux/lockd/bind.h      |    5 +++++
 ./include/linux/lockd/xdr.h       |    2 ++
 ./include/linux/sunrpc/msg_prot.h |    4 +++-
 ./include/linux/sunrpc/xdr.h      |    1 +
 ./net/sunrpc/svc.c                |    5 +++++
 9 files changed, 39 insertions(+), 26 deletions(-)

diff .prev/fs/lockd/svc4proc.c ./fs/lockd/svc4proc.c
--- .prev/fs/lockd/svc4proc.c	2006-10-17 09:10:54.000000000 +1000
+++ ./fs/lockd/svc4proc.c	2006-10-17 09:10:55.000000000 +1000
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
--- .prev/fs/lockd/svcproc.c	2006-10-17 09:10:54.000000000 +1000
+++ ./fs/lockd/svcproc.c	2006-10-17 09:10:55.000000000 +1000
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
--- .prev/fs/lockd/svcsubs.c	2006-10-17 09:10:40.000000000 +1000
+++ ./fs/lockd/svcsubs.c	2006-10-17 09:13:54.000000000 +1000
@@ -135,12 +135,6 @@ out_unlock:
 
 out_free:
 	kfree(file);
-#ifdef CONFIG_LOCKD_V4
-	if (nfserr == 1)
-		nfserr = nlm4_stale_fh;
-	else
-#endif
-	nfserr = nlm_lck_denied;
 	goto out_unlock;
 }
 

diff .prev/fs/nfsd/lockd.c ./fs/nfsd/lockd.c
--- .prev/fs/nfsd/lockd.c	2006-10-17 09:10:54.000000000 +1000
+++ ./fs/nfsd/lockd.c	2006-10-17 09:19:18.000000000 +1000
@@ -39,18 +39,20 @@ nlm_fopen(struct svc_rqst *rqstp, struct
 	fh_put(&fh);
 	rqstp->rq_client = NULL;
 	exp_readunlock();
- 	/* nlm and nfsd don't share error codes.
-	 * we invent: 0 = no error
-	 *            1 = stale file handle
-	 *	      2 = other error
+ 	/* We return nlm error codes as nlm doesn't know
+	 * about nfsd, but nfsd does know about nlm..
 	 */
 	switch (nfserr) {
 	case nfs_ok:
 		return 0;
+	case nfserr_dropit:
+		return nlm_drop_reply;
+#ifdef CONFIG_LOCKD_V4
 	case nfserr_stale:
-		return 1;
+		return nlm4_stale_fh;
+#endif
 	default:
-		return 2;
+		return nlm_lck_denied;
 	}
 }
 

diff .prev/include/linux/lockd/bind.h ./include/linux/lockd/bind.h
--- .prev/include/linux/lockd/bind.h	2006-10-17 09:20:09.000000000 +1000
+++ ./include/linux/lockd/bind.h	2006-10-17 09:22:26.000000000 +1000
@@ -10,6 +10,11 @@
 #define LINUX_LOCKD_BIND_H
 
 #include <linux/lockd/nlm.h>
+/* need xdr-encoded error codes too, so... */
+#include <linux/lockd/xdr.h>
+#ifdef CONFIG_LOCKD_V4
+#include <linux/lockd/xdr4.h>
+#endif
 
 /* Dummy declarations */
 struct svc_rqst;

diff .prev/include/linux/lockd/xdr.h ./include/linux/lockd/xdr.h
--- .prev/include/linux/lockd/xdr.h	2006-10-17 09:10:54.000000000 +1000
+++ ./include/linux/lockd/xdr.h	2006-10-17 09:10:55.000000000 +1000
@@ -22,6 +22,8 @@
 #define	nlm_lck_blocked		__constant_htonl(NLM_LCK_BLOCKED)
 #define	nlm_lck_denied_grace_period	__constant_htonl(NLM_LCK_DENIED_GRACE_PERIOD)
 
+#define nlm_drop_reply		__constant_htonl(30000)
+
 /* Lock info passed via NLM */
 struct nlm_lock {
 	char *			caller;

diff .prev/include/linux/sunrpc/msg_prot.h ./include/linux/sunrpc/msg_prot.h
--- .prev/include/linux/sunrpc/msg_prot.h	2006-10-17 09:10:55.000000000 +1000
+++ ./include/linux/sunrpc/msg_prot.h	2006-10-17 09:10:55.000000000 +1000
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
--- .prev/include/linux/sunrpc/xdr.h	2006-10-17 09:10:55.000000000 +1000
+++ ./include/linux/sunrpc/xdr.h	2006-10-17 09:10:55.000000000 +1000
@@ -74,6 +74,7 @@ struct xdr_buf {
 #define	rpc_proc_unavail	__constant_htonl(RPC_PROC_UNAVAIL)
 #define	rpc_garbage_args	__constant_htonl(RPC_GARBAGE_ARGS)
 #define	rpc_system_err		__constant_htonl(RPC_SYSTEM_ERR)
+#define	rpc_drop_reply		__constant_htonl(RPC_DROP_REPLY)
 
 #define	rpc_auth_ok		__constant_htonl(RPC_AUTH_OK)
 #define	rpc_autherr_badcred	__constant_htonl(RPC_AUTH_BADCRED)

diff .prev/net/sunrpc/svc.c ./net/sunrpc/svc.c
--- .prev/net/sunrpc/svc.c	2006-10-17 09:10:55.000000000 +1000
+++ ./net/sunrpc/svc.c	2006-10-17 09:10:55.000000000 +1000
@@ -828,6 +828,11 @@ svc_process(struct svc_rqst *rqstp)
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
