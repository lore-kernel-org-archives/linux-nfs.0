Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34618 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750893AbcGNEBe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jul 2016 00:01:34 -0400
Received: by mail-pf0-f196.google.com with SMTP id g202so4169161pfb.1
        for <linux-nfs@vger.kernel.org>; Wed, 13 Jul 2016 21:01:34 -0700 (PDT)
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Kinglong Mee <kinglongmee@gmail.com>
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH] nfs/blocklayout: Make sure calculate signature length aligned
Message-ID: <d8e643d9-307c-a112-cb7e-38e0ba1127bc@gmail.com>
Date: Thu, 14 Jul 2016 12:01:28 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Avoid a bad nfs server return an unaligned length of signature.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/blocklayout/dev.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/blocklayout/dev.c b/fs/nfs/blocklayout/dev.c
index e5b8967..3021015 100644
--- a/fs/nfs/blocklayout/dev.c
+++ b/fs/nfs/blocklayout/dev.c
@@ -89,7 +89,8 @@ nfs4_block_decode_volume(struct xdr_stream *xdr, struct pnfs_block_volume *b)
 			memcpy(&b->simple.sigs[i].sig, p,
 				b->simple.sigs[i].sig_len);
 
-			b->simple.len += 8 + 4 + b->simple.sigs[i].sig_len;
+			b->simple.len += 8 + 4 + \
+				(XDR_QUADLEN(b->simple.sigs[i].sig_len) << 2);
 		}
 		break;
 	case PNFS_BLOCK_VOLUME_SLICE:
-- 
2.7.4

