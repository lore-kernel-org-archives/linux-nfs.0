From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 3 of 6] svcrpc: move export table checks to a per-program pg_add_client method
Date: Tue, 18 Jan 2005 13:06:25 -0500
Message-ID: <1106070956.b175e53d.3@fieldses.org>
References: <1106070956.b175e53d.2@fieldses.org>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cqxk3-0003kd-94
	for nfs@lists.sourceforge.net; Tue, 18 Jan 2005 10:06:11 -0800
Received: from dh173.citi.umich.edu
	([141.211.133.173] helo=puzzle.fieldses.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1Cqxk2-0004ke-DA
	for nfs@lists.sourceforge.net; Tue, 18 Jan 2005 10:06:11 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <1106070956.b175e53d.2@fieldses.org>
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


svcauth_null_accept() and svcauth_unix_accept() are currently hard-wired to
check the source ip address on an incoming request against the export table,
which make sense for nfsd but not necessarily for other rpc-based services.

So instead we have the accept() method call a program-specific
pg_authenticate() method.  We also move the call to this method into
svc_process instead of calling it from the flavor-specific accept() routines.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---

 linux-2.6.11-rc1-bfields/fs/lockd/svc.c                    |   15 ++++++++++
 linux-2.6.11-rc1-bfields/fs/nfsd/nfssvc.c                  |    2 +
 linux-2.6.11-rc1-bfields/include/linux/sunrpc/svc.h        |    1 
 linux-2.6.11-rc1-bfields/net/sunrpc/auth_gss/svcauth_gss.c |    9 +-----
 linux-2.6.11-rc1-bfields/net/sunrpc/svc.c                  |   12 +++++++-
 linux-2.6.11-rc1-bfields/net/sunrpc/svcauth_unix.c         |   18 +------------
 6 files changed, 33 insertions(+), 24 deletions(-)

diff -puN fs/lockd/svc.c~svcrpc_unix_ip_mapping_method fs/lockd/svc.c
--- linux-2.6.11-rc1/fs/lockd/svc.c~svcrpc_unix_ip_mapping_method	2005-01-17 12:04:01.000000000 -0500
+++ linux-2.6.11-rc1-bfields/fs/lockd/svc.c	2005-01-18 12:50:53.000000000 -0500
@@ -403,6 +403,20 @@ static int param_set_##name(const char *
 	return 0;							\
 }
 
+static int lockd_authenticate(struct svc_rqst *rqstp)
+{
+	rqstp->rq_client = NULL;
+	switch (rqstp->rq_authop->flavour) {
+		case RPC_AUTH_NULL:
+		case RPC_AUTH_UNIX:
+			if (rqstp->rq_proc == 0)
+				return SVC_OK;
+			return svc_set_client(rqstp);
+	}
+	return SVC_DENIED;
+}
+
+
 param_set_min_max(port, int, simple_strtol, 0, 65535)
 param_set_min_max(grace_period, unsigned long, simple_strtoul,
 		  nlm_grace_period_min, nlm_grace_period_max)
@@ -483,4 +497,5 @@ static struct svc_program	nlmsvc_program
 	.pg_name		= "lockd",		/* service name */
 	.pg_class		= "nfsd",		/* share authentication with nfsd */
 	.pg_stats		= &nlmsvc_stats,	/* stats table */
+	.pg_authenticate = &lockd_authenticate	/* export authentication */
 };
diff -puN fs/nfsd/nfssvc.c~svcrpc_unix_ip_mapping_method fs/nfsd/nfssvc.c
--- linux-2.6.11-rc1/fs/nfsd/nfssvc.c~svcrpc_unix_ip_mapping_method	2005-01-17 12:04:02.000000000 -0500
+++ linux-2.6.11-rc1-bfields/fs/nfsd/nfssvc.c	2005-01-17 12:04:02.000000000 -0500
@@ -378,4 +378,6 @@ struct svc_program		nfsd_program = {
 	.pg_name		= "nfsd",		/* program name */
 	.pg_class		= "nfsd",		/* authentication class */
 	.pg_stats		= &nfsd_svcstats,	/* version table */
+	.pg_authenticate	= &svc_set_client,	/* export authentication */
+
 };
