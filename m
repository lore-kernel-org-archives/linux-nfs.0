Return-Path: <SRS0=cCtV=Q2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EBB90C43381
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 14:08:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B9C2A2146E
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 14:08:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="MxrSYggC"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726221AbfBSOIF (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 09:08:05 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:37839 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726141AbfBSOIE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Feb 2019 09:08:04 -0500
Received: by mail-it1-f196.google.com with SMTP id z124so6411334itc.2
        for <linux-nfs@vger.kernel.org>; Tue, 19 Feb 2019 06:08:04 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=eAvHVvgPCxfMHmYT5KyuUWb1kK6BSClv2xiAb0yzbuo=;
        b=MxrSYggChF8DLCTqbwMTvAyRqZJlkftLUe2oDMxGZprWlSFb4TgKmwNHuHwgiSuOmY
         vb5ZF2czp848txoJRKT/bCzVc9rGlCtuL9eyEGa8vOCnelY/cQKH0HFpKX2hYD/AAFGO
         BWxbrrcFywwwuHwqRVbIwnjo/eIaf+2bdfBZstbCqOr/tf40GlDuhiAMqN0eivrxDXsE
         CUFw3kTaVvS/PxAjXiAsJ3oSqDG4uchVP3bnmWiYnbcrZNGit0vZVIgVpuFYQcN9t245
         WQtniduOP+K9TMK0JuMyMML9Y5z8pR++Ilbn+f8r5NLWqo7o0UlsTiZQZNRrDWsZ41+G
         /0lg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=eAvHVvgPCxfMHmYT5KyuUWb1kK6BSClv2xiAb0yzbuo=;
        b=M4NgTpjGCFYtyBIEwP2xaltjZ4alQk1IFdqVL23XK+2n9A7XV3KYgjss4IByVKAU+l
         O54ZGobgENa1Iw9Z7Ngg7hyUAokeEfNugnEIIhuDeyb/rOk/IN9b359cBLib6L/NWa9g
         SqLH6eRjWUClnsvEiSdCLqeSesNNNAiCWFnlPnxfND57aEpys3fDSJd28gpy0YGecGUI
         vOoolFcDfqb/T3T1ByUvbh4aD6xtaYiaKX/EYyTsBxpzUg3Bs+ZXoA36NuSnmFyaQPC7
         mb45Gk5y+VInVL+3PabW0B9Y922YEbGzjXV2O41PIHrI2C0FGJMLvzePAiB2dgdf1Ksr
         LokA==
X-Gm-Message-State: AHQUAub8x/wlxfTyhkQ8+hMLQLgEQhEv7R6NjY4O3WxCYzt3DFTxMRbi
        Gu8BvbwprXzrFASLNi1xR0hraUY=
X-Google-Smtp-Source: AHgI3IamlVdEKh4J6n2AdiMg0PfEJkixu2tf8qdDGFc8PlZ3KfhV0hL2X/w6/FjPjXiBwNhg6dHsWA==
X-Received: by 2002:a5e:9e01:: with SMTP id i1mr18585976ioq.44.1550585283328;
        Tue, 19 Feb 2019 06:08:03 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id f26sm6674559ioh.1.2019.02.19.06.08.02
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 06:08:02 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: Use poll() to fix up the socket requeue races
Date:   Tue, 19 Feb 2019 09:06:16 -0500
Message-Id: <20190219140616.123141-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Because we clear XPRT_SOCK_DATA_READY before reading, we can end up
with a situation where new data arrives, causing xs_data_ready() to
queue up a second receive worker job for the same socket, which then
immediately gets stuck waiting on the transport receive mutex.
The fix is to only clear XPRT_SOCK_DATA_READY once we're done reading,
and then to use poll() to check if we might need to queue up a new
job in order to deal with any new data.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/xprtsock.c | 17 +++++++++++++++--
 1 file changed, 15 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index f5d7dcd9e8d9..a721c843d5d3 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -656,13 +656,25 @@ xs_read_stream(struct sock_xprt *transport, int flags)
 	return ret != 0 ? ret : -ESHUTDOWN;
 }
 
+static void xs_poll_check_readable(struct sock_xprt *transport)
+{
+	struct socket *sock = transport->sock;
+	__poll_t events;
+
+	clear_bit(XPRT_SOCK_DATA_READY, &transport->sock_state);
+	events = sock->ops->poll(NULL, sock, NULL);
+	if (!(events & (EPOLLIN | EPOLLRDNORM)) || events & EPOLLRDHUP)
+		return;
+	if (!test_and_set_bit(XPRT_SOCK_DATA_READY, &transport->sock_state))
+		queue_work(xprtiod_workqueue, &transport->recv_worker);
+}
+
 static void xs_stream_data_receive(struct sock_xprt *transport)
 {
 	size_t read = 0;
 	ssize_t ret = 0;
 
 	mutex_lock(&transport->recv_mutex);
-	clear_bit(XPRT_SOCK_DATA_READY, &transport->sock_state);
 	if (transport->sock == NULL)
 		goto out;
 	for (;;) {
@@ -672,6 +684,7 @@ static void xs_stream_data_receive(struct sock_xprt *transport)
 		read += ret;
 		cond_resched();
 	}
+	xs_poll_check_readable(transport);
 out:
 	mutex_unlock(&transport->recv_mutex);
 	trace_xs_stream_read_data(&transport->xprt, ret, read);
@@ -1362,7 +1375,6 @@ static void xs_udp_data_receive(struct sock_xprt *transport)
 	int err;
 
 	mutex_lock(&transport->recv_mutex);
-	clear_bit(XPRT_SOCK_DATA_READY, &transport->sock_state);
 	sk = transport->inet;
 	if (sk == NULL)
 		goto out;
@@ -1374,6 +1386,7 @@ static void xs_udp_data_receive(struct sock_xprt *transport)
 		consume_skb(skb);
 		cond_resched();
 	}
+	xs_poll_check_readable(transport);
 out:
 	mutex_unlock(&transport->recv_mutex);
 }
-- 
2.20.1

