From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] lockd: fix two struct definitions
Date: Wed, 3 Nov 2004 22:47:32 +0100
Message-ID: <20041103214732.GD31830@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261921AbUKCVtK@vger.kernel.org>
To: neilb@cse.unsw.edu.au, nfs@lists.sourceforge.net,
	trond.myklebust@fys.uio.no, linux-kernel@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Under fs/lockd/, there are two structs declared extern although they are 
in the same file. Furtheremore, they don't have to be global since their 
only users are in the same file.

Most of the changes to svc.c are only indent fixes caused by making the 
struct static.


diffstat output:
 fs/lockd/mon.c |    4 ++--
 fs/lockd/svc.c |   16 ++++++++--------
 2 files changed, 10 insertions(+), 10 deletions(-)


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.10-rc1-mm2-full/fs/lockd/mon.c.old	2004-11-03 22:29:13.000000000 +0100
+++ linux-2.6.10-rc1-mm2-full/fs/lockd/mon.c	2004-11-03 22:29:44.000000000 +0100
@@ -19,7 +19,7 @@
 
 static struct rpc_clnt *	nsm_create(void);
 
-extern struct rpc_program	nsm_program;
+static struct rpc_program	nsm_program;
 
 /*
  * Local NSM state
@@ -237,7 +237,7 @@
 
 static struct rpc_stat		nsm_stats;
 
-struct rpc_program		nsm_program = {
+static struct rpc_program	nsm_program = {
 		.name		= "statd",
 		.number		= SM_PROGRAM,
 		.nrvers		= sizeof(nsm_version)/sizeof(nsm_version[0]),
--- linux-2.6.10-rc1-mm2-full/fs/lockd/svc.c.old	2004-11-03 22:26:30.000000000 +0100
+++ linux-2.6.10-rc1-mm2-full/fs/lockd/svc.c	2004-11-03 22:30:05.000000000 +0100
@@ -38,7 +38,7 @@
 #define LOCKD_BUFSIZE		(1024 + NLMSVC_XDRSIZE)
 #define ALLOWED_SIGS		(sigmask(SIGKILL))
 
-extern struct svc_program	nlmsvc_program;
+static struct svc_program	nlmsvc_program;
 
 struct nlmsvc_binding *		nlmsvc_ops;
 EXPORT_SYMBOL(nlmsvc_ops);
@@ -476,11 +476,11 @@
 static struct svc_stat		nlmsvc_stats;
 
 #define NLM_NRVERS	(sizeof(nlmsvc_version)/sizeof(nlmsvc_version[0]))
-struct svc_program	nlmsvc_program = {
-	.pg_prog	= NLM_PROGRAM,		/* program number */
-	.pg_nvers	= NLM_NRVERS,		/* number of entries in nlmsvc_version */
-	.pg_vers	= nlmsvc_version,	/* version table */
-	.pg_name	= "lockd",		/* service name */
-	.pg_class	= "nfsd",		/* share authentication with nfsd */
-	.pg_stats	= &nlmsvc_stats,	/* stats table */
+static struct svc_program	nlmsvc_program = {
+	.pg_prog		= NLM_PROGRAM,		/* program number */
+	.pg_nvers		= NLM_NRVERS,		/* number of entries in nlmsvc_version */
+	.pg_vers		= nlmsvc_version,	/* version table */
+	.pg_name		= "lockd",		/* service name */
+	.pg_class		= "nfsd",		/* share authentication with nfsd */
+	.pg_stats		= &nlmsvc_stats,	/* stats table */
 };
