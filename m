Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:46996 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S932290AbbLBOkE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Dec 2015 09:40:04 -0500
From: Andrew Elble <aweits@rit.edu>
To: linux-nfs@vger.kernel.org
Cc: Andrew Elble <aweits@rit.edu>
Subject: [PATCH RFC 2/4] nfs: machine credential support for additional operations
Date: Wed,  2 Dec 2015 09:39:51 -0500
Message-Id: <1449067193-53310-3-git-send-email-aweits@rit.edu>
In-Reply-To: <1449067193-53310-1-git-send-email-aweits@rit.edu>
References: <1449067193-53310-1-git-send-email-aweits@rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow LAYOUTRETURN and DELEGRETURN to use machine credentials if the
server supports it. Add request for OPEN_DOWNGRADE as the close path
also uses that.

Signed-off-by: Andrew Elble <aweits@rit.edu>
---
 fs/nfs/nfs4proc.c         | 20 ++++++++++++++++++++
 include/linux/nfs_fs_sb.h |  1 +
 2 files changed, 21 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 765a03559363..f7f45792676d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5384,6 +5384,11 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
 	if (data == NULL)
 		return -ENOMEM;
 	nfs4_init_sequence(&data->args.seq_args, &data->res.seq_res, 1);
+
+	nfs4_state_protect(server->nfs_client,
+			NFS_SP4_MACH_CRED_CLEANUP,
+			&task_setup_data.rpc_client, &msg);
+
 	data->args.fhandle = &data->fh;
 	data->args.stateid = &data->stateid;
 	data->args.bitmask = server->cache_consistency_bitmask;
@@ -6862,10 +6867,13 @@ static const struct nfs41_state_protection nfs4_sp4_mach_cred_request = {
 	},
 	.allow.u.words = {
 		[0] = 1 << (OP_CLOSE) |
+		      1 << (OP_OPEN_DOWNGRADE) |
 		      1 << (OP_LOCKU) |
+		      1 << (OP_DELEGRETURN) |
 		      1 << (OP_COMMIT),
 		[1] = 1 << (OP_SECINFO - 32) |
 		      1 << (OP_SECINFO_NO_NAME - 32) |
+		      1 << (OP_LAYOUTRETURN - 32) |
 		      1 << (OP_TEST_STATEID - 32) |
 		      1 << (OP_FREE_STATEID - 32) |
 		      1 << (OP_WRITE - 32)
@@ -6930,11 +6938,19 @@ static int nfs4_sp4_select_mode(struct nfs_client *clp,
 		}
 
 		if (test_bit(OP_CLOSE, sp->allow.u.longs) &&
+		    test_bit(OP_OPEN_DOWNGRADE, sp->allow.u.longs) &&
+		    test_bit(OP_DELEGRETURN, sp->allow.u.longs) &&
 		    test_bit(OP_LOCKU, sp->allow.u.longs)) {
 			dfprintk(MOUNT, "  cleanup mode enabled\n");
 			set_bit(NFS_SP4_MACH_CRED_CLEANUP, &clp->cl_sp4_flags);
 		}
 
+		if (test_bit(OP_LAYOUTRETURN, sp->allow.u.longs)) {
+			dfprintk(MOUNT, "  pnfs cleanup mode enabled\n");
+			set_bit(NFS_SP4_MACH_CRED_PNFS_CLEANUP,
+				&clp->cl_sp4_flags);
+		}
+
 		if (test_bit(OP_SECINFO, sp->allow.u.longs) &&
 		    test_bit(OP_SECINFO_NO_NAME, sp->allow.u.longs)) {
 			dfprintk(MOUNT, "  secinfo mode enabled\n");
@@ -8086,6 +8102,10 @@ int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp, bool sync)
 	};
 	int status = 0;
 
+	nfs4_state_protect(NFS_SERVER(lrp->args.inode)->nfs_client,
+			NFS_SP4_MACH_CRED_PNFS_CLEANUP,
+			&task_setup_data.rpc_client, &msg);
+
 	dprintk("--> %s\n", __func__);
 	if (!sync) {
 		lrp->inode = nfs_igrab_and_active(lrp->args.inode);
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 2469ab0bb3a1..7fcc13c8cf1f 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -102,6 +102,7 @@ struct nfs_client {
 #define NFS_SP4_MACH_CRED_STATEID  4	/* TEST_STATEID and FREE_STATEID */
 #define NFS_SP4_MACH_CRED_WRITE    5	/* WRITE */
 #define NFS_SP4_MACH_CRED_COMMIT   6	/* COMMIT */
+#define NFS_SP4_MACH_CRED_PNFS_CLEANUP  7 /* LAYOUTRETURN */
 #endif /* CONFIG_NFS_V4 */
 
 	/* Our own IP address, as a null-terminated string.
-- 
2.6.3

