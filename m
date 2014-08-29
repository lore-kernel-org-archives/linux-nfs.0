Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34253 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752942AbaH2SzL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Aug 2014 14:55:11 -0400
Received: from bfields by fieldses.org with local (Exim 4.76)
	(envelope-from <bfields@fieldses.org>)
	id 1XNRKI-0003n9-GI
	for linux-nfs@vger.kernel.org; Fri, 29 Aug 2014 14:55:10 -0400
Date: Fri, 29 Aug 2014 14:55:10 -0400
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd4: fix rd_dircount enforcement
Message-ID: <20140829185510.GA13710@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Commit 3b299709091b "nfsd4: enforce rd_dircount" totally misunderstood
rd_dircount; it refers to total non-attribute bytes returned, not number
of directory entries returned.

Bring the code into agreement with RFC 3530 section 14.2.24.

Cc: stable@kernel.org
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index f9821ce6658a..e94457c33ad6 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2657,6 +2657,7 @@ nfsd4_encode_dirent(void *ccdv, const char *name, int namlen,
 	struct xdr_stream *xdr = cd->xdr;
 	int start_offset = xdr->buf->len;
 	int cookie_offset;
+	u32 name_and_cookie;
 	int entry_bytes;
 	__be32 nfserr = nfserr_toosmall;
 	__be64 wire_offset;
@@ -2718,7 +2719,14 @@ nfsd4_encode_dirent(void *ccdv, const char *name, int namlen,
 	cd->rd_maxcount -= entry_bytes;
 	if (!cd->rd_dircount)
 		goto fail;
-	cd->rd_dircount--;
+	/*
+	 * RFC 3530 14.2.24 describes rd_dircount as only a "hint", so
+	 * let's always let through the first entry, at least:
+	 */
+	name_and_cookie = 4 * XDR_QUADLEN(namlen) + 8;
+	if (name_and_cookie > cd->rd_dircount && cd->cookie_offset)
+		goto fail;
+	cd->rd_dircount -= min(cd->rd_dircount, name_and_cookie);
 	cd->cookie_offset = cookie_offset;
 skip_entry:
 	cd->common.err = nfs_ok;
@@ -3321,6 +3329,10 @@ nfsd4_encode_readdir(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 	}
 	maxcount = min_t(int, maxcount-16, bytes_left);
 
+	/* RFC 3530 14.2.24 allows us to ignore dircount when it's 0: */
+	if (!readdir->rd_dircount)
+		readdir->rd_dircount = INT_MAX;
+
 	readdir->xdr = xdr;
 	readdir->rd_maxcount = maxcount;
 	readdir->common.err = 0;
-- 
1.9.3

