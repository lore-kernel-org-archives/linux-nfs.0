Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:36749 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754096AbbC0Qwf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 12:52:35 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [RFC 38/39] rpc: Allow to demand-allocate pages to encode into
Date: Fri, 27 Mar 2015 17:50:36 +0100
Message-Id: <73447bd6fc331c911d32f212d85cc65898432ce5.1427471526.git.agruenba@redhat.com>
In-Reply-To: <cover.1427471526.git.agruenba@redhat.com>
References: <cover.1427471526.git.agruenba@redhat.com>
In-Reply-To: <cover.1427471526.git.agruenba@redhat.com>
References: <cover.1427471526.git.agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When encoding large, variable-length objects such as acls into xdr_bufs, it is
easier to allocate buffer pages on demand rather than computing the required
buffer size beforehand.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 net/sunrpc/xdr.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 4439ac4..062951b 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -537,6 +537,14 @@ static __be32 *xdr_get_next_encode_buffer(struct xdr_stream *xdr,
 	 */
 	xdr->scratch.iov_base = xdr->p;
 	xdr->scratch.iov_len = frag1bytes;
+
+	if (!*xdr->page_ptr) {
+		struct page *page = alloc_page(GFP_KERNEL);
+		if (!page)
+			return ERR_PTR(-ENOMEM);
+		*xdr->page_ptr = page;
+	}
+
 	p = page_address(*xdr->page_ptr);
 	/*
 	 * Note this is where the next encode will start after we've
-- 
2.1.0

