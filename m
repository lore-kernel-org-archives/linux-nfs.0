Return-Path: <SRS0=idK9=OF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F681C43441
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Nov 2018 20:06:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D30C4205C9
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Nov 2018 20:06:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="oapGAdSn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D30C4205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727222AbeK0HCI (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 27 Nov 2018 02:02:08 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:36469 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726296AbeK0HCI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Nov 2018 02:02:08 -0500
Received: by mail-it1-f196.google.com with SMTP id c9so29978337itj.1;
        Mon, 26 Nov 2018 12:06:54 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=X9usjo53GmlpOAGHzhioJW6830lwMRdrZemp/ghJFMU=;
        b=oapGAdSn84MshqMDjRReCTed4D6dK8vu5oxraYKU0ZMz9U9RjLPeEzLQlwJ2CEdcQt
         A9eGg/ZWlT+OoaPRu3MRMZ4JDQdsljqmAl3gmarNu34aZB8Z20/92P3LP7UraiL9iqad
         Z4kQZ6JIJ2G3PixSTXPHZzkcKU3S4+RAjHYFIGrnKuIb8q02b6rCa3j2VEIxXCd0bPO1
         OixlPba5l4ur537px+xvizMwMDOuv4n3EK+Ex0CCnx1tJOhwkZkQPDNEmw2jsv7/HGl5
         XtIRl6fEEqnHGeUlPOcxhXta3nJ7KCNMJcDfYqFgP43b67Ow3V5eJNwzLMGYK0OXJftP
         mFSA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=X9usjo53GmlpOAGHzhioJW6830lwMRdrZemp/ghJFMU=;
        b=EO7jSViGRxPiXsTYgscJbvnLJscS+jW6Jf2OkeoBoj8lqsLWLYoU85ThorbiVSiGM6
         qiQ8bHuK4+a6IT0CF0KbetGBtUbPgAUvt/CApRSARF+xofYkxCwUJg5jYJ8utlSybXQm
         74fDZ/u92ywR1pw5blfN0bDt8ew+A5AOFHhQrOU+FpeUxMNSRQ/grRZ0id10YfKIYm2T
         TyUItPScY1ZU4uwMDNLVI2f5PS93BUSMlC5IhvDDrJy1HSiDggBEUOArpiOzz4h0VtwL
         Fc7UONUhtvh+qtmIbt56Bggr0cqx7XB6cHTCF5gMWv849D7705UrdsHnxVl9LeZZOwtC
         n4eg==
X-Gm-Message-State: AA+aEWZP1ZqvlPBt34DKRPE4cJK7ZnYecURu7t2xd0APJ3QJfguRCXTw
        3vkLmFKSvvSHu30XcUW9arppPioA
X-Google-Smtp-Source: AFSGD/UtrIREby11+KDoIXjsvHIzXbtVd1mYvxfWYrDldWfk+/hgruXjju0++yNW+CB5exOCnN9RdA==
X-Received: by 2002:a24:138b:: with SMTP id 133-v6mr16311564itz.117.1543262813448;
        Mon, 26 Nov 2018 12:06:53 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id j14sm452730ioa.5.2018.11.26.12.06.52
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 12:06:52 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wAQK6piW010678;
        Mon, 26 Nov 2018 20:06:51 GMT
Subject: [PATCH v2 12/20] xprtrdma: Dynamically allocate rpcrdma_reqs
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 26 Nov 2018 15:06:51 -0500
Message-ID: <20181126200651.10321.94187.stgit@manet.1015granger.net>
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

rpcrdma_reps are dynamically allocated according to the server's
credit grant and the workload. rpcrdma_reqs can also be allocated
on demand. Having a number of these around means the transport can
handle minor bursts of RPC traffic easily.

Unlike TCP's dynamic slot allocator, these are not released by
->free_slot. This is because rpcrdma_reqs are large and have DMA
mapped buffers associated with them, and thus are costly to set up.

Instead, if the system needs memory, a shrinker can steal a few free
rpcrdma_reqs per transport. That can be added later if there is a
strong need.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/transport.c |    1 +
 net/sunrpc/xprtrdma/verbs.c     |   12 ++++++++----
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 3cbc9b7..254cb8c 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -450,6 +450,7 @@
 		xprt_clear_connected(xprt);
 		rpcrdma_ia_remove(ia);
 		clear_bit(RPCRDMA_IAF_REMOVING, &ia->ri_flags);
+		rpc_wake_up_next(&xprt->backlog);
 		return;
 	}
 	if (ep->rep_connected == -ENODEV)
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 6308e60..73d5247 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1171,7 +1171,7 @@ struct rpcrdma_req *
 	INIT_LIST_HEAD(&buf->rb_allreqs);
 
 	rc = -ENOMEM;
-	for (i = 0; i < buf->rb_max_requests; i++) {
+	for (i = 0; i < RPCRDMA_MIN_SLOT_TABLE; i++) {
 		struct rpcrdma_req *req;
 
 		req = rpcrdma_req_create(buf, GFP_KERNEL);
@@ -1360,9 +1360,13 @@ struct rpcrdma_req *
 	spin_lock(&buffers->rb_lock);
 	req = list_first_entry_or_null(&buffers->rb_send_bufs,
 				       struct rpcrdma_req, rl_list);
-	if (req)
-		list_del_init(&req->rl_list);
-	spin_unlock(&buffers->rb_lock);
+	if (req) {
+		list_del(&req->rl_list);
+		spin_unlock(&buffers->rb_lock);
+	} else {
+		spin_unlock(&buffers->rb_lock);
+		req = rpcrdma_req_create(buffers, GFP_NOFS);
+	}
 	return req;
 }
 

