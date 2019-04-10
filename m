Return-Path: <SRS0=wtRa=SM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37C61C10F11
	for <linux-nfs@archiver.kernel.org>; Wed, 10 Apr 2019 20:07:33 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 058652075B
	for <linux-nfs@archiver.kernel.org>; Wed, 10 Apr 2019 20:07:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="YL+dylZ6"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726630AbfDJUHc (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 10 Apr 2019 16:07:32 -0400
Received: from mail-it1-f193.google.com ([209.85.166.193]:35071 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726527AbfDJUHc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Apr 2019 16:07:32 -0400
Received: by mail-it1-f193.google.com with SMTP id w15so5644205itc.0;
        Wed, 10 Apr 2019 13:07:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=Cr96/Hl1X30wUkSboDTPUY+7mirgh5yOh7X3lSrBBeY=;
        b=YL+dylZ6SKL6eg8xVamQvkO26FMfKZ3z4PvHj//LXwLQAD5G4ZvPjYlhPqEczC1D5l
         6aGcpS1auiqLrBTr68DMd4Bbc4kfvJRjk82u6ojiWS8GExWmBApW2DpuJ+pGySk6hEWY
         5pBKdIP5UQdN0311XCE/+zy9Iu5CzCugcj5r5AMk3ULw6ry0N21WdL7dG9WftoQ/7aod
         dNCmfi8cB+Cyfx3L7G0w7Q7Ol4YytWB5qpkQUuqP5TK3BTb5IO3XD+z+ERvkiiqbOit5
         yC59hew+Y9EoMaGTY0nN2ffbF8QQtap+Oxd9Nms7VUBZqP2sh06PdJRJQg6iDqdVLezA
         DSdw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=Cr96/Hl1X30wUkSboDTPUY+7mirgh5yOh7X3lSrBBeY=;
        b=Zd3QFWnQzIpXpxFZ9PBTOk5WZqoMmseF6td5U1rz/DdNsiF3Kd1jVRMTIxVi25s9lQ
         gwH5uLLLNOoEQYBHVUCSM3hm/aVT+WYrkGXwBnUuTajBp5yRGMzF1amEGFgnayPol+Gt
         L8fqxmnNhC9RcB/Gs6x6uTBNMDAaI6MgKXRS9Ql8DphB/eVAtmXSHYYe0L0yQo3MvFCQ
         r1QSfpAX0TrRjcDdHqeCb/Rmn2boZO+K9Pm73DaoMr8Q1cCVmcRADKsGTd0AAiQvaegI
         lBeMgr50sjbJTMocVEsYW4kh+rQXWzJdttpA5lsYTJ4qT4gg5btYvQhwfXrjx2y/Tgxq
         DaMA==
X-Gm-Message-State: APjAAAW4lnNOONTB42aIxIJg21xlLn+ZcA4nqThS+fBZUWQ+5Z29PfKU
        NJ4HGduPynEotjCSgAsENnJoHBFj
X-Google-Smtp-Source: APXvYqwwJTu7UIeOMscgWjEbmON7ZGaLGxOihPCAKOJO8YV8TKo8DPLF5TM9SLl9a6HFUx4KQGOEoA==
X-Received: by 2002:a24:52c2:: with SMTP id d185mr4754297itb.94.1554926851372;
        Wed, 10 Apr 2019 13:07:31 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id v19sm14549579iol.27.2019.04.10.13.07.30
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 13:07:30 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3AK7UjI004537;
        Wed, 10 Apr 2019 20:07:30 GMT
Subject: [PATCH v1 11/19] xprtrdma: Increase maximum number of backchannel
 request
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 10 Apr 2019 16:07:30 -0400
Message-ID: <20190410200730.11522.38203.stgit@manet.1015granger.net>
In-Reply-To: <20190410200446.11522.21145.stgit@manet.1015granger.net>
References: <20190410200446.11522.21145.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Reflects the change introduced in commit 067c46967160 ("NFSv4.1:
Bump the default callback session slot count to 16").

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/xprt_rdma.h |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 9871cd9..f1bbe36 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -103,12 +103,14 @@ struct rpcrdma_ep {
 
 /* Pre-allocate extra Work Requests for handling backward receives
  * and sends. This is a fixed value because the Work Queues are
- * allocated when the forward channel is set up.
+ * allocated when the forward channel is set up, long before the
+ * backchannel is provisioned. This value is two times
+ * NFS4_DEF_CB_SLOT_TABLE_SIZE.
  */
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
-#define RPCRDMA_BACKWARD_WRS		(8)
+#define RPCRDMA_BACKWARD_WRS (32)
 #else
-#define RPCRDMA_BACKWARD_WRS		(0)
+#define RPCRDMA_BACKWARD_WRS (0)
 #endif
 
 /* Registered buffer -- registered kmalloc'd memory for RDMA SEND/RECV

