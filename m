Return-Path: <SRS0=q2Lh=Q3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8CA3DC43381
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 14:56:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5BD9121848
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 14:56:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="PB9I9BZb"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726441AbfBTO46 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 20 Feb 2019 09:56:58 -0500
Received: from mail-yw1-f67.google.com ([209.85.161.67]:40557 "EHLO
        mail-yw1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726194AbfBTO46 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Feb 2019 09:56:58 -0500
Received: by mail-yw1-f67.google.com with SMTP id c67so9296578ywa.7
        for <linux-nfs@vger.kernel.org>; Wed, 20 Feb 2019 06:56:57 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=9qxOPm4L8xhV6CpMnGkpUNUShb3i+T9FGKbgqdEv4bo=;
        b=PB9I9BZbUJHTez3IxIP4EHyyB6AuXve42e1bWMd3cA6dclVXdTNqKLafOWS1dOt02V
         CurJTrrcAiXlNXao5Yfad9jbWBRNiCAjm7VMUYKrL/mcP8pv83JCV2IoC413gCv5WyBh
         c1JBP/q2LE2/putBEejRD6av5WAxeEebbLd8cYtivxLL8o4zFuW5yVTY4xeWHLn4klts
         AVaWmOvI2lzN0dsZEEnIE+ySYBlfTi7W/PmLd0f2NEKQy+SdLtPghCov65ptTsvyFwjv
         S8LLjnPbO/cTpbzkkJJfw58/siVQxH7Qz1WJuyyIpVt3lRKcQZPE3xL5sRRwdaLlIyU0
         8Uow==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=9qxOPm4L8xhV6CpMnGkpUNUShb3i+T9FGKbgqdEv4bo=;
        b=e+VwPY1jKq5KEK1W2PZTRza+7fVzn9IPKsJ3FUiJM1ogEFJJkASUquKuxUaEkw64n6
         b7ING/5QjegJ/9JZjNPet7wBzElmYYLoCn1rd50Lfk7Pfwe5N5yR2XKzHT/OAHXjlNzw
         nWYIEGP8lT7S2JLSJagRzDXPJwk/JRHDGrRMpqCl3V10EpzqhCTme+zTZCIAn+AruKge
         MceqDRHf1kvvdcDg/GJlwg5RSzgwRflR6iWw4GO9czQG9NFalsGg/jBTTboQg4PXtKMB
         2jpSv2I6uYIjHLpt/U4Dhz4pLACOqJM75cNP86ZtjW90pe9hhBTw/b/jkbGCYaFfDYwS
         /vmA==
X-Gm-Message-State: AHQUAuayGIEQGHfuoBlvOyIJDo445fY75mEBA0yK9M839AaIM6JhD9UC
        zxdi+Ki30DTQFwbHYRKGJ9p3fRdO
X-Google-Smtp-Source: AHgI3IYSFwnpn9HclPJTwkKuYgPpZSou2FBXW55CleERjnVOUagapdLFoYoz3uDv8wvgb0/q1yDEuQ==
X-Received: by 2002:a0d:c683:: with SMTP id i125mr2646405ywd.471.1550674617550;
        Wed, 20 Feb 2019 06:56:57 -0800 (PST)
Received: from localhost.localdomain ([97.101.44.244])
        by smtp.gmail.com with ESMTPSA id h205sm11296586ywh.85.2019.02.20.06.56.56
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Feb 2019 06:56:56 -0800 (PST)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 1/1] SUNRPC: fix handling of half-closed connection
Date:   Wed, 20 Feb 2019 09:56:50 -0500
Message-Id: <20190220145650.21566-1-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

When server replies with an ACK to client's FIN/ACK, client ends
up stuck in a TCP_FIN_WAIT2 state and client's mount hangs.
Instead, make sure to close and reset client's socket and transport
when transitioned into that state.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 net/sunrpc/xprtsock.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 618e9c2..812e5e3 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1502,6 +1502,7 @@ static void xs_tcp_state_change(struct sock *sk)
 		clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
 		smp_mb__after_atomic();
 		break;
+	case TCP_FIN_WAIT2:
 	case TCP_CLOSE_WAIT:
 		/* The server initiated a shutdown of the socket */
 		xprt->connect_cookie++;
@@ -2152,6 +2153,7 @@ static void xs_tcp_shutdown(struct rpc_xprt *xprt)
 		kernel_sock_shutdown(sock, SHUT_RDWR);
 		trace_rpc_socket_shutdown(xprt, sock);
 		break;
+	case TCP_FIN_WAIT2:
 	case TCP_CLOSE:
 	case TCP_TIME_WAIT:
 		xs_reset_transport(transport);
-- 
1.8.3.1

