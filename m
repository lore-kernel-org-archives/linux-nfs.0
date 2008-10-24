From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/14] NSM: Move NSM program and procedure numbers to
	fs/lockd/mon.c
Date: Fri, 24 Oct 2008 14:10:32 -0400
Message-ID: <20081024181031.23810.12217.stgit@ingres.1015granger.net>
References: <20081024180150.23810.9718.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:41455 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753339AbYJXSLQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Oct 2008 14:11:16 -0400
Received: from agmgw2.us.oracle.com (agmgw2.us.oracle.com [152.68.180.213])
	by agminet01.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id m9OIBDgh009006
	for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2008 13:11:13 -0500
Received: from acsmt356.oracle.com (acsmt356.oracle.com [141.146.40.156])
	by agmgw2.us.oracle.com (Switch-3.2.0/Switch-3.2.0) with ESMTP id m9N6x3hH010235
	for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2008 12:11:12 -0600
Received: from ingres.1015granger.net (ingres.1015granger.net [127.0.0.1])
	by ingres.1015granger.net (8.14.2/8.14.2) with ESMTP id m9OIAWBq023951
	for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2008 14:10:32 -0400
In-Reply-To: <20081024180150.23810.9718.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Move the RPC program and procedure numbers for NSM into the
one source file that needs them: fs/lockd/mon.c.

And, as with NLM, NFS, and rpcbind calls, use NSMPROC_FOO instead of
SM_FOO for NSM procedure numbers.

Finally, make a couple of comments more precise: what is referred to
here as SM_NOTIFY is really an NLM (lockd) call, not NSMPROC_NOTIFY.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c                 |   37 +++++++++++++++++++++++++------------
 include/linux/lockd/sm_inter.h |    9 ---------
 2 files changed, 25 insertions(+), 21 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index db650cf..6f3a54e 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -18,6 +18,19 @@
 
 #define NLMDBG_FACILITY		NLMDBG_MONITOR
 
+#define NSM_PROGRAM		(100024)
+#define NSM_VERSION		(1)
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
+
 static struct rpc_clnt *	nsm_create(void);
 
 static struct rpc_program	nsm_program;
@@ -190,7 +203,7 @@ int nsm_monitor(struct nlm_host *host)
 	if (nsm->sm_monitored)
 		return 0;
 
-	status = nsm_mon_unmon(nsm, SM_MON, &res);
+	status = nsm_mon_unmon(nsm, NSMPROC_MON, &res);
 
 	if (status < 0 || res.status != 0)
 		printk(KERN_NOTICE "lockd: cannot monitor %s\n", host->h_name);
@@ -218,7 +231,7 @@ int nsm_unmonitor(struct nlm_host *host)
 	 && nsm->sm_monitored && !nsm->sm_sticky) {
 		dprintk("lockd: nsm_unmonitor(%s)\n", host->h_name);
 
-		status = nsm_mon_unmon(nsm, SM_UNMON, &res);
+		status = nsm_mon_unmon(nsm, NSMPROC_UNMON, &res);
 		if (status < 0)
 			printk(KERN_NOTICE "lockd: cannot unmonitor %s\n",
 					host->h_name);
@@ -246,7 +259,7 @@ nsm_create(void)
 		.addrsize	= sizeof(sin),
 		.servername	= "localhost",
 		.program	= &nsm_program,
-		.version	= SM_VERSION,
+		.version	= NSM_VERSION,
 		.authflavor	= RPC_AUTH_NULL,
 	};
 
@@ -280,7 +293,7 @@ static __be32 *xdr_encode_mon_name(__be32 *p, struct nsm_args *argp)
 /*
  * The "my_id" argument specifies the hostname and RPC procedure
  * to be called when the status manager receives notification
- * (via the SM_NOTIFY call) that the state of host "mon_name"
+ * (via the NLM_SM_NOTIFY call) that the state of host "mon_name"
  * has changed.
  */
 static __be32 *xdr_encode_my_id(__be32 *p, struct nsm_args *argp)
@@ -312,7 +325,7 @@ static __be32 *xdr_encode_mon_id(__be32 *p, struct nsm_args *argp)
 /*
  * The "priv" argument may contain private information required
  * by the SM_MON call. This information will be supplied in the
- * SM_NOTIFY call.
+ * NLM_SM_NOTIFY call.
  *
  * Linux provides the raw IP address of the monitored host,
  * left in network byte order.
@@ -379,22 +392,22 @@ xdr_decode_stat(struct rpc_rqst *rqstp, __be32 *p, struct nsm_res *resp)
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
@@ -413,7 +426,7 @@ static struct rpc_stat		nsm_stats;
 
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
 

