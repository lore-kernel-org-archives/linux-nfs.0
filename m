From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 4 of 6] nfs4: use new pg_set_client method to simplify nfs4 callback authentication
Date: Thu, 09 Dec 2004 17:28:37 -0500
Message-ID: <1102628809.16c39937.4@fieldses.org>
References: <1102628809.16c39937.3@fieldses.org>
Cc: nfs@lists.sourceforge.net, Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CcWlh-0005Fk-R2
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 14:28:13 -0800
Received: from dh173.citi.umich.edu
	([141.211.133.173] helo=puzzle.fieldses.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.41)
	id 1CcWlh-0006Q1-8t
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 14:28:13 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <1102628809.16c39937.3@fieldses.org>
Sender: nfs-admin@lists.sourceforge.net
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


Use new pg_authenticate method to simplify nfs4 callback authentication.

This also has the effect of changing the error return from rejectedcred to
badcred.  I believe the change is correct.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---

 linux-2.6.10-rc3-bfields/fs/nfs/callback.c |  156 +----------------------------
 1 files changed, 9 insertions(+), 147 deletions(-)

diff -puN fs/nfs/callback.c~nfs4_simplify_callback_auth fs/nfs/callback.c
--- linux-2.6.10-rc3/fs/nfs/callback.c~nfs4_simplify_callback_auth	2004-12-08 15:12:12.000000000 -0500
+++ linux-2.6.10-rc3-bfields/fs/nfs/callback.c	2004-12-08 15:12:12.000000000 -0500
@@ -139,133 +139,10 @@ out:
 	return ret;
 }
 
