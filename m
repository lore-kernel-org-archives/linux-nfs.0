From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 6 of 12] nfs4: use new pg_set_client method to simplify nfs4 callback authentication
Date: Tue, 08 Feb 2005 14:06:54 +1100
Message-ID: <E1CyLiI-0006VW-8K@notabene.cse.unsw.edu.au>
References: <20050208140033.24886.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CyLis-0006vI-LK
	for nfs@lists.sourceforge.net; Mon, 07 Feb 2005 19:07:30 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CyLir-0005Dw-Rl
	for nfs@lists.sourceforge.net; Mon, 07 Feb 2005 19:07:30 -0800
To: Andrew Morton <akpm@osdl.org>
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
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfs/callback.c |  156 +++-------------------------------------------------
 1 files changed, 9 insertions(+), 147 deletions(-)

diff ./fs/nfs/callback.c~current~ ./fs/nfs/callback.c
--- ./fs/nfs/callback.c~current~	2005-02-07 15:04:25.000000000 +1100
+++ ./fs/nfs/callback.c	2005-02-07 15:04:46.000000000 +1100
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


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
