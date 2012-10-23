Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:60714 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754948Ab2JWOxs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Oct 2012 10:53:48 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 18/25] SUNRPC: remove BUG_ON in xdr_shrink_bufhead
Date: Tue, 23 Oct 2012 10:43:42 -0400
Message-Id: <1351003429-18887-19-git-send-email-dros@netapp.com>
In-Reply-To: <1351003429-18887-1-git-send-email-dros@netapp.com>
References: <1351003429-18887-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace bounds checking BUG_ON() with a WARN_ON_ONCE() and resetting
the requested len to the max.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 net/sunrpc/xdr.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 08f50af..5605563 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -318,7 +318,10 @@ xdr_shrink_bufhead(struct xdr_buf *buf, size_t len)
 
 	tail = buf->tail;
 	head = buf->head;
-	BUG_ON (len > head->iov_len);
+
+	WARN_ON_ONCE(len > head->iov_len);
+	if (len > head->iov_len)
+		len = head->iov_len;
 
 	/* Shift the tail first */
 	if (tail->iov_len != 0) {
-- 
1.7.9.6 (Apple Git-31.1)

