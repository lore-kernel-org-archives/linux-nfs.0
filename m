Return-Path: <SRS0=4rwz=SG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D9F7C4360F
	for <linux-nfs@archiver.kernel.org>; Thu,  4 Apr 2019 02:52:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EB7E52133D
	for <linux-nfs@archiver.kernel.org>; Thu,  4 Apr 2019 02:52:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gmWQkX1K"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726167AbfDDCwN (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 3 Apr 2019 22:52:13 -0400
Received: from mail-pg1-f196.google.com ([209.85.215.196]:38455 "EHLO
        mail-pg1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726193AbfDDCwN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Apr 2019 22:52:13 -0400
Received: by mail-pg1-f196.google.com with SMTP id j26so457043pgl.5
        for <linux-nfs@vger.kernel.org>; Wed, 03 Apr 2019 19:52:12 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=ycD9dMaRjjhv4ksbWTrqZYOVZtHUbrOyeH8Dbo8C+BA=;
        b=gmWQkX1Ktjvfai6Mv/np7hW1jqgJBXN2MxfjpJmDHFA4viw5agdJN0BxLEOGPDyfwq
         Xk9GQFzB6kpz/YiZGqNI4whWsI7QoEvdiEnPxmZ/lhwNnpjx2diLhXsjVR2oMymsSqe2
         nhUiubzrob6AbWrV0pJrOMS1GIdwnbb1WQSdzTysJK7OsOdhKmPHQpEl/2DZ1TggWThN
         cMTxh/UCz9Ta+J/+4E/VHA5LuCmyMTo0uY4GRL6IxfSAmwvcQifKytdvShANNyja73l5
         /hLFpojGrfT158F6Pv4bBVRlklEKj+ekjOHU6pxL6IPp0DQSjRVSoTc7gleto3AbRIVc
         WVBw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=ycD9dMaRjjhv4ksbWTrqZYOVZtHUbrOyeH8Dbo8C+BA=;
        b=kSWPzIKefLPjnqgF58xmwDStJWeONPux6+EZGpNdG/F1LGXhHEHLTL+ZJYyrXGZlcX
         7JoGQEjVaEkc7CaNtBbyhOSNyZVZqjApAIgVE0rEdW5igj/vQ0DA6T5vNMuR8pLBDM04
         i1lyCyNqMGgJj7PtAOufGRequDEBqhdaJv2iXRctvdLIjOWS3G5kJVbCDyNO4tx95syS
         4i6qHz1enjqv+B3z7dnY1Ts4xs0st/I38QUSLVlYaBvttjXv3H+LjhzjON+2lhOXet5d
         1Fn7zC3IAFID+CSPD8mfphCg5NeyyvpxBLWmu02ADYp8Nz5BZyrQvSH6256R9YXttUVh
         huXw==
X-Gm-Message-State: APjAAAXQ4l4IeaiMG8BRmcIP3ehVwQTgdiaWeoWFjMVIO9UcICsobhnK
        ZCynVnuYdmhayQY6AvAT3tTXI28=
X-Google-Smtp-Source: APXvYqwIDn5NiWW8/y2mMsK2tbmxrW7B99/LmrkEZox3+np/g4IJYimeqR9yw8fFQWuJUJu+P3OQGg==
X-Received: by 2002:a63:db10:: with SMTP id e16mr3293906pgg.142.1554346332194;
        Wed, 03 Apr 2019 19:52:12 -0700 (PDT)
Received: from localhost.localdomain (63-235-104-78.dia.static.qwest.net. [63.235.104.78])
        by smtp.gmail.com with ESMTPSA id y5sm20370662pgv.15.2019.04.03.19.52.10
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 03 Apr 2019 19:52:10 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     "J. Bruce Fields" <bfields@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: Don't release the callback slot unless it was actually held
Date:   Wed,  3 Apr 2019 19:50:03 -0700
Message-Id: <20190404025003.6143-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If there are multiple callbacks queued, waiting for the callback
slot when the callback gets shut down, then they all currently
end up acting as if they hold the slot, and call
nfsd4_cb_sequence_done() resulting in interesting side-effects.

In addition, the 'retry_nowait' path in nfsd4_cb_sequence_done()
causes a loop back to nfsd4_cb_prepare() without first freeing the
slot, which causes a deadlock when nfsd41_cb_get_slot() gets called
a second time.

This patch therefore adds a boolean to track whether or not the
callback did pick up the slot, so that it can do the right thing
in these 2 cases.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfsd/nfs4callback.c | 8 +++++++-
 fs/nfsd/state.h        | 1 +
 2 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index a1e79acb009f..8c61339eb063 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -939,8 +939,9 @@ static void nfsd4_cb_prepare(struct rpc_task *task, void *calldata)
 	cb->cb_seq_status = 1;
 	cb->cb_status = 0;
 	if (minorversion) {
-		if (!nfsd41_cb_get_slot(clp, task))
+		if (!cb->cb_holds_slot && !nfsd41_cb_get_slot(clp, task))
 			return;
+		cb->cb_holds_slot = true;
 	}
 	rpc_call_start(task);
 }
@@ -967,6 +968,9 @@ static bool nfsd4_cb_sequence_done(struct rpc_task *task, struct nfsd4_callback
 		return true;
 	}
 
+	if (!cb->cb_holds_slot)
+		return true;
+
 	switch (cb->cb_seq_status) {
 	case 0:
 		/*
@@ -1004,6 +1008,7 @@ static bool nfsd4_cb_sequence_done(struct rpc_task *task, struct nfsd4_callback
 			cb->cb_seq_status);
 	}
 
+	cb->cb_holds_slot = false;
 	clear_bit(0, &clp->cl_cb_slot_busy);
 	rpc_wake_up_next(&clp->cl_cb_waitq);
 	dprintk("%s: freed slot, new seqid=%d\n", __func__,
@@ -1211,6 +1216,7 @@ void nfsd4_init_cb(struct nfsd4_callback *cb, struct nfs4_client *clp,
 	cb->cb_seq_status = 1;
 	cb->cb_status = 0;
 	cb->cb_need_restart = false;
+	cb->cb_holds_slot = false;
 }
 
 void nfsd4_run_cb(struct nfsd4_callback *cb)
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 4673bb2dca03..5b944a959b49 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -70,6 +70,7 @@ struct nfsd4_callback {
 	int cb_seq_status;
 	int cb_status;
 	bool cb_need_restart;
+	bool cb_holds_slot;
 };
 
 struct nfsd4_callback_ops {
-- 
2.20.1

