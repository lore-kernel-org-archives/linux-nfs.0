Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:62958 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754934Ab3HFVIm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Aug 2013 17:08:42 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: <Trond.Myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 3/5] nfs4.1: Add SP4_MACH_CRED cleanup support
Date: Tue, 6 Aug 2013 17:08:29 -0400
Message-ID: <1375823311-18457-4-git-send-email-dros@netapp.com>
In-Reply-To: <1375823311-18457-1-git-send-email-dros@netapp.com>
References: <1375823311-18457-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

CLOSE and LOCKU use the machine cred

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/nfs4proc.c         | 28 +++++++++++++++++++++++++++-
 include/linux/nfs_fs_sb.h |  1 +
 2 files changed, 28 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index faa3731..63b6e17 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2511,6 +2511,9 @@ int nfs4_do_close(struct nfs4_state *state, gfp_t gfp_mask, int wait)
 	};
 	int status = -ENOMEM;
 
+	nfs4_state_protect(server->nfs_client, NFS_SP4_MACH_CRED_CLEANUP,
+		&task_setup_data.rpc_client, &msg);
+
 	calldata = kzalloc(sizeof(*calldata), gfp_mask);
 	if (calldata == NULL)
 		goto out;
@@ -5093,6 +5096,9 @@ static struct rpc_task *nfs4_do_unlck(struct file_lock *fl,
 		.flags = RPC_TASK_ASYNC,
 	};
 
+	nfs4_state_protect(NFS_SERVER(lsp->ls_state->inode)->nfs_client,
+		NFS_SP4_MACH_CRED_CLEANUP, &task_setup_data.rpc_client, &msg);
+
 	/* Ensure this is an unlock - when canceling a lock, the
 	 * canceled lock is passed in, and it won't be an unlock.
 	 */
@@ -5926,6 +5932,15 @@ static const uint32_t _nfs4_spo_must_enforce[NFS4_OP_MAP_NUM_WORDS] = {
 };
 
 /*
+ * Operations we'd like to see to enable certain features
+ */
+static const uint32_t _nfs4_spo_must_allow[NFS4_OP_MAP_NUM_WORDS] = {
+	[0] = 1 << (OP_CLOSE) |
+	      1 << (OP_LOCKU)
+};
+
+
+/*
  * Select the state protection mode for client `clp' given the server results
  * from exchange_id in `sp'.
  *
@@ -5965,6 +5980,12 @@ static int _nfs4_sp4_select_mode(struct nfs_client *clp,
 			dfprintk(MOUNT, "sp4_mach_cred: disabled\n");
 			return -EINVAL;
 		}
+
+		if (test_bit(OP_CLOSE, sp->allow.u.longs) &&
+		    test_bit(OP_LOCKU, sp->allow.u.longs)) {
+			dfprintk(MOUNT, "  cleanup mode enabled\n");
+			set_bit(NFS_SP4_MACH_CRED_CLEANUP, &clp->cl_sp4_flags);
+		}
 	}
 
 	return 0;
@@ -6031,11 +6052,16 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
 	case SP4_MACH_CRED:
 		args.state_protect.how = SP4_MACH_CRED;
 
-		/* request minumum set of operations */
+		/* request enforcement of minumum set of operations */
 		memcpy(args.state_protect.enforce.u.words,
 		       &_nfs4_spo_must_enforce,
 		       sizeof(uint32_t) * NFS4_OP_MAP_NUM_WORDS);
 
+		/* ask for any other ops we may need for SP4 features */
+		memcpy(args.state_protect.allow.u.words,
+		       &_nfs4_spo_must_allow,
+		       sizeof(uint32_t) * NFS4_OP_MAP_NUM_WORDS);
+
 		break;
 
 	default:
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index a0af429..7da24e0 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -91,6 +91,7 @@ struct nfs_client {
 	unsigned long		cl_sp4_flags;
 #define NFS_SP4_MACH_CRED_MINIMAL  1	/* Minimal sp4_mach_cred - state ops
 					 * must use machine cred */
+#define NFS_SP4_MACH_CRED_CLEANUP  2	/* CLOSE and LOCKU */
 #endif /* CONFIG_NFS_V4 */
 
 #ifdef CONFIG_NFS_FSCACHE
-- 
1.7.12.4 (Apple Git-37)

