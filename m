Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50613 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752903Ab0HMVcG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:32:06 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 03/50] sunrpc: don't reset buflen twice in xdr_shrink_pagelen
Date: Fri, 13 Aug 2010 17:31:15 -0400
Message-Id: <1281735122-1496-4-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-3-git-send-email-andros@netapp.com>
References: <1281735122-1496-1-git-send-email-andros@netapp.com>
 <1281735122-1496-2-git-send-email-andros@netapp.com>
 <1281735122-1496-3-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Benny Halevy <bhalevy@panasas.com>

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
index a1f82a8..b43258e 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -403,16 +403,14 @@ xdr_shrink_pagelen(struct xdr_buf *buf, size_t len)
 
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
1.6.2.5

