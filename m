Return-Path: <SRS0=wtRa=SM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 474FEC10F11
	for <linux-nfs@archiver.kernel.org>; Wed, 10 Apr 2019 20:08:00 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 160062075B
	for <linux-nfs@archiver.kernel.org>; Wed, 10 Apr 2019 20:08:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="oPrzPOhS"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726720AbfDJUH7 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 10 Apr 2019 16:07:59 -0400
Received: from mail-io1-f67.google.com ([209.85.166.67]:35123 "EHLO
        mail-io1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726023AbfDJUH7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Apr 2019 16:07:59 -0400
Received: by mail-io1-f67.google.com with SMTP id p16so3331103iod.2;
        Wed, 10 Apr 2019 13:07:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=uoGfYWajZKkjcbjtVTLDy6dOkR7gJFyuID3v83PCoTw=;
        b=oPrzPOhS/sDiHAiLYhda3AhqcdANINLoSHfklvStbYBSi3NyHgRLxpP7puP1XMMLuA
         /gQT48GS7wp8Iys1H9o60U6c4EZ/AC1i+4iFvnfcv+h3wFKB66/ZqP3WAEdsZzkbp3a6
         wtY58j85hbAVoHBEVzWq4a/DQwLkJSSAxVh4AWKVkPL6WowLQRcgFrX7KOsYrsxarv1F
         w4YLGAPgdjfHHeFrUScDcSbN5vffoUNwxfBnnB3IPhTp3uEGQUzInyRS6ZeLEZ157a6J
         dzLZ/igdJUJ3Ks6FP5bwV8zpIb2XJUle2L8bkxU8E3m3fqqYaF46RlR1od0oVIOz6AE6
         ZoyA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=uoGfYWajZKkjcbjtVTLDy6dOkR7gJFyuID3v83PCoTw=;
        b=A66GnReDV9NCLMw022Ob3YVfuuP5PwRpdapcfKrgVRjkRT3FtEdexa6PkDFF1dLX+u
         CQFzyMXB/Ygny7AZ0O6Xp1av8hxWOImoo0rixWaaLUukbwd8mraq9V93ikMPjgprPE8C
         J8fGiB0H94ZscOp7MOdO3/mUGgRY7mQUJXzLRHd08ImTTDFlXLgvyeZTjS8WvNjSQOWc
         detbVKTfYFTRggCg4G83/8bOwToArZV//QFWPvT7QDLRx5CViDqdh3ttcQKPcTdIh/Ey
         HmOOF+BBjaJP78++GyQNm1Gi+Skgil9OptqCfAjYLlMKCUOHFWjJDpWhlEtgmue9HrY0
         yFLA==
X-Gm-Message-State: APjAAAXoyj60aRfQqW5d+dqbMHKs7MI6Fs+N5bZZlfbnb9ZL+NyqcJHl
        Sl0+H51XH6zMF4HSA0VZBOxPQ4di
X-Google-Smtp-Source: APXvYqz0Uieuo85B8wl82fv4KlCm1GxyvJDrkddcBkeZhozxhddDniYMWcfPB+xw+QQ1MOeObqghMA==
X-Received: by 2002:a5d:91d2:: with SMTP id k18mr21011986ior.24.1554926878381;
        Wed, 10 Apr 2019 13:07:58 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id e26sm14154439iom.56.2019.04.10.13.07.57
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 13:07:57 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3AK7vwL004552;
        Wed, 10 Apr 2019 20:07:57 GMT
Subject: [PATCH v1 16/19] SUNRPC: Update comments based on recent changes
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 10 Apr 2019 16:07:57 -0400
Message-ID: <20190410200756.11522.33482.stgit@manet.1015granger.net>
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

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprt.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index d7117d2..73db033 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -949,7 +949,7 @@ struct rpc_rqst *xprt_lookup_rqst(struct rpc_xprt *xprt, __be32 xid)
  * @req: Request to pin
  *
  * Caller must ensure this is atomic with the call to xprt_lookup_rqst()
- * so should be holding the xprt receive lock.
+ * so should be holding xprt->queue_lock.
  */
 void xprt_pin_rqst(struct rpc_rqst *req)
 {
@@ -961,7 +961,7 @@ void xprt_pin_rqst(struct rpc_rqst *req)
  * xprt_unpin_rqst - Unpin a request on the transport receive list
  * @req: Request to pin
  *
- * Caller should be holding the xprt receive lock.
+ * Caller should be holding xprt->queue_lock.
  */
 void xprt_unpin_rqst(struct rpc_rqst *req)
 {

