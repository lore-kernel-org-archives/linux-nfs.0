Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:34037 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751641AbbFRACy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Jun 2015 20:02:54 -0400
Received: by iebmu5 with SMTP id mu5so44635317ieb.1
        for <linux-nfs@vger.kernel.org>; Wed, 17 Jun 2015 17:02:54 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] pNFS: Fix a memory leak when attempted pnfs fails
Date: Wed, 17 Jun 2015 20:02:50 -0400
Message-Id: <1434585771-14169-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

pnfs_do_write() expects the call to pnfs_write_through_mds() to free the
pgio header and to release the layout segment before exiting. The problem
is that nfs_pgio_data_destroy() doesn't actually do this; it only frees
the memory allocated by nfs_generic_pgio().

Ditto for pnfs_do_read()...

Fix in both cases is to add a call to hdr->release(hdr).

Cc: stable@vger.kernel.org
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 230606243be6..219ee6a3f1b3 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1865,6 +1865,7 @@ pnfs_write_through_mds(struct nfs_pageio_descriptor *desc,
 		mirror->pg_recoalesce = 1;
 	}
 	nfs_pgio_data_destroy(hdr);
+	hdr->release(hdr);
 }
 
 static enum pnfs_try_status
@@ -1979,6 +1980,7 @@ pnfs_read_through_mds(struct nfs_pageio_descriptor *desc,
 		mirror->pg_recoalesce = 1;
 	}
 	nfs_pgio_data_destroy(hdr);
+	hdr->release(hdr);
 }
 
 /*
-- 
2.4.3

