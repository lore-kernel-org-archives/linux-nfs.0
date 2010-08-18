Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:10362 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753277Ab0HRUmn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Aug 2010 16:42:43 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 1/4] sunrpc: don't shorten buflen twice in xdr_shrink_pagelen
Date: Wed, 18 Aug 2010 23:42:39 +0300
Message-Id: <1282164159-20283-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4C6C4565.1070603@panasas.com>
References: <4C6C4565.1070603@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

On Jan. 14, 2009, 2:50 +0200, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
>
> The buflen is reset for all cases at the end of xdr_shrink_pagelen.
> The data left in the tail after xdr_read_pages is not processed when the
> buflen is incorrectly set.

Note that in this case we also lose (len - tail->iov_len)
bytes from the buffered data in pages.

Reported-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 net/sunrpc/xdr.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index a1f82a8..91f0de9 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -407,8 +407,7 @@ xdr_shrink_pagelen(struct xdr_buf *buf, size_t len)
 		if (tail->iov_len > len) {
 			copy = tail->iov_len - len;
 			memmove(p, tail->iov_base, copy);
-		} else
-			buf->buflen -= len;
+		}
 		/* Copy from the inlined pages into the tail */
 		copy = len;
 		if (copy > tail->iov_len)
-- 
1.7.2.1

