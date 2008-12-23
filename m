From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 03/69] SUNRPC: Convert the xdr helpers and rpc_pipefs to
 EXPORT_SYMBOL_GPL
Date: Tue, 23 Dec 2008 18:02:05 -0500
Message-ID: <20081223230205.13743.4865.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17668 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752178AbYLWXXi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:23:38 -0500
Received: from svlrsexc1-prd.hq.netapp.com ([10.57.115.30])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNNbsM006182
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:23:37 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We've never considered the sunrpc code as part of any ABI to be used by
out-of-tree modules.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/rpc_pipe.c |    6 +++---
 net/sunrpc/xdr.c      |   50 +++++++++++++++++++++++++------------------------
 2 files changed, 28 insertions(+), 28 deletions(-)


diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 23a2b8f..55b2049 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -113,7 +113,7 @@ out:
 	wake_up(&rpci->waitq);
 	return res;
 }
-EXPORT_SYMBOL(rpc_queue_upcall);
+EXPORT_SYMBOL_GPL(rpc_queue_upcall);
 
 static inline void
 rpc_inode_setowner(struct inode *inode, void *private)
@@ -808,7 +808,7 @@ err_dput:
 			-ENOMEM);
 	goto out;
 }
-EXPORT_SYMBOL(rpc_mkpipe);
+EXPORT_SYMBOL_GPL(rpc_mkpipe);
 
 /**
  * rpc_unlink - remove a pipe
@@ -839,7 +839,7 @@ rpc_unlink(struct dentry *dentry)
 	dput(parent);
 	return error;
 }
-EXPORT_SYMBOL(rpc_unlink);
+EXPORT_SYMBOL_GPL(rpc_unlink);
 
 /*
  * populate the filesystem
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 79a55d5..406e26d 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -28,7 +28,7 @@ xdr_encode_netobj(__be32 *p, const struct xdr_netobj *obj)
 	memcpy(p, obj->data, obj->len);
 	return p + XDR_QUADLEN(obj->len);
 }
-EXPORT_SYMBOL(xdr_encode_netobj);
+EXPORT_SYMBOL_GPL(xdr_encode_netobj);
 
 __be32 *
 xdr_decode_netobj(__be32 *p, struct xdr_netobj *obj)
@@ -41,7 +41,7 @@ xdr_decode_netobj(__be32 *p, struct xdr_netobj *obj)
 	obj->data = (u8 *) p;
 	return p + XDR_QUADLEN(len);
 }
-EXPORT_SYMBOL(xdr_decode_netobj);
+EXPORT_SYMBOL_GPL(xdr_decode_netobj);
 
 /**
  * xdr_encode_opaque_fixed - Encode fixed length opaque data
@@ -71,7 +71,7 @@ __be32 *xdr_encode_opaque_fixed(__be32 *p, const void *ptr, unsigned int nbytes)
 	}
 	return p;
 }
-EXPORT_SYMBOL(xdr_encode_opaque_fixed);
+EXPORT_SYMBOL_GPL(xdr_encode_opaque_fixed);
 
 /**
  * xdr_encode_opaque - Encode variable length opaque data
@@ -86,14 +86,14 @@ __be32 *xdr_encode_opaque(__be32 *p, const void *ptr, unsigned int nbytes)
 	*p++ = htonl(nbytes);
 	return xdr_encode_opaque_fixed(p, ptr, nbytes);
 }
-EXPORT_SYMBOL(xdr_encode_opaque);
+EXPORT_SYMBOL_GPL(xdr_encode_opaque);
 
 __be32 *
 xdr_encode_string(__be32 *p, const char *string)
 {
 	return xdr_encode_array(p, string, strlen(string));
 }
-EXPORT_SYMBOL(xdr_encode_string);
+EXPORT_SYMBOL_GPL(xdr_encode_string);
 
 __be32 *
 xdr_decode_string_inplace(__be32 *p, char **sp,
@@ -108,7 +108,7 @@ xdr_decode_string_inplace(__be32 *p, char **sp,
 	*sp = (char *) p;
 	return p + XDR_QUADLEN(len);
 }
-EXPORT_SYMBOL(xdr_decode_string_inplace);
+EXPORT_SYMBOL_GPL(xdr_decode_string_inplace);
 
 void
 xdr_encode_pages(struct xdr_buf *xdr, struct page **pages, unsigned int base,
@@ -136,7 +136,7 @@ xdr_encode_pages(struct xdr_buf *xdr, struct page **pages, unsigned int base,
 	xdr->buflen += len;
 	xdr->len += len;
 }
-EXPORT_SYMBOL(xdr_encode_pages);
+EXPORT_SYMBOL_GPL(xdr_encode_pages);
 
 void
 xdr_inline_pages(struct xdr_buf *xdr, unsigned int offset,
@@ -158,7 +158,7 @@ xdr_inline_pages(struct xdr_buf *xdr, unsigned int offset,
 
 	xdr->buflen += len;
 }
-EXPORT_SYMBOL(xdr_inline_pages);
+EXPORT_SYMBOL_GPL(xdr_inline_pages);
 
 /*
  * Helper routines for doing 'memmove' like operations on a struct xdr_buf
@@ -428,7 +428,7 @@ xdr_shift_buf(struct xdr_buf *buf, size_t len)
 {
 	xdr_shrink_bufhead(buf, len);
 }
-EXPORT_SYMBOL(xdr_shift_buf);
+EXPORT_SYMBOL_GPL(xdr_shift_buf);
 
 /**
  * xdr_init_encode - Initialize a struct xdr_stream for sending data.
@@ -465,7 +465,7 @@ void xdr_init_encode(struct xdr_stream *xdr, struct xdr_buf *buf, __be32 *p)
 		iov->iov_len += len;
 	}
 }
-EXPORT_SYMBOL(xdr_init_encode);
+EXPORT_SYMBOL_GPL(xdr_init_encode);
 
 /**
  * xdr_reserve_space - Reserve buffer space for sending
@@ -492,7 +492,7 @@ __be32 * xdr_reserve_space(struct xdr_stream *xdr, size_t nbytes)
 	xdr->buf->len += nbytes;
 	return p;
 }
-EXPORT_SYMBOL(xdr_reserve_space);
+EXPORT_SYMBOL_GPL(xdr_reserve_space);
 
 /**
  * xdr_write_pages - Insert a list of pages into an XDR buffer for sending
@@ -527,7 +527,7 @@ void xdr_write_pages(struct xdr_stream *xdr, struct page **pages, unsigned int b
 	buf->buflen += len;
 	buf->len += len;
 }
-EXPORT_SYMBOL(xdr_write_pages);
+EXPORT_SYMBOL_GPL(xdr_write_pages);
 
 /**
  * xdr_init_decode - Initialize an xdr_stream for decoding data.
@@ -547,7 +547,7 @@ void xdr_init_decode(struct xdr_stream *xdr, struct xdr_buf *buf, __be32 *p)
 	xdr->p = p;
 	xdr->end = (__be32 *)((char *)iov->iov_base + len);
 }
-EXPORT_SYMBOL(xdr_init_decode);
+EXPORT_SYMBOL_GPL(xdr_init_decode);
 
 /**
  * xdr_inline_decode - Retrieve non-page XDR data to decode
@@ -569,7 +569,7 @@ __be32 * xdr_inline_decode(struct xdr_stream *xdr, size_t nbytes)
 	xdr->p = q;
 	return p;
 }
-EXPORT_SYMBOL(xdr_inline_decode);
+EXPORT_SYMBOL_GPL(xdr_inline_decode);
 
 /**
  * xdr_read_pages - Ensure page-based XDR data to decode is aligned at current pointer position
@@ -613,7 +613,7 @@ void xdr_read_pages(struct xdr_stream *xdr, unsigned int len)
 	xdr->p = (__be32 *)((char *)iov->iov_base + padding);
 	xdr->end = (__be32 *)((char *)iov->iov_base + end);
 }
-EXPORT_SYMBOL(xdr_read_pages);
+EXPORT_SYMBOL_GPL(xdr_read_pages);
 
 /**
  * xdr_enter_page - decode data from the XDR page
@@ -638,7 +638,7 @@ void xdr_enter_page(struct xdr_stream *xdr, unsigned int len)
 	xdr->p = (__be32 *)(kaddr + xdr->buf->page_base);
 	xdr->end = (__be32 *)((char *)xdr->p + len);
 }
-EXPORT_SYMBOL(xdr_enter_page);
+EXPORT_SYMBOL_GPL(xdr_enter_page);
 
 static struct kvec empty_iov = {.iov_base = NULL, .iov_len = 0};
 
@@ -650,7 +650,7 @@ xdr_buf_from_iov(struct kvec *iov, struct xdr_buf *buf)
 	buf->page_len = 0;
 	buf->buflen = buf->len = iov->iov_len;
 }
-EXPORT_SYMBOL(xdr_buf_from_iov);
+EXPORT_SYMBOL_GPL(xdr_buf_from_iov);
 
 /* Sets subbuf to the portion of buf of length len beginning base bytes
  * from the start of buf. Returns -1 if base of length are out of bounds. */
