Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from m50-135.163.com ([123.125.50.135]:49652 "EHLO m50-135.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1427496AbdDWGt7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 23 Apr 2017 02:49:59 -0400
From: Pan Bian <bianpan2016@163.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Pan Bian <bianpan2016@163.com>
Subject: [PATCH 1/1] NFSv4: check return value of xdr_inline_decode
Date: Sun, 23 Apr 2017 14:49:41 +0800
Message-Id: <1492930181-9115-1-git-send-email-bianpan2016@163.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Function xdr_inline_decode() will return a NULL pointer if the input
buffer does not have long enough buffer to decode nbytes of data.
However, in function decode_op_map(), the return value of
xdr_inline_decode() is not validated before it is used. This patch adds
a check to the return value of xdr_inline_decode().

Signed-off-by: Pan Bian <bianpan2016@163.com>
---
 fs/nfs/nfs4xdr.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 80ce289..81afbbd 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -5579,6 +5579,8 @@ static int decode_op_map(struct xdr_stream *xdr, struct nfs4_op_map *op_map)
 	unsigned int i;
 
 	p = xdr_inline_decode(xdr, 4);
+	if (!p)
+		return -EIO;
 	bitmap_words = be32_to_cpup(p++);
 	if (bitmap_words > NFS4_OP_MAP_NUM_WORDS)
 		return -EIO;
-- 
1.9.1


