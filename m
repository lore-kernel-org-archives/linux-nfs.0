Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:34922 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756594AbbFPOsy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Jun 2015 10:48:54 -0400
Received: by pdbnf5 with SMTP id nf5so16052955pdb.2
        for <linux-nfs@vger.kernel.org>; Tue, 16 Jun 2015 07:48:53 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs <linux-nfs@vger.kernel.org>
Cc: Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH 02/11] pNFS: fill in nfs42_layoutstat_ops
Date: Tue, 16 Jun 2015 22:47:23 +0800
Message-Id: <1434466052-10491-3-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1434466052-10491-1-git-send-email-tao.peng@primarydata.com>
References: <1434466052-10491-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/nfs42proc.c | 47 +++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 47 insertions(+)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index ac92968..a053041 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -10,6 +10,11 @@
 #include <linux/nfs_fs.h>
 #include "nfs4_fs.h"
 #include "nfs42.h"
+#include "iostat.h"
+#include "pnfs.h"
+#include "internal.h"
+
+#define NFSDBG_FACILITY NFSDBG_PNFS
 
 static int nfs42_set_rw_stateid(nfs4_stateid *dst, struct file *file,
 				fmode_t fmode)
@@ -166,7 +171,44 @@ loff_t nfs42_proc_llseek(struct file *filep, loff_t offset, int whence)
 	return vfs_setpos(filep, res.sr_offset, inode->i_sb->s_maxbytes);
 }
 
+static void
+nfs42_layoutstat_prepare(struct rpc_task *task, void *calldata)
+{
+	struct nfs42_layoutstat_data *data = calldata;
+	struct nfs_server *server = NFS_SERVER(data->args.inode);
+
+	nfs41_setup_sequence(nfs4_get_session(server), &data->args.seq_args,
+			     &data->res.seq_res, task);
+}
+
+static void
+nfs42_layoutstat_done(struct rpc_task *task, void *calldata)
+{
+	struct nfs42_layoutstat_data *data = calldata;
+
+	if (!nfs4_sequence_done(task, &data->res.seq_res))
+		return;
+
+	/* well, we don't care about errors at all! */
+	if (task->tk_status)
+		dprintk("%s server returns %d\n", __func__, task->tk_status);
+}
+
+static void
+nfs42_layoutstat_release(void *calldata)
+{
+	struct nfs42_layoutstat_data *data = calldata;
+
+	pnfs_put_layout_hdr(NFS_I(data->args.inode)->layout);
+	nfs_iput_and_deactive(data->inode);
+	kfree(data->args.devinfo);
+	kfree(data);
+}
+
 static const struct rpc_call_ops nfs42_layoutstat_ops = {
+	.rpc_call_prepare = nfs42_layoutstat_prepare,
+	.rpc_call_done = nfs42_layoutstat_done,
+	.rpc_release = nfs42_layoutstat_release,
 };
 
 int nfs42_proc_layoutstats_generic(struct nfs_server *server,
@@ -186,6 +228,11 @@ int nfs42_proc_layoutstats_generic(struct nfs_server *server,
 	};
 	struct rpc_task *task;
 
+	data->inode = nfs_igrab_and_active(data->args.inode);
+	if (!data->inode) {
+		nfs42_layoutstat_release(data);
+		return -EAGAIN;
+	}
 	nfs4_init_sequence(&data->args.seq_args, &data->res.seq_res, 0);
 	task = rpc_run_task(&task_setup);
 	if (IS_ERR(task))
-- 
1.8.3.1

