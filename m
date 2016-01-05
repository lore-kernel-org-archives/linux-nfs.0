Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:40506 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751498AbcAES16 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Jan 2016 13:27:58 -0500
From: Andrew Elble <aweits@rit.edu>
To: linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com
Cc: Andrew Elble <aweits@rit.edu>
Subject: [PATCH v2] nfs: machine credential support for additional operations
Date: Tue,  5 Jan 2016 13:27:21 -0500
Message-Id: <1452018441-4648-1-git-send-email-aweits@rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow DELEGRETURN to use machine credentials if the
server supports it. Add request for OPEN_DOWNGRADE as the close path
also uses that.

Signed-off-by: Andrew Elble <aweits@rit.edu>
---
 v2: separated from series / removed LAYOUTRETURN as I can't test it currently

 fs/nfs/nfs4proc.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 89818036f035..d37e11e9b440 100644
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
@@ -6862,7 +6867,9 @@ static const struct nfs41_state_protection nfs4_sp4_mach_cred_request = {
 	},
 	.allow.u.words = {
 		[0] = 1 << (OP_CLOSE) |
+		      1 << (OP_OPEN_DOWNGRADE) |
 		      1 << (OP_LOCKU) |
+		      1 << (OP_DELEGRETURN) |
 		      1 << (OP_COMMIT),
 		[1] = 1 << (OP_SECINFO - 32) |
 		      1 << (OP_SECINFO_NO_NAME - 32) |
@@ -6930,6 +6937,8 @@ static int nfs4_sp4_select_mode(struct nfs_client *clp,
 		}
 
 		if (test_bit(OP_CLOSE, sp->allow.u.longs) &&
+		    test_bit(OP_OPEN_DOWNGRADE, sp->allow.u.longs) &&
+		    test_bit(OP_DELEGRETURN, sp->allow.u.longs) &&
 		    test_bit(OP_LOCKU, sp->allow.u.longs)) {
 			dfprintk(MOUNT, "  cleanup mode enabled\n");
 			set_bit(NFS_SP4_MACH_CRED_CLEANUP, &clp->cl_sp4_flags);
-- 
2.6.3

