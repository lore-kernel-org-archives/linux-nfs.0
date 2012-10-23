Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:1744 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754731Ab2JWOx3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Oct 2012 10:53:29 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 20/25] SUNRPC: remove BUG_ON from encode_rpcb_string
Date: Tue, 23 Oct 2012 10:43:44 -0400
Message-Id: <1351003429-18887-21-git-send-email-dros@netapp.com>
In-Reply-To: <1351003429-18887-1-git-send-email-dros@netapp.com>
References: <1351003429-18887-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace BUG_ON() with WARN_ON_ONCE() and truncate the encoded string if
len > max.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 net/sunrpc/rpcb_clnt.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index a70acae..411f332 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -884,7 +884,10 @@ static void encode_rpcb_string(struct xdr_stream *xdr, const char *string,
 	u32 len;
 
 	len = strlen(string);
-	BUG_ON(len > maxstrlen);
+	WARN_ON_ONCE(len > maxstrlen);
+	if (len > maxstrlen)
+		/* truncate and hope for the best */
+		len = maxstrlen;
 	p = xdr_reserve_space(xdr, 4 + len);
 	xdr_encode_opaque(p, string, len);
 }
-- 
1.7.9.6 (Apple Git-31.1)

