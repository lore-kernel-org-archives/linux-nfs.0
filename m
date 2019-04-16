Return-Path: <SRS0=Vlol=SS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91B80C10F13
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 13:37:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6089A217F9
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 13:37:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WuFzLuOC"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727240AbfDPNhD (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 16 Apr 2019 09:37:03 -0400
Received: from mail-it1-f195.google.com ([209.85.166.195]:36120 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726576AbfDPNhD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Apr 2019 09:37:03 -0400
Received: by mail-it1-f195.google.com with SMTP id y10so32503792itc.1;
        Tue, 16 Apr 2019 06:37:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=JKd9iNK2TVT0ttMrh4M0Vr+V0PaJkHGg3Qk02sk8z34=;
        b=WuFzLuOCK18LBVsNkP/3qGGuTUDeT/zlnxjSag1Q+kC4HJ2e3K6lk+XZue9POgwXhU
         I4wA8kGN02oRUWI1sRYheHPAmZMZafCe/1481iQhR3R2f43PfQ+MAIQtQCwZzslXE0Xy
         f9dxEvw1BLwjzlTG656V8udgbBV4fP4h7r4GiopuFDK2Quzj8ymvPPlQEdinWiIP+IJK
         WcmV/q6b/1J/iS84+W/TUwQeAjhL6I3nB6ZmNyg7jf6kLK4F9bqLAzGxigoI62Ta2SEL
         fA4i+Crdy+vaBbb9vXcPlIG84js4SS3Pc/AhktoQ9q0Xy+PgyczJhaRrB+1AUQmirs1H
         0Wmg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=JKd9iNK2TVT0ttMrh4M0Vr+V0PaJkHGg3Qk02sk8z34=;
        b=OkGLS8+7eRkAo9YnYOgUyDbKsnYUQ85VnVrAff9iA+ER3tr/kO67zmqrhtxFHnSomf
         WjJeAmJ6FTRZVFA68EbsfvDrdACtU0cPQO5xTcTKrOuj6qZTJXOhdj8ieD2T+yFNW3t1
         x7sxHFeFdad6V33EcKihazyeInZD2KGApAguWsJ+1CmsyF6t3K0s4hCOhwfFTp0QiycJ
         SBogkNWpRZB4oXGNTHeHvmRk0K9ygYFVp8nqzN/lpiYNYR4iBqmVrpx5/5Aos7M7f1jD
         Lq14tm9K02hPSsuBwZGIguLUVeDVGuIFKQ4UUXXn3gi/zXQ9lDibbnLBvps030cjBAgZ
         kVIg==
X-Gm-Message-State: APjAAAW6KIUSWMIkOETnNwU/znVQwfWZi/fsrXRW8Ns2I7EfKgvtKM1b
        WTFVJUkWVFiRa0U+Gagkq8Ytn3H1
X-Google-Smtp-Source: APXvYqzm1IvnaCvlYFCClNHdOtQjyP1UOjRdIoL1U2vAu036qG+lEGH4kDqrqxMoklLoeM/PMSasDg==
X-Received: by 2002:a02:b008:: with SMTP id p8mr57136378jah.90.1555421822758;
        Tue, 16 Apr 2019 06:37:02 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id 79sm9566792itw.18.2019.04.16.06.37.02
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 06:37:02 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3GDb1Sq021202;
        Tue, 16 Apr 2019 13:37:01 GMT
Subject: [PATCH v2 02/21] xprtrdma: Fix an frwr_map recovery nit
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Tue, 16 Apr 2019 09:37:01 -0400
Message-ID: <20190416133701.23113.93135.stgit@manet.1015granger.net>
In-Reply-To: <20190416133156.23113.91846.stgit@manet.1015granger.net>
References: <20190416133156.23113.91846.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

After a DMA map failure in frwr_map, mark the MR so that recycling
won't attempt to DMA unmap it.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Fixes: e2f34e26710b ("xprtrdma: Yet another double DMA-unmap")
---
 net/sunrpc/xprtrdma/frwr_ops.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 52cb6c1..a2a2e01 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -466,7 +466,7 @@ struct rpcrdma_mr_seg *frwr_map(struct rpcrdma_xprt *r_xprt,
 	return seg;
 
 out_dmamap_err:
-	frwr->fr_state = FRWR_IS_INVALID;
+	mr->mr_dir = DMA_NONE;
 	trace_xprtrdma_frwr_sgerr(mr, i);
 	rpcrdma_mr_put(mr);
 	return ERR_PTR(-EIO);