@@ -699,7 +699,7 @@ xdr_buf_subsegment(struct xdr_buf *buf, struct xdr_buf *subbuf,
 		return -1;
 	return 0;
 }
-EXPORT_SYMBOL(xdr_buf_subsegment);
+EXPORT_SYMBOL_GPL(xdr_buf_subsegment);
 
 static void __read_bytes_from_xdr_buf(struct xdr_buf *subbuf, void *obj, unsigned int len)
 {
@@ -730,7 +730,7 @@ int read_bytes_from_xdr_buf(struct xdr_buf *buf, unsigned int base, void *obj, u
 	__read_bytes_from_xdr_buf(&subbuf, obj, len);
 	return 0;
 }
-EXPORT_SYMBOL(read_bytes_from_xdr_buf);
+EXPORT_SYMBOL_GPL(read_bytes_from_xdr_buf);
 
 static void __write_bytes_to_xdr_buf(struct xdr_buf *subbuf, void *obj, unsigned int len)
 {
@@ -774,7 +774,7 @@ xdr_decode_word(struct xdr_buf *buf, unsigned int base, u32 *obj)
 	*obj = ntohl(raw);
 	return 0;
 }
-EXPORT_SYMBOL(xdr_decode_word);
+EXPORT_SYMBOL_GPL(xdr_decode_word);
 
 int
 xdr_encode_word(struct xdr_buf *buf, unsigned int base, u32 obj)
@@ -783,7 +783,7 @@ xdr_encode_word(struct xdr_buf *buf, unsigned int base, u32 obj)
 
 	return write_bytes_to_xdr_buf(buf, base, &raw, sizeof(obj));
 }
