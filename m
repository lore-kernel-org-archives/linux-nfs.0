Return-Path: <SRS0=vByh=57=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44D30C3815B
	for <linux-nfs@archiver.kernel.org>; Wed, 15 Apr 2020 12:28:57 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 1CD4920936
	for <linux-nfs@archiver.kernel.org>; Wed, 15 Apr 2020 12:28:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1586953737;
	bh=YXatwA0IzgcsJ9gEYbMuYDXR5EsegBs5QetUF828Olk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=s696XhGkqqoa+Tfclg4XhrKE8HIDerjlG6wGjSE2DZaCvBttF0c9GzmQe6pGwt8S9
	 BlUG9g4fjRnHLU86LsN0mLaGjaay/59xBkPgeu6VajR+swMvhGLVZ4zuLlBc0+DWAF
	 pbEJlVdt/vVYb91yuUWB3J2hmsf/cGualu2k2byM=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S369367AbgDOM2y (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 15 Apr 2020 08:28:54 -0400
Received: from mail.kernel.org ([198.145.29.99]:38158 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2409111AbgDOLpC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 15 Apr 2020 07:45:02 -0400
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 6EB4920732;
        Wed, 15 Apr 2020 11:45:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1586951102;
        bh=YXatwA0IzgcsJ9gEYbMuYDXR5EsegBs5QetUF828Olk=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=l8pOR6xPcOAKw45FutThlXPnIwxhKMEpTRrDEd5xrpc6YIwZ27K27q2n4FS8wSR2o
         VjOHk4qGvoaNVL77cCvSO36e6HTnUa3/s/id0L7qdT943llKG52U85fOiaD8QBuAR1
         mUCsuyZRpN/tryLZ+xDnFy8MjTrt5WGCfEhgLhq0=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 5.4 17/84] NFS: alloc_nfs_open_context() must use the file cred when available
Date:   Wed, 15 Apr 2020 07:43:34 -0400
Message-Id: <20200415114442.14166-17-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20200415114442.14166-1-sashal@kernel.org>
References: <20200415114442.14166-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

[ Upstream commit 1d179d6bd67369a52edea8562154b31ee20be1cc ]

If we're creating a nfs_open_context() for a specific file pointer,
we must use the cred assigned to that file.

Fixes: a52458b48af1 ("NFS/NFSD/SUNRPC: replace generic creds with 'struct cred'.")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/nfs/inode.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 2a03bfeec10a4..3802c88e83720 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -959,16 +959,16 @@ struct nfs_open_context *alloc_nfs_open_context(struct dentry *dentry,
 						struct file *filp)
 {
 	struct nfs_open_context *ctx;
-	const struct cred *cred = get_current_cred();
 
 	ctx = kmalloc(sizeof(*ctx), GFP_KERNEL);
-	if (!ctx) {
-		put_cred(cred);
+	if (!ctx)
 		return ERR_PTR(-ENOMEM);
-	}
 	nfs_sb_active(dentry->d_sb);
 	ctx->dentry = dget(dentry);
-	ctx->cred = cred;
+	if (filp)
+		ctx->cred = get_cred(filp->f_cred);
+	else
+		ctx->cred = get_current_cred();
 	ctx->ll_cred = NULL;
 	ctx->state = NULL;
 	ctx->mode = f_mode;
-- 
2.20.1

