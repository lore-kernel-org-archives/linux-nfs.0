Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f172.google.com ([209.85.223.172]:59681 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932675AbaFIPsq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jun 2014 11:48:46 -0400
Received: by mail-ie0-f172.google.com with SMTP id lx4so2681309iec.17
        for <linux-nfs@vger.kernel.org>; Mon, 09 Jun 2014 08:48:46 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH v3 7/7] nfs: remove unneeded EXPORTs
Date: Mon,  9 Jun 2014 11:48:39 -0400
Message-Id: <1402328919-5065-8-git-send-email-dros@primarydata.com>
In-Reply-To: <1402328919-5065-1-git-send-email-dros@primarydata.com>
References: <1402328919-5065-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

EXPORT_GPLs of nfs_pageio_add_request and nfs_pageio_complete aren't
needed anymore.

Suggested-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/pagelist.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 6c5dd8b..9097ee9 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -947,7 +947,6 @@ int nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 	} while (ret);
 	return ret;
 }
-EXPORT_SYMBOL_GPL(nfs_pageio_add_request);
 
 /*
  * nfs_pageio_resend - Transfer requests to new descriptor and resend
@@ -995,7 +994,6 @@ void nfs_pageio_complete(struct nfs_pageio_descriptor *desc)
 			break;
 	}
 }
-EXPORT_SYMBOL_GPL(nfs_pageio_complete);
 
 /**
  * nfs_pageio_cond_complete - Conditional I/O completion
-- 
1.8.5.2 (Apple Git-48)

