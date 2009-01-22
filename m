From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH] sunrpc: don't reset buflen twice in xdr_shrink_pagelen
Date: Thu, 22 Jan 2009 16:40:29 +0200
Message-ID: <1232635229-31095-1-git-send-email-bhalevy@panasas.com>
Cc: andros@netapp.com, linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Benny Halevy <bhalevy@panasas.com>
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:50264 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755828AbZAVPnK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jan 2009 10:43:10 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan. 14, 2009, 2:50 +0200, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
>
> The buflen is reset for all cases at the end of xdr_shrink_pagelen.
> The data left in the tail after xdr_read_pages is not processed when the
> buflen is incorrectly set.

Note that in this case we also lose (len - tail->iov_len)
bytes from the buffered data in pages.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Acked-by: Andy Adamson <andros@netapp.com>
---
 net/sunrpc/xdr.c |   14 ++++++--------
 1 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 406e26d..6b05601 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -402,16 +402,14 @@ xdr_shrink_pagelen(struct xdr_buf *buf, size_t len)
 
 	/* Shift the tail first */
 	if (tail->iov_len != 0) {
-		p = (char *)tail->iov_base + len;
-		if (tail->iov_len > len) {
-			copy = tail->iov_len - len;
-			memmove(p, tail->iov_base, copy);
-		} else
-			buf->buflen -= len;
-		/* Copy from the inlined pages into the tail */
 		copy = len;
-		if (copy > tail->iov_len)
+		if (tail->iov_len > len) {
+			p = (char *)tail->iov_base + len;
+			memmove(p, tail->iov_base, tail->iov_len - len);
+		} else {
 			copy = tail->iov_len;
+		}
+		/* Copy from the inlined pages into the tail */
 		_copy_from_pages((char *)tail->iov_base,
 				buf->pages, buf->page_base + pglen - len,
 				copy);
-- 
1.6.1

