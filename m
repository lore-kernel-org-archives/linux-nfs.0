Return-Path: <SRS0=HPA/=RI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0737BC10F03
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Mar 2019 01:31:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CBE5420675
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Mar 2019 01:31:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AK84iRrx"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726522AbfCEBbZ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 4 Mar 2019 20:31:25 -0500
Received: from mail-io1-f66.google.com ([209.85.166.66]:41985 "EHLO
        mail-io1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726095AbfCEBbZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Mar 2019 20:31:25 -0500
Received: by mail-io1-f66.google.com with SMTP id p196so5628659iod.9
        for <linux-nfs@vger.kernel.org>; Mon, 04 Mar 2019 17:31:24 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=GT2NTjVieipaYxdj4Jm8L8IE5XDhQwWkWagSf1ZCfWc=;
        b=AK84iRrxdc61An6HwQv1XPZWWg6HQRbDZdn8raiGwjzdBi/PeaSJY02w5BOQhXuVys
         f1eVAbBfYrpRPQvnqTMlKVB5AqAZ0TW7iPQ8GWkW/NqAPsKjwK8q2/uRNGVRU8umhjat
         wXVVHuskk/lcjy5jLslB83mvmxZgjyo5f2GrJ4FvkXmn5ItAsCKtJ8q9bCqolD/iWxXn
         JENtAIufcfin979DeTR7uLMIgjPDJn7gr+wdFM85aSx+5I184bG4jJSttl57/X34zxNk
         uA1A9ZzTtPQn/yo7OoHp6rPJ99q7IVeNvL7CoS04LWOL7AFVQwwxcdauz3NeVhPfDjL0
         xkLg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=GT2NTjVieipaYxdj4Jm8L8IE5XDhQwWkWagSf1ZCfWc=;
        b=WGMQNKF+EIssyl+dMhYFSsGYr52oWy7vebAaPlcW4LnqZ2ItPsQVchAGCxVhEgfKqO
         J7F5CmDpMxE/q98LZByVBPNwyTLDV64QC7RqBQeKhsmd3R31wVV52dWOi1q0FjLYAVFz
         c86OMNSd88C7otfeP1oZhvtcTdNiaIHKco3FaiTagK9ELYEvNPFPUjX8vRG+BmXlFYp2
         c9JNRXI+OeHUjyvxTH8VunU0JWmeCOEt140YxV8h84bjUR1zfsGAoUzg5cmKiuQf4VM7
         nN88t0OyDyZ/Vh3dCZ92QediYYCS/b+bFB9CMQuYy+IaP77earY6O8kviFrkf2arf3Oa
         CzCg==
X-Gm-Message-State: APjAAAXDHjLxjKJZbA8kILxxXX4+Ou9mw1nfnW7et0sgu10x5PQi1GRT
        1/MlwBOzAnHutdWgbotSGTLuwNk=
X-Google-Smtp-Source: APXvYqy0T0OJQrFAENuKHYvL1qTa2/087tumIHT9DInHYzZ9Ju9YiDWMJUNqlgg9b56yiwT/Wl16og==
X-Received: by 2002:a6b:cf0b:: with SMTP id o11mr11606124ioa.227.1551749483921;
        Mon, 04 Mar 2019 17:31:23 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id f26sm2901058ioh.1.2019.03.04.17.31.23
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 04 Mar 2019 17:31:23 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] SUNRPC: Micro-optimisation to avoid call_bind+call_commit
Date:   Mon,  4 Mar 2019 20:30:15 -0500
Message-Id: <20190305013015.30109-2-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190305013015.30109-1-trond.myklebust@hammerspace.com>
References: <20190305013015.30109-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Most tasks should not have to deal with disconnected or unbound
socket states, so let's move them out of the common state machine
path.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/clnt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index e7ae75a045c9..8678a05192d3 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1807,7 +1807,7 @@ call_encode(struct rpc_task *task)
 		xprt_request_enqueue_receive(task);
 	xprt_request_enqueue_transmit(task);
 out:
-	task->tk_action = call_bind;
+	task->tk_action = call_transmit;
 }
 
 /*
-- 
2.20.1

