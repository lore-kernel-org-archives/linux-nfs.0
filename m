Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3A66C43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:41:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 70DBA2133F
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:41:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AC6GUX2+"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388235AbeLQQlh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 11:41:37 -0500
Received: from mail-it1-f193.google.com ([209.85.166.193]:50381 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2388011AbeLQQlh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 11:41:37 -0500
Received: by mail-it1-f193.google.com with SMTP id z7so19484525iti.0;
        Mon, 17 Dec 2018 08:41:36 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=SJcMrwxu+G9rJtVuVfQqtypngoSzGPrG1TFAd0Mn5u8=;
        b=AC6GUX2+Z0KIUx2uQXi2iDj2gpSb4IRVyCWzX2KyLiQ323xYiMCibPklI9E+jzLCLr
         O3fSLgXlaa6526OIA1+yNv6+YGfLWZhwq3Fzp1IHmm6h7dkwAMxqa3L7sgRNTKtIquDz
         nd3yNnTfj80mIKxgwRPnoRJ0CbfnCdn0G5TR8lWaDr5+qVf7UbNmvpHIkeFjuED0KLpB
         lv0W4Bd7Nupr0vC5nwb72sckRe3b8362Rkv4XX0w/Xp4PzzP/OGFjbWyG1F+y10JBazL
         /yf6tEuTR+Ksmuo+oLfAJXIQBQubKzzhFd9ZNFzIGsQ6OBqgZmadmrbQRUxNRbyf4GMs
         cGkw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=SJcMrwxu+G9rJtVuVfQqtypngoSzGPrG1TFAd0Mn5u8=;
        b=gQCwRha1w3X0d7F+bJfQHylJeHF8kURWsPty+RA8K67fl9AtTlqg/ea0kGljm8SkrZ
         WnxjDK6Cr46zMa/kHJxI4lRThBTTZH1VGXUP67oJ4Yr4yECNuzZ5yeOPstOqc64Cjq1F
         +TPMsgRphCJVRedauW47fs2/y+0mmSCrtufNbapebOTbulPfxz2Ng4jzgKTcx+xlkUXn
         RayV1fIvoLPdnrUXM3rywRSR9HrclKq2sBye2YjNmlQn3T5XMqPCqgGiHKsMaS5sJGR6
         FxXrB1bNRkT0ohvKJD5gmmKy3uUpifFxVZkHhg6CX+BQB8CApoDgSSDlOI1F+NxdKkXm
         Pkbw==
X-Gm-Message-State: AA+aEWZB5BHhaMhR5eTU5xXZKY1kiB94JWaksswUk4bFqusNbqKZqdoS
        dPhJZfOT0fbiCX5tQVVfiO21SwaI
X-Google-Smtp-Source: AFSGD/XZPmjJaHmSNkQ/1BXQKpzjMC6YqYsviZAADuYh+SbITKGM8vIFpqSCnn9IH1XcHTCa89WoQw==
X-Received: by 2002:a24:750f:: with SMTP id y15mr11932067itc.177.1545064896285;
        Mon, 17 Dec 2018 08:41:36 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id n124sm7686601itn.4.2018.12.17.08.41.35
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 08:41:35 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBHGfZV6018654;
        Mon, 17 Dec 2018 16:41:35 GMT
Subject: [PATCH v4 25/30] SUNRPC: Fix some kernel doc complaints
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 17 Dec 2018 11:41:35 -0500
Message-ID: <20181217164134.24133.91936.stgit@manet.1015granger.net>
In-Reply-To: <20181217162406.24133.27356.stgit@manet.1015granger.net>
References: <20181217162406.24133.27356.stgit@manet.1015granger.net>
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
index 8a5e823..8ee9831 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1602,6 +1602,7 @@ static void xs_udp_set_buffer_size(struct rpc_xprt *xprt, size_t sndsize, size_t
 
 /**
  * xs_udp_timer - called when a retransmit timeout occurs on a UDP transport
+ * @xprt: controlling transport
  * @task: task that timed out
  *
  * Adjust the congestion window after a retransmit timeout has occurred.
@@ -2259,6 +2260,7 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 
 /**
  * xs_tcp_setup_socket - create a TCP socket and connect to a remote endpoint
+ * @work: queued work item
  *
  * Invoked by a work queue tasklet.
  */

