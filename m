Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f179.google.com ([209.85.160.179]:35145 "EHLO
	mail-yk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754515AbbJGRyz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Oct 2015 13:54:55 -0400
Received: by ykdz138 with SMTP id z138so25208965ykd.2
        for <linux-nfs@vger.kernel.org>; Wed, 07 Oct 2015 10:54:54 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: Use MSG_SENDPAGE_NOTLAST when calling sendpage()
Date: Wed,  7 Oct 2015 13:54:42 -0400
Message-Id: <1444240482-11287-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we're sending more pages via kernel_sendpage(), then set
MSG_SENDPAGE_NOTLAST.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/svcsock.c  | 2 +-
 net/sunrpc/xprtsock.c | 4 +++-
 2 files changed, 4 insertions(+), 2 deletions(-)

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
 
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 1471ecceabf9..e71aff251ac1 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -360,8 +360,10 @@ static int xs_send_pagedata(struct socket *sock, struct xdr_buf *xdr, unsigned i
 		int flags = XS_SENDMSG_FLAGS;
 
 		remainder -= len;
-		if (remainder != 0 || more)
+		if (more)
 			flags |= MSG_MORE;
+		if (remainder != 0)
+			flags |= MSG_SENDPAGE_NOTLAST | MSG_MORE;
 		err = do_sendpage(sock, *ppage, base, len, flags);
 		if (remainder == 0 || err != len)
 			break;
-- 
2.4.3

