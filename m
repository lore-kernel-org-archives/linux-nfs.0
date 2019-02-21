Return-Path: <SRS0=V3X6=Q4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF1ECC43381
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Feb 2019 16:18:07 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BDC4220836
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Feb 2019 16:18:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Ekg9i2kz"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727336AbfBUQSH (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 21 Feb 2019 11:18:07 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:50992 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726371AbfBUQSH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Feb 2019 11:18:07 -0500
Received: by mail-it1-f196.google.com with SMTP id m137so23252147ita.0
        for <linux-nfs@vger.kernel.org>; Thu, 21 Feb 2019 08:18:06 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=IC6opYrU272peHufrLZwtEhJiETEUMDJayo2Co+eLDI=;
        b=Ekg9i2kzkRRm/dsoTvlVtFcmOoVi5teV0ljUc+N2KgcNO6abmogqa8bMYiKIm48wZW
         Fe0IdxYUpahYepXJjFJr3T0N1z2ydYFWyRrH1IYRuxpTRdlHcmi3QH3n6WEouOh2CckB
         TwCKGp7d2ep7taIkGzvnlTZGhtlxn7emTLjqo2Jp70WtjeIfJpvS/4KQjZ+cBO2/mZJL
         kWKPwunUB38f5vOOQOQi4Mw7zaHoOpWUHSfLOhoPMqkeki6kUR8JgUm+DYx3+sd4Fhcs
         DNHNmbd3nUtG+wfuzCfBxO3CHnotECUGJo6KPL/CfPzWMl6n/Rs855H8AhnGh7kTZ7Mc
         fD1w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=IC6opYrU272peHufrLZwtEhJiETEUMDJayo2Co+eLDI=;
        b=pdjsX6WZu6U/6Tc/FKcoxDuQq7K/p9Hq5zeAoVxQFeZJK2Vg3/yg0ZeRrFBLgXfdXP
         gKDDLRW22i2gIrlRwTGze4teqv1yYRD/+5Ox6kOjnB6i8To4PZgyvSJC+Y/KC2tb3QKp
         L4YIoNZxpFaY47aUBRAgTwp+iz+eXxnKgsaKB2wWMl3Jpd7XjByGSU7xxKmrI6MZPJ5e
         pJCQQj33GGQwyGryL3oiE6aF5PYEre8jypVnaFOsvWFWenS91ztyBmtr5RKi0FLIKn1j
         CIjWCOsynZqPTTymb26+RW7QoLscBDEC5N4SyNEMM8ooy+8ZmThc34/razZO3IxrwI8t
         KWqQ==
X-Gm-Message-State: AHQUAuZX0gtshR+m4TQkIj8PsGAMCLMDrYQPN8rgC0j5EWcgRURFqaWJ
        McFENnUrzc5E0uekTPNR8r/5gZ0=
X-Google-Smtp-Source: AHgI3IaU4ise8C1nhBf9LWvaMgrv9ywwalwvAwJO3XBDbCok8L1TXR6p04dY/c0KRgDBIEtkbt1vxg==
X-Received: by 2002:a02:b885:: with SMTP id p5mr22278894jam.60.1550765885624;
        Thu, 21 Feb 2019 08:18:05 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id a16sm4588517itc.27.2019.02.21.08.18.04
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 21 Feb 2019 08:18:04 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v2] SUNRPC: Use poll() to fix up the socket requeue races
Date:   Thu, 21 Feb 2019 11:16:18 -0500
Message-Id: <20190221161618.21926-1-trond.myklebust@hammerspace.com>
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

v2: refactor xs_poll_check_readable() to pull out the poll() socket
    api details.  

 net/sunrpc/xprtsock.c | 26 ++++++++++++++++++++++++--
 1 file changed, 24 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index f5d7dcd9e8d9..da45bb1e931e 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -656,13 +656,34 @@ xs_read_stream(struct sock_xprt *transport, int flags)
 	return ret != 0 ? ret : -ESHUTDOWN;
 }
 
+static __poll_t xs_poll_socket(struct sock_xprt *transport)
+{
+	return transport->sock->ops->poll(NULL, transport->sock, NULL);
+}
+
+static bool xs_poll_socket_readable(struct sock_xprt *transport)
+{
+	__poll_t events = xs_poll_socket(transport);
+
+	return (events & (EPOLLIN | EPOLLRDNORM)) && !(events & EPOLLRDHUP);
+}
+
+static void xs_poll_check_readable(struct sock_xprt *transport)
+{
+
+	clear_bit(XPRT_SOCK_DATA_READY, &transport->sock_state);
+	if (!xs_poll_socket_readable(transport))
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
@@ -672,6 +693,7 @@ static void xs_stream_data_receive(struct sock_xprt *transport)
 		read += ret;
 		cond_resched();
 	}
+	xs_poll_check_readable(transport);
 out:
 	mutex_unlock(&transport->recv_mutex);
 	trace_xs_stream_read_data(&transport->xprt, ret, read);
@@ -1362,7 +1384,6 @@ static void xs_udp_data_receive(struct sock_xprt *transport)
 	int err;
 
 	mutex_lock(&transport->recv_mutex);
-	clear_bit(XPRT_SOCK_DATA_READY, &transport->sock_state);
 	sk = transport->inet;
 	if (sk == NULL)
 		goto out;
@@ -1374,6 +1395,7 @@ static void xs_udp_data_receive(struct sock_xprt *transport)
 		consume_skb(skb);
 		cond_resched();
 	}
+	xs_poll_check_readable(transport);
 out:
 	mutex_unlock(&transport->recv_mutex);
 }
-- 
2.20.1

