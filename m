Return-Path: <SRS0=ULVj=QS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 689A0C169C4
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Feb 2019 16:25:13 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 35B30218F0
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Feb 2019 16:25:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Esm3Wnbd"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728639AbfBKQZM (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 11 Feb 2019 11:25:12 -0500
Received: from mail-it1-f171.google.com ([209.85.166.171]:37719 "EHLO
        mail-it1-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728538AbfBKQZM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Feb 2019 11:25:12 -0500
Received: by mail-it1-f171.google.com with SMTP id b5so27668301iti.2;
        Mon, 11 Feb 2019 08:25:11 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=9kMKCrJ/Wheah38Npntkcn5b8Uj40xkO03LYa7PNCFQ=;
        b=Esm3WnbdwmTrSk47l3fb0wU3g+U0CapKyd+SsQt3zUxQs/n9zzh6GYZKcHYKtbSF3s
         aGf6n9BRcI+WTXClo3mHoBPXzNatPD8QDi8QVChoO18a3hx3lfccIn8V/loSKLxrZDN5
         YYX0dlj8ndCXqpoIu8wJGZzIxOTPeyDnd+PaeUecQlQFQ86V7T7D9uZDznh4V5OFmKmb
         Zn1PKku47ONs2msnoAtiAm/TfYQYLzgeO1Kryb2sDyZyVChNuajd8EUD+888Y1tOmHeh
         awL5mMhdLMA8dLoLLiac0OCyv3Pxb0TiOuBQCBglHZUqNxS/FYoe7NQY9f6JJRJu25Nb
         z5LQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=9kMKCrJ/Wheah38Npntkcn5b8Uj40xkO03LYa7PNCFQ=;
        b=QoyBgBZ5jclFSYr3V8IBbPiQJC+g8vKwmLK2/Q8ZGqK3vfCJaaGsFLGgmAGVfPmIpV
         9ZRnAi75Bgl7w5Vpzr/CTd8InQ2zQgdP4D28GG8DzhqJThI5FPwtmhU7Vz5iZNuwFq9p
         4zHZqPgygsjcXZjBXiWmt9at2P0ZOJ9ijRWOPLNdM58k16SDck1DziMihLQyuNJ2l54j
         BYcAZyvsmo8RGi42sH43uYv5BX6Io+yVy5KiYhwR6j9va3BfQ4LNvQhBw8NZ4hLD+fPv
         ktJHan8W7OgdzDAx49FCc6grIOmAwGlAIs8DPoKM/LIuqxyTZTlSRuhqBlZRQLMQsTXp
         MXGQ==
X-Gm-Message-State: AHQUAua7fqtc8zHiemiKoZzNhzJ430kpNgLoROY5I9hYzjHgwo89bJAi
        gnshdoL46LAtdk9XHwA84To=
X-Google-Smtp-Source: AHgI3IZ2KnTtDwhyJjusRHuBGCiyNByIR5N2z7nYJXTKLsT+XBtxm7CSib+M21xMV6eori0IWTpvgA==
X-Received: by 2002:a24:89:: with SMTP id 131mr157534ita.105.1549902311153;
        Mon, 11 Feb 2019 08:25:11 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id 70sm5372156ity.9.2019.02.11.08.25.10
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 08:25:10 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x1BGP9qw030003;
        Mon, 11 Feb 2019 16:25:09 GMT
Subject: [PATCH v1 17/23] SUNRPC: Remove xdr_buf_trim()
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 11 Feb 2019 11:25:09 -0500
Message-ID: <20190211162509.2817.29966.stgit@manet.1015granger.net>
In-Reply-To: <20190211161920.2817.20881.stgit@manet.1015granger.net>
References: <20190211161920.2817.20881.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The key action of xdr_buf_trim() is that it shortens buf->len, the
length of the xdr_buf's content. The other actions -- shortening the
head, pages, and tail components -- are actually not necessary. In
particular, changing the size of those components can corrupt the
RPC message contained in the buffer. This is an accident waiting to
happen rather than a current bug, as far as we know.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Acked-by: Bruce Fields <bfields@redhat.com>
---
 include/linux/sunrpc/xdr.h          |    1 -
 net/sunrpc/auth_gss/gss_krb5_wrap.c |    8 ++++---
 net/sunrpc/auth_gss/svcauth_gss.c   |    2 +-
 net/sunrpc/xdr.c                    |   41 -----------------------------------
 4 files changed, 6 insertions(+), 46 deletions(-)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index 65af6a2..9ee3970 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -179,7 +179,6 @@ static inline __be32 *xdr_encode_array(__be32 *p, const void *s, unsigned int le
 extern void xdr_shift_buf(struct xdr_buf *, size_t);
 extern void xdr_buf_from_iov(struct kvec *, struct xdr_buf *);
 extern int xdr_buf_subsegment(struct xdr_buf *, struct xdr_buf *, unsigned int, unsigned int);
-extern void xdr_buf_trim(struct xdr_buf *, unsigned int);
 extern int xdr_buf_read_netobj(struct xdr_buf *, struct xdr_netobj *, unsigned int);
 extern int read_bytes_from_xdr_buf(struct xdr_buf *, unsigned int, void *, unsigned int);
 extern int write_bytes_to_xdr_buf(struct xdr_buf *, unsigned int, void *, unsigned int);
diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index 5cdde6c..14a0aff 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -570,14 +570,16 @@ static void rotate_left(u32 base, struct xdr_buf *buf, unsigned int shift)
 	 */
 	movelen = min_t(unsigned int, buf->head[0].iov_len, buf->len);
 	movelen -= offset + GSS_KRB5_TOK_HDR_LEN + headskip;
-	BUG_ON(offset + GSS_KRB5_TOK_HDR_LEN + headskip + movelen >
-							buf->head[0].iov_len);
+	if (offset + GSS_KRB5_TOK_HDR_LEN + headskip + movelen >
+	    buf->head[0].iov_len)
+		return GSS_S_FAILURE;
 	memmove(ptr, ptr + GSS_KRB5_TOK_HDR_LEN + headskip, movelen);
 	buf->head[0].iov_len -= GSS_KRB5_TOK_HDR_LEN + headskip;
 	buf->len -= GSS_KRB5_TOK_HDR_LEN + headskip;
 
 	/* Trim off the trailing "extra count" and checksum blob */
-	xdr_buf_trim(buf, ec + GSS_KRB5_TOK_HDR_LEN + tailskip);
+	buf->len -= ec + GSS_KRB5_TOK_HDR_LEN + tailskip;
+
 	return GSS_S_COMPLETE;
 }
 
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 152790e..f1aabab 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -896,7 +896,7 @@ u32 svcauth_gss_flavor(struct auth_domain *dom)
 	if (svc_getnl(&buf->head[0]) != seq)
 		goto out;
 	/* trim off the mic and padding at the end before returning */
-	xdr_buf_trim(buf, round_up_to_quad(mic.len) + 4);
+	buf->len -= 4 + round_up_to_quad(mic.len);
 	stat = 0;
 out:
 	kfree(mic.data);
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 5f0aa53..4bce619 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -1139,47 +1139,6 @@ void xdr_enter_page(struct xdr_stream *xdr, unsigned int len)
 }
 EXPORT_SYMBOL_GPL(xdr_buf_subsegment);
 
