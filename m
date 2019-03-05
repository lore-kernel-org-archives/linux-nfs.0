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
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7492C43381
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Mar 2019 01:31:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B441B20675
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Mar 2019 01:31:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="XyWbUYLR"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726434AbfCEBbY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 4 Mar 2019 20:31:24 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:40088 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726095AbfCEBbY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Mar 2019 20:31:24 -0500
Received: by mail-it1-f196.google.com with SMTP id l139so1880445ita.5
        for <linux-nfs@vger.kernel.org>; Mon, 04 Mar 2019 17:31:23 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=nZRhqCSGAmuqPoKC3r6VvDIcMWODu7nvIwDgDx3PHGU=;
        b=XyWbUYLRF+jrk5TBB19U2x0WaVYpD0I92D4hpknETYgn0Hc5bBCf2L+2jiNjaAaiwH
         f8XuWZXObWWVliukZe0JzT4XMlmCRNTbzuZ/BZvFMrLhIaas3PrYaAoHLC67aCPrq6Ml
         +v9KrXdmuiFdybkttJPPI2V6prLJ1obmekUa0TjdJJid9wlFETnr56dM11V0NVZhnypW
         XyY7gxEuiqcBnADVCsiNcQnNeCAdZHcqitUnEVU6t05Ogkdu+UGydqtXl6FhxDkXP69O
         4mXR+wyMR5NDOBJQAYVhDekEMHR7/y64UBm1Wssqr3WkTPE1aOhPqlLW2Wb8qTvQpw59
         qptA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=nZRhqCSGAmuqPoKC3r6VvDIcMWODu7nvIwDgDx3PHGU=;
        b=GC1UD41k9hkEDxYfQ76Au1xCCoUvnlf/7ULbiOnys0x6WtZhdmkm26G0nRsikQsoFg
         Qqw8DO3n6d4QBzrZJO6llK+UAsfzIhW0Y2iZp7/mpsj+W8lednP4WXNm/4tzUaHHFQgB
         7X0yBRWfCLqskMPlaTc4wHoYO1zcWZ3q4K+KUigY11fwn7f8ZteNrHLn+iswlnRmtyy7
         dGHTpVRvyV+LNfFLVsQcziLizY1lxab1IpAtGhODBIVQX+3e4Fkgwin0GQjSY57kaVNx
         KUTegJpbVOk5hVSjRH1RkLrV71p8cPAplpvwVqIGkuqHho5I0GWVLfbHyX/CJP8JZIAG
         Cpgw==
X-Gm-Message-State: APjAAAX5pW0i/IMgP1TW0Luob4GfJ5wO4vZVb0vh0YL1bpMOslR27H7G
        EZfOSeN8XLJl9uULMpwNJuDUNHw=
X-Google-Smtp-Source: APXvYqwq5hK+N14TwCsKPYYkK3byMJQbwiiQIXmtsmht9IW8YhGhzvy9QCgmzbkZ9qUao0JavPdmdg==
X-Received: by 2002:a24:73c5:: with SMTP id y188mr1325577itb.147.1551749482884;
        Mon, 04 Mar 2019 17:31:22 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id f26sm2901058ioh.1.2019.03.04.17.31.22
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 04 Mar 2019 17:31:22 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] SUNRPC: Prevent thundering herd when the socket is not connected
Date:   Mon,  4 Mar 2019 20:30:14 -0500
Message-Id: <20190305013015.30109-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If the socket is not connected, then we want to initiate a reconnect
rather that trying to transmit requests. If there is a large number
of requests queued and waiting for the lock in call_transmit(),
then it can take a while for one of the to loop back and retake
the lock in call_connect.

Fixes: 89f90fe1ad8b ("SUNRPC: Allow calls to xprt_transmit() to drain...")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/clnt.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 241e8423fd0c..e7ae75a045c9 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2003,6 +2003,12 @@ call_transmit(struct rpc_task *task)
 	if (test_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate)) {
 		if (!xprt_prepare_transmit(task))
 			return;
+		/* Check that the connection is OK */
+		if (!xprt_connected(task->tk_xprt) ||
+		    !xprt_bound(task->tk_xprt)) {
+			task->tk_action = call_bind;
+			return;
+		}
 		xprt_transmit(task);
 	}
 	task->tk_action = call_transmit_status;
-- 
2.20.1

