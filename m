Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:52069 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751317AbeFDWby (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jun 2018 18:31:54 -0400
Received: by mail-it0-f65.google.com with SMTP id n7-v6so1020109itn.1
        for <linux-nfs@vger.kernel.org>; Mon, 04 Jun 2018 15:31:54 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id s5-v6sm4309480ioj.13.2018.06.04.15.31.53
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 04 Jun 2018 15:31:53 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 03/11] NFSv4: Don't ask for delegated attributes when revalidating the inode
Date: Mon,  4 Jun 2018 18:31:21 -0400
Message-Id: <20180604223129.121477-3-trond.myklebust@hammerspace.com>
In-Reply-To: <20180604223129.121477-2-trond.myklebust@hammerspace.com>
References: <20180604223129.121477-1-trond.myklebust@hammerspace.com>
 <20180604223129.121477-2-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Again, when revalidating the inode, we don't need to ask for attributes
for which we are authoritative.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4proc.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index cd60e8360ef2..744a6367618d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3832,9 +3832,10 @@ static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
 				struct nfs_fattr *fattr, struct nfs4_label *label,
 				struct inode *inode)
 {
+	__u32 bitmask[NFS4_BITMASK_SZ];
 	struct nfs4_getattr_arg args = {
 		.fh = fhandle,
-		.bitmask = server->attr_bitmask,
+		.bitmask = bitmask,
 	};
 	struct nfs4_getattr_res res = {
 		.fattr = fattr,
@@ -3847,7 +3848,7 @@ static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
 		.rpc_resp = &res,
 	};
 
-	args.bitmask = nfs4_bitmask(server, label);
+	nfs4_bitmap_copy_adjust(bitmask, nfs4_bitmask(server, label), inode);
 
 	nfs_fattr_init(fattr);
 	return nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
-- 
2.17.1

