Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og114.obsmtp.com ([64.18.0.28]:43024 "HELO
	exprod5og114.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753181Ab0JGVZm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Oct 2010 17:25:42 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] SQUASHME: pnfs: loga_minlength must not be greater than loga_length
Date: Thu,  7 Oct 2010 17:25:36 -0400
Message-Id: <1286486736-27457-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pnfs.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index f346533..6cc0543 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -622,6 +622,8 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 		return NULL;
 	}
 	lgp->args.minlength = PAGE_CACHE_SIZE;
+	if (lgp->args.minlength > range->length)
+		lgp->args.minlength = range->length;
 	lgp->args.maxcount = PNFS_LAYOUT_MAXSIZE;
 	lgp->args.range = *range;
 	lgp->args.type = server->pnfs_curr_ld->id;
-- 
1.7.2.3

