From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 02/85] nfs: return compound hdr.status when there are no op replies
Date: Mon, 10 Nov 2008 22:23:02 +0200
Message-ID: <1226348582-8154-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:48779 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751635AbYKJUXI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:23:08 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When there are no op replies encoded in the compound reply
hdr.status still contains the overall status of the compound
rpc.  This can happen, e.g., when the server returns a
NFS4ERR_MINOR_VERS_MISMATCH error.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index b916297..ac2386b 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2222,6 +2222,8 @@ static int decode_compound_hdr(struct xdr_stream *xdr, struct compound_hdr *hdr)
 	hdr->tag = (char *)p;
 	p += XDR_QUADLEN(hdr->taglen);
 	READ32(hdr->nops);
+	if (unlikely(hdr->nops < 1))
+		return nfs4_stat_to_errno(hdr->status);
 	return 0;
 }
 
-- 
1.6.0.2

