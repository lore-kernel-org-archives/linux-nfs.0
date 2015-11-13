Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:53101 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932077AbbKMInR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Nov 2015 03:43:17 -0500
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Peng Tao <tao.peng@primarydata.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 1/5] nfs: pass on count for CLONE operations
Date: Fri, 13 Nov 2015 09:38:45 +0100
Message-Id: <1447403929-13743-2-git-send-email-hch@lst.de>
In-Reply-To: <1447403929-13743-1-git-send-email-hch@lst.de>
References: <1447403929-13743-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently we pass uninitialized stack garbage in the count parameter.
The value is usually large enought to clone whole files and thus let
simple tests pass, but it makes the tests for range clones very unhappy.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/nfs42proc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 3e92a3c..303d22e 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -284,6 +284,7 @@ static int _nfs42_proc_clone(struct rpc_message *msg, struct file *src_f,
 		.dst_fh = NFS_FH(dst_inode),
 		.src_offset = src_offset,
 		.dst_offset = dst_offset,
+		.count = count,
 		.dst_bitmask = server->cache_consistency_bitmask,
 	};
 	struct nfs42_clone_res res = {
-- 
1.9.1

