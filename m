From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/18] NSM: Move NSM program and procedure numbers to
	fs/lockd/mon.c
Date: Wed, 05 Nov 2008 12:20:20 -0500
Message-ID: <20081105172019.6773.29249.stgit@ingres.1015granger.net>
References: <20081105171300.6773.40121.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:36346 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752752AbYKERU4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 12:20:56 -0500
In-Reply-To: <20081105171300.6773.40121.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Move the RPC program and procedure numbers for NSM into the
one source file that needs them: fs/lockd/mon.c.

And, as with NLM, NFS, and rpcbind calls, use NSMPROC_FOO instead of
SM_FOO for NSM procedure numbers.

Finally, make a couple of comments more precise: what is referred to
here as SM_NOTIFY is really the NLM (lockd) call NLMPROC_SM_NOTIFY,
not NSMPROC_NOTIFY.  The Linux kernel's NSM implementation does not
support NSMPROC_NOTIFY -- it's handled by rpc.statd and sm-notify
in user space.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c                 |   42 ++++++++++++++++++++++++++--------------
 include/linux/lockd/sm_inter.h |    9 ---------
 2 files changed, 27 insertions(+), 24 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 6fafc06..d245856 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -17,6 +17,18 @@
 
 
 #define NLMDBG_FACILITY		NLMDBG_MONITOR
+#define NSM_PROGRAM		100024
+#define NSM_VERSION		1
+
+enum {
+	NSMPROC_NULL,
+	NSMPROC_STAT,
+	NSMPROC_MON,
+	NSMPROC_UNMON,
+	NSMPROC_UNMON_ALL,
+	NSMPROC_SIMU_CRASH,
+	NSMPROC_NOTIFY,
+};
 
 struct nsm_args {
 	__be32			addr;		/* remote address */
@@ -56,7 +68,7 @@ static struct rpc_clnt *nsm_create(void)
 		.addrsize		= sizeof(sin),
 		.servername		= "localhost",
 		.program		= &nsm_program,
-		.version		= SM_VERSION,
+		.version		= NSM_VERSION,
 		.authflavor		= RPC_AUTH_NULL,
 	};
 
@@ -64,7 +76,7 @@ static struct rpc_clnt *nsm_create(void)
 }
 
 /*
- * Common procedure for SM_MON/SM_UNMON calls
+ * Common procedure for NSMPROC_MON/NSMPROC_UNMON calls
  */
 static int
 nsm_mon_unmon(struct nsm_handle *nsm, u32 proc, struct nsm_res *res)
@@ -124,7 +136,7 @@ int nsm_monitor(struct nlm_host *host)
 	if (nsm->sm_monitored)
 		return 0;
 
-	status = nsm_mon_unmon(nsm, SM_MON, &res);
+	status = nsm_mon_unmon(nsm, NSMPROC_MON, &res);
 
 	if (status < 0 || res.status != 0)
 		printk(KERN_NOTICE "lockd: cannot monitor %s\n", host->h_name);
@@ -152,7 +164,7 @@ int nsm_unmonitor(struct nlm_host *host)
 	 && nsm->sm_monitored && !nsm->sm_sticky) {
 		dprintk("lockd: nsm_unmonitor(%s)\n", host->h_name);
 
-		status = nsm_mon_unmon(nsm, SM_UNMON, &res);
+		status = nsm_mon_unmon(nsm, NSMPROC_UNMON, &res);
 		if (status < 0)
 			printk(KERN_NOTICE "lockd: cannot unmonitor %s\n",
 					host->h_name);
@@ -290,7 +302,7 @@ static __be32 *xdr_encode_mon_name(__be32 *p, struct nsm_args *argp)
 /*
  * The "my_id" argument specifies the hostname and RPC procedure
  * to be called when the status manager receives notification
- * (via the SM_NOTIFY call) that the state of host "mon_name"
+ * (via the NLMPROC_SM_NOTIFY call) that the state of host "mon_name"
  * has changed.
  */
 static __be32 *xdr_encode_my_id(__be32 *p, struct nsm_args *argp)
@@ -308,7 +320,7 @@ static __be32 *xdr_encode_my_id(__be32 *p, struct nsm_args *argp)
 
 /*
  * The "mon_id" argument specifies the non-private arguments
- * of an SM_MON or SM_UNMON call.
+ * of an NSMPROC_MON or NSMPROC_UNMON call.
  */
 static __be32 *xdr_encode_mon_id(__be32 *p, struct nsm_args *argp)
 {
@@ -321,8 +333,8 @@ static __be32 *xdr_encode_mon_id(__be32 *p, struct nsm_args *argp)
 
 /*
  * The "priv" argument may contain private information required
- * by the SM_MON call. This information will be supplied in the
- * SM_NOTIFY call.
+ * by the NSMPROC_MON call. This information will be supplied in the
+ * NLMPROC_SM_NOTIFY call.
  *
  * Linux provides the raw IP address of the monitored host,
  * left in network byte order.
@@ -389,22 +401,22 @@ xdr_decode_stat(struct rpc_rqst *rqstp, __be32 *p, struct nsm_res *resp)
 #define SM_unmonres_sz	1
 
 static struct rpc_procinfo	nsm_procedures[] = {
-[SM_MON] = {
-		.p_proc		= SM_MON,
+[NSMPROC_MON] = {
+		.p_proc		= NSMPROC_MON,
 		.p_encode	= (kxdrproc_t) xdr_encode_mon,
 		.p_decode	= (kxdrproc_t) xdr_decode_stat_res,
 		.p_arglen	= SM_mon_sz,
 		.p_replen	= SM_monres_sz,
-		.p_statidx	= SM_MON,
+		.p_statidx	= NSMPROC_MON,
 		.p_name		= "MONITOR",
 	},
-[SM_UNMON] = {
-		.p_proc		= SM_UNMON,
+[NSMPROC_UNMON] = {
+		.p_proc		= NSMPROC_UNMON,
 		.p_encode	= (kxdrproc_t) xdr_encode_unmon,
 		.p_decode	= (kxdrproc_t) xdr_decode_stat,
 		.p_arglen	= SM_mon_id_sz,
 		.p_replen	= SM_unmonres_sz,
-		.p_statidx	= SM_UNMON,
+		.p_statidx	= NSMPROC_UNMON,
 		.p_name		= "UNMONITOR",
 	},
 };
@@ -423,7 +435,7 @@ static struct rpc_stat		nsm_stats;
 
 static struct rpc_program	nsm_program = {
 		.name		= "statd",
-		.number		= SM_PROGRAM,
+		.number		= NSM_PROGRAM,
 		.nrvers		= ARRAY_SIZE(nsm_version),
 		.version	= nsm_version,
 		.stats		= &nsm_stats
diff --git a/include/linux/lockd/sm_inter.h b/include/linux/lockd/sm_inter.h
index 29f0206..da72872 100644
--- a/include/linux/lockd/sm_inter.h
+++ b/include/linux/lockd/sm_inter.h
@@ -9,15 +9,6 @@
 #ifndef LINUX_LOCKD_SM_INTER_H
 #define LINUX_LOCKD_SM_INTER_H
 
-#define SM_PROGRAM	100024
-#define SM_VERSION	1
-#define SM_STAT		1
-#define SM_MON		2
-#define SM_UNMON	3
-#define SM_UNMON_ALL	4
-#define SM_SIMU_CRASH	5
-#define SM_NOTIFY	6
-
 #define SM_MAXSTRLEN	1024
 #define SM_PRIV_SIZE	16
 

