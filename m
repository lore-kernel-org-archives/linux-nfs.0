Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:42192 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755605Ab1G1Rb0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Jul 2011 13:31:26 -0400
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH v4 06/27] pnfs: use lwb as layoutcommit length
Date: Thu, 28 Jul 2011 13:30:55 -0400
Message-Id: <1311874276-1386-7-git-send-email-rees@umich.edu>
In-Reply-To: <1311874276-1386-1-git-send-email-rees@umich.edu>
References: <1311874276-1386-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Peng Tao <bergwolf@gmail.com>

Using NFS4_MAX_UINT64 will break current protocol.

Signed-off-by: Peng Tao <peng_tao@emc.com>
---
 fs/nfs/nfs4xdr.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 0a1a7b8..5f769f8 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1955,7 +1955,7 @@ encode_layoutcommit(struct xdr_stream *xdr,
 	*p++ = cpu_to_be32(OP_LAYOUTCOMMIT);
 	/* Only whole file layouts */
 	p = xdr_encode_hyper(p, 0); /* offset */
-	p = xdr_encode_hyper(p, NFS4_MAX_UINT64); /* length */
+	p = xdr_encode_hyper(p, args->lastbytewritten + 1);	/* length */
 	*p++ = cpu_to_be32(0); /* reclaim */
 	p = xdr_encode_opaque_fixed(p, args->stateid.data, NFS4_STATEID_SIZE);
 	*p++ = cpu_to_be32(1); /* newoffset = TRUE */
-- 
1.7.4.1

