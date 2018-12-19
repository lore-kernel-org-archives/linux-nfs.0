Return-Path: <SRS0=a7kO=O4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE6AFC43387
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 16:00:27 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 83B8F217D9
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 16:00:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Vx+0MCCk"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729561AbeLSQAY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Dec 2018 11:00:24 -0500
Received: from mail-io1-f67.google.com ([209.85.166.67]:35467 "EHLO
        mail-io1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726652AbeLSQAY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Dec 2018 11:00:24 -0500
Received: by mail-io1-f67.google.com with SMTP id o13so275304ioh.2;
        Wed, 19 Dec 2018 08:00:23 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=yZQOIXq8m8T5Efj8bS/bVcfcxBqC9DeCwu7vAOO8MfU=;
        b=Vx+0MCCkHGc4rRgTVq3WR1EFeyxFbcoS/qhi2T7ZR31nB0O8xqEAG3evxsTDbzx04W
         CEOAP1lxiVWyOXZQCyungQsk8yENZ8F6kK+ZJ1Opd7Vs0Tnpa2WLYKtVA0mi1Fm+9hsy
         mJD6X1THFR9wEJAihtMHDySHT00k+KNEFP5FOW+VUrdiN64/qoXjsJHn5slJTlu8GFiU
         qOAtkJzJYRZ4GgBXsF4gCXAKP/zd/LgzOUzts7bv1wrLSM66SWnK2TuEo+EFcceH4Cke
         2orqQrg4TmCgEi8NdZvy2Pxt6k2EzdlLHqtI8rR9qGYy9R/Se0tlQwQUqsTwFDtcqrBt
         IbIg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=yZQOIXq8m8T5Efj8bS/bVcfcxBqC9DeCwu7vAOO8MfU=;
        b=CJQYoJzUSf2l+XQao5NgStcry4JFXhus0ErFk2tEEJGpSFNvPWDHOytTcjWItrkdQP
         jsUKya3gLrT6YoqQFUQmqtqw1LQPoIt8b5e29s6E32PSmldiAHuac7SnCKEhY0mzKV6G
         YmTm1oPAz/T57iQIq8TC0fFWv71ILqUIlAA/RnPTtljxnSDXxE+eoMDIHUPE+bmuvkO9
         IT29CxNaofZK3kYfIOa5yF0M/1aoUpeKWEOUT1le9HfdqdvLwsW2XxdJLxYS03YTCFRe
         fJ8+xf5d0Ay6fTRg6ZLWYglCCoikDXc7BI9ow/UWuO69KlzzpIbZxGeSJy8Ns/zfVzJE
         5Opw==
X-Gm-Message-State: AA+aEWYB8JH5PVw3SFyQ6FgxzeC6KLuIxasdRy/ygtCTLtVI+Mu3p8YY
        9isRje6BAR2u1ob6W+4TO64CIaGi
X-Google-Smtp-Source: AFSGD/WhmKV6E1HW1JAVJJkKiXpVCu/CLxJ2ZE3WxcRapqahf9f5Vcvp5DNEvYw2kOxiToewQXOSGQ==
X-Received: by 2002:a6b:720f:: with SMTP id n15mr18679088ioc.175.1545235223493;
        Wed, 19 Dec 2018 08:00:23 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id x79sm3373857ita.34.2018.12.19.08.00.22
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 08:00:22 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBJG0MtO025841;
        Wed, 19 Dec 2018 16:00:22 GMT
Subject: [PATCH v5 25/30] SUNRPC: Fix some kernel doc complaints
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 19 Dec 2018 11:00:22 -0500
Message-ID: <20181219160022.11602.84906.stgit@manet.1015granger.net>
In-Reply-To: <20181219155152.11602.18605.stgit@manet.1015granger.net>
References: <20181219155152.11602.18605.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Clean up some warnings observed when building with "make W=1".

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/auth_gss/gss_mech_switch.c |    2 +-
 net/sunrpc/backchannel_rqst.c         |    2 +-
 net/sunrpc/xprtmultipath.c            |    4 ++--
 net/sunrpc/xprtsock.c                 |    2 ++
 4 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_mech_switch.c b/net/sunrpc/auth_gss/gss_mech_switch.c
index 16ac0f4..379318d 100644
--- a/net/sunrpc/auth_gss/gss_mech_switch.c
+++ b/net/sunrpc/auth_gss/gss_mech_switch.c
@@ -244,7 +244,7 @@ struct gss_api_mech *
 
 /**
  * gss_mech_list_pseudoflavors - Discover registered GSS pseudoflavors
- * @array: array to fill in
+ * @array_ptr: array to fill in
  * @size: size of "array"
  *
  * Returns the number of array items filled in, or a negative errno.
diff --git a/net/sunrpc/backchannel_rqst.c b/net/sunrpc/backchannel_rqst.c
index fa5ba6e..ec451b8 100644
--- a/net/sunrpc/backchannel_rqst.c
+++ b/net/sunrpc/backchannel_rqst.c
@@ -197,7 +197,7 @@ int xprt_setup_bc(struct rpc_xprt *xprt, unsigned int min_reqs)
 /**
  * xprt_destroy_backchannel - Destroys the backchannel preallocated structures.
  * @xprt:	the transport holding the preallocated strucures
- * @max_reqs	the maximum number of preallocated structures to destroy
+ * @max_reqs:	the maximum number of preallocated structures to destroy
  *
  * Since these structures may have been allocated by multiple calls
  * to xprt_setup_backchannel, we only destroy up to the maximum number
diff --git a/net/sunrpc/xprtmultipath.c b/net/sunrpc/xprtmultipath.c
index e2d64c7..8394124 100644
--- a/net/sunrpc/xprtmultipath.c
+++ b/net/sunrpc/xprtmultipath.c
@@ -383,7 +383,7 @@ void xprt_iter_init_listall(struct rpc_xprt_iter *xpi,
 /**
  * xprt_iter_xchg_switch - Atomically swap out the rpc_xprt_switch
  * @xpi: pointer to rpc_xprt_iter
- * @xps: pointer to a new rpc_xprt_switch or NULL
+ * @newswitch: pointer to a new rpc_xprt_switch or NULL
  *
  * Swaps out the existing xpi->xpi_xpswitch with a new value.
  */
@@ -401,7 +401,7 @@ struct rpc_xprt_switch *xprt_iter_xchg_switch(struct rpc_xprt_iter *xpi,
 
 /**
  * xprt_iter_destroy - Destroys the xprt iterator
- * @xpi pointer to rpc_xprt_iter
+ * @xpi: pointer to rpc_xprt_iter
  */
 void xprt_iter_destroy(struct rpc_xprt_iter *xpi)
 {
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index f0b3700..d5ce1a8 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1600,6 +1600,7 @@ static void xs_udp_set_buffer_size(struct rpc_xprt *xprt, size_t sndsize, size_t
 
 /**
  * xs_udp_timer - called when a retransmit timeout occurs on a UDP transport
+ * @xprt: controlling transport
  * @task: task that timed out
  *
  * Adjust the congestion window after a retransmit timeout has occurred.
@@ -2257,6 +2258,7 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 
 /**
  * xs_tcp_setup_socket - create a TCP socket and connect to a remote endpoint
+ * @work: queued work item
  *
  * Invoked by a work queue tasklet.
  */

