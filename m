Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:21769 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755330Ab3HFVJe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Aug 2013 17:09:34 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: <Trond.Myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 5/5] nfs4.1: Add SP4_MACH_CRED stateid support
Date: Tue, 6 Aug 2013 17:08:31 -0400
Message-ID: <1375823311-18457-6-git-send-email-dros@netapp.com>
In-Reply-To: <1375823311-18457-1-git-send-email-dros@netapp.com>
References: <1375823311-18457-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

TEST_STATEID and FREE_STATEID use the machine cred

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/nfs4proc.c         | 19 +++++++++++++++++--
 include/linux/nfs_fs_sb.h |  1 +
 2 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d4aa158..7dee833 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5943,7 +5943,9 @@ static const uint32_t _nfs4_spo_must_allow[NFS4_OP_MAP_NUM_WORDS] = {
 	[0] = 1 << (OP_CLOSE) |
 	      1 << (OP_LOCKU),
 	[1] = 1 << (OP_SECINFO - 32) |
-	      1 << (OP_SECINFO_NO_NAME - 32)
+	      1 << (OP_SECINFO_NO_NAME - 32) |
+	      1 << (OP_TEST_STATEID - 32) |
+	      1 << (OP_FREE_STATEID - 32)
 };
 
 
@@ -5999,6 +6001,12 @@ static int _nfs4_sp4_select_mode(struct nfs_client *clp,
 			dfprintk(MOUNT, "  secinfo mode enabled\n");
 			set_bit(NFS_SP4_MACH_CRED_SECINFO, &clp->cl_sp4_flags);
 		}
+
+		if (test_bit(OP_TEST_STATEID, sp->allow.u.longs) &&
+		    test_bit(OP_FREE_STATEID, sp->allow.u.longs)) {
+			dfprintk(MOUNT, "  stateid mode enabled\n");
+			set_bit(NFS_SP4_MACH_CRED_STATEID, &clp->cl_sp4_flags);
+		}
 	}
 
 	return 0;
@@ -7325,11 +7333,15 @@ static int _nfs41_test_stateid(struct nfs_server *server,
 		.rpc_resp = &res,
 		.rpc_cred = cred,
 	};
+	struct rpc_clnt *rpc_client = server->client;
+
+	nfs4_state_protect(server->nfs_client, NFS_SP4_MACH_CRED_STATEID,
+		&rpc_client, &msg);
 
 	dprintk("NFS call  test_stateid %p\n", stateid);
 	nfs41_init_sequence(&args.seq_args, &res.seq_res, 0);
 	nfs4_set_sequence_privileged(&args.seq_args);
-	status = nfs4_call_sync_sequence(server->client, server, &msg,
+	status = nfs4_call_sync_sequence(rpc_client, server, &msg,
 			&args.seq_args, &res.seq_res);
 	if (status != NFS_OK) {
 		dprintk("NFS reply test_stateid: failed, %d\n", status);
@@ -7421,6 +7433,9 @@ static struct rpc_task *_nfs41_free_stateid(struct nfs_server *server,
 	};
 	struct nfs_free_stateid_data *data;
 
+	nfs4_state_protect(server->nfs_client, NFS_SP4_MACH_CRED_STATEID,
+		&task_setup.rpc_client, &msg);
+
 	dprintk("NFS call  free_stateid %p\n", stateid);
 	data = kmalloc(sizeof(*data), GFP_NOFS);
 	if (!data)
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 02fa36b..8ef3371 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -93,6 +93,7 @@ struct nfs_client {
 					 * must use machine cred */
 #define NFS_SP4_MACH_CRED_CLEANUP  2	/* CLOSE and LOCKU */
 #define NFS_SP4_MACH_CRED_SECINFO  3	/* SECINFO and SECINFO_NONAME */
+#define NFS_SP4_MACH_CRED_STATEID  4	/* TEST_STATEID and FREE_STATEID */
 #endif /* CONFIG_NFS_V4 */
 
 #ifdef CONFIG_NFS_FSCACHE
-- 
1.7.12.4 (Apple Git-37)

