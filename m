Return-Path: <SRS0=HPA/=RI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E2EDCC4360F
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Mar 2019 15:18:34 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B29D42087C
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Mar 2019 15:18:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jZhPdV2R"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728691AbfCEPSe (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 5 Mar 2019 10:18:34 -0500
Received: from mail-it1-f193.google.com ([209.85.166.193]:38782 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728481AbfCEPSe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Mar 2019 10:18:34 -0500
Received: by mail-it1-f193.google.com with SMTP id l66so4993259itg.3
        for <linux-nfs@vger.kernel.org>; Tue, 05 Mar 2019 07:18:33 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=cyoz9B+wDTlz4x0rCUfVddKoJ4TERhnTLbYg5vabN+Q=;
        b=jZhPdV2R5GsXHyRvdvITrPQHt6sIY4WTg3m/Um5lrVrlOumnJr3Ja8RbBqjuiw8M06
         Q4iePgrzWUNmOW4iytcVQeS9So2AcHdi4O9ZauEpHkwVUDU1ycgDOLhjW1mVqMckmazI
         fiROJIZeLOKMhRE8pylHQh3dnwO4ajAyzeFxgQCzSV65HHVLTGtAXsE02cwGEgXH/XLM
         ssxv6LNXxHx+qHCGbjSxo5tznk66/V7FSSmhgcnJI231oDH3gv7Ki3fcorBanBgUlWCK
         RPvSnBS2eQ5/zb8EAcp5vO3+HZYevbKg8PmhWLndDOoImw5ox0lMIWc2P9Bi+gd5Gbh0
         Zu+Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=cyoz9B+wDTlz4x0rCUfVddKoJ4TERhnTLbYg5vabN+Q=;
        b=OEDpRu9OgnJUi8BRTtnaZGN3kvHKnjR9B7qPB6FKtw1w9bWqr/1W9rH3ovulRtUAbJ
         oAuX0gId+wH8+aFsU+PXDQZJyND48R++tuMUB0MwqLQ80N7XqhZsAfWrSS2waW5gS2lT
         GR8aM5uJgd9wTvdE48RoYEOTK/HM+15mm3ziuJoVUOTNkakIP4bf3adWebFoGxx8vcok
         OjJqZzx5t+w0fk19bywjWDVAnbXP70/k5zoVu2EDipD7xksVNZgap4TM6qHTJtUkRdgK
         Iz8Lhl2w0tGJfiluRMUrtTYhwm9Grvi45EDQtKgAHKGrHP/YPvUIqJeLPjV0FgGRk5lG
         f5PQ==
X-Gm-Message-State: APjAAAVo0207AIvIRqAsmS4+QvC/EVXV+PXfC7uHfwpuzkn5v95cVt09
        uH6m0nMkgrEP5SfAO/E/ztXP/zE=
X-Google-Smtp-Source: APXvYqwQGzxl6mClIkZHn+RfgFRTz+uwD8oO97qtosuhtJLv9FUObTnyiqwFZFdkK4Vf1HUBEnpJvg==
X-Received: by 2002:a24:7688:: with SMTP id z130mr2683290itb.94.1551799112914;
        Tue, 05 Mar 2019 07:18:32 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id 10sm5003935itv.10.2019.03.05.07.18.32
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 05 Mar 2019 07:18:32 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 3/3] SUNRPC: Micro-optimisation to avoid call_bind+call_commit
Date:   Tue,  5 Mar 2019 10:17:22 -0500
Message-Id: <20190305151722.45732-3-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190305151722.45732-2-trond.myklebust@hammerspace.com>
References: <20190305151722.45732-1-trond.myklebust@hammerspace.com>
 <20190305151722.45732-2-trond.myklebust@hammerspace.com>
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
index c154684a35d4..b9251fd696ee 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1806,7 +1806,7 @@ call_encode(struct rpc_task *task)
 		xprt_request_enqueue_receive(task);
 	xprt_request_enqueue_transmit(task);
 out:
-	task->tk_action = call_bind;
+	task->tk_action = call_transmit;
 }
 
 /*
-- 
2.20.1

