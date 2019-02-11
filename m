Return-Path: <SRS0=ULVj=QS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C13D5C169C4
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Feb 2019 16:23:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 90C11218F0
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Feb 2019 16:23:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="P0MEPWSc"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726941AbfBKQX5 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 11 Feb 2019 11:23:57 -0500
Received: from mail-it1-f195.google.com ([209.85.166.195]:50993 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726892AbfBKQX5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Feb 2019 11:23:57 -0500
Received: by mail-it1-f195.google.com with SMTP id z7so27806292iti.0;
        Mon, 11 Feb 2019 08:23:56 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=th1O/wngdFHrunVx5REJASdpDp11bszNdXSRvbqxJFo=;
        b=P0MEPWSc7/Ux/owdLMthOmTwoAhjyBZy1ESm91k9wanj30NspTeDmD2tSbJGh5SCpb
         tFhvd1JI2JPc7QmkUIhqZ91EiQ9mhzZSac03UcWE6i5y89K6GzlNHt/BCjGZ7didMKaB
         1K0/ML7SJC2gnIlI3lPvuEaAmWne6JR/NCjAdVP96tKSO8XbJ6er1xIgUuvm6S8hjIWv
         nVQz3WmthC14mjHJ9e9ZzOytpTt5zmULubUNEn0y1izYrMzFTngM0fxUlIkE0uBEXkFi
         LwnSsyJ1L19itA/wPF94ViTjnOf4eOCg/CjN5L1uSdkDQUvZRcFcjcozeiR6ZinQi73x
         xItg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=th1O/wngdFHrunVx5REJASdpDp11bszNdXSRvbqxJFo=;
        b=BePkmil7jCE7jghlzeC29OTGRjD/I+GGkkGuyTcRPj1N4wukeC22myJYyszkgJL438
         OKO+NQiCT97STcG5tkW8SZon4EJh2zsqYaKvB1mpjsBLRKm1/yLyPQqaALaWaWX54xQ3
         qoWgb3fVfP373DJb+N51HEr8upt1/792jwNN9ls2RrIBdflg08hPXYQPkZpU7nbDjemN
         rreoJhh3f7PMH84xvJqHISFs0PTejcvls2Mc+unbobuyjgIXWnj0bseY9UBDu9QDLcYK
         pJXTJzMsTDnmU/5fiLUlf47ZpF0tDtAPkFY14yAscA8O+5dYFCQuABuDAVoWfPUhwe3e
         +DBA==
X-Gm-Message-State: AHQUAuaM93wJxgf5/EgTREM3cumTT4EnNbglPyLCQfvQ1Bo3MSeME8JD
        UI/3ER1CZV/9fq4WEYO5N+8=
X-Google-Smtp-Source: AHgI3IYinLotN5mo1DmV1c4QoD530pgtRvAEqi6bB4szK3CZQ8xFFEgwbtTGYd2PDlmLpEjvkPowUA==
X-Received: by 2002:a6b:ef0b:: with SMTP id k11mr20718390ioh.186.1549902236296;
        Mon, 11 Feb 2019 08:23:56 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id s4sm4505684iom.83.2019.02.11.08.23.55
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 08:23:55 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x1BGNsXt029961;
        Mon, 11 Feb 2019 16:23:54 GMT
Subject: [PATCH v1 03/23] xprtrdma: Reduce the doorbell rate (Receive)
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 11 Feb 2019 11:23:54 -0500
Message-ID: <20190211162354.2817.81043.stgit@manet.1015granger.net>
In-Reply-To: <20190211161920.2817.20881.stgit@manet.1015granger.net>
References: <20190211161920.2817.20881.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Post RECV WRs in batches to reduce the hardware doorbell rate per
transport. This helps the RPC-over-RDMA client scale better in
number of transports.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c     |    2 ++
 net/sunrpc/xprtrdma/xprt_rdma.h |   10 ++++++++++
 2 files changed, 12 insertions(+)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 4994e75..b4e997d 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1480,6 +1480,8 @@ struct rpcrdma_regbuf *
 	if (ep->rep_receive_count > needed)
 		goto out;
 	needed -= ep->rep_receive_count;
+	if (!temp)
+		needed += RPCRDMA_MAX_RECV_BATCH;
 
 	count = 0;
 	wr = NULL;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 33db208..10f6593 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -205,6 +205,16 @@ struct rpcrdma_rep {
 	struct ib_recv_wr	rr_recv_wr;
 };
 
+/* To reduce the rate at which a transport invokes ib_post_recv
+ * (and thus the hardware doorbell rate), xprtrdma posts Receive
+ * WRs in batches.
+ *
+ * Setting this to zero disables Receive post batching.
+ */
+enum {
+	RPCRDMA_MAX_RECV_BATCH = 7,
+};
+
 /* struct rpcrdma_sendctx - DMA mapped SGEs to unmap after Send completes
  */
 struct rpcrdma_req;

