Return-Path: <SRS0=ibFv=Q5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86B35C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 20:38:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 50F61206B6
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 20:38:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AY+bCB85"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726023AbfBVUi5 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Feb 2019 15:38:57 -0500
Received: from mail-it1-f193.google.com ([209.85.166.193]:35151 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725832AbfBVUi5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Feb 2019 15:38:57 -0500
Received: by mail-it1-f193.google.com with SMTP id v72so5176441itc.0
        for <linux-nfs@vger.kernel.org>; Fri, 22 Feb 2019 12:38:56 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=QyFXrS/w+uuKqSd4skjzZ+33Edua3ZagA2sz15JvwYk=;
        b=AY+bCB854Mses5IYJCgAI/bIB4fzCYlC95EqExkH6HOMYzJOzSuEHEIL/M57a8DwIR
         YbESm89OjESGKDoLNK7xooBJaNv5fcl320geE3+dcNbSmDTnJUIwCwCXwNvdr8BEPVu0
         Ua24SIxAbn6AFJfKSG1lajSwQhKmmxMEXRECyruws932pA5w3kYrb2HOktOIS0PDLRX7
         0XMx2fIS5YQar3y+2uEoQqOkNd0lSrQ6kzJEq25kens96ITPBV9aW3og+T+x8sb+KwD4
         hgtTaVshEKog5Yft6OGKnc1l1xxkdUqF/40X6v9skH02ZBktID5oZNywY4sJBga1LQla
         pLfQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=QyFXrS/w+uuKqSd4skjzZ+33Edua3ZagA2sz15JvwYk=;
        b=DtsJYu7OYBoFlK8wPKMH62bdSH9oi54v1i19mM3dZf84rXN3evbR4QiTfVEbVcimZM
         dA+KLqLJujqBF0UmvfYb+Ut2jra4CV++s+V1liDbUe7H0HkwdId0SVyFudopddrSBryp
         N3iZeFsIy10M/6coBG2wYyoxnf0+UT0uuiLOs/vFGNkpcV5JSSK28c2ENesQGIMBPKcZ
         gsQx7qw0iz05Vb7rt2VjBJWYOpSXQEPN1dWZsRfa5zjlOO0CqcGjF7Bb9z1ahbCEPqDL
         DPQFWfmUJKFRtadaNcpR+MPMGkkmI8sdO3Y3jaEPfWtCkGHRExDZtIt9CY7xSL4vaPqE
         V7Jg==
X-Gm-Message-State: AHQUAuZdY5Uti+SlqX9qbB5rddUEjbkUmt9kXCwKMKYBmI3/1CAdTyr+
        toKJn5s00iPbUjWZgLMNsOVGiUo=
X-Google-Smtp-Source: AHgI3IaDLLQEd5pMjEjJoDQd7F4juPU51nUSxmPn5rsWmFGMcC3f5zZ7khEuE1zN8ReMYQOghzEJjQ==
X-Received: by 2002:a24:70a:: with SMTP id f10mr3533514itf.56.1550867935543;
        Fri, 22 Feb 2019 12:38:55 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id b36sm1008626itd.2.2019.02.22.12.38.54
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 22 Feb 2019 12:38:54 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH] NFS/pnfs: Bulk destroy of layouts needs to be safe w.r.t. umount
Date:   Fri, 22 Feb 2019 15:37:47 -0500
Message-Id: <20190222203747.55794-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If a bulk layout recall or a metadata server reboot coincides with a
umount, then holding a reference to an inode is unsafe unless we
also hold a reference to the super block.

Fixes: fd9a8d7160937 ("NFSv4.1: Fix bulk recall and destroy of layouts")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/pnfs.c | 32 ++++++++++++++++++++++----------
 fs/nfs/pnfs.h |  1 +
 2 files changed, 23 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 53726da5c010..1a61eed69806 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -758,22 +758,34 @@ static int
 pnfs_layout_bulk_destroy_byserver_locked(struct nfs_client *clp,
 		struct nfs_server *server,
 		struct list_head *layout_list)
+	__must_hold(&clp->cl_lock)
+	__must_hold(RCU)
 {
 	struct pnfs_layout_hdr *lo, *next;
 	struct inode *inode;
 
 	list_for_each_entry_safe(lo, next, &server->layouts, plh_layouts) {
-		if (test_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags))
+		if (test_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags) ||
+		    test_bit(NFS_LAYOUT_INODE_FREEING, &lo->plh_flags))
 			continue;
+		/* If the sb is being destroyed, just bail */
+		if (!nfs_sb_active(server->super))
+			break;
 		inode = igrab(lo->plh_inode);
-		if (inode == NULL)
-			continue;
-		list_del_init(&lo->plh_layouts);
-		if (pnfs_layout_add_bulk_destroy_list(inode, layout_list))
-			continue;
-		rcu_read_unlock();
-		spin_unlock(&clp->cl_lock);
-		iput(inode);
+		if (inode != NULL) {
+			list_del_init(&lo->plh_layouts);
+			if (pnfs_layout_add_bulk_destroy_list(inode,
+						layout_list))
+				continue;
+			rcu_read_unlock();
+			spin_unlock(&clp->cl_lock);
+			iput(inode);
+		} else {
+			rcu_read_unlock();
+			spin_unlock(&clp->cl_lock);
+			set_bit(NFS_LAYOUT_INODE_FREEING, &lo->plh_flags);
+		}
+		nfs_sb_deactive(server->super);
 		spin_lock(&clp->cl_lock);
 		rcu_read_lock();
 		return -EAGAIN;
@@ -811,7 +823,7 @@ pnfs_layout_free_bulk_destroy_list(struct list_head *layout_list,
 		/* Free all lsegs that are attached to commit buckets */
 		nfs_commit_inode(inode, 0);
 		pnfs_put_layout_hdr(lo);
-		iput(inode);
+		nfs_iput_and_deactive(inode);
 	}
 	return ret;
 }
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 5e80a07b7bea..56659ccce1d8 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -104,6 +104,7 @@ enum {
 	NFS_LAYOUT_RETURN_REQUESTED,	/* Return this layout ASAP */
 	NFS_LAYOUT_INVALID_STID,	/* layout stateid id is invalid */
 	NFS_LAYOUT_FIRST_LAYOUTGET,	/* Serialize first layoutget */
+	NFS_LAYOUT_INODE_FREEING,	/* The inode is being freed */
 };
 
 enum layoutdriver_policy_flags {
-- 
2.20.1

