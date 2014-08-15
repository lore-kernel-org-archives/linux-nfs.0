Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f176.google.com ([209.85.216.176]:58460 "EHLO
	mail-qc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751381AbaHOOow (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Aug 2014 10:44:52 -0400
Received: by mail-qc0-f176.google.com with SMTP id m20so2386111qcx.7
        for <linux-nfs@vger.kernel.org>; Fri, 15 Aug 2014 07:44:51 -0700 (PDT)
Received: from tlielax.poochiereds.net ([2001:470:8:d63:3a60:77ff:fe93:a95d])
        by mx.google.com with ESMTPSA id i2sm9046955qge.27.2014.08.15.07.44.49
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Aug 2014 07:44:50 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [kernel RFC PATCH 3/4] nfsd: remove redundant boot_time parm from grace_done client tracking op
Date: Fri, 15 Aug 2014 10:44:39 -0400
Message-Id: <1408113880-5489-4-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1408113880-5489-1-git-send-email-jlayton@primarydata.com>
References: <1408113880-5489-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since it's stored in nfsd_net, we don't need to pass it in separately.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4recover.c | 17 ++++++++---------
 fs/nfsd/nfs4state.c   |  2 +-
 fs/nfsd/state.h       |  2 +-
 3 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 9c271f42604a..a0d2ba956a3f 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -58,7 +58,7 @@ struct nfsd4_client_tracking_ops {
 	void (*create)(struct nfs4_client *);
 	void (*remove)(struct nfs4_client *);
 	int (*check)(struct nfs4_client *);
-	void (*grace_done)(struct nfsd_net *, time_t);
+	void (*grace_done)(struct nfsd_net *);
 };
 
 /* Globals */
@@ -392,7 +392,7 @@ purge_old(struct dentry *parent, struct dentry *child, struct nfsd_net *nn)
 }
 
 static void
-nfsd4_recdir_purge_old(struct nfsd_net *nn, time_t boot_time)
+nfsd4_recdir_purge_old(struct nfsd_net *nn)
 {
 	int status;
 
@@ -1016,7 +1016,7 @@ nfsd4_cld_check(struct nfs4_client *clp)
 }
 
 static void
-nfsd4_cld_grace_done(struct nfsd_net *nn, time_t boot_time)
+nfsd4_cld_grace_done(struct nfsd_net *nn)
 {
 	int ret;
 	struct cld_upcall *cup;
@@ -1029,7 +1029,7 @@ nfsd4_cld_grace_done(struct nfsd_net *nn, time_t boot_time)
 	}
 
 	cup->cu_msg.cm_cmd = Cld_GraceDone;
-	cup->cu_msg.cm_u.cm_gracetime = (int64_t)boot_time;
+	cup->cu_msg.cm_u.cm_gracetime = (int64_t)nn->boot_time;
 	ret = cld_pipe_upcall(cn->cn_pipe, &cup->cu_msg);
 	if (!ret)
 		ret = cup->cu_msg.cm_status;
@@ -1245,13 +1245,12 @@ nfsd4_umh_cltrack_check(struct nfs4_client *clp)
 }
 
 static void
-nfsd4_umh_cltrack_grace_done(struct nfsd_net __attribute__((unused)) *nn,
-				time_t boot_time)
+nfsd4_umh_cltrack_grace_done(struct nfsd_net *nn)
 {
 	char *legacy;
 	char timestr[22]; /* FIXME: better way to determine max size? */
 
-	sprintf(timestr, "%ld", boot_time);
+	sprintf(timestr, "%ld", nn->boot_time);
 	legacy = nfsd4_cltrack_legacy_topdir();
 	nfsd4_umh_cltrack_upcall("gracedone", timestr, legacy);
 	kfree(legacy);
@@ -1356,10 +1355,10 @@ nfsd4_client_record_check(struct nfs4_client *clp)
 }
 
 void
-nfsd4_record_grace_done(struct nfsd_net *nn, time_t boot_time)
+nfsd4_record_grace_done(struct nfsd_net *nn)
 {
 	if (nn->client_tracking_ops)
-		nn->client_tracking_ops->grace_done(nn, boot_time);
+		nn->client_tracking_ops->grace_done(nn);
 }
 
 static int
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index de6bea769b24..6479c45a17c9 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4132,7 +4132,7 @@ nfsd4_end_grace(struct nfsd_net *nn)
 
 	dprintk("NFSD: end of grace period\n");
 	nn->grace_ended = true;
-	nfsd4_record_grace_done(nn, nn->boot_time);
+	nfsd4_record_grace_done(nn);
 	locks_end_grace(&nn->nfsd4_manager);
 	/*
 	 * Now that every NFSv4 client has had the chance to recover and
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index ecf579904892..854f0c574ccf 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -554,7 +554,7 @@ extern void nfsd4_client_tracking_exit(struct net *net);
 extern void nfsd4_client_record_create(struct nfs4_client *clp);
 extern void nfsd4_client_record_remove(struct nfs4_client *clp);
 extern int nfsd4_client_record_check(struct nfs4_client *clp);
-extern void nfsd4_record_grace_done(struct nfsd_net *nn, time_t boot_time);
+extern void nfsd4_record_grace_done(struct nfsd_net *nn);
 
 /* nfs fault injection functions */
 #ifdef CONFIG_NFSD_FAULT_INJECTION
-- 
1.9.3

