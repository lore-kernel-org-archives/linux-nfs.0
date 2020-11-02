Return-Path: <SRS0=KohJ=EI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82CE3C2D0A3
	for <linux-nfs@archiver.kernel.org>; Mon,  2 Nov 2020 18:17:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 361C520786
	for <linux-nfs@archiver.kernel.org>; Mon,  2 Nov 2020 18:17:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1604341051;
	bh=/yoJMgJe/NfX5jVwRvuhIyPkCnQJFVnd/8JyXo6l/54=;
	h=From:To:Subject:Date:In-Reply-To:References:List-ID:From;
	b=SFU/QRiA8VhsyMF520JgM6DBL2CBg+Y9ibqkWZvbf3qLoRK4HmNURyiVGO86zXofo
	 Eqox7RAGGKp2BqFXzrPdvVHTkc8hH1GTH8EI7nA2o0ZCjjdFc1ZNMkAbu8n9sLmJl4
	 I3DsCLic4DGwhn5pyMBr+bBs6ES4eHsewCpRuYxQ=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726324AbgKBSRa (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 2 Nov 2020 13:17:30 -0500
Received: from mail.kernel.org ([198.145.29.99]:40892 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726338AbgKBSR0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 2 Nov 2020 13:17:26 -0500
Received: from localhost.localdomain (c-68-36-133-222.hsd1.mi.comcast.net [68.36.133.222])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id DAFF722226
        for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2020 18:17:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1604341046;
        bh=/yoJMgJe/NfX5jVwRvuhIyPkCnQJFVnd/8JyXo6l/54=;
        h=From:To:Subject:Date:In-Reply-To:References:From;
        b=YHt/+mBfUxw5KKh1YXKOlCWZ4keitrjIm+weXlrZO2HR5G3ax38MaKj4hGqIE1cix
         0hYFzzFK2JAx0Q4SvYGG1Kqnolwutn0L+SHNFsayFDBCnr7fbNe8OqiXiuIMmonHo+
         mF/lAwBK5VioLOdMi8/NiNaWXUeQg0ob38Lobp94=
From:   trondmy@kernel.org
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 11/12] NFS: nfs_do_filldir() does not return a value
Date:   Mon,  2 Nov 2020 13:06:57 -0500
Message-Id: <20201102180658.6218-12-trondmy@kernel.org>
X-Mailer: git-send-email 2.28.0
In-Reply-To: <20201102180658.6218-11-trondmy@kernel.org>
References: <20201102180658.6218-1-trondmy@kernel.org>
 <20201102180658.6218-2-trondmy@kernel.org>
 <20201102180658.6218-3-trondmy@kernel.org>
 <20201102180658.6218-4-trondmy@kernel.org>
 <20201102180658.6218-5-trondmy@kernel.org>
 <20201102180658.6218-6-trondmy@kernel.org>
 <20201102180658.6218-7-trondmy@kernel.org>
 <20201102180658.6218-8-trondmy@kernel.org>
 <20201102180658.6218-9-trondmy@kernel.org>
 <20201102180658.6218-10-trondmy@kernel.org>
 <20201102180658.6218-11-trondmy@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

Clean up nfs_do_filldir().

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/dir.c | 21 +++++++--------------
 1 file changed, 7 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 564e737ef93e..a2cebd365948 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -875,13 +875,11 @@ int readdir_search_pagecache(nfs_readdir_descriptor_t *desc)
 /*
  * Once we've found the start of the dirent within a page: fill 'er up...
  */
-static 
-int nfs_do_filldir(nfs_readdir_descriptor_t *desc)
+static void nfs_do_filldir(struct nfs_readdir_descriptor *desc)
 {
 	struct file	*file = desc->file;
-	int i = 0;
-	int res = 0;
-	struct nfs_cache_array *array = NULL;
+	struct nfs_cache_array *array;
+	unsigned int i = 0;
 
 	array = kmap(desc->page);
 	for (i = desc->cache_entry_index; i < array->size; i++) {
@@ -908,9 +906,8 @@ int nfs_do_filldir(nfs_readdir_descriptor_t *desc)
 		desc->eof = true;
 
 	kunmap(desc->page);
-	dfprintk(DIRCACHE, "NFS: nfs_do_filldir() filling ended @ cookie %Lu; returning = %d\n",
-			(unsigned long long)desc->dir_cookie, res);
-	return res;
+	dfprintk(DIRCACHE, "NFS: nfs_do_filldir() filling ended @ cookie %llu\n",
+			(unsigned long long)desc->dir_cookie);
 }
 
 /*
@@ -951,7 +948,7 @@ int uncached_readdir(nfs_readdir_descriptor_t *desc)
 	if (status < 0)
 		goto out_release;
 
-	status = nfs_do_filldir(desc);
+	nfs_do_filldir(desc);
 
  out_release:
 	nfs_readdir_clear_array(desc->page);
@@ -1026,11 +1023,9 @@ static int nfs_readdir(struct file *file, struct dir_context *ctx)
 		if (res < 0)
 			break;
 
-		res = nfs_do_filldir(desc);
+		nfs_do_filldir(desc);
 		unlock_page(desc->page);
 		nfs_readdir_page_put(desc);
-		if (res < 0)
-			break;
 	} while (!desc->eof);
 
 	spin_lock(&file->f_lock);
@@ -1041,8 +1036,6 @@ static int nfs_readdir(struct file *file, struct dir_context *ctx)
 	spin_unlock(&file->f_lock);
 
 out:
-	if (res > 0)
-		res = 0;
 	dfprintk(FILE, "NFS: readdir(%pD2) returns %d\n", file, res);
 	return res;
 }
-- 
2.28.0

