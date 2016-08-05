Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:33122 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750954AbcHGBN5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 6 Aug 2016 21:13:57 -0400
Received: by mail-io0-f195.google.com with SMTP id y195so26647041iod.0
        for <linux-nfs@vger.kernel.org>; Sat, 06 Aug 2016 18:13:57 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/3] NFSv4: Cleanup the setting of the nfs4 lease period
Date: Fri,  5 Aug 2016 19:37:34 -0400
Message-Id: <1470440255-8612-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1470440255-8612-2-git-send-email-trond.myklebust@primarydata.com>
References: <1470440255-8612-1-git-send-email-trond.myklebust@primarydata.com>
 <1470440255-8612-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make a helper function nfs4_set_lease_period() and have
nfs41_setup_state_renewal() and nfs4_do_fsinfo() use it.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4_fs.h    |  4 ++++
 fs/nfs/nfs4proc.c   |  9 +++------
 fs/nfs/nfs4renewd.c | 17 +++++++++++++++++
 fs/nfs/nfs4state.c  |  9 +++------
 4 files changed, 27 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 4be567a54958..74a0e34e5ded 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -395,6 +395,10 @@ extern void nfs4_schedule_state_renewal(struct nfs_client *);
 extern void nfs4_renewd_prepare_shutdown(struct nfs_server *);
 extern void nfs4_kill_renewd(struct nfs_client *);
 extern void nfs4_renew_state(struct work_struct *);
+extern void nfs4_set_lease_period(struct nfs_client *clp,
+		unsigned long lease,
+		unsigned long lastrenewed);
+
 
 /* nfs4state.c */
 struct rpc_cred *nfs4_get_clid_cred(struct nfs_client *clp);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index da5c9e58e907..b9e18679af50 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4237,12 +4237,9 @@ static int nfs4_do_fsinfo(struct nfs_server *server, struct nfs_fh *fhandle, str
 		err = _nfs4_do_fsinfo(server, fhandle, fsinfo);
 		trace_nfs4_fsinfo(server, fhandle, fsinfo->fattr, err);
 		if (err == 0) {
-			struct nfs_client *clp = server->nfs_client;
-
-			spin_lock(&clp->cl_lock);
-			clp->cl_lease_time = fsinfo->lease_time * HZ;
-			clp->cl_last_renewal = now;
-			spin_unlock(&clp->cl_lock);
+			nfs4_set_lease_period(server->nfs_client,
+					fsinfo->lease_time * HZ,
+					now);
 			break;
 		}
 		err = nfs4_handle_exception(server, err, &exception);
diff --git a/fs/nfs/nfs4renewd.c b/fs/nfs/nfs4renewd.c
index e1ba58c3d1ad..062029ab344a 100644
--- a/fs/nfs/nfs4renewd.c
+++ b/fs/nfs/nfs4renewd.c
@@ -136,6 +136,23 @@ nfs4_kill_renewd(struct nfs_client *clp)
 	cancel_delayed_work_sync(&clp->cl_renewd);
 }
 
+/**
+ * nfs4_set_lease_period - Sets the lease period on a nfs_client
+ *
+ * @clp: pointer to nfs_client
+ * @lease: new value for lease period
+ * @lastrenewed: time at which lease was last renewed
+ */
+void nfs4_set_lease_period(struct nfs_client *clp,
+		unsigned long lease,
+		unsigned long lastrenewed)
+{
+	spin_lock(&clp->cl_lock);
+	clp->cl_lease_time = lease;
+	clp->cl_last_renewal = lastrenewed;
+	spin_unlock(&clp->cl_lock);
+}
+
 /*
  * Local variables:
  *   c-basic-offset: 8
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 834b875900d6..cada00aa5096 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -277,20 +277,17 @@ static int nfs41_setup_state_renewal(struct nfs_client *clp)
 {
 	int status;
 	struct nfs_fsinfo fsinfo;
+	unsigned long now;
 
 	if (!test_bit(NFS_CS_CHECK_LEASE_TIME, &clp->cl_res_state)) {
 		nfs4_schedule_state_renewal(clp);
 		return 0;
 	}
 
+	now = jiffies;
 	status = nfs4_proc_get_lease_time(clp, &fsinfo);
 	if (status == 0) {
-		/* Update lease time and schedule renewal */
-		spin_lock(&clp->cl_lock);
-		clp->cl_lease_time = fsinfo.lease_time * HZ;
-		clp->cl_last_renewal = jiffies;
-		spin_unlock(&clp->cl_lock);
-
+		nfs4_set_lease_period(clp, fsinfo.lease_time * HZ, now);
 		nfs4_schedule_state_renewal(clp);
 	}
 
-- 
2.7.4

