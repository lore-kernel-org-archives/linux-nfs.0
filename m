Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f179.google.com ([209.85.160.179]:34034 "EHLO
	mail-yk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932552AbbJHNUr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Oct 2015 09:20:47 -0400
Received: by ykdg206 with SMTP id g206so48021871ykd.1
        for <linux-nfs@vger.kernel.org>; Thu, 08 Oct 2015 06:20:46 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/2] SUNRPC: Use MSG_SENDPAGE_NOTLAST in svc_send_common()
Date: Thu,  8 Oct 2015 09:20:42 -0400
Message-Id: <1444310442-44698-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1444310442-44698-1-git-send-email-trond.myklebust@primarydata.com>
References: <20151008130008.GB32078@fieldses.org>
 <1444310442-44698-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow the NFS server to send large amounts of data in page form
without forcing early transmit by do_tcp_sendpages(). See
commit 2f5338442425 and commit 35f9c09fe9c7.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/svcsock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 0c8120229a03..48923730722d 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -181,7 +181,7 @@ int svc_send_common(struct socket *sock, struct xdr_buf *xdr,
 	struct page	**ppage = xdr->pages;
 	size_t		base = xdr->page_base;
 	unsigned int	pglen = xdr->page_len;
-	unsigned int	flags = MSG_MORE;
+	unsigned int	flags = MSG_MORE | MSG_SENDPAGE_NOTLAST;
 	int		slen;
 	int		len = 0;
 
-- 
2.4.3

