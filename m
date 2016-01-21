Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:38551 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751299AbcAUUzj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Jan 2016 15:55:39 -0500
Received: by mail-ig0-f176.google.com with SMTP id mw1so41896268igb.1
        for <linux-nfs@vger.kernel.org>; Thu, 21 Jan 2016 12:55:39 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] pNFS/flexfiles: Fix an XDR encoding bug in layoutreturn
Date: Thu, 21 Jan 2016 15:55:13 -0500
Message-Id: <1453409713-15878-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1453409713-15878-1-git-send-email-trond.myklebust@primarydata.com>
References: <1453409713-15878-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We must not skip encoding the statistics, or the server will see an
XDR encoding error.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: stable@vger.kernel.org # 4.0+
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 405f46ba490e..82959409b9a6 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1859,9 +1859,7 @@ ff_layout_encode_layoutreturn(struct pnfs_layout_hdr *lo,
 	start = xdr_reserve_space(xdr, 4);
 	BUG_ON(!start);
 
-	if (ff_layout_encode_ioerr(flo, xdr, args))
-		goto out;
-
+	ff_layout_encode_ioerr(flo, xdr, args);
 	ff_layout_encode_iostats(flo, xdr, args);
 out:
 	*start = cpu_to_be32((xdr->p - start - 1) * 4);
-- 
2.5.0

