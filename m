Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:33818 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030615AbbDXLFt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Apr 2015 07:05:49 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [RFC v3 41/45] rpc: Allow to demand-allocate pages to encode into
Date: Fri, 24 Apr 2015 13:04:38 +0200
Message-Id: <4bf77d045d2bd3494c695229cd0505b7002cc9a2.1429868795.git.agruenba@redhat.com>
In-Reply-To: <cover.1429868795.git.agruenba@redhat.com>
References: <cover.1429868795.git.agruenba@redhat.com>
In-Reply-To: <cover.1429868795.git.agruenba@redhat.com>
References: <cover.1429868795.git.agruenba@redhat.com>
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

