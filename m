Return-Path: <SRS0=PHUf=OT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92AA8C04EB8
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 16:30:53 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5530720821
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 16:30:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="IzmBiAOD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5530720821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728415AbeLJQaw (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 10 Dec 2018 11:30:52 -0500
Received: from mail-it1-f169.google.com ([209.85.166.169]:32943 "EHLO
        mail-it1-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726261AbeLJQaw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2018 11:30:52 -0500
Received: by mail-it1-f169.google.com with SMTP id m8so8413850itk.0;
        Mon, 10 Dec 2018 08:30:51 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=SJcMrwxu+G9rJtVuVfQqtypngoSzGPrG1TFAd0Mn5u8=;
        b=IzmBiAODPQa19W2SIdjXCapJtFmHCdo0Aat0zIi4E/7zUJD34QBFnv1EkwVdTAj4qb
         Hy/ED8muYyujg13gP/fxZDsjI8jFQp9Z70abIxFpuAeLK4MqQgpQWK5iZC77lviF4T/i
         wfDVRS3EzdVNJcvRBgqpx7prMAT6N0RIuTou6TvIoVS0/nmbyogxnLDu0U769PB3gdit
         NeRJMIwzj2p27zP4Ux1gPoCgxq3QbBMTmx50lT5viq2XvQXDP/85x7J+2LpfYqOVoOlb
         11SHMtz3NNyH2TuohWVL0wTGcOCF8X+nqlaJ43dFNOar5j29OmlNxOVcyWHXo9rmVP6p
         u/ow==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=SJcMrwxu+G9rJtVuVfQqtypngoSzGPrG1TFAd0Mn5u8=;
        b=jxmenb1ZIlMkN/bnWnEO1V5nmGhJKY5rhrXZX7LlYGM6HbPG5vbYIkYer94wpiivuw
         RBmKdh13S8sWGiyLAKEs1F+KOsMZO6l3tdkSX3jXhLCbp9tlX1fs3nSrfaP5M4DLQs8a
         oDJkF2yy1KDLWwyjAHyU9P8OGQ7esX36579UEf37wqLbK/ccdpW5YsYD9GOP6877b+kl
         2B5Vc4yRu3tfn9GcVEtaKgTZcB7NR1x/dM0/VyUh4MNR7R/WsFThXS+EzKJMrmGJ8al2
         MvVZpwgHLVf8QBUfLue+UHdDpNfl0q+bdSK6MkABvbWmh8Wuk6bFwtaX7ko/8u+YaYBd
         SRpA==
X-Gm-Message-State: AA+aEWZVfQeK3p36rMHYvZmNdCWuhifZSHph6sznleguUiNCnuQlCnub
        Kp5GltiuQTLLNBmqxXkA5hYOl1l3
X-Google-Smtp-Source: AFSGD/VgVs1bjN9uca0fdd9boZ8+d6TI/ydTNcWPzmi02w4NrNWPD4Cxv3BunsNEZTPNiJ5Zu/3j3A==
X-Received: by 2002:a02:7696:: with SMTP id z144mr11939458jab.102.1544459451088;
        Mon, 10 Dec 2018 08:30:51 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id u3sm667152ita.18.2018.12.10.08.30.50
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 08:30:50 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBAGUn2W031073;
        Mon, 10 Dec 2018 16:30:49 GMT
Subject: [PATCH v3 17/24] SUNRPC: Fix some kernel doc complaints
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 10 Dec 2018 11:30:49 -0500
Message-ID: <20181210163049.4198.21065.stgit@manet.1015granger.net>
In-Reply-To: <20181210161723.4198.51071.stgit@manet.1015granger.net>
References: <20181210161723.4198.51071.stgit@manet.1015granger.net>
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

