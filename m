Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:2204 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759174Ab3HMUht (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Aug 2013 16:37:49 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: <Trond.Myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 4/7] nfs4.1: Add SP4_MACH_CRED secinfo support
Date: Tue, 13 Aug 2013 16:37:35 -0400
Message-ID: <1376426258-28244-5-git-send-email-dros@netapp.com>
In-Reply-To: <1376426258-28244-1-git-send-email-dros@netapp.com>
References: <1376426258-28244-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

SECINFO and SECINFO_NONAME can use the machine credential.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/nfs4proc.c         | 15 ++++++++++++++-
 include/linux/nfs_fs_sb.h |  1 +
 2 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 76cfd0b..b86a7b2 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5820,7 +5820,12 @@ static int _nfs4_proc_secinfo(struct inode *dir, const struct qstr *name, struct
 	struct rpc_clnt *clnt = NFS_SERVER(dir)->nfs_client->cl_rpcclient;
 
 	dprintk("NFS call  secinfo %s\n", name->name);
+
+	nfs4_state_protect(NFS_SERVER(dir)->nfs_client,
+		NFS_SP4_MACH_CRED_SECINFO, &clnt, &msg);
+
 	status = nfs4_call_sync(clnt, NFS_SERVER(dir), &msg, &args.seq_args, &res.seq_res, 0);
+
 	dprintk("NFS reply  secinfo: %d\n", status);
 	return status;
 }
@@ -5938,7 +5943,9 @@ static const struct nfs41_state_protection nfs4_sp4_mach_cred_request = {
 	},
 	.allow.u.words = {
 		[0] = 1 << (OP_CLOSE) |
-		      1 << (OP_LOCKU)
+		      1 << (OP_LOCKU),
+		[1] = 1 << (OP_SECINFO - 32) |
+		      1 << (OP_SECINFO_NO_NAME - 32)
 	}
 };
 
@@ -6004,6 +6011,12 @@ static int nfs4_sp4_select_mode(struct nfs_client *clp,
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
index 7da24e0..0d86cec 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -92,6 +92,7 @@ struct nfs_client {
 #define NFS_SP4_MACH_CRED_MINIMAL  1	/* Minimal sp4_mach_cred - state ops
 					 * must use machine cred */
 #define NFS_SP4_MACH_CRED_CLEANUP  2	/* CLOSE and LOCKU */
+#define NFS_SP4_MACH_CRED_SECINFO  3	/* SECINFO and SECINFO_NO_NAME */
 #endif /* CONFIG_NFS_V4 */
 
 #ifdef CONFIG_NFS_FSCACHE
-- 
1.7.12.4 (Apple Git-37)

