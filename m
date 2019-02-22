Return-Path: <SRS0=ibFv=Q5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2DEBAC10F00
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 21:58:57 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DE49620675
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 21:58:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="DlltUKV5"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725911AbfBVV64 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Feb 2019 16:58:56 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:35626 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725859AbfBVV6z (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Feb 2019 16:58:55 -0500
Received: by mail-it1-f196.google.com with SMTP id v72so5489123itc.0
        for <linux-nfs@vger.kernel.org>; Fri, 22 Feb 2019 13:58:54 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=qV3H6/nt5cBtzHk8iz/yqH4FKIxUdlc/uQOn6PZUrg0=;
        b=DlltUKV5gaR8UiuaGGfH31C6ZK3t68nhEEOSKjCspsjYnGaQB3zYojtrtnwL5xcsj/
         m7VeGsDAaE7CgBxJ86h8blYDULmuJ5bhAbpQroqki38odDjFZFs97KXBCTlOGwc1zma4
         2zARQ2yhWjRsTutVP5epZx7go/Dv8lm/IjTsVPdtqpmRhPcIfqK2EFxKTlWlh14FWwHl
         5OoKvzVJ5+OkQqJvrX0NgQqU/X8ypIr2tPHnAyX6pP1oqPTMMf1JDv5CAz3IIRSYakDv
         rf89rUvH6JhyizJbNBvSB/sI8HnljipuqjYwn8mquy06/XQsAobzpMIVBYv/mBdApLKh
         NawA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:from:to:cc:subject:date:message-id
         :in-reply-to:references:mime-version:content-transfer-encoding;
        bh=qV3H6/nt5cBtzHk8iz/yqH4FKIxUdlc/uQOn6PZUrg0=;
        b=X6HJLO+B1ruQwzR4+3ILQC9TGhDl+GfEC8uzd1JPQVNsKtccv6D3V1OqsLO4UVhFEg
         oCu4vUAP5tuBT3g1YLd2/mATij3IMNtD/9gjJnzz5ovBh3GAQlaXJ4O9xtAcGTSlLdOR
         29gFxvvIcbIkM6/xKE5rX03WNl5ulzey8QG+o6hS5Oni8eAiZ7nsz6KSzTfL2fwWtCOJ
         g/9Oz+hLKbaHSaGnihrgF/RaFZOZspt+splriLHSuJQLqaJP0cXYz3fX2ZyI6co3KyXh
         ILKYv1rejM0vulvz80o6f/tQ43ZNK8hOaXrrY3KuOV6MBmVA+pns+B+lHN9oZA8l308S
         EYRA==
X-Gm-Message-State: AHQUAuaEJKvcLst8HZp9Ak+38nP0io80LR+YxbejZRGeUHNlsmq8NfXP
        fp+ewVEKOIDzJoRI7NLy6ZR8bEZg/x8=
X-Google-Smtp-Source: AHgI3Ibl4UxYctVNvxux7Dt6bE9fQyGrFBMACHakjfbxMeXOmtZSFAnURK0UMJ2hURWdB9kxMfGNLg==
X-Received: by 2002:a24:5647:: with SMTP id o68mr3695474itb.151.1550872734419;
        Fri, 22 Feb 2019 13:58:54 -0800 (PST)
Received: from gouda.nowheycreamery.com.nowheycreamery.com (d28-23-121-75.dim.wideopenwest.com. [23.28.75.121])
        by smtp.gmail.com with ESMTPSA id t74sm1532459itt.29.2019.02.22.13.58.53
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 13:58:53 -0800 (PST)
From:   Anna Schumaker <schumaker.anna@gmail.com>
X-Google-Original-From: Anna Schumaker <Anna.Schumaker@Netapp.com>
To:     bfields@fieldses.org
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFSD: nfsd4_encode_read{v}() should encode eof and maxcount
Date:   Fri, 22 Feb 2019 16:58:49 -0500
Message-Id: <20190222215850.20508-2-Anna.Schumaker@Netapp.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190222215850.20508-1-Anna.Schumaker@Netapp.com>
References: <20190222215850.20508-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

I intend to reuse nfsd4_encode_readv() for READ_PLUS, so I need an
alternate way to encode these values.  I think it makes sense for
nfsd4_encode_read() to handle this in a single place for both splice and
readv paths.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfsd/nfs4xdr.c | 67 ++++++++++++++++++-----------------------------
 1 file changed, 26 insertions(+), 41 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 3de42a729093..bb487e5c022c 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3453,24 +3453,19 @@ nfsd4_encode_open_downgrade(struct nfsd4_compoundres *resp, __be32 nfserr, struc
 static __be32 nfsd4_encode_splice_read(
 				struct nfsd4_compoundres *resp,
 				struct nfsd4_read *read,
-				struct file *file, unsigned long maxcount)
+				struct file *file, unsigned long *maxcount)
 {
 	struct xdr_stream *xdr = &resp->xdr;
 	struct xdr_buf *buf = xdr->buf;
-	u32 eof;
-	long len;
 	int space_left;
 	__be32 nfserr;
-	__be32 *p = xdr->p - 2;
 
 	/* Make sure there will be room for padding if needed */
 	if (xdr->end - xdr->p < 1)
 		return nfserr_resource;
 
-	len = maxcount;
 	nfserr = nfsd_splice_read(read->rd_rqstp, read->rd_fhp,
-				  file, read->rd_offset, &maxcount);
-	read->rd_length = maxcount;
+				  file, read->rd_offset, maxcount);
 	if (nfserr) {
 		/*
 		 * nfsd_splice_actor may have already messed with the
@@ -3481,27 +3476,21 @@ static __be32 nfsd4_encode_splice_read(
 		return nfserr;
 	}
 
-	eof = nfsd_eof_on_read(len, maxcount, read->rd_offset,
-				d_inode(read->rd_fhp->fh_dentry)->i_size);
-
-	*(p++) = htonl(eof);
-	*(p++) = htonl(maxcount);
-
-	buf->page_len = maxcount;
-	buf->len += maxcount;
-	xdr->page_ptr += (buf->page_base + maxcount + PAGE_SIZE - 1)
+	buf->page_len = *maxcount;
+	buf->len += *maxcount;
+	xdr->page_ptr += (buf->page_base + *maxcount + PAGE_SIZE - 1)
 							/ PAGE_SIZE;
 
 	/* Use rest of head for padding and remaining ops: */
 	buf->tail[0].iov_base = xdr->p;
 	buf->tail[0].iov_len = 0;
 	xdr->iov = buf->tail;
-	if (maxcount&3) {
-		int pad = 4 - (maxcount&3);
+	if (*maxcount&3) {
+		int pad = 4 - (*maxcount&3);
 
 		*(xdr->p++) = 0;
 
-		buf->tail[0].iov_base += maxcount&3;
+		buf->tail[0].iov_base += *maxcount&3;
 		buf->tail[0].iov_len = pad;
 		buf->len += pad;
 	}
@@ -3516,21 +3505,19 @@ static __be32 nfsd4_encode_splice_read(
 
 static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
 				 struct nfsd4_read *read,
-				 struct file *file, unsigned long maxcount)
+				 struct file *file, unsigned long *maxcount)
 {
 	struct xdr_stream *xdr = &resp->xdr;
-	u32 eof;
 	int v;
-	int starting_len = xdr->buf->len - 8;
+	int starting_len = xdr->buf->len;
 	long len;
 	int thislen;
 	__be32 nfserr;
-	__be32 tmp;
 	__be32 *p;
 	u32 zzz = 0;
 	int pad;
 
-	len = maxcount;
+	len = *maxcount;
 	v = 0;
 
 	thislen = min_t(long, len, ((void *)xdr->end - (void *)xdr->p));
@@ -3552,25 +3539,14 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
 	}
 	read->rd_vlen = v;
 
-	len = maxcount;
 	nfserr = nfsd_readv(resp->rqstp, read->rd_fhp, file, read->rd_offset,
-			    resp->rqstp->rq_vec, read->rd_vlen, &maxcount);
-	read->rd_length = maxcount;
+			    resp->rqstp->rq_vec, read->rd_vlen, maxcount);
 	if (nfserr)
 		return nfserr;
-	xdr_truncate_encode(xdr, starting_len + 8 + ((maxcount+3)&~3));
-
-	eof = nfsd_eof_on_read(len, maxcount, read->rd_offset,
-				d_inode(read->rd_fhp->fh_dentry)->i_size);
+	xdr_truncate_encode(xdr, starting_len + ((*maxcount+3)&~3));
 
-	tmp = htonl(eof);
-	write_bytes_to_xdr_buf(xdr->buf, starting_len    , &tmp, 4);
-	tmp = htonl(maxcount);
-	write_bytes_to_xdr_buf(xdr->buf, starting_len + 4, &tmp, 4);
-
-	pad = (maxcount&3) ? 4 - (maxcount&3) : 0;
-	write_bytes_to_xdr_buf(xdr->buf, starting_len + 8 + maxcount,
-								&zzz, pad);
+	pad = (*maxcount&3) ? 4 - (*maxcount&3) : 0;
+	write_bytes_to_xdr_buf(xdr->buf, starting_len + *maxcount, &zzz, pad);
 	return 0;
 
 }