diff -puN include/linux/sunrpc/svc.h~svcrpc_unix_ip_mapping_method include/linux/sunrpc/svc.h
--- linux-2.6.11-rc1/include/linux/sunrpc/svc.h~svcrpc_unix_ip_mapping_method	2005-01-17 12:04:02.000000000 -0500
+++ linux-2.6.11-rc1-bfields/include/linux/sunrpc/svc.h	2005-01-18 12:50:52.000000000 -0500
@@ -253,6 +253,7 @@ struct svc_program {
 	struct svc_stat *	pg_stats;	/* rpc statistics */
 	/* Override authentication. NULL means use default */
 	int			(*pg_authenticate_obsolete)(struct svc_rqst *, u32 *);
+	int			(*pg_authenticate)(struct svc_rqst *);
 };
 
 /*
diff -puN net/sunrpc/auth_gss/svcauth_gss.c~svcrpc_unix_ip_mapping_method net/sunrpc/auth_gss/svcauth_gss.c
--- linux-2.6.11-rc1/net/sunrpc/auth_gss/svcauth_gss.c~svcrpc_unix_ip_mapping_method	2005-01-17 12:04:02.000000000 -0500
+++ linux-2.6.11-rc1-bfields/net/sunrpc/auth_gss/svcauth_gss.c	2005-01-18 12:54:13.000000000 -0500
@@ -906,11 +906,6 @@ svcauth_gss_accept(struct svc_rqst *rqst
 		svc_putu32(resv, rpc_success);
 		goto complete;
 	case RPC_GSS_PROC_DATA:
-		*authp = rpc_autherr_badcred;
-		rqstp->rq_client =
-			find_gss_auth_domain(rsci->mechctx, gc->gc_svc);
-		if (rqstp->rq_client == NULL)
-			goto auth_err;
 		*authp = rpcsec_gsserr_ctxproblem;
 		if (gss_write_verf(rqstp, rsci->mechctx, gc->gc_seq))
 			goto auth_err;
@@ -924,8 +919,6 @@ svcauth_gss_accept(struct svc_rqst *rqst
 			if (unwrap_integ_data(&rqstp->rq_arg,
 					gc->gc_seq, rsci->mechctx))
 				goto auth_err;
-			svcdata->rsci = rsci;
-			cache_get(&rsci->h);
 			/* placeholders for length and seq. number: */
 			svcdata->body_start = resv->iov_base + resv->iov_len;
 			svc_putu32(resv, 0);
@@ -936,6 +929,8 @@ svcauth_gss_accept(struct svc_rqst *rqst
 		default:
 			goto auth_err;
 		}
+		svcdata->rsci = rsci;
+		cache_get(&rsci->h);
 		ret = SVC_OK;
 		goto out;
 	}
