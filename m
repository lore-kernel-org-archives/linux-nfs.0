Return-Path: <SRS0=2Ld2=NY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78957C43441
	for <linux-nfs@archiver.kernel.org>; Tue, 13 Nov 2018 22:50:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2287A22360
	for <linux-nfs@archiver.kernel.org>; Tue, 13 Nov 2018 22:50:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rctTPxgO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2287A22360
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726890AbeKNIuu (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 14 Nov 2018 03:50:50 -0500
Received: from mail-it1-f194.google.com ([209.85.166.194]:37330 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726022AbeKNIuu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Nov 2018 03:50:50 -0500
Received: by mail-it1-f194.google.com with SMTP id j79-v6so21113408itb.2
        for <linux-nfs@vger.kernel.org>; Tue, 13 Nov 2018 14:50:29 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=4+WEEZ4ByxFdWLwvkHN8jWPLi7VKIPvLjfxX88CO7Rs=;
        b=rctTPxgOgd7bv89EsiBmDjTaHWv5Bjaz6KvAhHUkSgxovkdfwWkXUnW4UYLKmBdpwh
         l057afKcLf7Qcc9dYG0orxTva3pWcIzKYKCLrcaTyJ2e2826IdOU8lkdFNiIgUcmagmf
         LTiJzfyzXoe0OS+Mm/+CXNFdSWaqTwoXhatEqDlAdIK4qi7K5xalSwUwT0v2jnJQgCGU
         rWiKRc5tjmd2wi3YXyYWawbKHRK8/zYoOhLEKARftnaoyOmWcC8lzSNvXdHwh1XxK8Gm
         kgpmYWgn5js2z0avouqrDkjC4a92y15ZgQjIEf92hRIsLycFAOPYo+KgjHvx83ioSNy1
         VUzw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=4+WEEZ4ByxFdWLwvkHN8jWPLi7VKIPvLjfxX88CO7Rs=;
        b=Eo82kyyDvV51CPCKJNTXjoCM/gIQdPk8rKv2xyvonA/NJYXtfsVYstIxZABrBYpI/1
         7kAO74/M7GVd6grjko9cb+Xe1nuJoGKRsGlGh8X1Hj3OgjOkLmw2WYEtIl0MCn7wohCN
         Lx/QyUP1tGhMpJG0OE4rQegzF4km4s3ShQ/3YSJeF7QqEf1La1P51NzI+VWPOr/g8NvZ
         EAI5t/s269XbXfIbV6TRvBPVo8rduXHcEFbxIkCcoMIDAUNrrnhLf6P/opa6p0Gk0wpc
         RPobn4DQCKyec45Aui/ndE6EeuZAM1XIhIzCw5fy2CVQ6ad0+FOqHchU6NuL2WAfhzsB
         Jn+A==
X-Gm-Message-State: AGRZ1gL1zKY7cpYbjJcQDQz29S2T3E7orS+Rq8L1FBlj0kUP4AchzZY4
        +2QyhbJTxAxRl5zRg9eRBlg4K54=
X-Google-Smtp-Source: AJdET5e07bdfCl4qF9qUt/k279xNy1h3QrQQ0Vcwa3JG8cf7nLJOYyOxOIkcU4tnhrFBPj+aJo07oA==
X-Received: by 2002:a02:5543:: with SMTP id e64-v6mr6400047jab.113.1542149429009;
        Tue, 13 Nov 2018 14:50:29 -0800 (PST)
Received: from localhost.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id o24-v6sm6416623ioa.39.2018.11.13.14.50.27
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 13 Nov 2018 14:50:28 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: Fix an Oops during delegation callbacks
Date:   Tue, 13 Nov 2018 17:49:20 -0500
Message-Id: <20181113224920.2385-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.19.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If the server sends a CB_GETATTR or a CB_RECALL while the filesystem is
being unmounted, then we can Oops when releasing the inode in
nfs4_callback_getattr() and nfs4_callback_recall().

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/callback_proc.c |  4 ++--
 fs/nfs/delegation.c    | 11 +++++++++--
 2 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index fa515d5ea5ba..7b861bbc0b43 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -66,7 +66,7 @@ __be32 nfs4_callback_getattr(void *argp, void *resp,
 out_iput:
 	rcu_read_unlock();
 	trace_nfs4_cb_getattr(cps->clp, &args->fh, inode, -ntohl(res->status));
-	iput(inode);
+	nfs_iput_and_deactive(inode);
 out:
 	dprintk("%s: exit with status = %d\n", __func__, ntohl(res->status));
 	return res->status;
@@ -108,7 +108,7 @@ __be32 nfs4_callback_recall(void *argp, void *resp,
 	}
 	trace_nfs4_cb_recall(cps->clp, &args->fh, inode,
 			&args->stateid, -ntohl(res));
-	iput(inode);
+	nfs_iput_and_deactive(inode);
 out:
 	dprintk("%s: exit with status = %d\n", __func__, ntohl(res));
 	return res;
diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 07b839560576..6ec2f78c1e19 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -850,16 +850,23 @@ nfs_delegation_find_inode_server(struct nfs_server *server,
 				 const struct nfs_fh *fhandle)
 {
 	struct nfs_delegation *delegation;
-	struct inode *res = NULL;
+	struct inode *freeme, *res = NULL;
 
 	list_for_each_entry_rcu(delegation, &server->delegations, super_list) {
 		spin_lock(&delegation->lock);
 		if (delegation->inode != NULL &&
 		    nfs_compare_fh(fhandle, &NFS_I(delegation->inode)->fh) == 0) {
-			res = igrab(delegation->inode);
+			freeme = igrab(delegation->inode);
+			if (freeme && nfs_sb_active(freeme->i_sb))
+				res = freeme;
 			spin_unlock(&delegation->lock);
 			if (res != NULL)
 				return res;
+			if (freeme) {
+				rcu_read_unlock();
+				iput(freeme);
+				rcu_read_lock();
+			}
 			return ERR_PTR(-EAGAIN);
 		}
 		spin_unlock(&delegation->lock);
-- 
2.19.1

