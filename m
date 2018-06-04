Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f41.google.com ([209.85.214.41]:55398 "EHLO
        mail-it0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751568AbeFDWbz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jun 2018 18:31:55 -0400
Received: by mail-it0-f41.google.com with SMTP id 144-v6so983856iti.5
        for <linux-nfs@vger.kernel.org>; Mon, 04 Jun 2018 15:31:55 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id s5-v6sm4309480ioj.13.2018.06.04.15.31.53
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 04 Jun 2018 15:31:54 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 04/11] NFSv4: Don't ask for delegated attributes when adding a hard link
Date: Mon,  4 Jun 2018 18:31:22 -0400
Message-Id: <20180604223129.121477-4-trond.myklebust@hammerspace.com>
In-Reply-To: <20180604223129.121477-3-trond.myklebust@hammerspace.com>
References: <20180604223129.121477-1-trond.myklebust@hammerspace.com>
 <20180604223129.121477-2-trond.myklebust@hammerspace.com>
 <20180604223129.121477-3-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4proc.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 744a6367618d..544cdcb79b4f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4378,11 +4378,12 @@ static int nfs4_proc_rename_done(struct rpc_task *task, struct inode *old_dir,
 static int _nfs4_proc_link(struct inode *inode, struct inode *dir, const struct qstr *name)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
+	__u32 bitmask[NFS4_BITMASK_SZ];
 	struct nfs4_link_arg arg = {
 		.fh     = NFS_FH(inode),
 		.dir_fh = NFS_FH(dir),
 		.name   = name,
-		.bitmask = server->attr_bitmask,
+		.bitmask = bitmask,
 	};
 	struct nfs4_link_res res = {
 		.server = server,
@@ -4404,9 +4405,9 @@ static int _nfs4_proc_link(struct inode *inode, struct inode *dir, const struct
 		status = PTR_ERR(res.label);
 		goto out;
 	}
-	arg.bitmask = nfs4_bitmask(server, res.label);
 
 	nfs4_inode_make_writeable(inode);
+	nfs4_bitmap_copy_adjust_setattr(bitmask, nfs4_bitmask(server, res.label), inode);
 
 	status = nfs4_call_sync(server->client, server, &msg, &arg.seq_args, &res.seq_res, 1);
 	if (!status) {
-- 
2.17.1

