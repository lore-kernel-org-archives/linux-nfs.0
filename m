Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:54633 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752333AbdJMUyU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 13 Oct 2017 16:54:20 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v5 10/10] NFSD stop queued async copies on client shutdown
Date: Fri, 13 Oct 2017 16:54:12 -0400
Message-ID: <20171013205412.65532-11-kolga@netapp.com>
In-Reply-To: <20171013205412.65532-1-kolga@netapp.com>
References: <20171013205412.65532-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If client is shutting down and there are still async copies going
on, then stop queued async copies.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfsd/nfs4proc.c  | 13 +++++++++++++
 fs/nfsd/nfs4state.c |  1 +
 fs/nfsd/state.h     |  1 +
 3 files changed, 15 insertions(+)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 78e25db..b00701d 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1098,6 +1098,19 @@ static void nfs4_put_copy(struct nfsd4_copy *copy)
 	kfree(copy);
 }
 
+void nfsd4_shutdown_copy(struct nfs4_client *clp)
+{
+	struct nfsd4_copy *copy;
+
+	spin_lock(&clp->async_lock);
+	list_for_each_entry(copy, &clp->async_copies, copies) {
+		set_tsk_thread_flag(copy->copy_task, TIF_SIGPENDING);
+		kthread_stop(copy->copy_task);
+		nfs4_put_copy(copy);
+	}
+	spin_unlock(&clp->async_lock);
+}
+
 static void nfsd4_cb_offload_release(struct nfsd4_callback *cb)
 {
 	struct nfsd4_copy *copy = container_of(cb, struct nfsd4_copy, cp_cb);
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f9151f2..efac39d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1947,6 +1947,7 @@ static __be32 mark_client_expired_locked(struct nfs4_client *clp)
 	}
 	nfsd4_return_all_client_layouts(clp);
 	nfsd4_shutdown_callback(clp);
+	nfsd4_shutdown_copy(clp);
 	if (clp->cl_cb_conn.cb_xprt)
 		svc_xprt_put(clp->cl_cb_conn.cb_xprt);
 	free_client(clp);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index b4de8ae..88869df 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -643,6 +643,7 @@ extern void nfsd4_init_cb(struct nfsd4_callback *cb, struct nfs4_client *clp,
 extern int nfsd4_create_callback_queue(void);
 extern void nfsd4_destroy_callback_queue(void);
 extern void nfsd4_shutdown_callback(struct nfs4_client *);
+extern void nfsd4_shutdown_copy(struct nfs4_client *clp);
 extern void nfsd4_prepare_cb_recall(struct nfs4_delegation *dp);
 extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
 							struct nfsd_net *nn);
-- 
1.8.3.1

