Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f182.google.com ([209.85.161.182]:60498 "EHLO
	mail-gg0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757809Ab3BGOvr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Feb 2013 09:51:47 -0500
Received: by mail-gg0-f182.google.com with SMTP id d1so295534ggn.27
        for <linux-nfs@vger.kernel.org>; Thu, 07 Feb 2013 06:51:46 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 1/2] sunrpc: trim off trailing checksum before returning decrypted or integrity authenticated buffer
Date: Thu,  7 Feb 2013 09:51:40 -0500
Message-Id: <1360248701-23963-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1360248701-23963-1-git-send-email-jlayton@redhat.com>
References: <1360248701-23963-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When GSSAPI integrity signatures are in use, or when we're using GSSAPI
privacy with the v2 token format, there is a trailing checksum on the
xdr_buf that is returned.

It's checked during the authentication stage, and afterward nothing
cares about it. Ordinarily, it's not a problem since the XDR code
generally ignores it, but it will be when we try to compute a checksum
over the buffer to help prevent XID collisions in the duplicate reply
cache.

Fix the code to trim off the checksums after verifying them. Note that
in unwrap_integ_data, we must avoid trying to reverify the checksum if
the request was deferred since it will no longer be present when it's
revisited.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 include/linux/sunrpc/xdr.h          |  1 +
 net/sunrpc/auth_gss/gss_krb5_wrap.c |  2 ++
 net/sunrpc/auth_gss/svcauth_gss.c   | 10 +++++++--
 net/sunrpc/xdr.c                    | 42 +++++++++++++++++++++++++++++++++++++
 4 files changed, 53 insertions(+), 2 deletions(-)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index 224d060..15f9204 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -152,6 +152,7 @@ xdr_adjust_iovec(struct kvec *iov, __be32 *p)
 extern void xdr_shift_buf(struct xdr_buf *, size_t);
 extern void xdr_buf_from_iov(struct kvec *, struct xdr_buf *);
 extern int xdr_buf_subsegment(struct xdr_buf *, struct xdr_buf *, unsigned int, unsigned int);
+extern void xdr_buf_trim(struct xdr_buf *, unsigned int);
 extern int xdr_buf_read_netobj(struct xdr_buf *, struct xdr_netobj *, unsigned int);
 extern int read_bytes_from_xdr_buf(struct xdr_buf *, unsigned int, void *, unsigned int);
 extern int write_bytes_to_xdr_buf(struct xdr_buf *, unsigned int, void *, unsigned int);
diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index 107c452..88edec9 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -574,6 +574,8 @@ gss_unwrap_kerberos_v2(struct krb5_ctx *kctx, int offset, struct xdr_buf *buf)
 	buf->head[0].iov_len -= GSS_KRB5_TOK_HDR_LEN + headskip;
 	buf->len -= GSS_KRB5_TOK_HDR_LEN + headskip;
 
+	/* Trim off the checksum blob */
+	xdr_buf_trim(buf, GSS_KRB5_TOK_HDR_LEN + tailskip);
 	return GSS_S_COMPLETE;
 }
 
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 73e9573..a5b41e2 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -817,13 +817,17 @@ read_u32_from_xdr_buf(struct xdr_buf *buf, int base, u32 *obj)
  *	The server uses base of head iovec as read pointer, while the
  *	client uses separate pointer. */
 static int
-unwrap_integ_data(struct xdr_buf *buf, u32 seq, struct gss_ctx *ctx)
+unwrap_integ_data(struct svc_rqst *rqstp, struct xdr_buf *buf, u32 seq, struct gss_ctx *ctx)
 {
 	int stat = -EINVAL;
 	u32 integ_len, maj_stat;
 	struct xdr_netobj mic;
 	struct xdr_buf integ_buf;
 
+	/* Did we already verify the signature on the original pass through? */
+	if (rqstp->rq_deferred)
+		return 0;
+
 	integ_len = svc_getnl(&buf->head[0]);
 	if (integ_len & 3)
 		return stat;
@@ -846,6 +850,8 @@ unwrap_integ_data(struct xdr_buf *buf, u32 seq, struct gss_ctx *ctx)
 		goto out;
 	if (svc_getnl(&buf->head[0]) != seq)
 		goto out;
+	/* trim off the mic at the end before returning */
+	xdr_buf_trim(buf, mic.len + 4);
 	stat = 0;
 out:
 	kfree(mic.data);
@@ -1190,7 +1196,7 @@ svcauth_gss_accept(struct svc_rqst *rqstp, __be32 *authp)
 			/* placeholders for length and seq. number: */
 			svc_putnl(resv, 0);
 			svc_putnl(resv, 0);
-			if (unwrap_integ_data(&rqstp->rq_arg,
+			if (unwrap_integ_data(rqstp, &rqstp->rq_arg,
 					gc->gc_seq, rsci->mechctx))
 				goto garbage_args;
 			break;
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 5605563..02c1577 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -879,6 +879,48 @@ xdr_buf_subsegment(struct xdr_buf *buf, struct xdr_buf *subbuf,
 }
 EXPORT_SYMBOL_GPL(xdr_buf_subsegment);
 
+/**
+ * xdr_buf_trim - lop at most "len" bytes off the end of "buf"
+ * @buf: buf to be trimmed
+ * @len: number of bytes to reduce "buf" by
+ *
+ * Trim an xdr_buf by the given number of bytes by fixing up the lengths. Note
+ * that it's possible that we'll trim less than that amount if the xdr_buf is
+ * too small, or if (for instance) it's all in the head and the parser has
+ * already read too far into it.
+ */
+void xdr_buf_trim(struct xdr_buf *buf, unsigned int len)
+{
+	size_t cur;
+	unsigned int trim = len;
+
+	if (buf->tail[0].iov_len) {
+		cur = min_t(size_t, buf->tail[0].iov_len, trim);
+		buf->tail[0].iov_len -= cur;
+		trim -= cur;
+		/* XXX: ok to leave tail[0].iov_base as non-NULL here? */
+		if (!trim)
+			goto fix_len;
+	}
+
+	if (buf->page_len) {
+		cur = min_t(unsigned int, buf->page_len, trim);
+		buf->page_len -= cur;
+		trim -= cur;
+		if (!trim)
+			goto fix_len;
+	}
+
+	if (buf->head[0].iov_len) {
+		cur = min_t(size_t, buf->head[0].iov_len, trim);
+		buf->head[0].iov_len -= cur;
+		trim -= cur;
+	}
+fix_len:
+	buf->len -= (len - trim);
+}
+EXPORT_SYMBOL_GPL(xdr_buf_trim);
+
 static void __read_bytes_from_xdr_buf(struct xdr_buf *subbuf, void *obj, unsigned int len)
 {
 	unsigned int this_len;
-- 
1.7.11.7

