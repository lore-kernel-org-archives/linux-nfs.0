Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f53.google.com ([209.85.220.53]:37663 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751291AbaLPTC6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Dec 2014 14:02:58 -0500
Received: by mail-pa0-f53.google.com with SMTP id kq14so14695812pab.40
        for <linux-nfs@vger.kernel.org>; Tue, 16 Dec 2014 11:02:57 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <Trond.Myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 30/50] nfs: introduce pg_cleanup op for pgio descriptors
Date: Tue, 16 Dec 2014 11:01:33 -0800
Message-Id: <1418756513-95187-31-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1418756513-95187-1-git-send-email-loghyr@primarydata.com>
References: <1418756513-95187-1-git-send-email-loghyr@primarydata.com>
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

