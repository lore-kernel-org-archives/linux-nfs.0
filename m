Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:59533 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755443Ab2KVSmy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Nov 2012 13:42:54 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 20/20] NFSv4.1: CB_RECALL_SLOT must schedule a sequence op after updating targets
Date: Wed, 21 Nov 2012 17:43:19 -0500
Message-Id: <1353537799-60488-21-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1353537799-60488-20-git-send-email-Trond.Myklebust@netapp.com>
References: <1353537799-60488-1-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-2-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-3-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-4-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-5-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-6-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-7-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-8-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-9-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-10-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-11-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-12-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-13-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-14-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-15-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-16-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-17-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-18-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-19-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-20-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

RFC5661 requires us to make sure that the server knows we've updated
our slot table size by sending at least one SEQUENCE op containing the
new 'highest_slotid' value.
We can do so using the 'CHECK_LEASE' functionality of the state
manager.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/callback_proc.c | 1 +
 fs/nfs/nfs4_fs.h       | 1 +
 fs/nfs/nfs4state.c     | 7 +++++++
 3 files changed, 9 insertions(+)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 8610bd1..f99faad 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -570,6 +570,7 @@ __be32 nfs4_callback_recallslot(struct cb_recallslotargs *args, void *dummy,
 	status = htonl(NFS4_OK);
 
 	nfs41_set_target_slotid(fc_tbl, args->crsa_target_highest_slotid);
+	nfs41_server_notify_target_slotid_update(cps->clp);
 out:
 	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
 	return status;
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index fa1a055..0a109ec 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -334,6 +334,7 @@ struct rpc_cred *nfs4_get_exchange_id_cred(struct nfs_client *clp);
 int nfs41_discover_server_trunking(struct nfs_client *clp,
 			struct nfs_client **, struct rpc_cred *);
 extern void nfs4_schedule_session_recovery(struct nfs4_session *, int);
+extern void nfs41_server_notify_target_slotid_update(struct nfs_client *clp);
 #else
 static inline void nfs4_schedule_session_recovery(struct nfs4_session *session, int err)
 {
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 3940cd4..55a3e8c 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1904,6 +1904,13 @@ void nfs4_schedule_session_recovery(struct nfs4_session *session, int err)
 }
 EXPORT_SYMBOL_GPL(nfs4_schedule_session_recovery);
 
+void nfs41_server_notify_target_slotid_update(struct nfs_client *clp)
+{
+	/* Use CHECK_LEASE to ping the server with a SEQUENCE */
+	set_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state);
+	nfs4_schedule_state_manager(clp);
+}
+
 static void nfs4_reset_all_state(struct nfs_client *clp)
 {
 	if (test_and_set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state) == 0) {
-- 
1.7.11.7

