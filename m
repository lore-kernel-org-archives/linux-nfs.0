Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:19603 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753186AbbKXS3r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Nov 2015 13:29:47 -0500
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH Version 2 2/2] Adding tracepoint to cached open
Date: Tue, 24 Nov 2015 13:29:42 -0500
Message-ID: <1448389782-99578-3-git-send-email-kolga@netapp.com>
In-Reply-To: <1448389782-99578-1-git-send-email-kolga@netapp.com>
References: <1448389782-99578-1-git-send-email-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs4proc.c  |  2 ++
 fs/nfs/nfs4trace.h | 39 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 41 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5c891c3..877b46d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1598,6 +1598,7 @@ _nfs4_opendata_to_nfs4_state(struct nfs4_opendata *data)
 
 	if (!data->rpc_done) {
 		state = nfs4_try_open_cached(data);
+		trace_nfs4_cached_open(data->state);
 		goto out;
 	}
 
@@ -2015,6 +2016,7 @@ static void nfs4_open_prepare(struct rpc_task *task, void *calldata)
 	}
 	return;
 unlock_no_action:
+	trace_nfs4_cached_open(data->state);
 	rcu_read_unlock();
 out_no_action:
 	task->tk_action = NULL;
diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
index 9058aec..8704372 100644
--- a/fs/nfs/nfs4trace.h
+++ b/fs/nfs/nfs4trace.h
@@ -473,6 +473,45 @@ DEFINE_NFS4_OPEN_EVENT(nfs4_open_reclaim);
 DEFINE_NFS4_OPEN_EVENT(nfs4_open_expired);
 DEFINE_NFS4_OPEN_EVENT(nfs4_open_file);
 
+TRACE_EVENT(nfs4_cached_open,
+		TP_PROTO(
+			const struct nfs4_state *state
+		),
+		TP_ARGS(state),
+		TP_STRUCT__entry(
+			__field(dev_t, dev)
+			__field(u32, fhandle)
+			__field(u64, fileid)
+			__field(unsigned int, fmode)
+			__field(int, stateid_seq)
+			__field(u32, stateid_hash)
+		),
+
+		TP_fast_assign(
+			const struct inode *inode = state->inode;
+
+			__entry->dev = inode->i_sb->s_dev;
+			__entry->fileid = NFS_FILEID(inode);
+			__entry->fhandle = nfs_fhandle_hash(NFS_FH(inode));
+			__entry->fmode = (__force unsigned int)state->state;
+			__entry->stateid_seq =
+				be32_to_cpu(state->stateid.seqid);
+			__entry->stateid_hash =
+				nfs_stateid_hash(&state->stateid);
+		),
+
+		TP_printk(
+			"fmode=%s fileid=%02x:%02x:%llu "
+			"fhandle=0x%08x stateid=%d:0x%08x",
+			__entry->fmode ?  show_fmode_flags(__entry->fmode) :
+					  "closed",
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			(unsigned long long)__entry->fileid,
+			__entry->fhandle,
+			__entry->stateid_seq, __entry->stateid_hash
+		)
+);
+
 TRACE_EVENT(nfs4_close,
 		TP_PROTO(
 			const struct nfs4_state *state,
-- 
1.8.3.1

