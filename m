Return-Path: <SRS0=RY80=RS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8DD35C10F00
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 17:52:54 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5EB78218A1
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 17:52:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cnqnNU+D"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726487AbfCORwx (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Mar 2019 13:52:53 -0400
Received: from mail-it1-f194.google.com ([209.85.166.194]:39293 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726218AbfCORwx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Mar 2019 13:52:53 -0400
Received: by mail-it1-f194.google.com with SMTP id l15so12207233iti.4
        for <linux-nfs@vger.kernel.org>; Fri, 15 Mar 2019 10:52:53 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=zVS5VHJ0av8yLm6V2IK7TAsLZN7eFuKuNOq2AVl0B/M=;
        b=cnqnNU+DlAD8vpQgdugVw0Nj94B9PvdG4bVinDKCd1onHjMhRE4DosUrGGla1NfwUZ
         7FFr9k/dyJB5JP9YXIDu3KqqvH4fq2f7yHfTeElE89dZE0+YCq6Q5WQGp0IMOgoxqxZ2
         B0wu4FJLFh/3U8YBnu1NrU1i61/xjwLs1P6hp+qSDUr/mjRM39kweCDyEDtvIDFdSQSX
         vDno+lIylWBszWHKCmx3W4Ebl6+HzHYVoLkmoLxdoFbY/ixQ+j8hHzU6ASdk9EQCGN+A
         d5TQUolIQS5Ck2HFbzd2qZO0BHoHFdJprKsM6SkkoeeQYzqz1bnhtkiJrICnOZHTqR7f
         EfwA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=zVS5VHJ0av8yLm6V2IK7TAsLZN7eFuKuNOq2AVl0B/M=;
        b=K0phKXHrRI9+oQ5PypSv+0pyqpb/SSWHAXrtF+eZQiMPnaYsNtmYuLedblfu2bWTzI
         rIqu0b57oaoVjF4OoxBDyPJQw/iojN7O5i0GDIYiXGh7OdY3jMZwoaqnQqjwfqOHey6O
         tZt8cO5HQkuuJcWNzLHxie2RSkL9JCMcbUiWxyJSKUcswYsNqZ/h0KWkYS1qOj7FG6c+
         rlVbRKTQhE6fnRCEJHErXa+YLPBJN4UQC2vA6GjQGTmBd9zwoB1u1f2v0C/5r9eJOA/l
         09I+KY9vl77zUmGiGqPTtxTN/t2aorCU14M4yJblVmPGL/YXkKNEsJ2afN2EnYLyCrd1
         Kbvw==
X-Gm-Message-State: APjAAAVd0TePiFmuU3ZEHWTknApUxWFzhLQILpUSi/6pDgKR/hiFe6+g
        /SCLkR0s0TRwoBUuTAB0lKCO350=
X-Google-Smtp-Source: APXvYqyU2/7a3pTyrYLq+vmjYrScPQbv/NKyNX0mkOLp+BPEbHcdWSaT98foXYJxotjxmlTueH0YNw==
X-Received: by 2002:a02:240d:: with SMTP id f13mr3456178jaa.105.1552672372366;
        Fri, 15 Mar 2019 10:52:52 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id r2sm1138415itk.5.2019.03.15.10.52.51
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 15 Mar 2019 10:52:51 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 2/6] SUNRPC: Fix the minimal size for reply buffer allocation
Date:   Fri, 15 Mar 2019 13:51:37 -0400
Message-Id: <20190315175141.68792-2-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190315175141.68792-1-trond.myklebust@hammerspace.com>
References: <20190315175141.68792-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

We must at minimum allocate enough memory to be able to see any auth
errors in the reply from the server.

Fixes: 2c94b8eca1a26 ("SUNRPC: Use au_rslack when computing reply...")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/clnt.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 4216fe33204a..310873895578 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1730,7 +1730,12 @@ call_allocate(struct rpc_task *task)
 	req->rq_callsize = RPC_CALLHDRSIZE + (auth->au_cslack << 1) +
 			   proc->p_arglen;
 	req->rq_callsize <<= 2;
-	req->rq_rcvsize = RPC_REPHDRSIZE + auth->au_rslack + proc->p_replen;
+	/*
+	 * Note: the reply buffer must at minimum allocate enough space
+	 * for the 'struct accepted_reply' from RFC5531.
+	 */
+	req->rq_rcvsize = RPC_REPHDRSIZE + auth->au_rslack + \
+			max_t(size_t, proc->p_replen, 2);
 	req->rq_rcvsize <<= 2;
 
 	status = xprt->ops->buf_alloc(task);
-- 
2.20.1

