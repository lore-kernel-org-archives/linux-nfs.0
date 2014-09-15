Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f175.google.com ([209.85.223.175]:43668 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754266AbaIOSPG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Sep 2014 14:15:06 -0400
Received: by mail-ie0-f175.google.com with SMTP id at20so5109022iec.20
        for <linux-nfs@vger.kernel.org>; Mon, 15 Sep 2014 11:15:06 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: stable@vger.kernel.org
Cc: Weston Andros Adamson <dros@primarydata.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 14/14] nfs: can_coalesce_requests must enforce contiguity
Date: Mon, 15 Sep 2014 14:14:45 -0400
Message-Id: <1410804885-17228-15-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1410804885-17228-14-git-send-email-trond.myklebust@primarydata.com>
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
 <1410804885-17228-14-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Weston Andros Adamson <dros@primarydata.com>

commit 78270e8fbc2916bfc8305b8f58f33474cce1ec0e upstream.

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
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pagelist.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 91e84b3ad63e..34136ff5abf0 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -833,6 +833,14 @@ static bool nfs_can_coalesce_requests(struct nfs_page *prev,
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
1.9.3

