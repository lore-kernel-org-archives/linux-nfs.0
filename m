Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f180.google.com ([209.85.213.180]:39926 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755037AbaHNVjl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Aug 2014 17:39:41 -0400
Received: by mail-ig0-f180.google.com with SMTP id l13so221038iga.1
        for <linux-nfs@vger.kernel.org>; Thu, 14 Aug 2014 14:39:41 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 2/2] nfs: can_coalesce_requests must enforce contiguity
Date: Thu, 14 Aug 2014 17:39:33 -0400
Message-Id: <1408052373-4306-3-git-send-email-dros@primarydata.com>
In-Reply-To: <1408052373-4306-1-git-send-email-dros@primarydata.com>
References: <1408052373-4306-1-git-send-email-dros@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 6094f83864c1d1296566a282cba05ba613f151ee
"nfs: allow coalescing of subpage requests" got rid of the requirement
that requests cover whole pages, but it made some incorrect assumptions.

It turns out that callers of this interface can map adjacent requests
(by file position as seen by req_offset + req->wb_bytes) to different pages,
even when they could share a page. An example is the direct I/O interface -
iov_iter_get_pages_alloc may return one segment with a partial page filled
and the next segment (which is adjacent in the file position) starts with a
new page.

Reported-by: Toralf Förster <toralf.foerster@gmx.de>
Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/pagelist.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 73476df..d512887 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -836,6 +836,14 @@ static bool nfs_can_coalesce_requests(struct nfs_page *prev,
 			return false;
 		if (req_offset(req) != req_offset(prev) + prev->wb_bytes)
 			return false;
+		if (req->wb_page == prev->wb_page) {
+			if (req->wb_pgbase != prev->wb_pgbase + prev->wb_bytes)
+				return false;
+		} else {
+			if (req->wb_pgbase != 0 ||
+			    prev->wb_pgbase + prev->wb_bytes != PAGE_CACHE_SIZE)
+				return false;
+		}
 	}
 	size = pgio->pg_ops->pg_test(pgio, prev, req);
 	WARN_ON_ONCE(size > req->wb_bytes);
-- 
1.8.5.2 (Apple Git-48)

