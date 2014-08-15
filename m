Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f178.google.com ([209.85.216.178]:60639 "EHLO
	mail-qc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751381AbaHOOox (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Aug 2014 10:44:53 -0400
Received: by mail-qc0-f178.google.com with SMTP id x3so2384788qcv.37
        for <linux-nfs@vger.kernel.org>; Fri, 15 Aug 2014 07:44:52 -0700 (PDT)
Received: from tlielax.poochiereds.net ([2001:470:8:d63:3a60:77ff:fe93:a95d])
        by mx.google.com with ESMTPSA id i2sm9046955qge.27.2014.08.15.07.44.51
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Aug 2014 07:44:51 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [kernel RFC PATCH 4/4] nfsd: pass extra info in env vars to upcalls to allow for early grace period end
Date: Fri, 15 Aug 2014 10:44:40 -0400
Message-Id: <1408113880-5489-5-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1408113880-5489-1-git-send-email-jlayton@primarydata.com>
References: <1408113880-5489-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In order to support lifting the grace period early, we must tell the
nfsdcltrack what sort of client the "create" upcall is for. We can't
reliably tell if a v4.0 client has completed reclaiming, so we can only
lift the grace period once all the v4.1+ clients have issued a
RECLAIM_COMPLETE and if there are no v4.0 clients.

Also, in order to lift the grace period, we have to tell userland when
the grace period started so that it can tell whether a RECLAIM_COMPLETE
has been issued for each client since then.

Since this is all optional info, we pass it along in environment
variables to the "init" and "create" upcalls. By doing this, we don't
need to revise the upcall format. The UMH upcall can simply make use of
this info if it happens to be present. If it's not then it can just
avoid lifting the grace period early.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4recover.c | 90 ++++++++++++++++++++++++++++++++++++++++++++-------
 fs/nfsd/nfs4state.c   |  4 +--
 2 files changed, 80 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index a0d2ba956a3f..2b61bcd92b58 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -1062,6 +1062,8 @@ MODULE_PARM_DESC(cltrack_legacy_disable,
 
 #define LEGACY_TOPDIR_ENV_PREFIX "NFSDCLTRACK_LEGACY_TOPDIR="
 #define LEGACY_RECDIR_ENV_PREFIX "NFSDCLTRACK_LEGACY_RECDIR="
+#define CLIENT_MINORVERS_ENV_PREFIX "NFSDCLTRACK_CLIENT_MINORVERSION="
+#define GRACE_START_ENV_PREFIX "NFSDCLTRACK_GRACE_START="
 
 static char *
 nfsd4_cltrack_legacy_topdir(void)
@@ -1126,10 +1128,60 @@ nfsd4_cltrack_legacy_recdir(const struct xdr_netobj *name)
 	return result;
 }
 
+static char *
+nfsd4_cltrack_client_minorversion(struct nfs4_client *clp)
+{
+	int copied;
+	size_t len;
+	char *result;
+
+	/* prefix + max width of integer string + terminating NULL */
+	len = strlen(CLIENT_MINORVERS_ENV_PREFIX) + 10 + 1;
+
+	result = kmalloc(len, GFP_KERNEL);
+	if (!result)
+		return result;
+
+	copied = snprintf(result, len, CLIENT_MINORVERS_ENV_PREFIX "%u",
+				clp->cl_minorversion);
+	if (copied >= len) {
+		/* just return nothing if output was truncated */
+		kfree(result);
+		return NULL;
+	}
+
+	return result;
+}
+
+static char *
+nfsd4_cltrack_grace_start(time_t grace_start)
+{
+	int copied;
+	size_t len;
+	char *result;
+
+	/* prefix + max width of int64_t string + terminating NULL */
+	len = strlen(GRACE_START_ENV_PREFIX) + 22 + 1;
+
+	result = kmalloc(len, GFP_KERNEL);
+	if (!result)
+		return result;
+
+	copied = snprintf(result, len, GRACE_START_ENV_PREFIX "%ld",
+				grace_start);
+	if (copied >= len) {
+		/* just return nothing if output was truncated */
+		kfree(result);
+		return NULL;
+	}
+
+	return result;
+}
+
 static int
-nfsd4_umh_cltrack_upcall(char *cmd, char *arg, char *legacy)
+nfsd4_umh_cltrack_upcall(char *cmd, char *arg, char *env0, char *env1)
 {
-	char *envp[2];
+	char *envp[3];
 	char *argv[4];
 	int ret;
 
@@ -1140,10 +1192,12 @@ nfsd4_umh_cltrack_upcall(char *cmd, char *arg, char *legacy)
 
 	dprintk("%s: cmd: %s\n", __func__, cmd);
 	dprintk("%s: arg: %s\n", __func__, arg ? arg : "(null)");
-	dprintk("%s: legacy: %s\n", __func__, legacy ? legacy : "(null)");
+	dprintk("%s: env0: %s\n", __func__, env0 ? env0 : "(null)");
+	dprintk("%s: env1: %s\n", __func__, env1 ? env1 : "(null)");
 
-	envp[0] = legacy;
-	envp[1] = NULL;
+	envp[0] = env0;
+	envp[1] = env1;
+	envp[2] = NULL;
 
 	argv[0] = (char *)cltrack_prog;
 	argv[1] = cmd;
@@ -1187,28 +1241,40 @@ bin_to_hex_dup(const unsigned char *src, int srclen)
 }
 
 static int
-nfsd4_umh_cltrack_init(struct net __attribute__((unused)) *net)
+nfsd4_umh_cltrack_init(struct net *net)
 {
+	int ret;
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+	char *grace_start = nfsd4_cltrack_grace_start(nn->boot_time);
+
 	/* XXX: The usermode helper s not working in container yet. */
 	if (net != &init_net) {
 		WARN(1, KERN_ERR "NFSD: attempt to initialize umh client "
 			"tracking in a container!\n");
 		return -EINVAL;
 	}
-	return nfsd4_umh_cltrack_upcall("init", NULL, NULL);
+
+	ret = nfsd4_umh_cltrack_upcall("init", NULL, grace_start, NULL);
+	kfree(grace_start);
+	return ret;
 }
 
 static void
 nfsd4_umh_cltrack_create(struct nfs4_client *clp)
 {
-	char *hexid;
+	char *hexid, *minorvers, *grace_start;
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 
 	hexid = bin_to_hex_dup(clp->cl_name.data, clp->cl_name.len);
 	if (!hexid) {
 		dprintk("%s: can't allocate memory for upcall!\n", __func__);
 		return;
 	}
-	nfsd4_umh_cltrack_upcall("create", hexid, NULL);
+	minorvers = nfsd4_cltrack_client_minorversion(clp);
+	grace_start = nfsd4_cltrack_grace_start(nn->boot_time);
+	nfsd4_umh_cltrack_upcall("create", hexid, minorvers, grace_start);
+	kfree(minorvers);
+	kfree(grace_start);
 	kfree(hexid);
 }
 
@@ -1222,7 +1288,7 @@ nfsd4_umh_cltrack_remove(struct nfs4_client *clp)
 		dprintk("%s: can't allocate memory for upcall!\n", __func__);
 		return;
 	}
-	nfsd4_umh_cltrack_upcall("remove", hexid, NULL);
+	nfsd4_umh_cltrack_upcall("remove", hexid, NULL, NULL);
 	kfree(hexid);
 }
 
