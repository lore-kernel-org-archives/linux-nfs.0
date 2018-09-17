Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:43731 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728343AbeIQSbz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Sep 2018 14:31:55 -0400
Received: by mail-qt0-f196.google.com with SMTP id g53-v6so15098236qtg.10
        for <linux-nfs@vger.kernel.org>; Mon, 17 Sep 2018 06:04:40 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain ([66.187.232.65])
        by smtp.gmail.com with ESMTPSA id q1-v6sm10499607qkl.31.2018.09.17.06.04.38
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Sep 2018 06:04:38 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 38/44] SUNRPC: Add a label for RPC calls that require allocation on receive
Date: Mon, 17 Sep 2018 09:03:29 -0400
Message-Id: <20180917130335.112832-39-trond.myklebust@hammerspace.com>
In-Reply-To: <20180917130335.112832-38-trond.myklebust@hammerspace.com>
References: <20180917130335.112832-1-trond.myklebust@hammerspace.com>
 <20180917130335.112832-2-trond.myklebust@hammerspace.com>
 <20180917130335.112832-3-trond.myklebust@hammerspace.com>
 <20180917130335.112832-4-trond.myklebust@hammerspace.com>
 <20180917130335.112832-5-trond.myklebust@hammerspace.com>
 <20180917130335.112832-6-trond.myklebust@hammerspace.com>
 <20180917130335.112832-7-trond.myklebust@hammerspace.com>
 <20180917130335.112832-8-trond.myklebust@hammerspace.com>
 <20180917130335.112832-9-trond.myklebust@hammerspace.com>
 <20180917130335.112832-10-trond.myklebust@hammerspace.com>
 <20180917130335.112832-11-trond.myklebust@hammerspace.com>
 <20180917130335.112832-12-trond.myklebust@hammerspace.com>
 <20180917130335.112832-13-trond.myklebust@hammerspace.com>
 <20180917130335.112832-14-trond.myklebust@hammerspace.com>
 <20180917130335.112832-15-trond.myklebust@hammerspace.com>
 <20180917130335.112832-16-trond.myklebust@hammerspace.com>
 <20180917130335.112832-17-trond.myklebust@hammerspace.com>
 <20180917130335.112832-18-trond.myklebust@hammerspace.com>
 <20180917130335.112832-19-trond.myklebust@hammerspace.com>
 <20180917130335.112832-20-trond.myklebust@hammerspace.com>
 <20180917130335.112832-21-trond.myklebust@hammerspace.com>
 <20180917130335.112832-22-trond.myklebust@hammerspace.com>
 <20180917130335.112832-23-trond.myklebust@hammerspace.com>
 <20180917130335.112832-24-trond.myklebust@hammerspace.com>
 <20180917130335.112832-25-trond.myklebust@hammerspace.com>
 <20180917130335.112832-26-trond.myklebust@hammerspace.com>
 <20180917130335.112832-27-trond.myklebust@hammerspace.com>
 <20180917130335.112832-28-trond.myklebust@hammerspace.com>
 <20180917130335.112832-29-trond.myklebust@hammerspace.com>
 <20180917130335.112832-30-trond.myklebust@hammerspace.com>
 <20180917130335.112832-31-trond.myklebust@hammerspace.com>
 <20180917130335.112832-32-trond.myklebust@hammerspace.com>
 <20180917130335.112832-33-trond.myklebust@hammerspace.com>
 <20180917130335.112832-34-trond.myklebust@hammerspace.com>
 <20180917130335.112832-35-trond.myklebust@hammerspace.com>
 <20180917130335.112832-36-trond.myklebust@hammerspace.com>
 <20180917130335.112832-37-trond.myklebust@hammerspace.com>
 <20180917130335.112832-38-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the RPC call relies on the receive call allocating pages as buffers,
then let's label it so that we
a) Don't leak memory by allocating pages for requests that do not expect
   this behaviour
b) Can optimise for the common case where calls do not require allocation.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs3xdr.c                  | 4 +++-
 include/linux/sunrpc/xdr.h        | 1 +
 net/sunrpc/auth_gss/gss_rpc_xdr.c | 1 +
 net/sunrpc/socklib.c              | 2 +-
 4 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 64e4fa33d89f..d8c4c10b15f7 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -1364,10 +1364,12 @@ static void nfs3_xdr_enc_getacl3args(struct rpc_rqst *req,
 
 	encode_nfs_fh3(xdr, args->fh);
 	encode_uint32(xdr, args->mask);
-	if (args->mask & (NFS_ACL | NFS_DFACL))
+	if (args->mask & (NFS_ACL | NFS_DFACL)) {
 		prepare_reply_buffer(req, args->pages, 0,
 					NFSACL_MAXPAGES << PAGE_SHIFT,
 					ACL3_getaclres_sz);
+		req->rq_rcv_buf.flags |= XDRBUF_SPARSE_PAGES;
+	}
 }
 
 static void nfs3_xdr_enc_setacl3args(struct rpc_rqst *req,
diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index 2bd68177a442..431829233392 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -58,6 +58,7 @@ struct xdr_buf {
 			flags;		/* Flags for data disposition */
 #define XDRBUF_READ		0x01		/* target of file read */
 #define XDRBUF_WRITE		0x02		/* source of file write */
+#define XDRBUF_SPARSE_PAGES	0x04		/* Page array is sparse */
 
 	unsigned int	buflen,		/* Total length of storage buffer */
 			len;		/* Length of XDR encoded message */
diff --git a/net/sunrpc/auth_gss/gss_rpc_xdr.c b/net/sunrpc/auth_gss/gss_rpc_xdr.c
index 444380f968f1..006062ad5f58 100644
--- a/net/sunrpc/auth_gss/gss_rpc_xdr.c
+++ b/net/sunrpc/auth_gss/gss_rpc_xdr.c
@@ -784,6 +784,7 @@ void gssx_enc_accept_sec_context(struct rpc_rqst *req,
 	xdr_inline_pages(&req->rq_rcv_buf,
 		PAGE_SIZE/2 /* pretty arbitrary */,
 		arg->pages, 0 /* page base */, arg->npages * PAGE_SIZE);
+	req->rq_rcv_buf.flags |= XDRBUF_SPARSE_PAGES;
 done:
 	if (err)
 		dprintk("RPC:       gssx_enc_accept_sec_context: %d\n", err);
diff --git a/net/sunrpc/socklib.c b/net/sunrpc/socklib.c
index f217c348b341..08f00a98151f 100644
--- a/net/sunrpc/socklib.c
+++ b/net/sunrpc/socklib.c
@@ -104,7 +104,7 @@ ssize_t xdr_partial_copy_from_skb(struct xdr_buf *xdr, unsigned int base, struct
 
 		/* ACL likes to be lazy in allocating pages - ACLs
 		 * are small by default but can get huge. */
-		if (unlikely(*ppage == NULL)) {
+		if ((xdr->flags & XDRBUF_SPARSE_PAGES) && *ppage == NULL) {
 			*ppage = alloc_page(GFP_ATOMIC);
 			if (unlikely(*ppage == NULL)) {
 				if (copied == 0)
-- 
2.17.1
