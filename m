Return-Path: <SRS0=idK9=OF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83B03C43441
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Nov 2018 20:07:30 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 46094205C9
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Nov 2018 20:07:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HsODZUul"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 46094205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727001AbeK0HCl (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 27 Nov 2018 02:02:41 -0500
Received: from mail-it1-f193.google.com ([209.85.166.193]:56174 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727234AbeK0HCk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Nov 2018 02:02:40 -0500
Received: by mail-it1-f193.google.com with SMTP id o19so30355729itg.5;
        Mon, 26 Nov 2018 12:07:26 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=o4T/kuXT2AXq22bdG8oX+0KaLdFcDFx3nH7CktLNld8=;
        b=HsODZUulZjIMyiinTRvI3T6tPM9UKeuBkQM/WYr/2H9K5dT3szzQXwMZsTfahg6XaC
         5ywEu1MikdXowm8dXwAyIJCv/+2Ji+bcNjzl+ATwu8PC53i9zz1v8E9aiWJAPjJ0hJnN
         Fdplel9GgaaqE5vTxMZ6j/w+cuZrM6TcAcVUcB5MMvxpUjpka91XzNlTkBgj6MOolxl/
         4lvfmbsjQHLZCeJO9KAq5CyJHuIv6IQvP6YsoKF8H9lXk28SOSMGg6O7OFPJLI3/IJvE
         Dxml/Ldq1zxQuixR+mumL8e7TBixt87ALB5Ocjz6qxkavzds1xvIcgLB07bZwSxBBRZi
         UI1Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=o4T/kuXT2AXq22bdG8oX+0KaLdFcDFx3nH7CktLNld8=;
        b=XiUJt8S5bIePyDIWceNa1EMeDZCzCLgrGM2pXfgBQ57u2t2dqO7SACsu+rZ4DOaAGP
         yvefFcm6DlU5J9TxSCR/1jzH4Hu28xeiVJ5HQSfnHtJDdTkWnUxAPi31es1xWPlTNRZh
         aTG28LFJcCD4k2CAWhkM/ICfw4e/ucA+AtzK4pfzGhG3JfoADGb+KuJTdw5s/Cj38nRN
         PVNaU+QySd8kSYbW79M2xhUMjdcdDcjGfU1Rmc1Y61LN39mg1hWLb7+uFfM5gatsvwor
         eY9rLS6EbN+XPPBAlU4mxUHsi54qJBk5VnBeBLpxgIpFi4DE1tEmZTnGJyhC2rG58rkH
         CKmw==
X-Gm-Message-State: AA+aEWa2BjUjNyBkAekSpBaNyhhz88f/Keod+EdtLvNSykywoKh/H3bK
        +436Ggvtp461oIWPc3Xkq/QGAfd/
X-Google-Smtp-Source: AJdET5dArYNXvU9D6TrTQpa0B2aQOhixquivOCQR1FUQ23FWlTSp1uEd34a9S6R1LBG45RKbKcBhDg==
X-Received: by 2002:a24:940f:: with SMTP id j15-v6mr24865738ite.12.1543262844950;
        Mon, 26 Nov 2018 12:07:24 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id 15sm991015itv.11.2018.11.26.12.07.24
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 12:07:24 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wAQK7NPr010698;
        Mon, 26 Nov 2018 20:07:23 GMT
Subject: [PATCH v2 18/20] SUNRPC: Fix some kernel doc complaints
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 26 Nov 2018 15:07:23 -0500
Message-ID: <20181126200723.10321.28175.stgit@manet.1015granger.net>
In-Reply-To: <20181126194611.10321.71714.stgit@manet.1015granger.net>
References: <20181126194611.10321.71714.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Clean up.

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
index ae77c71..4ef19c0 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1607,6 +1607,7 @@ static void xs_udp_set_buffer_size(struct rpc_xprt *xprt, size_t sndsize, size_t
 
 /**
  * xs_udp_timer - called when a retransmit timeout occurs on a UDP transport
+ * @xprt: controlling transport
  * @task: task that timed out
  *
  * Adjust the congestion window after a retransmit timeout has occurred.
@@ -2264,6 +2265,7 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 
 /**
  * xs_tcp_setup_socket - create a TCP socket and connect to a remote endpoint
+ * @work: queued work item
  *
  * Invoked by a work queue tasklet.
  */

