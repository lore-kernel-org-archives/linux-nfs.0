Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f52.google.com ([209.85.220.52]:45598 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965072AbbBBWkm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Feb 2015 17:40:42 -0500
Received: by mail-pa0-f52.google.com with SMTP id kx10so87841421pab.11
        for <linux-nfs@vger.kernel.org>; Mon, 02 Feb 2015 14:40:42 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v6 30/53] nfs: introduce pg_cleanup op for pgio descriptors
Date: Mon,  2 Feb 2015 14:38:44 -0800
Message-Id: <1422916747-86649-31-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1422916747-86649-1-git-send-email-loghyr@primarydata.com>
References: <1422916747-86649-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Weston Andros Adamson <dros@primarydata.com>

Add a new operation to nfs_pageio_ops that is called on nfs_pageio_complete.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/pagelist.c        | 5 ++++-
 include/linux/nfs_page.h | 1 +
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index c4d1758..1c03187 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -1050,7 +1050,7 @@ int nfs_pageio_resend(struct nfs_pageio_descriptor *desc,
 EXPORT_SYMBOL_GPL(nfs_pageio_resend);
 
 /**
- * nfs_pageio_complete - Complete I/O on an nfs_pageio_descriptor
+ * nfs_pageio_complete - Complete I/O then cleanup an nfs_pageio_descriptor
  * @desc: pointer to io descriptor
  */
 void nfs_pageio_complete(struct nfs_pageio_descriptor *desc)
@@ -1062,6 +1062,9 @@ void nfs_pageio_complete(struct nfs_pageio_descriptor *desc)
 		if (!nfs_do_recoalesce(desc))
 			break;
 	}
+
+	if (desc->pg_ops->pg_cleanup)
+		desc->pg_ops->pg_cleanup(desc);
 }
 
 /**
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 4c3aa80..479c566 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -58,6 +58,7 @@ struct nfs_pageio_ops {
 	size_t	(*pg_test)(struct nfs_pageio_descriptor *, struct nfs_page *,
 			   struct nfs_page *);
 	int	(*pg_doio)(struct nfs_pageio_descriptor *);
+	void	(*pg_cleanup)(struct nfs_pageio_descriptor *);
 };
 
 struct nfs_rw_ops {
-- 
1.9.3

