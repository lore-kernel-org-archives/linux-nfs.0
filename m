From: Olaf Kirch <okir@suse.de>
Subject: Re: Re: [PATCH 3 of 6] svcrpc: move export table checks to a per-program pg_add_client method
Date: Fri, 24 Sep 2004 09:42:09 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040924074209.GA18703@suse.de>
References: <1095375544.839c1c96.3@fieldses.org> <1095383919.10216.142.camel@lade.trondhjem.org> <20040917022015.GA15212@fieldses.org> <16721.8596.980204.899779@cse.unsw.edu.au> <20040923214644.GA19291@fieldses.org> <16723.40128.804230.618580@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="gBBFr7Ir9EOA20Yy"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CAkjn-0006HK-Nl
	for nfs@lists.sourceforge.net; Fri, 24 Sep 2004 00:43:27 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CAkjl-00075k-U5
	for nfs@lists.sourceforge.net; Fri, 24 Sep 2004 00:43:27 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16723.40128.804230.618580@cse.unsw.edu.au>
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


--gBBFr7Ir9EOA20Yy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Sep 24, 2004 at 02:04:16PM +1000, Neil Brown wrote:
> Does anyone have objections to the following patch, which presumes the 
> svcauth_unix_set_client patch from Bruce.  With it, locking starts
> working again.

It looks to me as if the patch forgets to include the NULL verifier
for those procedures that don't need authentication.

I think you also want to do the same in svcauth_null_accept, as some
lockd implementations actually use AUTH_NULL.

For what it's worth, I added a similar patch to our tree yesterday
to fix this problem. (This is mostly FYI - the patch won't apply cleanly
to the vanilla kernel, as it is based on top of the kernel-statd stuff)

Olaf
-- 
Olaf Kirch     | Things that make Monday morning interesting, #1:
okir@suse.de   |        "I want to use NFS over AX25, can you help me?"
---------------+ 

--gBBFr7Ir9EOA20Yy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=sunrpc-optional-auth

Index: linux-2.6.5/fs/lockd/svc.c
===================================================================
--- linux-2.6.5.orig/fs/lockd/svc.c	2004-09-22 15:57:04.000000000 +0200
+++ linux-2.6.5/fs/lockd/svc.c	2004-09-22 15:58:34.000000000 +0200
@@ -211,6 +211,32 @@
 	module_put_and_exit(0);
 }
 
+static int
+lockd_rqst_needs_auth(struct svc_rqst *rqstp)
+{
+	u32 proc = rqstp->rq_proc;
+
+	if (proc == 0
+	 || proc == NLMPROC_GRANTED
+	 || proc == NLMPROC_TEST_RES
+	 || proc == NLMPROC_LOCK_RES
+	 || proc == NLMPROC_CANCEL_RES
+	 || proc == NLMPROC_UNLOCK_RES
+	 || proc == NLMPROC_GRANTED_RES
+	 || proc == NLMPROC_NSM_NOTIFY)
+		return 0;
+	return 1;
+}
+
+#ifdef CONFIG_STATD
+static int
+statd_rqst_needs_auth(struct svc_rqst *rqstp)
+{
+	/* statd is unauthenticated */
+	return 0;
+}
+#endif
+
 /*
  * Bring up the lockd process if it's not already up.
  */
@@ -480,6 +506,8 @@
 	.pg_name	= "statd",		/* service name */
 	.pg_class	= "nfsd",		/* share authentication with nfsd */
 	.pg_stats	= &nsmsvc_stats,	/* stats table */
+
+	.pg_need_auth	= statd_rqst_needs_auth,
 };
 
 #define nsmsvc_program_p &nsmsvc_program
@@ -529,4 +557,6 @@
 	.pg_name	= "lockd",		/* service name */
 	.pg_class	= "nfsd",		/* share authentication with nfsd */
 	.pg_stats	= &nlmsvc_stats,	/* stats table */
+
+	.pg_need_auth	= lockd_rqst_needs_auth,
 };
Index: linux-2.6.5/fs/nfsd/nfssvc.c
===================================================================
--- linux-2.6.5.orig/fs/nfsd/nfssvc.c	2004-09-22 15:57:04.000000000 +0200
+++ linux-2.6.5/fs/nfsd/nfssvc.c	2004-09-22 15:58:34.000000000 +0200
@@ -360,6 +360,14 @@
 	return 1;
 }
 
