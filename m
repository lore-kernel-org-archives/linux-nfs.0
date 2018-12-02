Return-Path: <SRS0=5YGM=OL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE77EC04EB8
	for <linux-nfs@archiver.kernel.org>; Sun,  2 Dec 2018 14:43:33 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9BFC32054F
	for <linux-nfs@archiver.kernel.org>; Sun,  2 Dec 2018 14:43:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mykSkUu2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9BFC32054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725862AbeLBOne (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 2 Dec 2018 09:43:34 -0500
Received: from mail-io1-f65.google.com ([209.85.166.65]:37766 "EHLO
        mail-io1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725856AbeLBOnd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 2 Dec 2018 09:43:33 -0500
Received: by mail-io1-f65.google.com with SMTP id f14so2860300iol.4
        for <linux-nfs@vger.kernel.org>; Sun, 02 Dec 2018 06:43:32 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=B5Z6tKPScmWV4iPuFE4Zo2CrsYsh3o08ASWwx6vbJ1o=;
        b=mykSkUu2ewDBFry7Lrq7sV49+RNTAqdOAfZAmTfNI/4EQgQBQIw/xnDqlzcIAP340y
         jZNbgE2E0g+O5Ry8jKMwXH8eys7StGPhz5kTVlxZna1hNyKysiXanFpp6/8P/hp9r4T5
         wRN1lAXfbdr+oKRt5YQpdKPusBWa5xr19bZe/D4wG5jwHe/sRWUxOSN8ZP1EH69Thndx
         cayOh/KsrzLp6CAVvCZfOdi8K1QC5vS3mjLJKs9FnTVj5x1C9R7LKWJHv6BcNwPgMLOU
         KZDNMwoLuCxO36KaLqfKpw52bKZ+dyZU+hmtDNnrtKdAUKLt0k5EaPOwgpvUw/bArmgc
         U/9g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=B5Z6tKPScmWV4iPuFE4Zo2CrsYsh3o08ASWwx6vbJ1o=;
        b=Qtm5yVsluv+UVQ7Bvmf7a1nvZ8Z+KD+ufUbjqSEiEOigcoCPKFXX6nM1bntAZ0GO2G
         6vCFBTGgW9z+HkH5+u/Yreg11SPz+2el9djnTjHSeztY/TeH4iNfhmlFgu4uBAvVcPjK
         d6gU+Am7pLlYqKNtIYXXjdVJFwjXTJ8XUP9PoSXPmTBAfa1xRfn8QEuMGOv3myzU2woJ
         NpFZieZJBW2TnfEv7ewBVrmiUmwPa3/Uud9JnFYiw8Wy42X/NRJR2QQonzsW6AXfkOP5
         joPxCP5ijl75/rw/aMJ9QY8gIGQBaP3RKhufXRLvWpNukLNqC+bUjRlk1oB7eMI4dYpV
         lhOg==
X-Gm-Message-State: AA+aEWb3ix9EkRHKlOAac1NYc5jNJX7L7NG192wy+pSZlRNwiRg45ivO
        a/F90haD3CdsnnWiFFLUpg==
X-Google-Smtp-Source: AFSGD/UNeiW56GHAj6CwIFDyPXZReCinFWvtR1YC6vyjJdlisHNkv5bHlrKAIo9GkNhGjGZBbmIXPQ==
X-Received: by 2002:a6b:7903:: with SMTP id i3mr10523461iop.273.1543761811593;
        Sun, 02 Dec 2018 06:43:31 -0800 (PST)
Received: from localhost.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id p19sm2376777itp.13.2018.12.02.06.43.29
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 02 Dec 2018 06:43:30 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: Fix a potential race in xprt_connect()
Date:   Sun,  2 Dec 2018 09:42:23 -0500
Message-Id: <20181202144223.42562-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.19.2
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If an asynchronous connection attempt completes while another task is
in xprt_connect(), then the call to rpc_sleep_on() could end up
racing with the call to xprt_wake_pending_tasks().
So add a second test of the connection state after we've put the
task to sleep and set the XPRT_CONNECTING flag, when we know that there
can be no asynchronous connection attempts still in progress.

Fixes: 0b9e79431377d ("SUNRPC: Move the test for XPRT_CONNECTING into...")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/xprt.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 122c91c28e7c..ce927002862a 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -826,8 +826,15 @@ void xprt_connect(struct rpc_task *task)
 			return;
 		if (xprt_test_and_set_connecting(xprt))
 			return;
-		xprt->stat.connect_start = jiffies;
-		xprt->ops->connect(xprt, task);
+		/* Race breaker */
+		if (!xprt_connected(xprt)) {
+			xprt->stat.connect_start = jiffies;
+			xprt->ops->connect(xprt, task);
+		} else {
+			xprt_clear_connecting(xprt);
+			task->tk_status = 0;
+			rpc_wake_up_queued_task(&xprt->pending, task);
+		}
 	}
 	xprt_release_write(xprt, task);
 }
-- 
2.19.2

