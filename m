Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f173.google.com ([209.85.216.173]:50691 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754078Ab3JJR47 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Oct 2013 13:56:59 -0400
Received: by mail-qc0-f173.google.com with SMTP id l13so1458644qcy.4
        for <linux-nfs@vger.kernel.org>; Thu, 10 Oct 2013 10:56:58 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Andi Kleen <andi@firstfloor.org>,
        Trond.Myklebust@netapp.com, kwc@citi.umich.edu
Subject: [PATCH] sunrpc: trim off EC bytes in addition to the checksum blob when doing a GSSAPI v2 unwrap
Date: Thu, 10 Oct 2013 13:56:50 -0400
Message-Id: <1381427810-10633-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As Bruce points out in RFC 4121, section 4.2.3:

   "In Wrap tokens that provide for confidentiality, the first 16 octets
    of the Wrap token (the "header", as defined in section 4.2.6), SHALL
    be appended to the plaintext data before encryption.  Filler octets
    MAY be inserted between the plaintext data and the "header.""

...and...

   "In Wrap tokens with confidentiality, the EC field SHALL be used to
    encode the number of octets in the filler..."

It's possible for the client to stuff different data in that area on a
retransmission, which could make the checksum come out wrong in the DRC
code.

After decrypting the blob, we should trim off any extra count bytes in
addition to the checksum blob.

Reported-by: "J. Bruce Fields" <bfields@fieldses.org>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/auth_gss/gss_krb5_wrap.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index 1da52d1..ec1f4d0 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -574,8 +574,8 @@ gss_unwrap_kerberos_v2(struct krb5_ctx *kctx, int offset, struct xdr_buf *buf)
 	buf->head[0].iov_len -= GSS_KRB5_TOK_HDR_LEN + headskip;
 	buf->len -= GSS_KRB5_TOK_HDR_LEN + headskip;
 
-	/* Trim off the checksum blob */
-	xdr_buf_trim(buf, GSS_KRB5_TOK_HDR_LEN + tailskip);
+	/* Trim off the trailing "extra count" and checksum blob */
+	xdr_buf_trim(buf, ec + GSS_KRB5_TOK_HDR_LEN + tailskip);
 	return GSS_S_COMPLETE;
 }
 
-- 
1.8.3.1