-/**
- * xdr_buf_trim - lop at most "len" bytes off the end of "buf"
- * @buf: buf to be trimmed
- * @len: number of bytes to reduce "buf" by
- *
- * Trim an xdr_buf by the given number of bytes by fixing up the lengths. Note
- * that it's possible that we'll trim less than that amount if the xdr_buf is
- * too small, or if (for instance) it's all in the head and the parser has
- * already read too far into it.
- */
-void xdr_buf_trim(struct xdr_buf *buf, unsigned int len)
-{
-	size_t cur;
-	unsigned int trim = len;
-
-	if (buf->tail[0].iov_len) {
-		cur = min_t(size_t, buf->tail[0].iov_len, trim);
-		buf->tail[0].iov_len -= cur;
-		trim -= cur;
-		if (!trim)
-			goto fix_len;
-	}
-
-	if (buf->page_len) {
-		cur = min_t(unsigned int, buf->page_len, trim);
-		buf->page_len -= cur;
-		trim -= cur;
-		if (!trim)
-			goto fix_len;
-	}
-
-	if (buf->head[0].iov_len) {
-		cur = min_t(size_t, buf->head[0].iov_len, trim);
-		buf->head[0].iov_len -= cur;
-		trim -= cur;
-	}
-fix_len:
-	buf->len -= (len - trim);
-}
-EXPORT_SYMBOL_GPL(xdr_buf_trim);
-
 static void __read_bytes_from_xdr_buf(struct xdr_buf *subbuf, void *obj, unsigned int len)
 {
 	unsigned int this_len;