-/*
- * AUTH_NULL authentication
- */
-static int nfs_callback_null_accept(struct svc_rqst *rqstp, u32 *authp)
-{
-	struct kvec    *argv = &rqstp->rq_arg.head[0];
-	struct kvec    *resv = &rqstp->rq_res.head[0];
-
-	if (argv->iov_len < 3*4)
-		return SVC_GARBAGE;
-
-	if (svc_getu32(argv) != 0) {
-		dprintk("svc: bad null cred\n");
-		*authp = rpc_autherr_badcred;
-		return SVC_DENIED;
-	}
-	if (svc_getu32(argv) != RPC_AUTH_NULL || svc_getu32(argv) != 0) {
-		dprintk("svc: bad null verf\n");
-		 *authp = rpc_autherr_badverf;
-		 return SVC_DENIED;
-	}
-
-	/* Signal that mapping to nobody uid/gid is required */
-	rqstp->rq_cred.cr_uid = (uid_t) -1;
-	rqstp->rq_cred.cr_gid = (gid_t) -1;
-	rqstp->rq_cred.cr_group_info = groups_alloc(0);
-	if (rqstp->rq_cred.cr_group_info == NULL)
-		return SVC_DROP; /* kmalloc failure - client must retry */
-
-	/* Put NULL verifier */
-	svc_putu32(resv, RPC_AUTH_NULL);
-	svc_putu32(resv, 0);
-	dprintk("%s: success, returning %d!\n", __FUNCTION__, SVC_OK);
-	return SVC_OK;
-}
-
-static int nfs_callback_null_release(struct svc_rqst *rqstp)
-{
-	if (rqstp->rq_cred.cr_group_info)
-		put_group_info(rqstp->rq_cred.cr_group_info);
-	rqstp->rq_cred.cr_group_info = NULL;
-	return 0; /* don't drop */
-}
-
-static struct auth_ops nfs_callback_auth_null = {
-	.name = "null",
-	.flavour = RPC_AUTH_NULL,
-	.accept = nfs_callback_null_accept,
-	.release = nfs_callback_null_release,
-};
-
-/*
- * AUTH_SYS authentication
- */
-static int nfs_callback_unix_accept(struct svc_rqst *rqstp, u32 *authp)
-{
-	struct kvec    *argv = &rqstp->rq_arg.head[0];
-	struct kvec    *resv = &rqstp->rq_res.head[0];
-	struct svc_cred *cred = &rqstp->rq_cred;
-	u32 slen, i;
-	int len = argv->iov_len;
-
-	dprintk("%s: start\n", __FUNCTION__);
-	cred->cr_group_info = NULL;
-	rqstp->rq_client = NULL;
-	if ((len -= 3*4) < 0)
-		return SVC_GARBAGE;
-
-	/* Get length, time stamp and machine name */
-	svc_getu32(argv);
-	svc_getu32(argv);
-	slen = XDR_QUADLEN(ntohl(svc_getu32(argv)));
-	if (slen > 64 || (len -= (slen + 3)*4) < 0)
-		goto badcred;
-	argv->iov_base = (void*)((u32*)argv->iov_base + slen);
-	argv->iov_len -= slen*4;
-
-	cred->cr_uid = ntohl(svc_getu32(argv));
-	cred->cr_gid = ntohl(svc_getu32(argv));
-	slen = ntohl(svc_getu32(argv));
-	if (slen > 16 || (len -= (slen + 2)*4) < 0)
-		goto badcred;
-	cred->cr_group_info = groups_alloc(slen);
-	if (cred->cr_group_info == NULL)
-		return SVC_DROP;
-	for (i = 0; i < slen; i++)
-		GROUP_AT(cred->cr_group_info, i) = ntohl(svc_getu32(argv));
-
-	if (svc_getu32(argv) != RPC_AUTH_NULL || svc_getu32(argv) != 0) {
-		*authp = rpc_autherr_badverf;
-		return SVC_DENIED;
-	}
-	/* Put NULL verifier */
-	svc_putu32(resv, RPC_AUTH_NULL);
-	svc_putu32(resv, 0);
-	dprintk("%s: success, returning %d!\n", __FUNCTION__, SVC_OK);
-	return SVC_OK;
-badcred:
-	*authp = rpc_autherr_badcred;
-	return SVC_DENIED;
-}
-
-static int nfs_callback_unix_release(struct svc_rqst *rqstp)
-{
-	if (rqstp->rq_cred.cr_group_info)
-		put_group_info(rqstp->rq_cred.cr_group_info);
-	rqstp->rq_cred.cr_group_info = NULL;
-	return 0;
-}
-
-static struct auth_ops nfs_callback_auth_unix = {
-	.name = "unix",
-	.flavour = RPC_AUTH_UNIX,
-	.accept = nfs_callback_unix_accept,
-	.release = nfs_callback_unix_release,
-};
-
-/*
- * Hook the authentication protocol
- */
-static int nfs_callback_auth(struct svc_rqst *rqstp, u32 *authp)
+static int nfs_callback_authenticate(struct svc_rqst *rqstp)
 {
 	struct in_addr *addr = &rqstp->rq_addr.sin_addr;
 	struct nfs4_client *clp;
-	struct kvec *argv = &rqstp->rq_arg.head[0];
-	int flavour;
-	int retval;
 
 	/* Don't talk to strangers */
 	clp = nfs4_find_client(addr);
@@ -273,34 +150,19 @@ static int nfs_callback_auth(struct svc_
 		return SVC_DROP;
 	dprintk("%s: %u.%u.%u.%u NFSv4 callback!\n", __FUNCTION__, NIPQUAD(addr));
 	nfs4_put_client(clp);
-	flavour = ntohl(svc_getu32(argv));
-	switch(flavour) {
+	switch (rqstp->rq_authop->flavour) {
 		case RPC_AUTH_NULL:
-			if (rqstp->rq_proc != CB_NULL) {
-				*authp = rpc_autherr_tooweak;
-				retval = SVC_DENIED;
-				break;
-			}
-			rqstp->rq_authop = &nfs_callback_auth_null;
-			retval = nfs_callback_null_accept(rqstp, authp);
+			if (rqstp->rq_proc != CB_NULL)
+				return SVC_DENIED;
 			break;
 		case RPC_AUTH_UNIX:
-			/* Eat the authentication flavour */
-			rqstp->rq_authop = &nfs_callback_auth_unix;
-			retval = nfs_callback_unix_accept(rqstp, authp);
 			break;
+		case RPC_AUTH_GSS:
+			/* FIXME: RPCSEC_GSS handling? */
 		default:
-			/* FIXME: need to add RPCSEC_GSS upcalls */
-#if 0
-			svc_ungetu32(argv);
-			retval = svc_authenticate(rqstp, authp);
-#else
-			*authp = rpc_autherr_rejectedcred;
-			retval = SVC_DENIED;
-#endif
+			return SVC_DENIED;
 	}
-	dprintk("%s: flavour %d returning error %d\n", __FUNCTION__, flavour, retval);
-	return retval;
+	return SVC_OK;
 }
 
 /*
@@ -321,5 +183,5 @@ static struct svc_program nfs4_callback_
 	.pg_name = "NFSv4 callback",			/* service name */
 	.pg_class = "nfs",				/* authentication class */
 	.pg_stats = &nfs4_callback_stats,
-	.pg_authenticate_obsolete = nfs_callback_auth,
+	.pg_authenticate = nfs_callback_authenticate,
 };
_


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
