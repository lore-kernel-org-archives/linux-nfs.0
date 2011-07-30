Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:50243 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753436Ab1G3Gdo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Jul 2011 02:33:44 -0400
Message-ID: <4E33A5BB.8000407@panasas.com>
Date: Fri, 29 Jul 2011 23:33:31 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>, Jim Rees <rees@umich.edu>,
        Peng Tao <bergwolf@gmail.com>, NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 4/6] pnfs: use lwb as layoutcommit length
References: <4E33A288.80403@panasas.com>
In-Reply-To: <4E33A288.80403@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Peng Tao <bergwolf@gmail.com>

Using NFS4_MAX_UINT64 will break current protocol.

[Needed in v3.0]
CC: Stable Tree <stable@kernel.org>
Signed-off-by: Peng Tao <peng_tao@emc.com>
---
 fs/nfs/nfs4xdr.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index e6e8f3b..fc97fd5 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1888,7 +1888,7 @@ encode_layoutcommit(struct xdr_stream *xdr,
 	*p++ = cpu_to_be32(OP_LAYOUTCOMMIT);
 	/* Only whole file layouts */
 	p = xdr_encode_hyper(p, 0); /* offset */
-	p = xdr_encode_hyper(p, NFS4_MAX_UINT64); /* length */
+	p = xdr_encode_hyper(p, args->lastbytewritten + 1);	/* length */
 	*p++ = cpu_to_be32(0); /* reclaim */
 	p = xdr_encode_opaque_fixed(p, args->stateid.data, NFS4_STATEID_SIZE);
 	*p++ = cpu_to_be32(1); /* newoffset = TRUE */
-- 
1.7.6


