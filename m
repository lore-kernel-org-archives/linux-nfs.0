Return-Path: <SRS0=RY80=RS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6DB0AC43381
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 17:52:55 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4157F218A1
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 17:52:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="h7O+/mGy"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726489AbfCORwy (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Mar 2019 13:52:54 -0400
Received: from mail-it1-f195.google.com ([209.85.166.195]:40432 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726218AbfCORwy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Mar 2019 13:52:54 -0400
Received: by mail-it1-f195.google.com with SMTP id l139so12192528ita.5
        for <linux-nfs@vger.kernel.org>; Fri, 15 Mar 2019 10:52:54 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ghVaYxP4lrdAW7QE3DJPRmBO3oJmBjuC2pYalHI4xgE=;
        b=h7O+/mGyLxlHqgYvuy+u5K5B3iPQGfccDIQ3CTHH4YXgBsGw0aBM1CXxFsnwGPG/IB
         0LW+IPu2a8W2obPG1BQxJyDZwWieMjh0cgbk22QXOJchHJkn4qSSjFFccH/KFwldD6LN
         SmgEjzkfqE6Ly2bi20qugxp1ESTVV/+xvdhxWG80QdGnWZDdEmovPqNN0wSAqCqs9yNo
         upaG5pjiZdAswusemr3SVGBB/PZUaXUZCLhvQqKSrS3wDP+uEHgEOwRiPv+K0od2pRzf
         5g5i8jPaPVJy09QbJzfXCyaKGngHYPPRJeJvrDfSIGLByp/nrnwxfpB9mLfTMkPQpo5p
         12YQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=ghVaYxP4lrdAW7QE3DJPRmBO3oJmBjuC2pYalHI4xgE=;
        b=uFsC+P+6GgWYE4CI7y06uQW2jaOIiqXLA1dV1+6XxHGgapPGWz3/X69CP6v04LRlSa
         KR+5bnZJsjU+YRhKtjKOeFlkeRA8NHZjNeqJbiEH8aCvtsoiGzXztdDhVnrdVvBU2c90
         fhXEty4E4fRcvI5CvQHlzyerwls2DAT0B/5NGmVBMpXqrTbypLCDRVuDD0L6WR1Yvjn+
         y6uOzL+9pxU+BIWcTUh8/ZPT6pJFCuRIGlMszTF6dYFnHhUMUzR4lw31sggaupM8Ru9i
         yt/1fipvLyrNXs0XvykHK+KUD6gzlk+7Nyy3edSgcxrvpUyM5DiNMJaVoVW4EuAK0rzs
         QbhA==
X-Gm-Message-State: APjAAAUiQqmyQb82wtD9VWqi+Xt+D3XOi/L1Fwq0cad4ycTMJS3m66Cz
        Vf2RaTylfuQBEQqGbWTrjLtwJ3c=
X-Google-Smtp-Source: APXvYqzh/DQfKJ/sOTWwEwfSSYx4wVSng7XYD2sY+qMiCjmshK6X4tBq1UrV5xNbNJOvcNlKQdRUFA==
X-Received: by 2002:a02:4904:: with SMTP id z4mr3182633jaa.46.1552672373165;
        Fri, 15 Mar 2019 10:52:53 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id r2sm1138415itk.5.2019.03.15.10.52.52
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 15 Mar 2019 10:52:52 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 3/6] SUNRPC: Use the ENOTCONN error on socket disconnect
Date:   Fri, 15 Mar 2019 13:51:38 -0400
Message-Id: <20190315175141.68792-3-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190315175141.68792-2-trond.myklebust@hammerspace.com>
References: <20190315175141.68792-1-trond.myklebust@hammerspace.com>
 <20190315175141.68792-2-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

When the socket is closed, we currently send an EAGAIN error to all
pending requests in order to ask them to retransmit. Use ENOTCONN
instead, to ensure that they try to reconnect before attempting to
transmit.
This also helps SOFTCONN tasks to behave correctly in this
situation.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/xprt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index e096c5a725df..d7117d241460 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -664,7 +664,7 @@ void xprt_disconnect_done(struct rpc_xprt *xprt)
 	spin_lock_bh(&xprt->transport_lock);
 	xprt_clear_connected(xprt);
 	xprt_clear_write_space_locked(xprt);
-	xprt_wake_pending_tasks(xprt, -EAGAIN);
+	xprt_wake_pending_tasks(xprt, -ENOTCONN);
 	spin_unlock_bh(&xprt->transport_lock);
 }
 EXPORT_SYMBOL_GPL(xprt_disconnect_done);
-- 
2.20.1

