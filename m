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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B7CBC43612
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 22:53:47 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4978F21473
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 22:53:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="YIyFtgPM"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726548AbeLQWxq (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 17:53:46 -0500
Received: from mail-oi1-f194.google.com ([209.85.167.194]:43965 "EHLO
        mail-oi1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728393AbeLQWxq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 17:53:46 -0500
Received: by mail-oi1-f194.google.com with SMTP id u18so396434oie.10
        for <linux-nfs@vger.kernel.org>; Mon, 17 Dec 2018 14:53:46 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=OYdSkdwnF17y1PiG4MmckyXHoUkwaxYyhRRTBSGfoWI=;
        b=YIyFtgPM8zRM5Cd5yWv/5kgYkSgTMEzJSWBMPcmNaeRnHNA0eB1PkA90QiuD4Ca8Fs
         ZXiAL3VXJyrCnohytdACmmEHY6zHYOoD640xqhxSFvaWmCrsBY2Yl9R1T7KCPsO98EY0
         MCI6GSyPexiU5Ahg54FA83r5ZOEi2MIWpsZIAlD4PY58bdEmD48B6I8YxjjVMxgXwBNn
         6HRNnd7GVPIRbbm55DzwKW7wUO6a8wzyMwswls+Ja4ySbbcoTkO/0zpNy02AHqbAmPaG
         lJU9YXRndgzAuAPDy7s1EGk1uvE0ZTNc04FpTWRQlZDnwKd2/PmlFrnTii1+CipHfS3B
         y+Gw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=OYdSkdwnF17y1PiG4MmckyXHoUkwaxYyhRRTBSGfoWI=;
        b=SnzNVAW8lycsSoPTTJyrlWiuOXygiloy2nfi0KKci2oiCv15nlT6tZeMbpH9MBPUeR
         bxu+ZAdWj/a9oahLg0AzJBJ7g4F+CyDcPlt2bFf+lAsPp6o5YOVuvUaLkLfgrYpu/e94
         NjJk9EczjoPUnMeVOgd57bJjJ4qrWkdG6KRHHYsbPTSbFkOQtY/sJIbOsYvLFx3A0ThN
         DYxf4efnkem6DYZPyVO907g5T/7kqz7h4xI5QJB9mhullDoNZI9Rc9uEw0WqrqTykp1s
         7Mu8p7zZ8UCvdgaOaJ3Tez4qibtPBY4I/IRYbCXQ4XobYmLk9D9RCdleOPdYudG2Ka2D
         k5VA==
X-Gm-Message-State: AA+aEWbjpyEWerz6mREj+M2FnTHwtfnG7fD9PHKAWdYRaRoZaA/qUnh0
        055yiHMUlGQPykK9KmVkzA==
X-Google-Smtp-Source: AFSGD/WvWqfaHsoE6d2OW9QXnygmMk0al7nhSHMArY4rq275PQTgwjvJ5NRkz3UTWcCbmLknrfwV8g==
X-Received: by 2002:aca:b102:: with SMTP id a2mr6762362oif.180.1545087225671;
        Mon, 17 Dec 2018 14:53:45 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id 30sm6984266ots.52.2018.12.17.14.53.44
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Dec 2018 14:53:45 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Dave Wysochanski <dwysocha@redhat.com>,
        Scott Mayhew <smayhew@redhat.com>
Cc:     Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/3] SUNRPC: Fix a race with XPRT_CONNECTING
Date:   Mon, 17 Dec 2018 17:52:34 -0500
Message-Id: <20181217225235.124448-2-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.19.2
In-Reply-To: <20181217225235.124448-1-trond.myklebust@hammerspace.com>
References: <20181217225235.124448-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Ensure that we clear XPRT_CONNECTING before releasing the XPRT_LOCK so that
we don't have races between the (asynchronous) socket setup code and
tasks in xprt_connect().

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/xprtsock.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 4c471b4235ba..f0b3700cec95 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2090,8 +2090,8 @@ static void xs_udp_setup_socket(struct work_struct *work)
 	trace_rpc_socket_connect(xprt, sock, 0);
 	status = 0;
 out:
-	xprt_unlock_connect(xprt, transport);
 	xprt_clear_connecting(xprt);
+	xprt_unlock_connect(xprt, transport);
 	xprt_wake_pending_tasks(xprt, status);
 }
 
@@ -2327,8 +2327,8 @@ static void xs_tcp_setup_socket(struct work_struct *work)
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

