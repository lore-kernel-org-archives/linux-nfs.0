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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21276C43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 22:53:47 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E0F2021473
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 22:53:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UBUcz1Pq"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728394AbeLQWxq (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 17:53:46 -0500
Received: from mail-ot1-f66.google.com ([209.85.210.66]:34873 "EHLO
        mail-ot1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726548AbeLQWxq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 17:53:46 -0500
Received: by mail-ot1-f66.google.com with SMTP id 81so13840292otj.2
        for <linux-nfs@vger.kernel.org>; Mon, 17 Dec 2018 14:53:45 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=lEVwmO/uBF/Xs4RGSebb/8JoOWj8BhKveIV1MM+oB+k=;
        b=UBUcz1PqFhUgKX5wZI3LPcz4JAiiuqVffZBdmzaZsdHoOGBWn4HSXQ+r3fW66JvHkp
         acoSjA2guoxijE/YcprJVnxdfBxtQwQq2mnAV9iFAdc6vcV+D9BKSLKLB4dvNRoTGp5h
         4xUaEY7tWAExaq0tRRnAhVlFMXfR33rbMd9f7AI3PnaTeC7lxGMWQW+KVKLPyXoKjMsU
         wXsMBpkF/xQmvycEXt/2wLImSUiJozEuFAMxGUcm5NU7KaWydscTXewKV5C4adTS0aXv
         UfhmLwzdt20hIB7uohnXQwcGq9whIMlVSP0SR0B67jHs6tH8PE9ATYld3oOWXdHJBO5D
         YLLA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=lEVwmO/uBF/Xs4RGSebb/8JoOWj8BhKveIV1MM+oB+k=;
        b=FSPQikuDF3pGF0S/XGIarAiYfwSlmizP7C24Dzn7hljWxIoPpSeNde+ihCnwronEFu
         08jM/CPw+Se1kPAirJ1lPNcq5JGD1zpbdWcfjxwRFZlVRUnCHBa0fdKGDprzqOp3RMM9
         yi7yi39Aj1Am5DA1WXWHzRC/huBReGLgHzajeD7w922oOXdeID0Q1otFR7oK6RXPizbc
         D0ZtfTJ39qRZ11Cw+zjWq6XGhn0WreReUDItR5VgMC4+xNEcP47iq3wUqEMUNxt735sc
         r7x6855H0TUotbR7Xh6hyAerUjtzdgJQgYs7++QkNb/jshL3Hv0/5OQlTI9mQpY72VVb
         A/2A==
X-Gm-Message-State: AA+aEWbMCbhrSW2I2kPbK8HmpfX1RUXxsIaMJfdNrbPP7kD2MldrInz4
        KtYD6CpKps0cQC+gFauVSL/QfTGO9w==
X-Google-Smtp-Source: AFSGD/V2UGZmeW6foT2vZN5RHMvwKDwjr/lp0X/dl03llE4IkzQNFRNky+9j3cpULVu0q9WB5bz18w==
X-Received: by 2002:a9d:2e5:: with SMTP id 92mr11212685otl.59.1545087224517;
        Mon, 17 Dec 2018 14:53:44 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id 30sm6984266ots.52.2018.12.17.14.53.42
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Dec 2018 14:53:43 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Dave Wysochanski <dwysocha@redhat.com>,
        Scott Mayhew <smayhew@redhat.com>
Cc:     Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/3] SUNRPC: Fix disconnection races
Date:   Mon, 17 Dec 2018 17:52:33 -0500
Message-Id: <20181217225235.124448-1-trond.myklebust@hammerspace.com>
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
 net/sunrpc/clnt.c     | 1 +
 net/sunrpc/xprt.c     | 5 ++++-
 net/sunrpc/xprtsock.c | 6 ++----
 3 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index c6782aa47525..24cbddc44c88 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1952,6 +1952,7 @@ call_connect_status(struct rpc_task *task)
 		/* retry with existing socket, after a delay */
 		rpc_delay(task, 3*HZ);
 		/* fall through */
+	case -ENOTCONN:
 	case -EAGAIN:
 		/* Check for timeouts before looping back to call_bind */
 	case -ETIMEDOUT:
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index ce927002862a..3fb001dff670 100644
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
@@ -852,6 +854,7 @@ static void xprt_connect_status(struct rpc_task *task)
 	case -ENETUNREACH:
 	case -EHOSTUNREACH:
 	case -EPIPE:
+	case -ENOTCONN:
 	case -EAGAIN:
 		dprintk("RPC: %5u xprt_connect_status: retrying\n", task->tk_pid);
 		break;
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 8a5e823e0b33..4c471b4235ba 100644
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
-- 
2.19.2

