From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 3 of 6] svcrpc: move export table checks to a per-program pg_add_client method
Date: Thu, 16 Sep 2004 19:16:29 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1095375544.839c1c96.3@fieldses.org>
References: <1095375544.839c1c96.2@fieldses.org>
Cc: nfs@lists.sourceforge.net, Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C85UN-00012A-2R
	for nfs@lists.sourceforge.net; Thu, 16 Sep 2004 16:16:31 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1C85UM-0002hw-BG
	for nfs@lists.sourceforge.net; Thu, 16 Sep 2004 16:16:30 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <1095375544.839c1c96.2@fieldses.org>
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

So instead we have svcauth_null_accept() and svcauth_unix_accept() call a
program-specific pg_add_client() method.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---

 linux-2.6.9-rc2-bfields/fs/lockd/svc.c                 |   11 +++++++++++
 linux-2.6.9-rc2-bfields/fs/nfsd/nfssvc.c               |   11 +++++++++++
 linux-2.6.9-rc2-bfields/include/linux/sunrpc/svc.h     |    1 +
 linux-2.6.9-rc2-bfields/include/linux/sunrpc/svcauth.h |    2 ++
 linux-2.6.9-rc2-bfields/net/sunrpc/svcauth_unix.c      |    8 ++------
 5 files changed, 27 insertions(+), 6 deletions(-)

diff -puN net/sunrpc/svcauth_unix.c~svcrpc_unix_ip_mapping_method net/sunrpc/svcauth_unix.c
--- linux-2.6.9-rc2/net/sunrpc/svcauth_unix.c~svcrpc_unix_ip_mapping_method	2004-09-16 16:40:53.000000000 -0400
+++ linux-2.6.9-rc2-bfields/net/sunrpc/svcauth_unix.c	2004-09-16 16:40:53.000000000 -0400
@@ -334,10 +334,6 @@ svcauth_unix_set_client(struct svc_rqst 
 {
 	struct ip_map key, *ipm;
 
-	rqstp->rq_client = NULL;
-	if (rqstp->rq_proc == 0)
-		return SVC_OK;
-
 	strcpy(key.m_class, rqstp->rq_server->sv_program->pg_class);
 	key.m_addr = rqstp->rq_addr.sin_addr;
 
@@ -395,7 +391,7 @@ svcauth_null_accept(struct svc_rqst *rqs
 	if (cred->cr_group_info == NULL)
 		return SVC_DROP; /* kmalloc failure - client must retry */
 
-	rv = svcauth_unix_set_client(rqstp);
+	rv = rqstp->rq_server->sv_program->pg_set_client(rqstp);
 	if (rv == SVC_DENIED)
 		goto badcred;
 
@@ -473,7 +469,7 @@ svcauth_unix_accept(struct svc_rqst *rqs
 		return SVC_DENIED;
 	}
 
-	rv = svcauth_unix_set_client(rqstp);
+	rv = rqstp->rq_server->sv_program->pg_set_client(rqstp);
 	if (rv == SVC_DENIED)
 		goto badcred;
 
diff -puN net/sunrpc/svc.c~svcrpc_unix_ip_mapping_method net/sunrpc/svc.c
diff -puN include/linux/sunrpc/svc.h~svcrpc_unix_ip_mapping_method include/linux/sunrpc/svc.h
--- linux-2.6.9-rc2/include/linux/sunrpc/svc.h~svcrpc_unix_ip_mapping_method	2004-09-16 16:40:53.000000000 -0400
+++ linux-2.6.9-rc2-bfields/include/linux/sunrpc/svc.h	2004-09-16 16:40:53.000000000 -0400
@@ -253,6 +253,7 @@ struct svc_program {
 	struct svc_stat *	pg_stats;	/* rpc statistics */
 	/* Override authentication. NULL means use default */
 	int			(*pg_authenticate)(struct svc_rqst *, u32 *);
+	int			(*pg_set_client)(struct svc_rqst *);
 };
 
 /*
diff -L fs/nsfd/nfssvc.c -puN /dev/null /dev/null
diff -puN fs/lockd/svc.c~svcrpc_unix_ip_mapping_method fs/lockd/svc.c
--- linux-2.6.9-rc2/fs/lockd/svc.c~svcrpc_unix_ip_mapping_method	2004-09-16 16:40:53.000000000 -0400
+++ linux-2.6.9-rc2-bfields/fs/lockd/svc.c	2004-09-16 16:40:53.000000000 -0400
@@ -398,6 +398,16 @@ static int param_set_##name(const char *
 	return 0;							\
 }
 
+static int lockd_set_client(struct svc_rqst *rqstp)
+{
+	rqstp->rq_client = NULL;
+	if (rqstp->rq_proc == 0) /* XXX not quite right. */
+		return SVC_OK;
+	else
+		return svcauth_unix_set_client(rqstp);
+}
+
+
 param_set_min_max(port, int, simple_strtol, 0, 65535)
 param_set_min_max(grace_period, unsigned long, simple_strtoul,
 		  nlm_grace_period_min, nlm_grace_period_max)
@@ -478,4 +488,5 @@ struct svc_program	nlmsvc_program = {
 	.pg_name	= "lockd",		/* service name */
 	.pg_class	= "nfsd",		/* share authentication with nfsd */
 	.pg_stats	= &nlmsvc_stats,	/* stats table */
+	.pg_set_client	= &lockd_set_client	/* XXX export authentication */
 };
diff -puN include/linux/sunrpc/svcauth.h~svcrpc_unix_ip_mapping_method include/linux/sunrpc/svcauth.h
--- linux-2.6.9-rc2/include/linux/sunrpc/svcauth.h~svcrpc_unix_ip_mapping_method	2004-09-16 16:40:53.000000000 -0400
+++ linux-2.6.9-rc2-bfields/include/linux/sunrpc/svcauth.h	2004-09-16 16:40:53.000000000 -0400
@@ -119,6 +119,8 @@ extern struct auth_domain *auth_unix_loo
 extern int auth_unix_forget_old(struct auth_domain *dom);
 extern void svcauth_unix_purge(void);
 
+extern int svcauth_unix_set_client(struct svc_rqst *);
+
 static inline unsigned long hash_str(char *name, int bits)
 {
 	unsigned long hash = 0;
diff -puN fs/nfsd/nfssvc.c~svcrpc_unix_ip_mapping_method fs/nfsd/nfssvc.c
--- linux-2.6.9-rc2/fs/nfsd/nfssvc.c~svcrpc_unix_ip_mapping_method	2004-09-16 16:40:53.000000000 -0400
+++ linux-2.6.9-rc2-bfields/fs/nfsd/nfssvc.c	2004-09-16 16:40:53.000000000 -0400
@@ -359,6 +359,15 @@ nfsd_dispatch(struct svc_rqst *rqstp, u3
 	return 1;
 }
 
+static int nfsd_set_client(struct svc_rqst *rqstp)
+{
+	rqstp->rq_client = NULL;
+	if (rqstp->rq_proc == 0)
+		return SVC_OK;
+	else
+		return svcauth_unix_set_client(rqstp);
+}
+
 extern struct svc_version nfsd_version2, nfsd_version3, nfsd_version4;
 
 static struct svc_version *	nfsd_version[] = {
@@ -379,4 +388,6 @@ struct svc_program		nfsd_program = {
 	.pg_name		= "nfsd",		/* program name */
 	.pg_class		= "nfsd",		/* authentication class */
 	.pg_stats		= &nfsd_svcstats,	/* version table */
+	.pg_set_client		= nfsd_set_client,	/* export authentication */
+
 };
_


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