@@ -1238,7 +1304,7 @@ nfsd4_umh_cltrack_check(struct nfs4_client *clp)
 		return -ENOMEM;
 	}
 	legacy = nfsd4_cltrack_legacy_recdir(&clp->cl_name);
-	ret = nfsd4_umh_cltrack_upcall("check", hexid, legacy);
+	ret = nfsd4_umh_cltrack_upcall("check", hexid, legacy, NULL);
 	kfree(legacy);
 	kfree(hexid);
 	return ret;
@@ -1252,7 +1318,7 @@ nfsd4_umh_cltrack_grace_done(struct nfsd_net *nn)
 
 	sprintf(timestr, "%ld", nn->boot_time);
 	legacy = nfsd4_cltrack_legacy_topdir();
-	nfsd4_umh_cltrack_upcall("gracedone", timestr, legacy);
+	nfsd4_umh_cltrack_upcall("gracedone", timestr, legacy, NULL);
 	kfree(legacy);
 }
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6479c45a17c9..2506a0609b99 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -6358,10 +6358,10 @@ nfs4_state_start_net(struct net *net)
 	ret = nfs4_state_create_net(net);
 	if (ret)
 		return ret;
-	nfsd4_client_tracking_init(net);
 	nn->boot_time = get_seconds();
-	locks_start_grace(net, &nn->nfsd4_manager);
 	nn->grace_ended = false;
+	locks_start_grace(net, &nn->nfsd4_manager);
+	nfsd4_client_tracking_init(net);
 	printk(KERN_INFO "NFSD: starting %ld-second grace period (net %p)\n",
 	       nn->nfsd4_grace, net);
 	queue_delayed_work(laundry_wq, &nn->laundromat_work, nn->nfsd4_grace * HZ);
-- 
1.9.3