+static int
+nfsd_rqst_needs_auth(struct svc_rqst *rqstp)
+{
+	if (rqstp->rq_proc == 0)
+		return 0;
+	return 1;
+}
+
 extern struct svc_version nfsd_version2, nfsd_version3, nfsd_version4;
 
 static struct svc_version *	nfsd_version[] = {
@@ -386,6 +394,8 @@
 	.pg_vers		= nfsd_acl_version,
 	.pg_name		= "nfsd",
 	.pg_stats		= &nfsd_acl_svcstats,
+
+	.pg_need_auth		= nfsd_rqst_needs_auth,
 };
 # define nfsd_acl_program_p &nfsd_acl_program
 #else
@@ -401,4 +411,6 @@
 	.pg_name		= "nfsd",		/* program name */
 	.pg_class		= "nfsd",		/* authentication class */
 	.pg_stats		= &nfsd_svcstats,	/* version table */
+
+	.pg_need_auth		= nfsd_rqst_needs_auth,
 };
Index: linux-2.6.5/include/linux/sunrpc/svc.h
===================================================================
--- linux-2.6.5.orig/include/linux/sunrpc/svc.h	2004-09-22 15:57:04.000000000 +0200
+++ linux-2.6.5/include/linux/sunrpc/svc.h	2004-09-22 15:58:56.000000000 +0200
@@ -264,6 +264,8 @@
 	char *			pg_name;	/* service name */
 	char *			pg_class;	/* class name: services sharing authentication */
 	struct svc_stat *	pg_stats;	/* rpc statistics */
+
+	int			(*pg_need_auth)(struct svc_rqst *);
 };
 
 /*
Index: linux-2.6.5/net/sunrpc/svcauth_unix.c
===================================================================
--- linux-2.6.5.orig/net/sunrpc/svcauth_unix.c	2004-09-22 15:57:04.000000000 +0200
+++ linux-2.6.5/net/sunrpc/svcauth_unix.c	2004-09-22 15:59:20.000000000 +0200
@@ -337,6 +337,7 @@
 static int
 svcauth_null_accept(struct svc_rqst *rqstp, u32 *authp)
 {
+	struct svc_program *prog = rqstp->rq_server->sv_program;
 	struct iovec	*argv = &rqstp->rq_arg.head[0];
 	struct iovec	*resv = &rqstp->rq_res.head[0];
 	int		rv=0;
@@ -363,9 +364,10 @@
 	if (rqstp->rq_cred.cr_group_info == NULL)
 		return SVC_DROP; /* kmalloc failure - client must retry */
 
-	/* Put NULL verifier */
-	svc_putu32(resv, RPC_AUTH_NULL);
-	svc_putu32(resv, 0);
+	if (prog->pg_need_auth && !prog->pg_need_auth(rqstp)) {
+		rv = SVC_OK;
+		goto accepted;
+	}
 
 	key.m_class = rqstp->rq_server->sv_program->pg_class;
 	key.m_addr = rqstp->rq_addr.sin_addr;
@@ -395,6 +397,11 @@
 	if (rqstp->rq_client == NULL && rqstp->rq_proc != 0)
 		*authp = rpc_autherr_badcred;
 
+accepted:
+	/* Put NULL verifier */
+	svc_putu32(resv, RPC_AUTH_NULL);
+	svc_putu32(resv, 0);
+
 	return rv;
 }
 
@@ -420,6 +427,7 @@
 int
 svcauth_unix_accept(struct svc_rqst *rqstp, u32 *authp)
 {
+	struct svc_program *prog = rqstp->rq_server->sv_program;
 	struct iovec	*argv = &rqstp->rq_arg.head[0];
 	struct iovec	*resv = &rqstp->rq_res.head[0];
 	struct svc_cred	*cred = &rqstp->rq_cred;
@@ -462,6 +470,10 @@
 	key.m_class = rqstp->rq_server->sv_program->pg_class;
 	key.m_addr = rqstp->rq_addr.sin_addr;
 
+	if (prog->pg_need_auth && !prog->pg_need_auth(rqstp)) {
+		rv = SVC_OK;
+		goto accepted;
+	}
 
 	ipm = ip_map_lookup(&key, 0);
 
@@ -486,6 +498,7 @@
 	if (rv  == SVC_OK && rqstp->rq_client == NULL && rqstp->rq_proc != 0)
 		goto badcred;
 
+accepted:
 	/* Put NULL verifier */
 	svc_putu32(resv, RPC_AUTH_NULL);
 	svc_putu32(resv, 0);

--gBBFr7Ir9EOA20Yy--


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
