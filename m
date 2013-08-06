Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:62958 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755341Ab3HFVIn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Aug 2013 17:08:43 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: <Trond.Myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 4/5] nfs4.1: Add SP4_MACH_CRED secinfo support
Date: Tue, 6 Aug 2013 17:08:30 -0400
Message-ID: <1375823311-18457-5-git-send-email-dros@netapp.com>
In-Reply-To: <1375823311-18457-1-git-send-email-dros@netapp.com>
References: <1375823311-18457-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

SECINFO and SECINFO_NONAME use the machine cred

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/nfs4proc.c         | 17 +++++++++++++++--
 include/linux/nfs_fs_sb.h |  1 +
 2 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 63b6e17..d4aa158 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5815,9 +5815,14 @@ static int _nfs4_proc_secinfo(struct inode *dir, const struct qstr *name, struct
 		.rpc_argp = &args,
 		.rpc_resp = &res,
 	};
+	struct rpc_clnt *rpc_client = NFS_SERVER(dir)->client;
+
+	nfs4_state_protect(NFS_SERVER(dir)->nfs_client,
+		NFS_SP4_MACH_CRED_SECINFO, &rpc_client, &msg);
 
 	dprintk("NFS call  secinfo %s\n", name->name);
-	status = nfs4_call_sync(NFS_SERVER(dir)->client, NFS_SERVER(dir), &msg, &args.seq_args, &res.seq_res, 0);
+	status = nfs4_call_sync(rpc_client, NFS_SERVER(dir), &msg,
+				&args.seq_args, &res.seq_res, 0);
 	dprintk("NFS reply  secinfo: %d\n", status);
 	return status;
 }
@@ -5936,7 +5941,9 @@ static const uint32_t _nfs4_spo_must_enforce[NFS4_OP_MAP_NUM_WORDS] = {
  */
 static const uint32_t _nfs4_spo_must_allow[NFS4_OP_MAP_NUM_WORDS] = {
 	[0] = 1 << (OP_CLOSE) |
-	      1 << (OP_LOCKU)
+	      1 << (OP_LOCKU),
+	[1] = 1 << (OP_SECINFO - 32) |
+	      1 << (OP_SECINFO_NO_NAME - 32)
 };
 
 
@@ -5986,6 +5993,12 @@ static int _nfs4_sp4_select_mode(struct nfs_client *clp,
 			dfprintk(MOUNT, "  cleanup mode enabled\n");
 			set_bit(NFS_SP4_MACH_CRED_CLEANUP, &clp->cl_sp4_flags);
 		}
+
+		if (test_bit(OP_SECINFO, sp->allow.u.longs) &&
+		    test_bit(OP_SECINFO_NO_NAME, sp->allow.u.longs)) {
+			dfprintk(MOUNT, "  secinfo mode enabled\n");
+			set_bit(NFS_SP4_MACH_CRED_SECINFO, &clp->cl_sp4_flags);
+		}
 	}
 
 	return 0;
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 7da24e0..02fa36b 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -92,6 +92,7 @@ struct nfs_client {
 #define NFS_SP4_MACH_CRED_MINIMAL  1	/* Minimal sp4_mach_cred - state ops
 					 * must use machine cred */
 #define NFS_SP4_MACH_CRED_CLEANUP  2	/* CLOSE and LOCKU */
+#define NFS_SP4_MACH_CRED_SECINFO  3	/* SECINFO and SECINFO_NONAME */
 #endif /* CONFIG_NFS_V4 */
 
 #ifdef CONFIG_NFS_FSCACHE
-- 
1.7.12.4 (Apple Git-37)

