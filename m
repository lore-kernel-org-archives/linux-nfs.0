Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:58766 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753110Ab3HVAYe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Aug 2013 20:24:34 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH v4 21/21] NFSv4.1: Add tracepoints for debugging test_stateid events
Date: Wed, 21 Aug 2013 20:24:19 -0400
Message-ID: <1377131059-40121-22-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1377131059-40121-21-git-send-email-Trond.Myklebust@netapp.com>
References: <1377131059-40121-1-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-2-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-3-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-4-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-5-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-6-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-7-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-8-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-9-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-10-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-11-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-12-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-13-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-14-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-15-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-16-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-17-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-18-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-19-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-20-git-send-email-Trond.Myklebust@netapp.com>
 <1377131059-40121-21-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add tracepoints to detect issues with the TEST_STATEID operation.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c  |  3 +++
 fs/nfs/nfs4trace.h | 49 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 52 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 44ba5eb..ee3bc24 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1946,6 +1946,7 @@ static void nfs41_clear_delegation_stateid(struct nfs4_state *state)
 		cred = get_rpccred(delegation->cred);
 		rcu_read_unlock();
 		status = nfs41_test_stateid(server, stateid, cred);
+		trace_nfs4_test_delegation_stateid(state, NULL, status);
 	} else
 		rcu_read_unlock();
 
@@ -1988,6 +1989,7 @@ static int nfs41_check_open_stateid(struct nfs4_state *state)
 		return -NFS4ERR_BAD_STATEID;
 
 	status = nfs41_test_stateid(server, stateid, cred);
+	trace_nfs4_test_open_stateid(state, NULL, status);
 	if (status != NFS_OK) {
 		/* Free the stateid unless the server explicitly
 		 * informs us the stateid is unrecognized. */
@@ -5468,6 +5470,7 @@ static int nfs41_check_expired_locks(struct nfs4_state *state)
 			status = nfs41_test_stateid(server,
 					&lsp->ls_stateid,
 					cred);
+			trace_nfs4_test_lock_stateid(state, lsp, status);
 			if (status != NFS_OK) {
 				/* Free the stateid unless the server
 				 * informs us the stateid is unrecognized. */
diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
index 05b96a6..849cf14 100644
--- a/fs/nfs/nfs4trace.h
+++ b/fs/nfs/nfs4trace.h
@@ -638,6 +638,55 @@ TRACE_EVENT(nfs4_delegreturn_exit,
 		)
 );
 
+#ifdef CONFIG_NFS_V4_1
+DECLARE_EVENT_CLASS(nfs4_test_stateid_event,
+		TP_PROTO(
+			const struct nfs4_state *state,
+			const struct nfs4_lock_state *lsp,
+			int error
+		),
+
+		TP_ARGS(state, lsp, error),
+
+		TP_STRUCT__entry(
+			__field(int, error)
+			__field(dev_t, dev)
+			__field(u32, fhandle)
+			__field(u64, fileid)
+		),
+
+		TP_fast_assign(
+			const struct inode *inode = state->inode;
+
+			__entry->error = error;
+			__entry->dev = inode->i_sb->s_dev;
+			__entry->fileid = NFS_FILEID(inode);
+			__entry->fhandle = nfs_fhandle_hash(NFS_FH(inode));
+		),
+
+		TP_printk(
+			"error=%d (%s) fileid=%02x:%02x:%llu fhandle=0x%08x",
+			__entry->error,
+			show_nfsv4_errors(__entry->error),
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			(unsigned long long)__entry->fileid,
+			__entry->fhandle
+		)
+);
+
+#define DEFINE_NFS4_TEST_STATEID_EVENT(name) \
+	DEFINE_EVENT(nfs4_test_stateid_event, name, \
+			TP_PROTO( \
+				const struct nfs4_state *state, \
+				const struct nfs4_lock_state *lsp, \
+				int error \
+			), \
+			TP_ARGS(state, lsp, error))
+DEFINE_NFS4_TEST_STATEID_EVENT(nfs4_test_delegation_stateid);
+DEFINE_NFS4_TEST_STATEID_EVENT(nfs4_test_open_stateid);
+DEFINE_NFS4_TEST_STATEID_EVENT(nfs4_test_lock_stateid);
+#endif /* CONFIG_NFS_V4_1 */
+
 DECLARE_EVENT_CLASS(nfs4_lookup_event,
 		TP_PROTO(
 			const struct inode *dir,
-- 
1.8.3.1

