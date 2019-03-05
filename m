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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00FE7C43381
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Mar 2019 15:18:34 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B9B0F2087C
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Mar 2019 15:18:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="N86omJ3K"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728439AbfCEPSd (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 5 Mar 2019 10:18:33 -0500
Received: from mail-io1-f66.google.com ([209.85.166.66]:38367 "EHLO
        mail-io1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727114AbfCEPSc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Mar 2019 10:18:32 -0500
Received: by mail-io1-f66.google.com with SMTP id p18so7322950ioh.5
        for <linux-nfs@vger.kernel.org>; Tue, 05 Mar 2019 07:18:32 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=nZRhqCSGAmuqPoKC3r6VvDIcMWODu7nvIwDgDx3PHGU=;
        b=N86omJ3KMoC5tP6ofBJwI0pe5WxFD8doUTQhVYZ6tNoAZNDeFrUEXcaEoKHUiUYIBJ
         NTOuvuYXIQ/HQ/9j+POF9/yOvYKwqgNSuMxGlWAtOv7ZhzwbGOPM9krXakFIUngS6yEO
         tgJ4OYkgzworGL0Ygj2e9Gro/pT75uoqaW3C1+DlPGYHZaGc4uIhNbXmHayngM32LUJB
         N0qKeoB7gwL6FpetW9Fj0Hmp2qgAhVWasOg9fUQ6GTUIkii6yfq0V0LSn95P8m2urgkB
         ryXyL47WJApDQFNv6oYwpgGoRGkaHbROXZck2gl3qxcsbPrLjtni+Si8kUN4yQX1potr
         pVOQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=nZRhqCSGAmuqPoKC3r6VvDIcMWODu7nvIwDgDx3PHGU=;
        b=Fy4kd7VNNMWQce5ey8N4z2RsoJwsAdlywqKNqsEy8lwHQVH/8IBigmRLH7Us+eaaB9
         KZdGwGiu5epYFPmtssBfbx8a7eR7kUE8vaj5B6M+6DfALiCHGbe9XkKrR1hYWsjp/1AE
         yTdI26t4ySu5pPBMkJ0DtKpOLaaswJZ4fyzLsNC8eUedjXQGdc7pSiqTy5OS5X/AW2zX
         9hCs/LkfTglcLHvxkC+yJk/trf9B8m+QNpW5t9w6WvXk6H5kyFK/6tBm5kxadKdjlwU/
         tmdDoJgQ0hjPUpvmCXDiN21DlipsiAo4h5h+LkMCHWNbMpUVXBoSoVOZw4mxaMSxfPTc
         T9mw==
X-Gm-Message-State: APjAAAVuGRo5IVIES3RCaZhgUngjFwKDiAl/1Kn+7I8/e1eLCbz7/w27
        wbAIDMLkFOk3SMxtEGgNonf4SyU=
X-Google-Smtp-Source: APXvYqxDi2QIYzIqY3P+leMUTDIyOXXxswbvgwaV3LVc8WIK3+yrCiKSYnCWMcB2iPBMR//vVTi/og==
X-Received: by 2002:a5d:97c8:: with SMTP id k8mr304348ios.267.1551799111405;
        Tue, 05 Mar 2019 07:18:31 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id 10sm5003935itv.10.2019.03.05.07.18.29
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 05 Mar 2019 07:18:30 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/3] SUNRPC: Prevent thundering herd when the socket is not connected
Date:   Tue,  5 Mar 2019 10:17:20 -0500
Message-Id: <20190305151722.45732-1-trond.myklebust@hammerspace.com>
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

