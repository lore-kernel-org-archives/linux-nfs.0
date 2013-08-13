Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:10013 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759174Ab3HMUhs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Aug 2013 16:37:48 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: <Trond.Myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 3/7] nfs4.1: Add SP4_MACH_CRED cleanup support
Date: Tue, 13 Aug 2013 16:37:34 -0400
Message-ID: <1376426258-28244-4-git-send-email-dros@netapp.com>
In-Reply-To: <1376426258-28244-1-git-send-email-dros@netapp.com>
References: <1376426258-28244-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

CLOSE and LOCKU can use the machine credential.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/nfs4proc.c         | 19 ++++++++++++++++++-
 include/linux/nfs_fs_sb.h |  1 +
 2 files changed, 19 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7acf20e..76cfd0b 100644
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
@@ -5091,6 +5094,9 @@ static struct rpc_task *nfs4_do_unlck(struct file_lock *fl,
 		.flags = RPC_TASK_ASYNC,
 	};
 
+	nfs4_state_protect(NFS_SERVER(lsp->ls_state->inode)->nfs_client,
+		NFS_SP4_MACH_CRED_CLEANUP, &task_setup_data.rpc_client, &msg);
+
 	/* Ensure this is an unlock - when canceling a lock, the
 	 * canceled lock is passed in, and it won't be an unlock.
 	 */
@@ -5918,7 +5924,8 @@ out:
 }
 
 /*
- * Minimum set of SP4_MACH_CRED operations from RFC 5661
+ * Minimum set of SP4_MACH_CRED operations from RFC 5661 in the enforce map
+ * and operations we'd like to see to enable certain features in the allow map
  */
 static const struct nfs41_state_protection nfs4_sp4_mach_cred_request = {
 	.how = SP4_MACH_CRED,
@@ -5928,6 +5935,10 @@ static const struct nfs41_state_protection nfs4_sp4_mach_cred_request = {
 		      1 << (OP_CREATE_SESSION - 32) |
 		      1 << (OP_DESTROY_SESSION - 32) |
 		      1 << (OP_DESTROY_CLIENTID - 32)
+	},
+	.allow.u.words = {
+		[0] = 1 << (OP_CLOSE) |
+		      1 << (OP_LOCKU)
 	}
 };
 
@@ -5987,6 +5998,12 @@ static int nfs4_sp4_select_mode(struct nfs_client *clp,
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

