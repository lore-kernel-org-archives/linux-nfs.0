Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f177.google.com ([209.85.213.177]:34313 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932081AbaHNVjk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Aug 2014 17:39:40 -0400
Received: by mail-ig0-f177.google.com with SMTP id hn18so207817igb.10
        for <linux-nfs@vger.kernel.org>; Thu, 14 Aug 2014 14:39:40 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 1/2] nfs: disallow duplicate pages in pgio page vectors
Date: Thu, 14 Aug 2014 17:39:32 -0400
Message-Id: <1408052373-4306-2-git-send-email-dros@primarydata.com>
In-Reply-To: <1408052373-4306-1-git-send-email-dros@primarydata.com>
References: <1408052373-4306-1-git-send-email-dros@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Adjacent requests that share the same page are allowed, but should only
use one entry in the page vector. This avoids overruning the page
vector - it is sized based on how many bytes there are, not by
request count.

This fixes issues that manifest as "Redzone overwritten" bugs (the
vector overrun) and hangs waiting on page read / write, as it waits on
the same page more than once.

This also adds bounds checking to the page vector with a graceful failure
(WARN_ON_ONCE and pgio error returned to application).

Reported-by: Toralf Förster <toralf.foerster@gmx.de>
Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/pagelist.c | 22 +++++++++++++++++++---
 1 file changed, 19 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index e0c2e72..73476df 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -733,10 +733,11 @@ int nfs_generic_pgio(struct nfs_pageio_descriptor *desc,
 		     struct nfs_pgio_header *hdr)
 {
 	struct nfs_page		*req;
-	struct page		**pages;
+	struct page		**pages,
+				*last_page;
 	struct list_head *head = &desc->pg_list;
 	struct nfs_commit_info cinfo;
-	unsigned int pagecount;
+	unsigned int pagecount, pageused;
 
 	pagecount = nfs_page_array_len(desc->pg_base, desc->pg_count);
 	if (!nfs_pgarray_set(&hdr->page_array, pagecount))
@@ -744,11 +745,26 @@ int nfs_generic_pgio(struct nfs_pageio_descriptor *desc,
 
 	nfs_init_cinfo(&cinfo, desc->pg_inode, desc->pg_dreq);
 	pages = hdr->page_array.pagevec;
+	last_page = NULL;
+	pageused = 0;
 	while (!list_empty(head)) {
 		req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
 		nfs_list_add_request(req, &hdr->pages);
-		*pages++ = req->wb_page;
+
+		if (pageused >= pagecount) {
+			WARN_ON_ONCE(1);
+			return nfs_pgio_error(desc, hdr);
+		}
+
+		if (!last_page || last_page != req->wb_page) {
+			*pages++ = last_page = req->wb_page;
+			pageused++;
+		}
+	}
+	if (pageused != pagecount) {
+		WARN_ON_ONCE(1);
+		return nfs_pgio_error(desc, hdr);
 	}
 
 	if ((desc->pg_ioflags & FLUSH_COND_STABLE) &&
-- 
1.8.5.2 (Apple Git-48)

