Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:10013 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759185Ab3HMUhv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Aug 2013 16:37:51 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: <Trond.Myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 5/7] nfs4.1: Add SP4_MACH_CRED stateid support
Date: Tue, 13 Aug 2013 16:37:36 -0400
Message-ID: <1376426258-28244-6-git-send-email-dros@netapp.com>
In-Reply-To: <1376426258-28244-1-git-send-email-dros@netapp.com>
References: <1376426258-28244-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

TEST_STATEID and FREE_STATEID can use the machine credential.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/nfs4proc.c         | 19 +++++++++++++++++--
 include/linux/nfs_fs_sb.h |  1 +
 2 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index b86a7b2..b8e668a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5945,7 +5945,9 @@ static const struct nfs41_state_protection nfs4_sp4_mach_cred_request = {
 		[0] = 1 << (OP_CLOSE) |
 		      1 << (OP_LOCKU),
 		[1] = 1 << (OP_SECINFO - 32) |
-		      1 << (OP_SECINFO_NO_NAME - 32)
+		      1 << (OP_SECINFO_NO_NAME - 32) |
+		      1 << (OP_TEST_STATEID - 32) |
+		      1 << (OP_FREE_STATEID - 32)
 	}
 };
 
@@ -6017,6 +6019,12 @@ static int nfs4_sp4_select_mode(struct nfs_client *clp,
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
@@ -7337,11 +7345,15 @@ static int _nfs41_test_stateid(struct nfs_server *server,
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
@@ -7433,6 +7445,9 @@ static struct rpc_task *_nfs41_free_stateid(struct nfs_server *server,
 	};
 	struct nfs_free_stateid_data *data;
 
+	nfs4_state_protect(server->nfs_client, NFS_SP4_MACH_CRED_STATEID,
+		&task_setup.rpc_client, &msg);
+
 	dprintk("NFS call  free_stateid %p\n", stateid);
 	data = kmalloc(sizeof(*data), GFP_NOFS);
 	if (!data)
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 0d86cec..010feab 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -93,6 +93,7 @@ struct nfs_client {
 					 * must use machine cred */
 #define NFS_SP4_MACH_CRED_CLEANUP  2	/* CLOSE and LOCKU */
 #define NFS_SP4_MACH_CRED_SECINFO  3	/* SECINFO and SECINFO_NO_NAME */
+#define NFS_SP4_MACH_CRED_STATEID  4	/* TEST_STATEID and FREE_STATEID */
 #endif /* CONFIG_NFS_V4 */
 
 #ifdef CONFIG_NFS_FSCACHE
-- 
1.7.12.4 (Apple Git-37)

