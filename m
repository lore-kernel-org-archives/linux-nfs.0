Return-Path: <SRS0=ibFv=Q5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 428C9C4360F
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 21:59:27 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 05DBE2075C
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 21:59:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WuOebTDU"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726080AbfBVV70 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Feb 2019 16:59:26 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:51264 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726116AbfBVV70 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Feb 2019 16:59:26 -0500
Received: by mail-it1-f196.google.com with SMTP id e24so5198146itl.1
        for <linux-nfs@vger.kernel.org>; Fri, 22 Feb 2019 13:59:25 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=qMztH1Z/ISVDK8syfUI8w3o74RPBKZoQXBT47BWAYBc=;
        b=WuOebTDUVX9yD9O1W/+YAA3JItxtDt2GIJwIoOqf6mvr+ddfpEaWf9j0LjLvbu8/uh
         kAa8UVJxPMV0yE3MMaFjFmrwOir3cKV30dxwvKZKwBgCBXB5YEt7KCuE+NNSGd2/W4NV
         c9V/H2C4lJ2XOD5MraS6iBRvLYc3vlxFrrGV+YOl6asGwz8rNrl45HBV9mmdQN2CTOEq
         Q/vKLAk4UKkX9XkMgtANlYzEmKiVigsXFgdp2xHT8q147WcI1deIGReMgns/O0Zp4nUx
         bJtfJ/Yoq+qJkSAMu0rzRgxK0GVf4x6hhg/Xd2xubF1sU/3melVQWAqrVMru7up05jAJ
         ivug==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:from:to:cc:subject:date:message-id
         :in-reply-to:references:mime-version:content-transfer-encoding;
        bh=qMztH1Z/ISVDK8syfUI8w3o74RPBKZoQXBT47BWAYBc=;
        b=ewxtTFonBywcMzhAGVeUU+ZygCbucYs9b7j5eHRIC3sZ0PiSRnttq1JwRPja1MQsWD
         ATVsf4Bb+cF92xr7vjW431RhKsoW3PhueuWNlFdnFwWTMiF+uGBad+M+sxvHcQqot5KE
         5RCBfBR/qH/51xakDeEM2Ry7mfiMLhKS7VVwZzA8VV6l7Eg2MtGQ3KnlzBR3+zK+t3BR
         k87KTtKXRBX8PHJ/9K1+oVK8PtgwTm5GOJ1zOPJHnMmfKC0qLaSGHkxzMIryNFnC7Ij5
         cs/UPiNfEU6WWHYeYSvo9C8NWOkhpHKlNpQFUjqUO2sy4oY3pdAodiPD0nGBZItO9hsb
         OCWA==
X-Gm-Message-State: AHQUAuZUbn7h9noq60a/++mKTWGFc+DzhzmONOvG+n3AKuev5S6mp7qw
        z9c4/i0FZEXaxDu2GkQ5CsU=
X-Google-Smtp-Source: AHgI3IZHjaVU855kwvV1orSGvKNIvSDIRco53cbiPzmNd4IIxrirxFRVxYj6ZcItF0TTX4rPZMDiqA==
X-Received: by 2002:a24:57cf:: with SMTP id u198mr3518276ita.160.1550872765159;
        Fri, 22 Feb 2019 13:59:25 -0800 (PST)
Received: from gouda.nowheycreamery.com.nowheycreamery.com (d28-23-121-75.dim.wideopenwest.com. [23.28.75.121])
        by smtp.gmail.com with ESMTPSA id f13sm998171iol.82.2019.02.22.13.59.24
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 13:59:24 -0800 (PST)
From:   schumaker.anna@gmail.com
X-Google-Original-From: Anna.Schumaker@Netapp.com
To:     Trond.Myklebust@hammerspace.com, linux-nfs@vger.kernel.org
Cc:     Anna.Schumaker@Netapp.com
Subject: [PATCH 5/6] NFS: Add support for decoding multiple segments
Date:   Fri, 22 Feb 2019 16:59:17 -0500
Message-Id: <20190222215918.20647-6-Anna.Schumaker@Netapp.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190222215918.20647-1-Anna.Schumaker@Netapp.com>
References: <20190222215918.20647-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

We now have everything we need to read holes and then shift data to
where it's supposed to be.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs42xdr.c | 36 ++++++++++++++++++++----------------
 1 file changed, 20 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
index 57ec9c0fc00a..2b8b3a2524c4 100644
--- a/fs/nfs/nfs42xdr.c
+++ b/fs/nfs/nfs42xdr.c
@@ -523,11 +523,11 @@ static int decode_read_plus_data(struct xdr_stream *xdr, struct nfs_pgio_res *re
 	p = xdr_decode_hyper(p, &offset);
 	count = be32_to_cpup(p);
 
-	recvd = xdr_read_pages(xdr, count);
+	recvd = xdr_align_data(xdr, res->count, count);
 	if (recvd < count)
 		res->eof = 0;
 
-	res->count = recvd;
+	res->count += recvd;
 	return 0;
 out_overflow:
 	print_overflow_msg(__func__, xdr);
@@ -547,11 +547,11 @@ static int decode_read_plus_hole(struct xdr_stream *xdr, struct nfs_pgio_res *re
 	p = xdr_decode_hyper(p, &offset);
 	p = xdr_decode_hyper(p, &length);
 
-	recvd = xdr_expand_hole(xdr, 0, length);
+	recvd = xdr_expand_hole(xdr, res->count, length);
 	if (recvd < length)
 		res->eof = 0;
 
-	res->count = recvd;
+	res->count += recvd;
 	return 0;
 out_overflow:
 	print_overflow_msg(__func__, xdr);
@@ -562,7 +562,7 @@ static int decode_read_plus(struct xdr_stream *xdr, struct nfs_pgio_res *res)
 {
 	__be32 *p;
 	int status, type;
-	uint32_t segments;
+	uint32_t i, segments;
 
 	status = decode_op_hdr(xdr, OP_READ_PLUS);
 	if (status)
@@ -575,20 +575,24 @@ static int decode_read_plus(struct xdr_stream *xdr, struct nfs_pgio_res *res)
 	res->count = 0;
 	res->eof = be32_to_cpup(p++);
 	segments = be32_to_cpup(p++);
-	if (segments == 0)
-		return 0;
 
-	p = xdr_inline_decode(xdr, 4);
-	if (unlikely(!p))
-		goto out_overflow;
+	for (i = 0; i < segments; i++) {
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(!p))
+			goto out_overflow;
 
-	type = be32_to_cpup(p++);
-	if (type == NFS4_CONTENT_DATA)
-		status = decode_read_plus_data(xdr, res);
-	else
-		status = decode_read_plus_hole(xdr, res);
+		type = be32_to_cpup(p);
+		if (type == NFS4_CONTENT_DATA)
+			status = decode_read_plus_data(xdr, res);
+		else
+			status = decode_read_plus_hole(xdr, res);
+		if (status)
+			break;
+		if (res->count == xdr->buf->page_len)
+			break;
+	}
 
-	if (segments > 1)
+	if (i < segments)
 		res->eof = 0;
 	return status;
 out_overflow:
-- 
2.20.1

