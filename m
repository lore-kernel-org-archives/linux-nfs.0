Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:32837 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752475AbbFZTlZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Jun 2015 15:41:25 -0400
Received: by igtg8 with SMTP id g8so8633692igt.0
        for <linux-nfs@vger.kernel.org>; Fri, 26 Jun 2015 12:41:24 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] pNFS/flexfiles: Fix the reset of struct pgio_header when resending
Date: Fri, 26 Jun 2015 15:41:21 -0400
Message-Id: <1435347681-15181-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

hdr->good_bytes needs to be set to the length of the request, not
zero.

Cc: stable@vger.kernel.org # 4.0+
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 594ab35eacfb..c12951b9551e 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -774,7 +774,7 @@ static void ff_layout_reset_write(struct nfs_pgio_header *hdr, bool retry_pnfs)
 			nfs_direct_set_resched_writes(hdr->dreq);
 			/* fake unstable write to let common nfs resend pages */
 			hdr->verf.committed = NFS_UNSTABLE;
-			hdr->good_bytes = 0;
+			hdr->good_bytes = hdr->args.count;
 		}
 		return;
 	}
-- 
2.4.3

