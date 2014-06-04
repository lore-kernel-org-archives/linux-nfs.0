Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40033 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751405AbaFDVe5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Jun 2014 17:34:57 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/4] nfsd4: simplify server xdr->next_page use
Date: Wed,  4 Jun 2014 17:34:52 -0400
Message-Id: <1401917695-8309-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1401917695-8309-1-git-send-email-bfields@redhat.com>
References: <1401917695-8309-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

The rpc code makes available to the NFS server an array of pages to
encod into.  The server represents its reply as an xdr buf, with the
head pointing into the first page in that array, the pages ** array
starting just after that, and the tail (if any) sharing any leftover
space in the page used by the head.

While encoding, we use xdr_stream->page_ptr to keep track of which page
we're currently using.

Currently we set xdr_stream->page_ptr to buf->pages, which makes the
head a weird exception to the rule that page_ptr always points to the
page we're currently encoding into.  So, instead set it to buf->pages -
1 (the page actually containing the head), and remove the need for a
little unintuitive logic in xdr_get_next_encode_buffer() and
xdr_truncate_encode.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c |    2 +-
 net/sunrpc/xdr.c   |    6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index f053c5a..6851b00 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1264,7 +1264,7 @@ static void svcxdr_init_encode(struct svc_rqst *rqstp,
 	/* Tail and page_len should be zero at this point: */
 	buf->len = buf->head[0].iov_len;
 	xdr->scratch.iov_len = 0;
-	xdr->page_ptr = buf->pages;
+	xdr->page_ptr = buf->pages - 1;
 	buf->buflen = PAGE_SIZE * (1 + rqstp->rq_page_end - buf->pages)
 		- rqstp->rq_auth_slack;
 }
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 3992844..a4981f8 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -523,10 +523,9 @@ __be32 *xdr_get_next_encode_buffer(struct xdr_stream *xdr, size_t nbytes)
 	frag2bytes = nbytes - frag1bytes;
 	if (xdr->iov)
 		xdr->iov->iov_len += frag1bytes;
-	else {
+	else
 		xdr->buf->page_len += frag1bytes;
-		xdr->page_ptr++;
-	}
+	xdr->page_ptr++;
 	xdr->iov = NULL;
 	/*
 	 * If the last encode didn't end exactly on a page boundary, the
@@ -641,6 +640,7 @@ void xdr_truncate_encode(struct xdr_stream *xdr, size_t len)
 	if (fraglen)
 		xdr->end = head->iov_base + head->iov_len;
 	/* (otherwise assume xdr->end is already set) */
+	xdr->page_ptr--;
 	head->iov_len = len;
 	buf->len = len;
 	xdr->p = head->iov_base + head->iov_len;
-- 
1.7.9.5

