Return-Path: <SRS0=2rvl=36=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D79D8C35254
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Feb 2020 19:16:13 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A853720838
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Feb 2020 19:16:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GgZ6eIZj"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727587AbgBJTQN (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 10 Feb 2020 14:16:13 -0500
Received: from mail-yw1-f68.google.com ([209.85.161.68]:44119 "EHLO
        mail-yw1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727572AbgBJTQM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Feb 2020 14:16:12 -0500
Received: by mail-yw1-f68.google.com with SMTP id t141so3931965ywc.11
        for <linux-nfs@vger.kernel.org>; Mon, 10 Feb 2020 11:16:12 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=a+13WK+Oz13ZrEk9aniPwYJ/cSiJ37KnFThG8SEGIeU=;
        b=GgZ6eIZjLQxLLqbZrVoSTkzMgVbN/ajMHuWoz4PQkrW7jzcD5ixDKQdVerWFEtdCS2
         lM8e72DAHDvJbEPs6kiTSTyEnlU3eoLk2useIgl4NGJvJHA44hbwKuoJGLA/JD8uwgEK
         zQ//fVOgT40NWlJ+3MVvlEM4QYZRcwMDRB8AgwO8X9UMI98xeBactWnzq7hbxMaJJx/q
         pMbT6NeTEQr3unWM/NS5eZ6GAP6Oi4X4Cyxqwu/LJxW4L8ZA5qV2pNsD163OrOUgy8Ts
         Klyk1cOrVJHh84td5rgEPT11PTp5/sjvkIipTvUFpqvKsIPZXGv0N8FZ5NJDD6sOzw/q
         ez9Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=a+13WK+Oz13ZrEk9aniPwYJ/cSiJ37KnFThG8SEGIeU=;
        b=ia1ofhLwAQBmSFD3YbqfGCwbxET/mC5nGrAqRmgpkN5Msp9QDITgp5gHygVfXO1aZq
         3oA7VK04NMlsUuQXy1Kwbp3M+da+p81l4qiDBFEwVhhyoHr1Lf4zltwirdueubq+qU/Q
         HcwxvMLLu2u9ilC0gA71Rp8j+tO0yavAXEOx54Apr+PSTC5q0Mk0RcfArb6nGG2MGhet
         QpUiF3MvJ1VjgyKRlpGSBQ2/VReaF+R+kOGiRVpO+ZWSWS9vs+KALgcnJCLOc2P9k3PI
         NEcwrgse3sVZnAVUkptpEF5KzRl/9AdXcFBhzMw2WCS7bIZ2IjIzMJqpouVk9SIECy26
         Kdlw==
X-Gm-Message-State: APjAAAWvaPTE8gfP+QfSoLRyTD1xzZ4SAOjpxtiSCL1b+L8NMveMvV4b
        +wzPMKmNYtiTimgrdv33L/vYcwpnJA==
X-Google-Smtp-Source: APXvYqzcB2M1xN6pV6/e7/B65yB6pNLPKEAsNNPm4WycGa3XwqCy93Mesnsej88RJuyMvqrRHQxKdQ==
X-Received: by 2002:a0d:e186:: with SMTP id k128mr2310405ywe.178.1581362171224;
        Mon, 10 Feb 2020 11:16:11 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id o4sm660222ywd.5.2020.02.10.11.16.10
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 10 Feb 2020 11:16:10 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 7/8] NFS: Avoid referencing the cred twice in async rename/unlink
Date:   Mon, 10 Feb 2020 14:13:44 -0500
Message-Id: <20200210191345.557460-8-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.24.1
In-Reply-To: <20200210191345.557460-7-trond.myklebust@hammerspace.com>
References: <20200210191345.557460-1-trond.myklebust@hammerspace.com>
 <20200210191345.557460-2-trond.myklebust@hammerspace.com>
 <20200210191345.557460-3-trond.myklebust@hammerspace.com>
 <20200210191345.557460-4-trond.myklebust@hammerspace.com>
 <20200210191345.557460-5-trond.myklebust@hammerspace.com>
 <20200210191345.557460-6-trond.myklebust@hammerspace.com>
 <20200210191345.557460-7-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

In both async rename and rename, we take a reference to the
cred in the call arguments.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/unlink.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 0effeee28352..b27ebdccef70 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -98,7 +98,7 @@ static void nfs_do_call_unlink(struct inode *inode, struct nfs_unlinkdata *data)
 		.callback_ops = &nfs_unlink_ops,
 		.callback_data = data,
 		.workqueue = nfsiod_workqueue,
-		.flags = RPC_TASK_ASYNC,
+		.flags = RPC_TASK_ASYNC | RPC_TASK_CRED_NOREF,
 	};
 	struct rpc_task *task;
 	struct inode *dir = d_inode(data->dentry->d_parent);
@@ -341,7 +341,7 @@ nfs_async_rename(struct inode *old_dir, struct inode *new_dir,
 		.callback_ops = &nfs_rename_ops,
 		.workqueue = nfsiod_workqueue,
 		.rpc_client = NFS_CLIENT(old_dir),
-		.flags = RPC_TASK_ASYNC,
+		.flags = RPC_TASK_ASYNC | RPC_TASK_CRED_NOREF,
 	};
 
 	data = kzalloc(sizeof(*data), GFP_KERNEL);
-- 
2.24.1

