Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:37116 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755246Ab2DIV4r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Apr 2012 17:56:47 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] NFSv4.1 fix page number calulation bug for filelayout decode buffer
Date: Mon,  9 Apr 2012 17:55:35 -0400
Message-Id: <1334008535-2875-2-git-send-email-andros@netapp.com>
In-Reply-To: <1334008535-2875-1-git-send-email-andros@netapp.com>
References: <1334008535-2875-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayoutdev.c |    2 +-
 fs/nfs/pnfs.c              |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index a866bbd..696e448 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -699,7 +699,7 @@ get_device_info(struct inode *inode, struct nfs4_deviceid *dev_id, gfp_t gfp_fla
 	 * GETDEVICEINFO's maxcount
 	 */
 	max_resp_sz = server->nfs_client->cl_session->fc_attrs.max_resp_sz;
-	max_pages = max_resp_sz >> PAGE_SHIFT;
+	max_pages = (max_resp_sz + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	dprintk("%s inode %p max_resp_sz %u max_pages %d\n",
 		__func__, inode, max_resp_sz, max_pages);
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index b5d4515..b73af2e 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -587,7 +587,7 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 
 	/* allocate pages for xdr post processing */
 	max_resp_sz = server->nfs_client->cl_session->fc_attrs.max_resp_sz;
-	max_pages = max_resp_sz >> PAGE_SHIFT;
+	max_pages = (max_resp_sz + PAGE_SIZE - 1) >> PAGE_SHIFT;
 
 	pages = kcalloc(max_pages, sizeof(struct page *), gfp_flags);
 	if (!pages)
-- 
1.7.6.4

