Return-Path: <SRS0=4THU=SH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E59FC4360F
	for <linux-nfs@archiver.kernel.org>; Fri,  5 Apr 2019 15:56:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 197312146F
	for <linux-nfs@archiver.kernel.org>; Fri,  5 Apr 2019 15:56:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Nk3xIWzu"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727152AbfDEP4r (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 5 Apr 2019 11:56:47 -0400
Received: from mail-pg1-f195.google.com ([209.85.215.195]:36511 "EHLO
        mail-pg1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726730AbfDEP4r (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Apr 2019 11:56:47 -0400
Received: by mail-pg1-f195.google.com with SMTP id 85so3298317pgc.3
        for <linux-nfs@vger.kernel.org>; Fri, 05 Apr 2019 08:56:47 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=n3l7/FVbdfGI8MSJ9NggZj4G66uSmVGqzdm0VtOgy5Q=;
        b=Nk3xIWzuKxvr0ojH55mZBI4znOrVxBq2jO64EPOTioqgpdMgbahsvyqtKlXw4Ph1jo
         Vui63KA4qkI/Rm3i/Tx+8BVsvst9N98m3Um83/+ryFbF7L6flp5NXmcDPB/EB0gweyh+
         PXU3XauCGT4/OEWSqapverPExQTn8SBjMg1jPQz7ON34T3QSF132KM8zdFD5xBSqCsLc
         s+eeeJBLtOPYK2jzvjEkjhCK4SHuYcB/acBzQG3gx41theohBdvCh1xe9a4NwLJP+ytd
         HUH7sUEz7WTbVOJouIl7wwAO6P0uGWh6tyv1LDG+4cTnJ49vZrafj4uUN3OouTXq0P01
         ryTw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=n3l7/FVbdfGI8MSJ9NggZj4G66uSmVGqzdm0VtOgy5Q=;
        b=fPe6o1+45w8EXZl5VZy3AZ/df7aL9yld4KMXSZWEhh4PVB73PhjZqkZCfu6QqpTcHU
         snxHadcIQcVbV9JsMvnEKq2+nd9PSe9wL3isiXftxt/MwdQ80C4VesyNSF2G5gMJu24b
         1hz+nFHMzeeyqOPhJlp0DscBu8cHr6ppId00z8O8ag5L1uGtBdpEwL815wXYDRS4EWZS
         j3dAK0Thl+eLf3r4206NcQZOU5hbUVMBXXk2G3RXzalsEDfvGcT2pz8bjHdlT+Rup9Dc
         loucQqaRlfa0rY6iiRGQNPhAwPJ7v1u2UmqHzraLhrEaxiIFj7Vp464nvUS9xIfh6JAj
         yqFQ==
X-Gm-Message-State: APjAAAXnCTrJtkzVtuCp3SJgw9sOyh9kN/afZ7w0W7MDYsZZLyJ9nZ1F
        L0j7nkbAPYcs7U0Prbfm3Q==
X-Google-Smtp-Source: APXvYqyBBRfxtIAenXYaLIlqXl8oPUwKdnNAe0zGoCX0rTEeAgjg9+WwZK29B1uPiT7oKYoXwpwAQw==
X-Received: by 2002:a63:f40d:: with SMTP id g13mr13083435pgi.345.1554479806007;
        Fri, 05 Apr 2019 08:56:46 -0700 (PDT)
Received: from localhost.localdomain (c-69-181-67-218.hsd1.ca.comcast.net. [69.181.67.218])
        by smtp.gmail.com with ESMTPSA id g5sm34817078pfo.53.2019.04.05.08.56.44
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 05 Apr 2019 08:56:44 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     "J. Bruce Fields" <bfields@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v2] nfsd: Don't release the callback slot unless it was actually held
Date:   Fri,  5 Apr 2019 08:54:37 -0700
Message-Id: <20190405155437.5545-1-trond.myklebust@hammerspace.com>
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
v2: try to restart the callback if we hit nfsd4_cb_sequence_done()
    without a slot.

 fs/nfsd/nfs4callback.c | 8 +++++++-
 fs/nfsd/state.h        | 1 +
 2 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index d219159b98af..7caa3801ce72 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -1010,8 +1010,9 @@ static void nfsd4_cb_prepare(struct rpc_task *task, void *calldata)
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
@@ -1038,6 +1039,9 @@ static bool nfsd4_cb_sequence_done(struct rpc_task *task, struct nfsd4_callback
 		return true;
 	}
 
+	if (!cb->cb_holds_slot)
+		goto need_restart;
+
 	switch (cb->cb_seq_status) {
 	case 0:
 		/*
@@ -1076,6 +1080,7 @@ static bool nfsd4_cb_sequence_done(struct rpc_task *task, struct nfsd4_callback
 			cb->cb_seq_status);
 	}
 
+	cb->cb_holds_slot = false;
 	clear_bit(0, &clp->cl_cb_slot_busy);
 	rpc_wake_up_next(&clp->cl_cb_waitq);
 	dprintk("%s: freed slot, new seqid=%d\n", __func__,
@@ -1283,6 +1288,7 @@ void nfsd4_init_cb(struct nfsd4_callback *cb, struct nfs4_client *clp,
 	cb->cb_seq_status = 1;
 	cb->cb_status = 0;
 	cb->cb_need_restart = false;
+	cb->cb_holds_slot = false;
 }
 
 void nfsd4_run_cb(struct nfsd4_callback *cb)
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 396c76755b03..9d6cb246c6c5 100644
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