@@ -3585,6 +3561,8 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 	int starting_len = xdr->buf->len;
 	struct raparms *ra = NULL;
 	__be32 *p;
+	long len;
+	u32 eof;
 
 	p = xdr_reserve_space(xdr, 8); /* eof flag and byte count */
 	if (!p) {
@@ -3602,15 +3580,22 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 	maxcount = min_t(unsigned long, maxcount,
 			 (xdr->buf->buflen - xdr->buf->len));
 	maxcount = min_t(unsigned long, maxcount, read->rd_length);
+	len = maxcount;
 
 	if (read->rd_tmp_file)
 		ra = nfsd_init_raparms(file);
 
 	if (file->f_op->splice_read &&
 	    test_bit(RQ_SPLICE_OK, &resp->rqstp->rq_flags))
-		nfserr = nfsd4_encode_splice_read(resp, read, file, maxcount);
+		nfserr = nfsd4_encode_splice_read(resp, read, file, &maxcount);
 	else
-		nfserr = nfsd4_encode_readv(resp, read, file, maxcount);
+		nfserr = nfsd4_encode_readv(resp, read, file, &maxcount);
+
+	read->rd_length = maxcount;
+	eof = nfsd_eof_on_read(len, maxcount, read->rd_offset,
+			       d_inode(read->rd_fhp->fh_dentry)->i_size);
+	*p++ = cpu_to_be32(eof);
+	*p++ = cpu_to_be32(maxcount);
 
 	if (ra)
 		nfsd_put_raparams(file, ra);
-- 
2.20.1

