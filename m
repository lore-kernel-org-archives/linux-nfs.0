Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f176.google.com ([209.85.223.176]:62826 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754414AbaIOSPF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Sep 2014 14:15:05 -0400
Received: by mail-ie0-f176.google.com with SMTP id ar1so5161719iec.35
        for <linux-nfs@vger.kernel.org>; Mon, 15 Sep 2014 11:15:05 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: stable@vger.kernel.org
Cc: Weston Andros Adamson <dros@primarydata.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 13/14] nfs: disallow duplicate pages in pgio page vectors
Date: Mon, 15 Sep 2014 14:14:44 -0400
Message-Id: <1410804885-17228-14-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1410804885-17228-13-git-send-email-trond.myklebust@primarydata.com>
References: <1410804885-17228-1-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-2-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-3-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-4-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-5-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-6-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-7-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-8-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-9-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-10-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-11-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-12-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-13-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Weston Andros Adamson <dros@primarydata.com>

commit bba5c1887a925a9945d22217d38d58d8b3ba1043 upstream.

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
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pagelist.c | 18 +++++++++++++++---
 1 file changed, 15 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index f56b6351b660..91e84b3ad63e 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -734,10 +734,11 @@ int nfs_generic_pgio(struct nfs_pageio_descriptor *desc,
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
@@ -745,12 +746,23 @@ int nfs_generic_pgio(struct nfs_pageio_descriptor *desc,
 
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
+		if (WARN_ON_ONCE(pageused >= pagecount))
+			return nfs_pgio_error(desc, hdr);
+
+		if (!last_page || last_page != req->wb_page) {
+			*pages++ = last_page = req->wb_page;
+			pageused++;
+		}
 	}
+	if (WARN_ON_ONCE(pageused != pagecount))
+		return nfs_pgio_error(desc, hdr);
 
 	if ((desc->pg_ioflags & FLUSH_COND_STABLE) &&
 	    (desc->pg_moreio || nfs_reqs_to_commit(&cinfo)))
-- 
1.9.3

