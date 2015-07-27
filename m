Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:36423 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750883AbbG0Oaq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Jul 2015 10:30:46 -0400
Received: by igbij6 with SMTP id ij6so74030643igb.1
        for <linux-nfs@vger.kernel.org>; Mon, 27 Jul 2015 07:30:46 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Weston Andros Adamson <dros@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFS: Fix a memory leak in nfs_do_recoalesce
Date: Mon, 27 Jul 2015 10:30:39 -0400
Message-Id: <1438007440-7045-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the function exits early, then we must put those requests that were
not processed back onto the &mirror->pg_list so they can be cleaned up
by nfs_pgio_error().

Fixes: a7d42ddb30997 ("nfs: add mirroring support to pgio layer")
Cc: stable@vger.kernel.org # v4.0+
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pagelist.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 1da68d3b1eda..8b15d98192c5 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -1109,8 +1109,11 @@ static int nfs_do_recoalesce(struct nfs_pageio_descriptor *desc)
 			nfs_list_remove_request(req);
 			if (__nfs_pageio_add_request(desc, req))
 				continue;
-			if (desc->pg_error < 0)
+			if (desc->pg_error < 0) {
+				list_splice_init(&head, &mirror->pg_list);
+				mirror->pg_recoalesce = 1;
 				return 0;
+			}
 			break;
 		}
 	} while (mirror->pg_recoalesce);
-- 
2.4.3

