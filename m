Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:42586 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753885AbbHQQoL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Aug 2015 12:44:11 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 3/5] pnfs/blocklayout: reject too long signatures
Date: Mon, 17 Aug 2015 18:40:59 +0200
Message-Id: <1439829661-1505-4-git-send-email-hch@lst.de>
In-Reply-To: <1439829661-1505-1-git-send-email-hch@lst.de>
References: <1439829661-1505-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of overwriting kernel memory reject too long signatures.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/blocklayout/dev.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/nfs/blocklayout/dev.c b/fs/nfs/blocklayout/dev.c
index e535599..d76993a 100644
--- a/fs/nfs/blocklayout/dev.c
+++ b/fs/nfs/blocklayout/dev.c
@@ -65,6 +65,11 @@ nfs4_block_decode_volume(struct xdr_stream *xdr, struct pnfs_block_volume *b)
 				return -EIO;
 			p = xdr_decode_hyper(p, &b->simple.sigs[i].offset);
 			b->simple.sigs[i].sig_len = be32_to_cpup(p++);
+			if (b->simple.sigs[i].sig_len > PNFS_BLOCK_UUID_LEN) {
+				pr_info("signature too long: %d\n",
+					b->simple.sigs[i].sig_len);
+				return -EIO;
+			}
 
 			p = xdr_inline_decode(xdr, b->simple.sigs[i].sig_len);
 			if (!p)
-- 
1.9.1

