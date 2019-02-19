Return-Path: <SRS0=cCtV=Q2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C05CEC43381
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 16:23:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8AD8E2147A
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 16:23:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="tvN2P5+r"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725991AbfBSQXL (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 11:23:11 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:37730 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726342AbfBSQXL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Feb 2019 11:23:11 -0500
Received: by mail-it1-f196.google.com with SMTP id z124so7593444itc.2
        for <linux-nfs@vger.kernel.org>; Tue, 19 Feb 2019 08:23:11 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=oIzVSIi6+b8+6GYlIs63aoI4uIzn/vPHe/BBtI19YpU=;
        b=tvN2P5+r+TaB5Jsjd82FmmJG7ctRQdQZQVnavRCmJkRl9UYNuHYD72fz32Y6rElPwW
         uATVp/KlFCEpgByzevgOFLE0ZOasfecYnaeGU2tyuhkkmIyOPBw7gEFi4wZ6Cim+PzsR
         zy9awrl6yIuVG1DHuU8eJaYLGgnys4ovew0siqEv20t2ECut4yPfjYcv0lXx7Gy5KAkP
         CKX8VK83xZoFTAatzy0bKJbUEDP7l27qWuXomzQULTcakuD2LvmXOAlBe7lbJuRiFBrm
         1PP/WUGAnGwkPCCoB4XT42vgqruP/ZIni0PX+SSqYHKh/W9bK5wAPSOQAUsp9AtEpNiB
         P7OQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=oIzVSIi6+b8+6GYlIs63aoI4uIzn/vPHe/BBtI19YpU=;
        b=Qnx/gELEdMZPAS0k89DsOZRtpr9gk5lxS0IZCGQZzkdoJHH5ZCzE/g3ZCv3wKVsWer
         H0slSj922R3nfkIMqAG3TPUj5oP7PRFWFhvw/ltid0d7c4fTPjf4q8Um4Teov+9PsJjX
         xmz9erjYB5HglvJo+FCdWg0fQzQVztAR7XEBeCdMmxFFpS6CH78U+rkVVJhaWB8FCO61
         4/W3T1PCNAEOvWTtZErlC0+M1yc1w71SrXdchzrK2N5LjUSuDsOOY7Z2ffvtsp9A1tID
         uIMkfGLzYBHgdNd1uw/QB8k6zIxS2vPRYVxhrAI8jz3q3WpOi1Zpw0tYZ/N2c75kIl9j
         ERpA==
X-Gm-Message-State: AHQUAuZPB4AikhVnfVnDD3SxIob/wiu3m7o27EauFmaJB++tkuxn64hx
        IdONWB4Ml6yNigT2BWx49mYatKc=
X-Google-Smtp-Source: AHgI3IZMUm45Pv1Zf8XzLkWvyfxQMDuBBnbdXrsNicDNDL5A8dktWMN3/DCHgdgElUpaZ8Mf8lWHsQ==
X-Received: by 2002:a6b:dc01:: with SMTP id s1mr17211417ioc.253.1550593390512;
        Tue, 19 Feb 2019 08:23:10 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id o9sm882683itb.23.2019.02.19.08.23.09
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 08:23:09 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] SUNRPC: Don't suppress socket errors when a message read completes
Date:   Tue, 19 Feb 2019 11:22:00 -0500
Message-Id: <20190219162202.68013-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If the message read completes, but the socket returned an error
condition, we should ensure to propagate that error.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/xprtsock.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index d663f75a6536..52c98dc480ec 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -498,11 +498,9 @@ xs_read_stream_request(struct sock_xprt *transport, struct msghdr *msg,
 			&read);
 	transport->recv.offset += read;
 	transport->recv.copied += read;
-	if (transport->recv.offset == transport->recv.len) {
-		if (xs_read_stream_request_done(transport))
-			msg->msg_flags |= MSG_EOR;
-		return read;
-	}
+	if (transport->recv.offset == transport->recv.len &&
+	    xs_read_stream_request_done(transport))
+		msg->msg_flags |= MSG_EOR;
 
 	switch (ret) {
 	default:
-- 
2.20.1

