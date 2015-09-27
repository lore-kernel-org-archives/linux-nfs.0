Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34176 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932167AbbI0WNG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 27 Sep 2015 18:13:06 -0400
From: Andreas Gruenbacher <agruenba@redhat.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>, "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-ext4@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org
Subject: [PATCH v8 35/41] sunrpc: Allow to demand-allocate pages to encode into
Date: Mon, 28 Sep 2015 00:09:26 +0200
Message-Id: <1443391772-10171-36-git-send-email-agruenba@redhat.com>
In-Reply-To: <1443391772-10171-1-git-send-email-agruenba@redhat.com>
References: <1443391772-10171-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When encoding large, variable-length objects such as acls into xdr_bufs,
it is easier to allocate buffer pages on demand rather than precomputing
the required buffer size.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 net/sunrpc/xdr.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 4439ac4..63c1c36 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -537,6 +537,15 @@ static __be32 *xdr_get_next_encode_buffer(struct xdr_stream *xdr,
 	 */
 	xdr->scratch.iov_base = xdr->p;
 	xdr->scratch.iov_len = frag1bytes;
+
+	if (!*xdr->page_ptr) {
+		struct page *page = alloc_page(GFP_NOFS);
+
+		if (!page)
+			return NULL;
+		*xdr->page_ptr = page;
+	}
+
 	p = page_address(*xdr->page_ptr);
 	/*
 	 * Note this is where the next encode will start after we've
-- 
2.4.3

