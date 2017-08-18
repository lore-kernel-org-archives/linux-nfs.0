Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:36194 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752256AbdHRSwF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Aug 2017 14:52:05 -0400
Received: by mail-io0-f194.google.com with SMTP id j32so6146832iod.3
        for <linux-nfs@vger.kernel.org>; Fri, 18 Aug 2017 11:52:05 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v4 4/5] SUNRPC: Cleanup xs_tcp_read_common()
Date: Fri, 18 Aug 2017 14:51:52 -0400
Message-Id: <20170818185153.20023-5-trond.myklebust@primarydata.com>
In-Reply-To: <20170818185153.20023-4-trond.myklebust@primarydata.com>
References: <20170818185153.20023-1-trond.myklebust@primarydata.com>
 <20170818185153.20023-2-trond.myklebust@primarydata.com>
 <20170818185153.20023-3-trond.myklebust@primarydata.com>
 <20170818185153.20023-4-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Simplify the code to avoid a full copy of the struct xdr_skb_reader.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprtsock.c | 25 ++++++++-----------------
 1 file changed, 8 insertions(+), 17 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index e8f44fc76754..a344bea15fc7 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1287,25 +1287,12 @@ static inline void xs_tcp_read_common(struct rpc_xprt *xprt,
 	}
 
 	len = desc->count;
-	if (len > transport->tcp_reclen - transport->tcp_offset) {
-		struct xdr_skb_reader my_desc;
-
-		len = transport->tcp_reclen - transport->tcp_offset;
-		memcpy(&my_desc, desc, sizeof(my_desc));
-		my_desc.count = len;
-		r = xdr_partial_copy_from_skb(rcvbuf, transport->tcp_copied,
-					  &my_desc, xdr_skb_read_bits);
-		desc->count -= r;
-		desc->offset += r;
-	} else
-		r = xdr_partial_copy_from_skb(rcvbuf, transport->tcp_copied,
+	if (len > transport->tcp_reclen - transport->tcp_offset)
+		desc->count = transport->tcp_reclen - transport->tcp_offset;
+	r = xdr_partial_copy_from_skb(rcvbuf, transport->tcp_copied,
 					  desc, xdr_skb_read_bits);
 
-	if (r > 0) {
-		transport->tcp_copied += r;
-		transport->tcp_offset += r;
-	}
-	if (r != len) {
+	if (desc->count) {
 		/* Error when copying to the receive buffer,
 		 * usually because we weren't able to allocate
 		 * additional buffer pages. All we can do now
@@ -1325,6 +1312,10 @@ static inline void xs_tcp_read_common(struct rpc_xprt *xprt,
 		return;
 	}
 
+	transport->tcp_copied += r;
+	transport->tcp_offset += r;
+	desc->count = len - r;
+
 	dprintk("RPC:       XID %08x read %zd bytes\n",
 			ntohl(transport->tcp_xid), r);
 	dprintk("RPC:       xprt = %p, tcp_copied = %lu, tcp_offset = %u, "
-- 
2.13.5

