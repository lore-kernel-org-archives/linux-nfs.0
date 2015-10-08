Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f178.google.com ([209.85.160.178]:36200 "EHLO
	mail-yk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932190AbbJHNUp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Oct 2015 09:20:45 -0400
Received: by ykba192 with SMTP id a192so44152451ykb.3
        for <linux-nfs@vger.kernel.org>; Thu, 08 Oct 2015 06:20:44 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/2] SUNRPC: Use MSG_SENDPAGE_NOTLAST in xs_send_pagedata()
Date: Thu,  8 Oct 2015 09:20:41 -0400
Message-Id: <1444310442-44698-1-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <20151008130008.GB32078@fieldses.org>
References: <20151008130008.GB32078@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we're sending more than one page via kernel_sendpage(), then set
MSG_SENDPAGE_NOTLAST between the pages so that we don't send suboptimal
frames (see commit 2f5338442425 and commit 35f9c09fe9c7).

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprtsock.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

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

