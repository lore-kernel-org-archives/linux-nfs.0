Return-Path: <SRS0=Z4n1=RO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2DB97C43381
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Mar 2019 01:31:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EF67920652
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Mar 2019 01:31:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rpQIoFBd"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726916AbfCKBbL (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 10 Mar 2019 21:31:11 -0400
Received: from mail-io1-f47.google.com ([209.85.166.47]:40610 "EHLO
        mail-io1-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727056AbfCKBbL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 10 Mar 2019 21:31:11 -0400
Received: by mail-io1-f47.google.com with SMTP id p17so2603848iol.7
        for <linux-nfs@vger.kernel.org>; Sun, 10 Mar 2019 18:31:10 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=7XDzLdk6wYYHBUZn6T3GDQV3N0qgM4JOMSW85fV9bEw=;
        b=rpQIoFBdCQN3EypyT0BvhqisgJOZMhVTi7vR6pUPeNCMvS5+7xSuL2TufabjKjNMTn
         7V/+fKPU6t3QXo9wsYxC1XGj5ZoC+CdZiBnrpmncVoUMcirvA3xL5K/5mvZWYTM27JeR
         ovHGLi2kfHH25GJfweQ+b08V4gymFC/YL/+dNY6O6lvtpJZkF4BOW85OPdlT7OYQJjAZ
         JvSLhx/fvKd2eJPV40LzaMdxc+YhWcT4Vcieyk9zUVlhQV5nwMX+r3upsp6Ec19OE7QS
         77PiqBIdaju4BF3V6xKDcazbaMCAyt37MvIJc6B3bPvz5LqZGFTUqTsjs22lfxmrf74w
         K/Lg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=7XDzLdk6wYYHBUZn6T3GDQV3N0qgM4JOMSW85fV9bEw=;
        b=uHxfI6/yTbXQ99JxhRoHhylQiwcvlVdcYSrOItFTmB66TntAt3sufRVCayyqsIuri9
         TaSiUXlYHpLZqkDKy/Mgt7SFc1oEvlW/YUh3pdKngjE5YQ00lDgavi47AnlQa2BSKZ4c
         j+ZaAe4FvcouNZmTQuuvn1o42O4HrQr3WJG5hUwODTJXsU+1maf7zGbMdvBYtVcgOpnl
         tiGJcRKKXU7nYBcz1RbGDOvX7xcMqSnftrPJ2s2uLJ3wAWSIBCVyLrcIUBRrFZbTNT+W
         qqFR+goAvKMVtKsJWiE1Oy2uRugAfR16JrNRibGqhDkzWvJePpa0xzTYA1Ta17sFewju
         GkgQ==
X-Gm-Message-State: APjAAAVW8KJEowVbluco/cf/Irl/2AE70W532ngoYdHjkeEkhpWDw3Yt
        SVKIldKgOKUXYTgH3H/ar5o525A=
X-Google-Smtp-Source: APXvYqzjH8tj56BkqGoxySzPZIrvkd7jMphPz+4vQtb0b1frKnKFPXzjB4+3C5qr0kIG8Uq+G60tYg==
X-Received: by 2002:a6b:7219:: with SMTP id n25mr6872288ioc.117.1552267869492;
        Sun, 10 Mar 2019 18:31:09 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id p79sm7515011itb.7.2019.03.10.18.31.08
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 10 Mar 2019 18:31:08 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 5/5] SUNRPC: Take the transport send lock before binding+connecting
Date:   Sun, 10 Mar 2019 21:29:57 -0400
Message-Id: <20190311012957.3994-5-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190311012957.3994-4-trond.myklebust@hammerspace.com>
References: <20190311012957.3994-1-trond.myklebust@hammerspace.com>
 <20190311012957.3994-2-trond.myklebust@hammerspace.com>
 <20190311012957.3994-3-trond.myklebust@hammerspace.com>
 <20190311012957.3994-4-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Before trying to bind a port, ensure we grab the send lock to
ensure that we don't change the port while another task is busy
transmitting requests.
The connect code already takes the send lock in xprt_connect(),
but it is harmless to take it before that.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/clnt.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 498dd6ad5bc5..4216fe33204a 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1867,6 +1867,9 @@ call_bind(struct rpc_task *task)
 	dprint_status(task);
 
 	task->tk_action = call_bind_status;
+	if (!xprt_prepare_transmit(task))
+		return;
+
 	task->tk_timeout = xprt->bind_timeout;
 	xprt->ops->rpcbind(task);
 }
@@ -1911,6 +1914,8 @@ call_bind_status(struct rpc_task *task)
 		task->tk_rebind_retry--;
 		rpc_delay(task, 3*HZ);
 		goto retry_timeout;
+	case -EAGAIN:
+		goto retry_timeout;
 	case -ETIMEDOUT:
 		dprintk("RPC: %5u rpcbind request timed out\n",
 				task->tk_pid);
@@ -1952,7 +1957,7 @@ call_bind_status(struct rpc_task *task)
 
 retry_timeout:
 	task->tk_status = 0;
-	task->tk_action = call_encode;
+	task->tk_action = call_bind;
 	rpc_check_timeout(task);
 }
 
@@ -1986,6 +1991,8 @@ call_connect(struct rpc_task *task)
 		rpc_exit(task, -ENOTCONN);
 		return;
 	}
+	if (!xprt_prepare_transmit(task))
+		return;
 	xprt_connect(task);
 }
 
-- 
2.20.1

