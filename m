Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78BFEC43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 20:06:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 489F920874
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 20:06:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lSaEJXFc"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2387657AbeLQUGe (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 15:06:34 -0500
Received: from mail-oi1-f195.google.com ([209.85.167.195]:36824 "EHLO
        mail-oi1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728192AbeLQUGe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 15:06:34 -0500
Received: by mail-oi1-f195.google.com with SMTP id x23so53867oix.3
        for <linux-nfs@vger.kernel.org>; Mon, 17 Dec 2018 12:06:33 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=FxX4iM1Ll70i0pWqw29xJS9IXa9k69XOlGzVJrtUmyc=;
        b=lSaEJXFcXEbJhXdoqOPriFh363RTm6LPnHuyHbbzypOKmm6JvnBj8it0644grkw7w1
         S0m2qaF5q5m6dQsYcYCHanonSfqwRoKefTaXlVvzLE8mgo7O4OGQ2JfBc+OQMa9p7KC2
         JC4oGIGks1D/TYgGSoBGS6MYwwmTspY8GFr1/DqDVOphnfTfz6EnwylQUTHuVZxtoXno
         vSiackBQMKLTssBML4uqokr1RDk1MteZpf7jb/k6IR1vtuD9R5XiosHZsyvYE1FTKfM6
         PNoALfhr+jB8o9d2zVLKhHtvo3VgbMwCdXTWPBuDwXt+4yha+eHJx04zBpGotr4PKIaK
         TnyA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=FxX4iM1Ll70i0pWqw29xJS9IXa9k69XOlGzVJrtUmyc=;
        b=Xjyh9mJijwcd9SuYtv6rnawtvWfSuras/5enkRESypCCDSEqlvCs73q4NIogtT7jdg
         +eYg25rj5CZWwftASvpag7Xoziuut4OOQrKUE15FVm6j22el9aaNkghxNZQBbNE91gyb
         FBz7KeTTm93CNzYpxPiYoKB+D8HWCTBXfiKiJwRrJEO3Hd4Kd89Kns/sWnGNgx1Lw5yJ
         hRUyf/FzH1qtBwxKmOKqcVdddY4bDJWtWdxri/LKstlVkKwHN6VLofAVlzyf3cwnI2Ho
         Rw9CYU485/hYRGO0D653HXf6KZsUI88TS1lBSKlk7mmx23fpP/XuTXx+DjENO7VjsxTo
         49gg==
X-Gm-Message-State: AA+aEWYAZEyQEjOW6hHHXCfOf+n9yIWt7DuqHuWxn6h7+QxZ5tJF5TVG
        yAnL9eTAzIPgt15XJ7LgAv0Ipc9R8g==
X-Google-Smtp-Source: AFSGD/Vj8yy5jb7qQn9sZwcCrTbCUz2O+iI3mie8Vk95WFX87wRoYS8hvPYvE1fSM0sYpFqD0fbhZw==
X-Received: by 2002:aca:5344:: with SMTP id h65mr6381590oib.13.1545077192662;
        Mon, 17 Dec 2018 12:06:32 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id c7sm674063otf.59.2018.12.17.12.06.31
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Dec 2018 12:06:31 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Dave Wysochanski <dwysocha@redhat.com>,
        Scott Mayhew <smayhew@redhat.com>
Cc:     Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: Fix disconnection races
Date:   Mon, 17 Dec 2018 15:05:24 -0500
Message-Id: <20181217200524.105368-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.19.2
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

When the socket is closed, we need to call xprt_disconnect_done() in order
to clean up the XPRT_WRITE_SPACE flag, and wake up the sleeping tasks.

However, we also want to ensure that we don't wake them up before the socket
is closed, since that would cause thundering herd issues with everyone
piling up to retransmit before the TCP shutdown dance has completed.
Only the task that holds XPRT_LOCKED needs to wake up early in order to
allow the close to complete.

Reported-by: Dave Wysochanski <dwysocha@redhat.com>
Reported-by: Scott Mayhew <smayhew@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/xprt.c     |  4 +++-
 net/sunrpc/xprtsock.c | 10 ++++------
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index ce927002862a..089e53a87379 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -680,7 +680,9 @@ void xprt_force_disconnect(struct rpc_xprt *xprt)
 	/* Try to schedule an autoclose RPC call */
 	if (test_and_set_bit(XPRT_LOCKED, &xprt->state) == 0)
 		queue_work(xprtiod_workqueue, &xprt->task_cleanup);
-	xprt_wake_pending_tasks(xprt, -EAGAIN);
+	else if (xprt->snd_task)
+		rpc_wake_up_queued_task_set_status(&xprt->pending,
+				xprt->snd_task, -ENOTCONN);
 	spin_unlock_bh(&xprt->transport_lock);
 }
 EXPORT_SYMBOL_GPL(xprt_force_disconnect);
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 8a5e823e0b33..f0b3700cec95 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1217,6 +1217,8 @@ static void xs_reset_transport(struct sock_xprt *transport)
 
 	trace_rpc_socket_close(xprt, sock);
 	sock_release(sock);
+
+	xprt_disconnect_done(xprt);
 }
 
 /**
@@ -1237,8 +1239,6 @@ static void xs_close(struct rpc_xprt *xprt)
 
 	xs_reset_transport(transport);
 	xprt->reestablish_timeout = 0;
-
-	xprt_disconnect_done(xprt);
 }
 
 static void xs_inject_disconnect(struct rpc_xprt *xprt)
@@ -1489,8 +1489,6 @@ static void xs_tcp_state_change(struct sock *sk)
 					&transport->sock_state))
 			xprt_clear_connecting(xprt);
 		clear_bit(XPRT_CLOSING, &xprt->state);
-		if (sk->sk_err)
-			xprt_wake_pending_tasks(xprt, -sk->sk_err);
 		/* Trigger the socket release */
 		xs_tcp_force_close(xprt);
 	}
@@ -2092,8 +2090,8 @@ static void xs_udp_setup_socket(struct work_struct *work)
 	trace_rpc_socket_connect(xprt, sock, 0);
 	status = 0;
 out:
-	xprt_unlock_connect(xprt, transport);
 	xprt_clear_connecting(xprt);
+	xprt_unlock_connect(xprt, transport);
 	xprt_wake_pending_tasks(xprt, status);
 }
 
@@ -2329,8 +2327,8 @@ static void xs_tcp_setup_socket(struct work_struct *work)
 	}
 	status = -EAGAIN;
 out:
-	xprt_unlock_connect(xprt, transport);
 	xprt_clear_connecting(xprt);
+	xprt_unlock_connect(xprt, transport);
 	xprt_wake_pending_tasks(xprt, status);
 }
 
-- 
2.19.2

