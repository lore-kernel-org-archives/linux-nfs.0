Return-Path: <SRS0=5e7g=PK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0F27C43387
	for <linux-nfs@archiver.kernel.org>; Wed,  2 Jan 2019 22:54:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id ADA7D20879
	for <linux-nfs@archiver.kernel.org>; Wed,  2 Jan 2019 22:54:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="EQjNpHZw"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729986AbfABWyY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 2 Jan 2019 17:54:24 -0500
Received: from mail-it1-f194.google.com ([209.85.166.194]:37109 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729935AbfABWyX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Jan 2019 17:54:23 -0500
Received: by mail-it1-f194.google.com with SMTP id b5so40646901iti.2
        for <linux-nfs@vger.kernel.org>; Wed, 02 Jan 2019 14:54:23 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=JnS30+nLU7JMRkJbA97ROxzOslQkF9kggR9DlamwWFk=;
        b=EQjNpHZwWHG9bneFJrj/6kfARAWQVepC51EAHbUEE/jpk6rW/owbvDJCMqwUR10olj
         xXPWL5CYFkMuirANYZ1wbHxri+26+yh1fC773sWCGLZdv5xkL8q5mkkqviYvCLPXw54c
         YtVgQPTKOXtwSBIQR91vieR3F9lwTfEr4ImcaRJVjQmZISHEOftcZ9mmbl8XWJcX+h1f
         oDfVfqNiGFJD/uotUnih03wsIQBkCnuLFB7lCcMJXugf0oqTjmIV9G1wCiDkyBqbWyC7
         wcyuSTxIytFBwKF+DyqG9clHmlwzVYAykG5D89tXPntweYpzbAif3CCS9oTfuQOtK71r
         8fAw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=JnS30+nLU7JMRkJbA97ROxzOslQkF9kggR9DlamwWFk=;
        b=XeziPA9UiHXZ/7Nt/0gsS9hLj7jVehmvEByZBwANrzB9NpoFY7lqfznh1fx8Oluby7
         tPgNCmTqg6NTlIR1DFMGlFm8TIzPpXWHmYgF2H2pzFYL2PaSjm+Hf9g4b1YU39M2dMc1
         cOv81DqIsHDya0c/cN2o/kjrzvmh9eHGxX7a0qN/4kdi2h+miIQ2860nHvq+14LJyDJa
         jfjJ+ItDzWeRMrrnwco2Yl887+IV8RP1RTLffFbgjuqxTkY/PblJsff2xz5CSuh+xsb7
         +EyvGU34TeUD74EWEo7gQUONVYWjh9mOqVoh4F7kWwcpuRaOWM12QoTLpHl8gFl3OkqI
         Rz2Q==
X-Gm-Message-State: AJcUukcZMbCQPjrzMKOsFH6ncWnfNr5fm7SUeZZrTbLaI8GRPT5efTDP
        3g6fzh1BQmGAhliM3vGmdA==
X-Google-Smtp-Source: AFSGD/V76bJfz+/VIHRsewRaN2XCHD9fon5aXpplsVm/1Ww7bB4iDHpN8TP3SAPaDRjScS/zGPrtDw==
X-Received: by 2002:a24:64b:: with SMTP id 72mr29063429itv.59.1546469662748;
        Wed, 02 Jan 2019 14:54:22 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id d3sm23036154itc.40.2019.01.02.14.54.21
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 02 Jan 2019 14:54:22 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 2/4] SUNRPC: Fix the RPCSEC_GSS sequence semantics after request re-encoding
Date:   Wed,  2 Jan 2019 17:53:11 -0500
Message-Id: <20190102225313.2097-3-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190102225313.2097-2-trond.myklebust@hammerspace.com>
References: <20190102225313.2097-1-trond.myklebust@hammerspace.com>
 <20190102225313.2097-2-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

When we have to re-encode the RPCSEC_GSS request because it has fallen
outside the GSS sequence window, we want to avoid moving it to the front
of the transmission queue, since that moves the entire sequence window
forward, and may result in more requests falling out.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/xprt.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 9075ae150ae5..040c45c68fb3 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1322,6 +1322,12 @@ xprt_request_transmit(struct rpc_rqst *req, struct rpc_task *snd_task)
 		}
 		/* Verify that our message lies in the RPCSEC_GSS window */
 		if (rpcauth_xmit_need_reencode(task)) {
+			if (xprt->ops->release_request &&
+			    xprt_request_retransmit_after_disconnect(task)) {
+				spin_lock_bh(&xprt->transport_lock);
+				xprt->ops->release_request(task);
+				spin_unlock_bh(&xprt->transport_lock);
+			}
 			status = -EBADMSG;
 			goto out_dequeue;
 		}
-- 
2.20.1

