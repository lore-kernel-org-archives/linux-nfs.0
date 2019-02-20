Return-Path: <SRS0=q2Lh=Q3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3BD5CC4360F
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 03:04:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0310A21738
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 03:04:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="LfGP6j62"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727576AbfBTDEz (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 22:04:55 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:53284 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730294AbfBTDEy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Feb 2019 22:04:54 -0500
Received: by mail-it1-f196.google.com with SMTP id x131so11868208itc.3
        for <linux-nfs@vger.kernel.org>; Tue, 19 Feb 2019 19:04:54 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Yy9Xb49TwkFxziiRu/R/ocobF/tPtbPtQyavRZ/j5ek=;
        b=LfGP6j62phosiI7istMqYOZSVgwzyFUY9WH418wxwHXpNC/aRFTwS6R16VtbHcyync
         2RMfGlmtPEMOPreiFad+tCwR05HmMvjjXDWm6e84wc7cSyG4knnNhy2IyPEscGB3cltZ
         5u3b+sknBLmJ/6Y8ubiqjJsHaKAkYSmfd/Oulk7SI3LZbpc+4XIPNBTs0x4tWBbh2T/C
         I60kotKxHtDVzLoDSQ2qQExAKtG+5FNaeIkTpP3EBB/PVeMj6l8MIIszY1l5y3e17bFU
         EiQIpPWDVHb1jwWLg+fTwlS60ozGymPN8pd7fKdmNU+gZKS77hytIySRUCzho2oxkK7S
         BnTw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=Yy9Xb49TwkFxziiRu/R/ocobF/tPtbPtQyavRZ/j5ek=;
        b=XM/awiqGIMMyOBA8f/eER1WpLiyPBsbYhd1I/lLpIXLVsbannpvKi1SDRL81LmV/eo
         4tCWI5MrL42zvAcEG7wzo+GNe8Tzc/fhvi9p0ZCd2ULbt/AY4SRSNl17m3YjV9WG1ytR
         x2U/Rq2hplsQQ9GuVM9RX8k+iftgr1W9vaxZsIxtgRDRW+nRfxQ/1h9qVxQjBkLSvnxJ
         9xxHH+5SKXmk/aK6xYKWP/dP7F/6VbMRfQOiwAALOOuZYd3CGYF+1sBmjLjCY2DsYGDC
         M4M92EGiLbhWfFyY+EknumkmFFzxofmst3jajV5iQy0OBfOzZi0GmSRnFj8qpBJJe1Kk
         WysQ==
X-Gm-Message-State: AHQUAubGpwZPffNx0iXDNLrqp9rWFfgFccjP+Uh1ZSGiO5M7bWyL1fa6
        ZYrKdXsVaCrvBWPpcek86Gem25I=
X-Google-Smtp-Source: AHgI3IYKMqfS0iw4CpAske1kmugHaFysYErqDwLXkVA9wXZqoEzZBaEd6s7aysS6XT+pf1VRPX7bsg==
X-Received: by 2002:a24:415a:: with SMTP id x87mr1111388ita.93.1550631893555;
        Tue, 19 Feb 2019 19:04:53 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id a192sm2036924ita.0.2019.02.19.19.04.52
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 19:04:53 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 4/4] SUNRPC: Remove the redundant 'zerocopy' argument to xs_sendpages()
Date:   Tue, 19 Feb 2019 22:03:41 -0500
Message-Id: <20190220030341.58766-5-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190220030341.58766-4-trond.myklebust@hammerspace.com>
References: <20190220030341.58766-1-trond.myklebust@hammerspace.com>
 <20190220030341.58766-2-trond.myklebust@hammerspace.com>
 <20190220030341.58766-3-trond.myklebust@hammerspace.com>
 <20190220030341.58766-4-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/xprtsock.c | 16 ++++------------
 1 file changed, 4 insertions(+), 12 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 73586114b825..9fe74d79cdc7 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -760,11 +760,10 @@ static int xs_send_pagedata(struct socket *sock, struct msghdr *msg, struct xdr_
  * @addrlen: UDP only -- length of destination address
  * @xdr: buffer containing this request
  * @base: starting position in the buffer
- * @zerocopy: true if it is safe to use sendpage()
  * @sent_p: return the total number of bytes successfully queued for sending
  *
  */
-static int xs_sendpages(struct socket *sock, struct sockaddr *addr, int addrlen, struct xdr_buf *xdr, unsigned int base, bool zerocopy, int *sent_p)
+static int xs_sendpages(struct socket *sock, struct sockaddr *addr, int addrlen, struct xdr_buf *xdr, unsigned int base, int *sent_p)
 {
 	struct msghdr msg = {
 		.msg_name = addr,
@@ -919,7 +918,7 @@ static int xs_local_send_request(struct rpc_rqst *req)
 	req->rq_xtime = ktime_get();
 	status = xs_sendpages(transport->sock, NULL, 0, xdr,
 			      transport->xmit.offset,
-			      true, &sent);
+			      &sent);
 	dprintk("RPC:       %s(%u) = %d\n",
 			__func__, xdr->len - transport->xmit.offset, status);
 
@@ -986,7 +985,7 @@ static int xs_udp_send_request(struct rpc_rqst *req)
 
 	req->rq_xtime = ktime_get();
 	status = xs_sendpages(transport->sock, xs_addr(xprt), xprt->addrlen,
-			      xdr, 0, true, &sent);
+			      xdr, 0, &sent);
 
 	dprintk("RPC:       xs_udp_send_request(%u) = %d\n",
 			xdr->len, status);
@@ -1050,7 +1049,6 @@ static int xs_tcp_send_request(struct rpc_rqst *req)
 	struct rpc_xprt *xprt = req->rq_xprt;
 	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
 	struct xdr_buf *xdr = &req->rq_snd_buf;
-	bool zerocopy = true;
 	bool vm_wait = false;
 	int status;
 	int sent;
@@ -1067,12 +1065,6 @@ static int xs_tcp_send_request(struct rpc_rqst *req)
 	xs_pktdump("packet data:",
 				req->rq_svec->iov_base,
 				req->rq_svec->iov_len);
-	/* Don't use zero copy if this is a resend. If the RPC call
-	 * completes while the socket holds a reference to the pages,
-	 * then we may end up resending corrupted data.
-	 */
-	if (req->rq_task->tk_flags & RPC_TASK_SENT)
-		zerocopy = false;
 
 	if (test_bit(XPRT_SOCK_UPD_TIMEOUT, &transport->sock_state))
 		xs_tcp_set_socket_timeouts(xprt, transport->sock);
@@ -1085,7 +1077,7 @@ static int xs_tcp_send_request(struct rpc_rqst *req)
 		sent = 0;
 		status = xs_sendpages(transport->sock, NULL, 0, xdr,
 				      transport->xmit.offset,
-				      zerocopy, &sent);
+				      &sent);
 
 		dprintk("RPC:       xs_tcp_send_request(%u) = %d\n",
 				xdr->len - transport->xmit.offset, status);
-- 
2.20.1

