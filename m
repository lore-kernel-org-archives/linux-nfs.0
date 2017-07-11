Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:58566 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934061AbdGKQoz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 11 Jul 2017 12:44:55 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>,
        <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC v3 37/42] NFSD stop queued async copies on client shutdown
Date: Tue, 11 Jul 2017 12:44:11 -0400
Message-ID: <20170711164416.1982-38-kolga@netapp.com>
In-Reply-To: <20170711164416.1982-1-kolga@netapp.com>
References: <20170711164416.1982-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If client is shutting down and there are still async copies going
on, then stop queued async copies.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfsd/nfs4proc.c  | 21 ++++++++++++++++-----
 fs/nfsd/nfs4state.c |  1 +
 fs/nfsd/state.h     |  2 ++
 3 files changed, 19 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 7e7b416..b93713d 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -92,6 +92,12 @@ void nfsd4_destroy_copy_queue(void)
 	destroy_workqueue(copy_wq);
 }
 
+void nfsd4_shutdown_copy(struct nfs4_client *clp)
+{
+	set_bit(NFSD4_CLIENT_COPY_KILL, &clp->cl_flags);
+	flush_workqueue(copy_wq);
+}
+
 #define NFSDDBG_FACILITY		NFSDDBG_PROC
 
 static u32 nfsd_attrmask[] = {
@@ -1416,15 +1422,16 @@ static void nfsd4_do_async_copy(struct work_struct *work)
 {
 	struct nfsd4_copy *copy =
 		container_of(work, struct nfsd4_copy, cp_work);
-	struct nfsd4_copy *cb_copy;
+	struct nfsd4_copy *cb_copy = NULL;
+
+	if (test_bit(NFSD4_CLIENT_COPY_KILL, &copy->cp_clp->cl_flags))
+		goto out_err;
 
 	if (copy->cp_src.nl_nsvr > 0) { /* Inter server SSC */
 		copy->fh_src = nfs42_ssc_open(copy->ss_mnt, &copy->c_fh,
 						&copy->stateid);
-		if (IS_ERR(copy->fh_src)) {
-			nfsd4_interssc_disconnect(copy->ss_mnt);
-			return;
-		}
+		if (IS_ERR(copy->fh_src))
+			goto out_err;
 	}
 	copy->nfserr = nfsd4_do_copy(copy, 0);
 	cb_copy = kzalloc(sizeof(struct nfsd4_copy), GFP_KERNEL);
@@ -1439,6 +1446,10 @@ static void nfsd4_do_async_copy(struct work_struct *work)
 	nfsd4_run_cb(&cb_copy->cp_cb);
 out:
 	kfree(copy);
+	return;
+out_err:
+	nfsd4_interssc_disconnect(copy->ss_mnt);
+	goto out;
 }
 
 static __be32
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index bcd87c9..7727ce53 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1995,6 +1995,7 @@ static __be32 mark_client_expired_locked(struct nfs4_client *clp)
 	}
 	nfsd4_return_all_client_layouts(clp);
 	nfsd4_shutdown_callback(clp);
+	nfsd4_shutdown_copy(clp);
 	if (clp->cl_cb_conn.cb_xprt)
 		svc_xprt_put(clp->cl_cb_conn.cb_xprt);
 	free_client(clp);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index ebf968d..fa749763 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -336,6 +336,7 @@ struct nfs4_client {
 #define NFSD4_CLIENT_RECLAIM_COMPLETE	(3)	/* reclaim_complete done */
 #define NFSD4_CLIENT_CONFIRMED		(4)	/* client is confirmed */
 #define NFSD4_CLIENT_UPCALL_LOCK	(5)	/* upcall serialization */
+#define NFSD4_CLIENT_COPY_KILL		(6)	/* stop copy workqueue */
 #define NFSD4_CLIENT_CB_FLAG_MASK	(1 << NFSD4_CLIENT_CB_UPDATE | \
 					 1 << NFSD4_CLIENT_CB_KILL)
 	unsigned long		cl_flags;
@@ -645,6 +646,7 @@ extern void nfsd4_init_cb(struct nfsd4_callback *cb, struct nfs4_client *clp,
 extern int nfsd4_create_callback_queue(void);
 extern void nfsd4_destroy_callback_queue(void);
 extern void nfsd4_shutdown_callback(struct nfs4_client *);
+extern void nfsd4_shutdown_copy(struct nfs4_client *clp);
 extern void nfsd4_prepare_cb_recall(struct nfs4_delegation *dp);
 extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
 							struct nfsd_net *nn);
-- 
1.8.3.1