diff -puN net/sunrpc/svcauth_unix.c~svcrpc_unix_ip_mapping_method net/sunrpc/svcauth_unix.c
--- linux-2.6.11-rc1/net/sunrpc/svcauth_unix.c~svcrpc_unix_ip_mapping_method	2005-01-17 12:04:02.000000000 -0500
+++ linux-2.6.11-rc1-bfields/net/sunrpc/svcauth_unix.c	2005-01-18 12:44:10.000000000 -0500
@@ -368,7 +368,6 @@ svcauth_null_accept(struct svc_rqst *rqs
 	struct kvec	*argv = &rqstp->rq_arg.head[0];
 	struct kvec	*resv = &rqstp->rq_res.head[0];
 	struct svc_cred	*cred = &rqstp->rq_cred;
-	int		rv=0;
 
 	cred->cr_group_info = NULL;
 	rqstp->rq_client = NULL;
@@ -394,19 +393,11 @@ svcauth_null_accept(struct svc_rqst *rqs
 	if (cred->cr_group_info == NULL)
 		return SVC_DROP; /* kmalloc failure - client must retry */
 
-	rv = svcauth_unix_set_client(rqstp);
-	if (rv == SVC_DENIED)
-		goto badcred;
-
 	/* Put NULL verifier */
 	svc_putu32(resv, RPC_AUTH_NULL);
 	svc_putu32(resv, 0);
 
-	return rv;
-
-badcred:
-	*authp = rpc_autherr_badcred;
-	return SVC_DENIED;
+	return SVC_OK;
 }
 
 static int
@@ -441,7 +432,6 @@ svcauth_unix_accept(struct svc_rqst *rqs
 	struct svc_cred	*cred = &rqstp->rq_cred;
 	u32		slen, i;
 	int		len   = argv->iov_len;
-	int		rv=0;
 
 	cred->cr_group_info = NULL;
 	rqstp->rq_client = NULL;
@@ -473,15 +463,11 @@ svcauth_unix_accept(struct svc_rqst *rqs
 		return SVC_DENIED;
 	}
 
-	rv = svcauth_unix_set_client(rqstp);
-	if (rv == SVC_DENIED)
-		goto badcred;
-
 	/* Put NULL verifier */
 	svc_putu32(resv, RPC_AUTH_NULL);
 	svc_putu32(resv, 0);
 
-	return rv;
+	return SVC_OK;
 
 badcred:
 	*authp = rpc_autherr_badcred;
diff -puN net/sunrpc/svc.c~svcrpc_unix_ip_mapping_method net/sunrpc/svc.c
--- linux-2.6.11-rc1/net/sunrpc/svc.c~svcrpc_unix_ip_mapping_method	2005-01-17 12:04:02.000000000 -0500
+++ linux-2.6.11-rc1-bfields/net/sunrpc/svc.c	2005-01-18 12:50:52.000000000 -0500
@@ -264,6 +264,7 @@ svc_process(struct svc_serv *serv, struc
 	u32			dir, prog, vers, proc,
 				auth_stat, rpc_stat;
 	int			auth_res;
+	u32			*accept_statp;
 
 	rpc_stat = rpc_success;
 
@@ -299,6 +300,9 @@ svc_process(struct svc_serv *serv, struc
 	if (vers != 2)		/* RPC version number */
 		goto err_bad_rpc;
 
+	/* Save position in case we later decide to reject: */
+	accept_statp = resv->iov_base + resv->iov_len;
+
 	svc_putu32(resv, xdr_zero);		/* ACCEPT */
 
 	rqstp->rq_prog = prog = ntohl(svc_getu32(argv));	/* program number */
@@ -315,6 +319,11 @@ svc_process(struct svc_serv *serv, struc
 		auth_res = progp->pg_authenticate_obsolete(rqstp, &auth_stat);
 	else
 		auth_res = svc_authenticate(rqstp, &auth_stat);
+	/* Also give the program a chance to reject this call: */
+	if (auth_res == SVC_OK) {
+		auth_stat = rpc_autherr_badcred;
+		auth_res = progp->pg_authenticate(rqstp);
+	}
 	switch (auth_res) {
 	case SVC_OK:
 		break;
@@ -437,7 +446,8 @@ err_bad_rpc:
 err_bad_auth:
 	dprintk("svc: authentication failed (%d)\n", ntohl(auth_stat));
 	serv->sv_stats->rpcbadauth++;
-	resv->iov_len -= 4;
+	/* Restore write pointer to location of accept status: */
+	xdr_ressize_check(rqstp, accept_statp);
 	svc_putu32(resv, xdr_one);	/* REJECT */
 	svc_putu32(resv, xdr_one);	/* AUTH_ERROR */
 	svc_putu32(resv, auth_stat);	/* status */
_


-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
