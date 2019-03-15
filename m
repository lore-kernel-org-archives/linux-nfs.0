Return-Path: <SRS0=RY80=RS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32425C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 17:52:54 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EF888218A1
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 17:52:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Zp7e1oKy"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726435AbfCORwx (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Mar 2019 13:52:53 -0400
Received: from mail-it1-f195.google.com ([209.85.166.195]:36111 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726218AbfCORww (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Mar 2019 13:52:52 -0400
Received: by mail-it1-f195.google.com with SMTP id h9so12215219itl.1
        for <linux-nfs@vger.kernel.org>; Fri, 15 Mar 2019 10:52:52 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=CV+jgYjyC+jl2oQOZ8LyJFNlQ4TVrbZtGa5+Xopy62g=;
        b=Zp7e1oKyz5mufVcXrOUAcOofauFJdEPNv5Wmu1MmaJW4xXCTvsAXqSLmT/vQdA9omK
         aqhW/mTT6N6oTGY28vDc3dfYx456fuvlgv2xu8aGeYv4rLX5bu1WjQFuTotdWQG4AAxv
         Jogxb7Bc6izf6KwdRAJz4UnN4oTJXjwgt7O/nk4iRFA9wl0onkbudx4ON7CIOk4A6zp1
         me+IK3jqKw2bn7rw2POLUCWPVFmmJja1zdCOLznU1zuWPBInryhSUddRyemNJpZej9Kh
         YwMENJgrJFnFfvDBuLulI+bK0UX8wdm+b+BG0bY44NuuJi/XpaokjqFk9efkxx+tzX7X
         T5NQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=CV+jgYjyC+jl2oQOZ8LyJFNlQ4TVrbZtGa5+Xopy62g=;
        b=kjMocE5uc9e6s8KpFutNtM5eMl+HWH2+vsRS0YdU5deVg7IAHcd58UxUG87ilBP/Cj
         RawUHi5wTkXdo/lEaVn8N4TEqiUeb8sg28EaxU1ERwTlqaC0moJnuTQTwSnCUquNW9uA
         pPc5qV9EpzM35Ziyx2Tg1ZQLZZNaHRtLseGUTe6h+fRMDPlUkx8SprI0ifPOoUDPUDGa
         sap+/5okRB6kLzSL4Jplr0f8n5SY26W1GK2RmtmcVv/FQeiTvDEN/54lYb6EK1fqvIxh
         /cLt1x7ht/1sQu7Pe4MN1A0qSmkQ2j+ONGpeJJgnQSaeP/TgwYFArHmar3t8xlHrEyv+
         5h8g==
X-Gm-Message-State: APjAAAUq0jI7UiwcImYe1fANefBTWFuDePvxF0YJeepCjuw6TPyugzZp
        PQOWGJQn1XpkN7T6zvKqhKPu1as=
X-Google-Smtp-Source: APXvYqxbzck9mdocczrlmBjgsllIxousn6zTweF7xtcDNF8Ox8CE+Q0M4O79AyrtboddzL+X1z+VvQ==
X-Received: by 2002:a24:e00e:: with SMTP id c14mr2822981ith.8.1552672371548;
        Fri, 15 Mar 2019 10:52:51 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id r2sm1138415itk.5.2019.03.15.10.52.50
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 15 Mar 2019 10:52:50 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 1/6] SUNRPC: Fix a client regression when handling oversized replies
Date:   Fri, 15 Mar 2019 13:51:36 -0400
Message-Id: <20190315175141.68792-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If the server sends a reply that is larger than the pre-allocated
buffer, then the current code may fail to register how much of
the stream that it has finished reading. This again can lead to
hangs.

Fixes: e92053a52e68 ("SUNRPC: Handle zero length fragments correctly")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/xprtsock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 42f45d33dc56..9359539907ba 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -453,7 +453,7 @@ xs_read_xdr_buf(struct socket *sock, struct msghdr *msg, int flags,
 			goto out;
 		if (ret != want)
 			goto out;
-	} else
+	} else if (offset < seek_init)
 		offset = seek_init;
 	ret = -EMSGSIZE;
 out:
-- 
2.20.1

