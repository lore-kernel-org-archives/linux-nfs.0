Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f182.google.com ([209.85.160.182]:33270 "EHLO
	mail-yk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933505AbbGJUdn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jul 2015 16:33:43 -0400
Received: by ykeo3 with SMTP id o3so151915037yke.0
        for <linux-nfs@vger.kernel.org>; Fri, 10 Jul 2015 13:33:42 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: linux-nfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, william@gandi.net, bfields@fieldses.org
Subject: [RFC PATCH 1/4] Revert "nfs: take extra reference to fl->fl_file when running a LOCKU operation"
Date: Fri, 10 Jul 2015 16:33:31 -0400
Message-Id: <1436560414-26306-2-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1436560414-26306-1-git-send-email-jeff.layton@primarydata.com>
References: <1436560414-26306-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This reverts commit db2efec0caba4f81a22d95a34da640b86c313c8e.

William reported that he was seeing instability with this patch, which
is likely due to the fact that it can cause the kernel to take a new
reference to a filp after the last reference has already been put.

Revert this patch for now, as we'll need to fix this in another way.

Cc: stable@vger.kernel.org
Reported-by: William Dauchy <william@gandi.net>
Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/nfs4proc.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6f228b5af819..60be01f69b84 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5484,7 +5484,6 @@ static struct nfs4_unlockdata *nfs4_alloc_unlockdata(struct file_lock *fl,
 	atomic_inc(&lsp->ls_count);
 	/* Ensure we don't close file until we're done freeing locks! */
 	p->ctx = get_nfs_open_context(ctx);
-	get_file(fl->fl_file);
 	memcpy(&p->fl, fl, sizeof(p->fl));
 	p->server = NFS_SERVER(inode);
 	return p;
@@ -5496,7 +5495,6 @@ static void nfs4_locku_release_calldata(void *data)
 	nfs_free_seqid(calldata->arg.seqid);
 	nfs4_put_lock_state(calldata->lsp);
 	put_nfs_open_context(calldata->ctx);
-	fput(calldata->fl.fl_file);
 	kfree(calldata);
 }
 
-- 
2.4.3

