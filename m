Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:36397 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S947383AbdDTVWh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Apr 2017 17:22:37 -0400
Received: by mail-io0-f195.google.com with SMTP id x86so20956319ioe.3
        for <linux-nfs@vger.kernel.org>; Thu, 20 Apr 2017 14:22:37 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] pNFS: Unexport pnfs_put_lseg_locked and _pnfs_return_layout
Date: Thu, 20 Apr 2017 17:22:31 -0400
Message-Id: <20170420212232.88086-3-trond.myklebust@primarydata.com>
In-Reply-To: <20170420212232.88086-2-trond.myklebust@primarydata.com>
References: <20170420212232.88086-1-trond.myklebust@primarydata.com>
 <20170420212232.88086-2-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

They are not used outside the NFSv4 module.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index dd042498ce7c..3917a6272789 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -563,7 +563,6 @@ pnfs_put_lseg_locked(struct pnfs_layout_segment *lseg)
 		}
 	}
 }
-EXPORT_SYMBOL_GPL(pnfs_put_lseg_locked);
 
 /*
  * is l2 fully contained in l1?
@@ -1209,7 +1208,6 @@ _pnfs_return_layout(struct inode *ino)
 	dprintk("<-- %s status: %d\n", __func__, status);
 	return status;
 }
-EXPORT_SYMBOL_GPL(_pnfs_return_layout);
 
 int
 pnfs_commit_and_return_layout(struct inode *inode)
-- 
2.9.3

