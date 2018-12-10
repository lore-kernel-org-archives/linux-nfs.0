Return-Path: <SRS0=PHUf=OT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02EBCC04EB8
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 16:29:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B9D042082F
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 16:29:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="EeKVCgxr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B9D042082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727473AbeLJQ32 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 10 Dec 2018 11:29:28 -0500
Received: from mail-it1-f195.google.com ([209.85.166.195]:52123 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728163AbeLJQ31 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2018 11:29:27 -0500
Received: by mail-it1-f195.google.com with SMTP id x19so18256534itl.1;
        Mon, 10 Dec 2018 08:29:25 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=Hk+H/FlUOfiDb+RjDzbB7nDXOiHXCNrQ5XBWd5waOJM=;
        b=EeKVCgxrXKO0DrTRuSK16ZZf9FMrJNizC5QZPW9irgvli6anL2uSSbLc6GSHkPN8pZ
         RY/FffrnnT2KKlJb2Tr9EgoEID/g3eq4Byi85Ij5ar33eZyYdg5ZfXeCqb7kyjx6WGCe
         BgXnLxPtouk4VfxUn/p74lvt4PFuJh/KCgtLpZw8w4DsJk3SF6wMMl/lX5aVdmNA+m1j
         904bfUB/sCi3WjJVzfnum4EIp31/qzqrvVKWyPlbKph6CTy9Y4uwHlZYqHcPn0fChYLY
         SFsKgXqHRShW4ARdxW7yi/sMvLVtjBGzhxTmTkEQdbUPei5L2FQHZnZ+K/opgUWA/OQD
         WjOQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=Hk+H/FlUOfiDb+RjDzbB7nDXOiHXCNrQ5XBWd5waOJM=;
        b=KN+1jg77Cufxi9tcAfpopTAat9H/S+FLa+s8KBnQP6KDx+FfTyAnkFobRH1Gt04eRJ
         4HjgJNePuKybIo96YIcdouCB8GXTFdO+XayGqNzEQMvcY3zk8vyt3pfkY5xMEzaWktbf
         ZWIZgF5cjAswXJYPcevVqHtVVpRIu2QnehT3PPWvtSLuZtk590KvK9gM1VwhxgQVPza5
         L8yVpTy9jKvfX97qXi3BHYJ51mLkAs7Rzk7O+3uHxqx683Of2FZM3IaUmvHZAsdtR+O8
         1195e9LjxPoDW+LlmShBbWJUFiqfgazN50OULaF1J75Xu0sRHhdVsgkTNuRHz9iUSonF
         ok9A==
X-Gm-Message-State: AA+aEWbJhPVD5sK6+L+/deTvleib+9Hy+jwKhRoPVyv3NM0mLD75j8qr
        iJUFv7Dn0JdUBUdTHXBHttq5xaIs
X-Google-Smtp-Source: AFSGD/WexSmDrJO3bZetI28CToiJaLMnN95MmNOdMeGdEAeZAhUkJuh1jTxl5poaZCPuVBWBU4PNuw==
X-Received: by 2002:a24:bd48:: with SMTP id x69mr10974535ite.81.1544459365476;
        Mon, 10 Dec 2018 08:29:25 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id g10sm4185980iop.25.2018.12.10.08.29.24
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 08:29:24 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBAGTNRU031014;
        Mon, 10 Dec 2018 16:29:23 GMT
Subject: [PATCH v3 01/24] xprtrdma: Prevent leak of rpcrdma_rep objects
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 10 Dec 2018 11:29:23 -0500
Message-ID: <20181210162923.4198.13485.stgit@manet.1015granger.net>
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

If a reply has been processed but the RPC is later retransmitted
anyway, the req->rl_reply field still contains the only pointer to
the old rpcrdma rep. When the next reply comes in, the reply handler
will stomp on the rl_reply field, leaking the old rep.

A trace event is added to capture such leaks.

This problem seems to be worsened by the restructuring of the RPC
Call path in v4.20. Fully addressing this issue will require at
least a re-architecture of the disconnect logic, which is not
appropriate during -rc.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/rpcrdma.h |   28 ++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/rpc_rdma.c |    4 ++++
 2 files changed, 32 insertions(+)

diff --git a/include/trace/events/rpcrdma.h b/include/trace/events/rpcrdma.h
index b093058..602972d 100644
--- a/include/trace/events/rpcrdma.h
+++ b/include/trace/events/rpcrdma.h
@@ -917,6 +917,34 @@
 DEFINE_CB_EVENT(xprtrdma_cb_call);
 DEFINE_CB_EVENT(xprtrdma_cb_reply);
 
+TRACE_EVENT(xprtrdma_leaked_rep,
+	TP_PROTO(
+		const struct rpc_rqst *rqst,
+		const struct rpcrdma_rep *rep
+	),
+
+	TP_ARGS(rqst, rep),
+
+	TP_STRUCT__entry(
+		__field(unsigned int, task_id)
+		__field(unsigned int, client_id)
+		__field(u32, xid)
+		__field(const void *, rep)
+	),
+
+	TP_fast_assign(
+		__entry->task_id = rqst->rq_task->tk_pid;
+		__entry->client_id = rqst->rq_task->tk_client->cl_clid;
+		__entry->xid = be32_to_cpu(rqst->rq_xid);
+		__entry->rep = rep;
+	),
+
+	TP_printk("task:%u@%u xid=0x%08x rep=%p",
+		__entry->task_id, __entry->client_id, __entry->xid,
+		__entry->rep
+	)
+);
+
 /**
  ** Server-side RPC/RDMA events
  **/
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 9f53e02..a2eb647 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -1356,6 +1356,10 @@ void rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 	}
 
 	req = rpcr_to_rdmar(rqst);
+	if (req->rl_reply) {
+		trace_xprtrdma_leaked_rep(rqst, req->rl_reply);
+		rpcrdma_recv_buffer_put(req->rl_reply);
+	}
 	req->rl_reply = rep;
 	rep->rr_rqst = rqst;
 	clear_bit(RPCRDMA_REQ_F_PENDING, &req->rl_flags);

