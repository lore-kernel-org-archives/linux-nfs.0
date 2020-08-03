Return-Path: <SRS0=ybPJ=BN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.8 required=3.0 tests=BAYES_00,
	DKIM_ADSP_CUSTOM_MED,DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8951C433E0
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Aug 2020 17:00:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 9931C20678
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Aug 2020 17:00:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cKl8Rk+4"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726802AbgHCRAU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 Aug 2020 13:00:20 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:56482 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728150AbgHCRAT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Aug 2020 13:00:19 -0400
Received: from mail-il1-x144.google.com (mail-il1-x144.google.com [IPv6:2607:f8b0:4864:20::144])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 5FD74C06174A
        for <linux-nfs@vger.kernel.org>; Mon,  3 Aug 2020 10:00:19 -0700 (PDT)
Received: by mail-il1-x144.google.com with SMTP id c16so19896756ils.8
        for <linux-nfs@vger.kernel.org>; Mon, 03 Aug 2020 10:00:19 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=TPVjLWkHWk0AYBeQ8gyCJuqxE5qMckHU/9X8Fc5Z/6Y=;
        b=cKl8Rk+4dkSa/OzwrYjhUWyzLCvQhwG/KXhdapsZJrIEzkm8LPCHZHOEzsmgDF5kr5
         hBBH1BRcRF4nSRnAA4Uy8hr6cPjqMW6AHRPLJWtKqDLW1+nO33Yber5CwVqSrAoBNECm
         gmD/xl4XmXp6IDvQ6AzHNXPt7CrYP3RzkA+AYMyiTSZsGm/+eyen4TB3Br2pSV4dWmh6
         Vsl7eY+AijcfOGQXf3vSrniO0rpQoxS+sm0BkkuxEr/R7Cmk1VALJpal+pQI0a3MoPxy
         CZ7uqWqmFZ7EVBG8S0nOhZdvMYNLpKEiek0OeQ/fY0dVDlTWY27bpqxChYBRLuhpS8F/
         MwrA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:from:to:cc:subject:date:message-id
         :in-reply-to:references:mime-version:content-transfer-encoding;
        bh=TPVjLWkHWk0AYBeQ8gyCJuqxE5qMckHU/9X8Fc5Z/6Y=;
        b=G4BvLdpkmLhXIsYZxw7/DThFgBb8Ixk0LKdUlNvVecrOSTC7wUXQp0V5yy68A3/Zih
         aX/vO9aVaSDO4CakQNEtMJJwKTJyp0TnfWilckbqNL+BB7pzl49cRJeRylF9VzL5DctD
         +7c0gg0M6/EafeOC96J1AeAsflDS+T58c2pV36Il0udefuK2FgFAqmvQMICMejlJg0QU
         e4pqnx19HFqP31kIq26HpikGZLJy22IBQuKYK6H74xH599vHcxE5M+Lvv2C1vN4P2EXq
         4QEHm2zDAL4XoEUvh4vzFAhjFOgo2OG8PzUlNKkBxLIldVuQNFSpj2xx+rep32XwORmP
         0Geg==
X-Gm-Message-State: AOAM533eq8hnzGwAVgf20DvA9nbrqr4kx1wBjyeIx2kxhTV/9FXEyTUH
        7z7VwKOH3mrWz7E/f4fxy7dCzlDn
X-Google-Smtp-Source: ABdhPJzZiKxHF7iDQLqNEgBolB987DI6ZK0g8Qsuffx+VX7ox9fyuTpzjUwnDMMZVp4h9Xzv+BwtHA==
X-Received: by 2002:a92:1f0f:: with SMTP id i15mr293027ile.237.1596474018494;
        Mon, 03 Aug 2020 10:00:18 -0700 (PDT)
Received: from gouda.nowheycreamery.com (c-68-32-74-190.hsd1.mi.comcast.net. [68.32.74.190])
        by smtp.gmail.com with ESMTPSA id a6sm10498040ioo.44.2020.08.03.10.00.17
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 03 Aug 2020 10:00:17 -0700 (PDT)
From:   schumaker.anna@gmail.com
X-Google-Original-From: Anna.Schumaker@Netapp.com
To:     linux-nfs@vger.kernel.org
Cc:     Anna.Schumaker@Netapp.com
Subject: [PATCH v3 03/10] NFS: Use xdr_page_pos() in NFSv4 decode_getacl()
Date:   Mon,  3 Aug 2020 13:00:06 -0400
Message-Id: <20200803170013.1348350-4-Anna.Schumaker@Netapp.com>
X-Mailer: git-send-email 2.27.0
In-Reply-To: <20200803170013.1348350-1-Anna.Schumaker@Netapp.com>
References: <20200803170013.1348350-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4xdr.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 47817ef0aadb..6742646d4feb 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -5279,7 +5279,6 @@ static int decode_getacl(struct xdr_stream *xdr, struct rpc_rqst *req,
 	uint32_t attrlen,
 		 bitmap[3] = {0};
 	int status;
-	unsigned int pg_offset;
 
 	res->acl_len = 0;
 	if ((status = decode_op_hdr(xdr, OP_GETATTR)) != 0)
@@ -5287,9 +5286,6 @@ static int decode_getacl(struct xdr_stream *xdr, struct rpc_rqst *req,
 
 	xdr_enter_page(xdr, xdr->buf->page_len);
 
-	/* Calculate the offset of the page data */
-	pg_offset = xdr->buf->head[0].iov_len;
-
 	if ((status = decode_attr_bitmap(xdr, bitmap)) != 0)
 		goto out;
 	if ((status = decode_attr_length(xdr, &attrlen, &savep)) != 0)
@@ -5302,7 +5298,7 @@ static int decode_getacl(struct xdr_stream *xdr, struct rpc_rqst *req,
 		/* The bitmap (xdr len + bitmaps) and the attr xdr len words
 		 * are stored with the acl data to handle the problem of
 		 * variable length bitmaps.*/
-		res->acl_data_offset = xdr_stream_pos(xdr) - pg_offset;
+		res->acl_data_offset = xdr_page_pos(xdr);
 		res->acl_len = attrlen;
 
 		/* Check for receive buffer overflow */
-- 
2.27.0

