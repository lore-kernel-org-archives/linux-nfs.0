Return-Path: <SRS0=TAi6=EF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.3 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNWANTED_LANGUAGE_BODY,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BCB9EC388F9
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Oct 2020 22:07:43 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 5A1FD2087E
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Oct 2020 22:07:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1604095663;
	bh=MOBmL2uL4txSencAZUUeyuOlu/ZATH07W1xk5scpDbw=;
	h=From:To:Subject:Date:In-Reply-To:References:List-ID:From;
	b=ofwrT1FvT/UkVnWupJsOWHb0OJwKMsuxdaZS3e/VuG6jVNiddGD5c3RB5RvmdAepv
	 oWclQneq4vAfALY3sWvfnCDEflYBt3xllgM7HcKzzC7eFWjsLmwoTsrEFGsehhyt1B
	 guh/A6wthhEBSGhxTPhVVatOD/9tKGkovZqTGoH0=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725914AbgJ3WHm (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 30 Oct 2020 18:07:42 -0400
Received: from mail.kernel.org ([198.145.29.99]:58810 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725792AbgJ3WHm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Oct 2020 18:07:42 -0400
Received: from localhost.localdomain (c-68-36-133-222.hsd1.mi.comcast.net [68.36.133.222])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id D2B8322227
        for <linux-nfs@vger.kernel.org>; Fri, 30 Oct 2020 22:07:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1604095662;
        bh=MOBmL2uL4txSencAZUUeyuOlu/ZATH07W1xk5scpDbw=;
        h=From:To:Subject:Date:In-Reply-To:References:From;
        b=SR1kYCq4JgZuWtsceH5oAI/VbgCf4DMaX1P3n4E08iexNHd1Bwl6DUF5lUrMbc3BS
         sgKPgNYH4KTtMrbdn3O/99MPWSt8ys0C9O0TS7LU/cosQO2NAGrYd2gsMbN5iCGI5g
         aIXSyfaoL2C4SIIaArvBJ1pS7kz6ENIbJ/ddAlbE=
From:   trondmy@kernel.org
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFS: Remove unnecessary inode lock in nfs_fsync_dir()
Date:   Fri, 30 Oct 2020 17:57:30 -0400
Message-Id: <20201030215730.85147-2-trondmy@kernel.org>
X-Mailer: git-send-email 2.28.0
In-Reply-To: <20201030215730.85147-1-trondmy@kernel.org>
References: <20201030215730.85147-1-trondmy@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

nfs_inc_stats() is already thread-safe, and there are no other reasons
to hold the inode lock here.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/dir.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index e56b1bd99537..4e011adaf967 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -997,13 +997,9 @@ static loff_t nfs_llseek_dir(struct file *filp, loff_t offset, int whence)
 static int nfs_fsync_dir(struct file *filp, loff_t start, loff_t end,
 			 int datasync)
 {
-	struct inode *inode = file_inode(filp);
-
 	dfprintk(FILE, "NFS: fsync dir(%pD2) datasync %d\n", filp, datasync);
 
-	inode_lock(inode);
-	nfs_inc_stats(inode, NFSIOS_VFSFSYNC);
-	inode_unlock(inode);
+	nfs_inc_stats(file_inode(filp), NFSIOS_VFSFSYNC);
 	return 0;
 }
 
-- 
2.28.0

