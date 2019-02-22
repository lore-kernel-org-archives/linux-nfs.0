Return-Path: <SRS0=ibFv=Q5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,UNWANTED_LANGUAGE_BODY,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4CCBC10F00
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 21:59:22 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B022A20675
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 21:59:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="BiF2D6Sa"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725980AbfBVV7W (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Feb 2019 16:59:22 -0500
Received: from mail-it1-f195.google.com ([209.85.166.195]:37587 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725811AbfBVV7W (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Feb 2019 16:59:22 -0500
Received: by mail-it1-f195.google.com with SMTP id z124so5473617itc.2
        for <linux-nfs@vger.kernel.org>; Fri, 22 Feb 2019 13:59:21 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=j9tlMpBtp9gDs6lVOYg/yJOuvnSiUE8uqzXngwi0XZ4=;
        b=BiF2D6Sauk6Yn1ZiOaGCqrUcGfdUd0XfRpcMVCuVhSWcCiKeh5mag2zh1O7TjpOmY1
         3sM3m8HeSsSVHIT9xBbQ4fz4mgjQRk/xzVU4g1SHES+5cFinoaWon4zDead2j3sAOI+c
         0yRtGwvPgA3EyWNYlRzWSmYT75mS5VC2s8XirJQoJgnZPvtfW1Ig0bDXNy6jELSrxtXS
         vPEY6CvqM0XQK04tdfvh/Cfn1Eog40laIQeNxB8+9QEW+3/2LWImAekMzdb8fyBma1nw
         WfeiSfx/ESa5+Y9dVh8JvXc7IH4kJuqq51wP9eXDq6igVQBTh2aJGOGlKM5felk/mfgN
         AeBg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:from:to:cc:subject:date:message-id
         :in-reply-to:references:mime-version:content-transfer-encoding;
        bh=j9tlMpBtp9gDs6lVOYg/yJOuvnSiUE8uqzXngwi0XZ4=;
        b=BcldYSz0hDCVRyGG35pq1XPRWGkpx54VzhPjMGW3Mds0wQQLd8MRp05b3NlR7t2pii
         GWQkt6DDZN9kRTxa7b7dbuOA6+6lmLbHjfDHqLAOLlbnelzSUdzwh46wOz+8fjw9/om7
         8V/rkhKFwBp+4iPy0n6Aur/oSwdCtJvScNwJ0icRLQ6M1gOneCI9Fe6XTsfwSqpp1VqT
         qNv8mpyePDM0sUCm+UHkMtMkiewZQYRLSC2yF/to3+lMalS/n278dienuUVDp0RgrGcA
         2AAq1mso8Q2J2z4tlg+o1wQiSwB3FZwg1rSUKhzGSd1r9Q+t/3oWXrcCEUL8FbsKlg0Q
         dSfA==
X-Gm-Message-State: AHQUAuY372ooleyKkCgoswwQNh2gcUKlpETbW9NRqkzi73wYcHGXQq8+
        of/ffe00uFquimmCWl76pZr02MIYfx4=
X-Google-Smtp-Source: AHgI3IbH8x9i+KBqUS3lVkBTuVJ/YzWa8UV0tboCpNkZz8l9ImnVapHNjJPwFtHlWhmMaDVEHXZbcQ==
X-Received: by 2002:a24:2b4c:: with SMTP id h73mr3897888ita.159.1550872760990;
        Fri, 22 Feb 2019 13:59:20 -0800 (PST)
Received: from gouda.nowheycreamery.com.nowheycreamery.com (d28-23-121-75.dim.wideopenwest.com. [23.28.75.121])
        by smtp.gmail.com with ESMTPSA id f13sm998171iol.82.2019.02.22.13.59.19
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 13:59:19 -0800 (PST)
From:   schumaker.anna@gmail.com
X-Google-Original-From: Anna.Schumaker@Netapp.com
To:     Trond.Myklebust@hammerspace.com, linux-nfs@vger.kernel.org
Cc:     Anna.Schumaker@Netapp.com
Subject: [PATCH 1/6] SUNRPC: Split out a function for setting current page
Date:   Fri, 22 Feb 2019 16:59:13 -0500
Message-Id: <20190222215918.20647-2-Anna.Schumaker@Netapp.com>
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

I'm going to need this bit of code in a few places for READ_PLUS
decoding, so let's make it a helper function.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 net/sunrpc/xdr.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index f302c6eb8779..0fb9bbd2f3c7 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -792,6 +792,12 @@ static int xdr_set_page_base(struct xdr_stream *xdr,
 	return 0;
 }
 
+static void xdr_set_page(struct xdr_stream *xdr, unsigned int base)
+{
+	if (xdr_set_page_base(xdr, base, PAGE_SIZE) < 0)
+		xdr_set_iov(xdr, xdr->buf->tail, xdr->nwords << 2);
+}
+
 static void xdr_set_next_page(struct xdr_stream *xdr)
 {
 	unsigned int newbase;
@@ -799,8 +805,7 @@ static void xdr_set_next_page(struct xdr_stream *xdr)
 	newbase = (1 + xdr->page_ptr - xdr->buf->pages) << PAGE_SHIFT;
 	newbase -= xdr->buf->page_base;
 
-	if (xdr_set_page_base(xdr, newbase, PAGE_SIZE) < 0)
-		xdr_set_iov(xdr, xdr->buf->tail, xdr->nwords << 2);
+	xdr_set_page(xdr, newbase);
 }
 
 static bool xdr_set_next_buffer(struct xdr_stream *xdr)
-- 
2.20.1