-EXPORT_SYMBOL(xdr_encode_word);
+EXPORT_SYMBOL_GPL(xdr_encode_word);
 
 /* If the netobj starting offset bytes from the start of xdr_buf is contained
  * entirely in the head or the tail, set object to point to it; otherwise
@@ -821,7 +821,7 @@ int xdr_buf_read_netobj(struct xdr_buf *buf, struct xdr_netobj *obj, unsigned in
 	__read_bytes_from_xdr_buf(&subbuf, obj->data, obj->len);
 	return 0;
 }
-EXPORT_SYMBOL(xdr_buf_read_netobj);
+EXPORT_SYMBOL_GPL(xdr_buf_read_netobj);
 
 /* Returns 0 on success, or else a negative error code. */
 static int
@@ -1027,7 +1027,7 @@ xdr_decode_array2(struct xdr_buf *buf, unsigned int base,
 
 	return xdr_xcode_array2(buf, base, desc, 0);
 }
-EXPORT_SYMBOL(xdr_decode_array2);
+EXPORT_SYMBOL_GPL(xdr_decode_array2);
 
 int
 xdr_encode_array2(struct xdr_buf *buf, unsigned int base,
@@ -1039,7 +1039,7 @@ xdr_encode_array2(struct xdr_buf *buf, unsigned int base,
 
 	return xdr_xcode_array2(buf, base, desc, 1);
 }
-EXPORT_SYMBOL(xdr_encode_array2);
+EXPORT_SYMBOL_GPL(xdr_encode_array2);
 
 int
 xdr_process_buf(struct xdr_buf *buf, unsigned int offset, unsigned int len,
@@ -1106,5 +1106,5 @@ xdr_process_buf(struct xdr_buf *buf, unsigned int offset, unsigned int len,
 out:
 	return ret;
 }
-EXPORT_SYMBOL(xdr_process_buf);
+EXPORT_SYMBOL_GPL(xdr_process_buf);
 

