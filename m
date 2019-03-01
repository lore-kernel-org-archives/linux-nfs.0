Return-Path: <SRS0=Psyw=RE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D50ADC10F03
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 19:13:54 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A02CF2075B
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 19:13:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="reHxuhHR"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728416AbfCATNx (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 1 Mar 2019 14:13:53 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:55697 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728593AbfCATNx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Mar 2019 14:13:53 -0500
Received: by mail-it1-f196.google.com with SMTP id z131so21774431itf.5
        for <linux-nfs@vger.kernel.org>; Fri, 01 Mar 2019 11:13:53 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ecJSxXkJWc6H7Uk/M3bNVg3kRgIhdIQ/bIf5pSfdVBM=;
        b=reHxuhHRUZG6iRysmwom23XtzEnoYdxo5fzlr6/2Mk/RdhyrW9yY/1ImJ6rT/EGWQM
         iGnA/I0r5d22gtWgk9NDuLYzepBTdSQ8OHl12n+PUT1oDAhOR942wdxsu1A4kMMCQBAq
         fp2vST7bmXoZqbIGHkU1bTFf5PPGw1fvuKXmz0zmaZ9Wu1DYTz0tQJRZBrtZR8XCDLjc
         hm3/vsyjpzHbwIhgjcm3uzPKVxVABwDYFmAFwEB+hAdxcFR0hrtUyFO/DiPSUyLAMiWV
         CfC7hafXSgMlcdsJ66GfdEjodCDEb9+oYtY6g6bUXPzaNmrOuBWHmYeJfRpagt+fyRTC
         gaZQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=ecJSxXkJWc6H7Uk/M3bNVg3kRgIhdIQ/bIf5pSfdVBM=;
        b=m12EKhd/j+S76V5u3ZrPqpQdy1upfqlFTYctzbBRkRLn3pztpK8M55n83xZGjsH90F
         Jn+dclZoOse8+0tO/mW62Z6XulN/dsNLyimhjAUyhmITA+LLjdXVKxuiYqWfk3l+Vb5r
         ylYs8YoWOkXQggXfIJv9rK/hNoqewQmxJAoLDaGNR1VU/O64sHGnjslqogZCfhxkGovT
         LtPUidx1+wbuQ5Gb821oosEj+cDHxUSmsRb1UCqXAcGh6u/Ypt2OeAAfjdzmP05ArrTu
         XYrO8sxout3fGReBRfBRxZLlYpSyno2XXR0NLoWXGCh2aRoqgqwJFlPoy+6x9uk3WfGo
         ddqg==
X-Gm-Message-State: APjAAAUzUKl16y2HPKPZhXZXT75TxCrlH98g64qAnjeb0F3mQw+wNEDx
        pFDgADB94bW1d/OLPWSPMF1MJrE=
X-Google-Smtp-Source: AHgI3IaF3pbuWZn6i5dWMd6c6CztO96YZq99xjp9Z4u4ahNtM8WVkO8IPbIngZg8HtxxiXafW6LBDQ==
X-Received: by 2002:a24:6c0e:: with SMTP id w14mr3928415itb.12.1551467632460;
        Fri, 01 Mar 2019 11:13:52 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id n184sm719405itn.7.2019.03.01.11.13.51
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 01 Mar 2019 11:13:51 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFSv4.1: Don't process the sequence op more than once.
Date:   Fri,  1 Mar 2019 14:11:53 -0500
Message-Id: <20190301191153.104498-2-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190301191153.104498-1-trond.myklebust@hammerspace.com>
References: <20190301191153.104498-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Ensure that if we call nfs41_sequence_process() a second time for the
same rpc_task, then we only process the results once.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5f8517d1a0a5..5b980246b035 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -754,7 +754,7 @@ static int nfs41_sequence_process(struct rpc_task *task,
 	if (slot == NULL)
 		goto out_noaction;
 	/* don't increment the sequence number if the task wasn't sent */
-	if (!RPC_WAS_SENT(task))
+	if (!RPC_WAS_SENT(task) || slot->seq_done)
 		goto out;
 
 	session = slot->table->session;
-- 
2.20.1

