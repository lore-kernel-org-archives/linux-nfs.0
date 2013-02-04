Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f53.google.com ([209.85.128.53]:56072 "EHLO
	mail-qe0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750773Ab3BDRvY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Feb 2013 12:51:24 -0500
Received: by mail-qe0-f53.google.com with SMTP id 1so2939666qee.40
        for <linux-nfs@vger.kernel.org>; Mon, 04 Feb 2013 09:51:23 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] sunrpc: fix comment in struct xdr_buf definition
Date: Mon,  4 Feb 2013 12:51:17 -0500
Message-Id: <1360000277-12778-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...these pages aren't necessarily contiguous.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 include/linux/sunrpc/xdr.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index 6398899..224d060 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -56,7 +56,7 @@ struct xdr_buf {
 	struct kvec	head[1],	/* RPC header + non-page data */
 			tail[1];	/* Appended after page data */
 
-	struct page **	pages;		/* Array of contiguous pages */
+	struct page **	pages;		/* Array of pages */
 	unsigned int	page_base,	/* Start of page data */
 			page_len,	/* Length of page data */
 			flags;		/* Flags for data disposition */
-- 
1.7.11.7

