Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f175.google.com ([209.85.214.175]:43587 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752400AbaBTC2d (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Feb 2014 21:28:33 -0500
Received: by mail-ob0-f175.google.com with SMTP id wn1so1438584obc.34
        for <linux-nfs@vger.kernel.org>; Wed, 19 Feb 2014 18:28:32 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/7] NFSv4.1: Minor optimisation in get_layout_by_fh_locked()
Date: Wed, 19 Feb 2014 21:28:22 -0500
Message-Id: <1392863305-14870-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1392863305-14870-3-git-send-email-trond.myklebust@primarydata.com>
References: <1392863305-14870-1-git-send-email-trond.myklebust@primarydata.com>
 <1392863305-14870-2-git-send-email-trond.myklebust@primarydata.com>
 <1392863305-14870-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the filehandles match, but the igrab() fails, or the layout is
freed before we can get it, then just return NULL.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/callback_proc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 570c8a1d2f3d..41db5258e7a7 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -127,13 +127,13 @@ static struct pnfs_layout_hdr * get_layout_by_fh_locked(struct nfs_client *clp,
 				continue;
 			ino = igrab(lo->plh_inode);
 			if (!ino)
-				continue;
+				break;
 			spin_lock(&ino->i_lock);
 			/* Is this layout in the process of being freed? */
 			if (NFS_I(ino)->layout != lo) {
 				spin_unlock(&ino->i_lock);
 				iput(ino);
-				continue;
+				break;
 			}
 			pnfs_get_layout_hdr(lo);
 			spin_unlock(&ino->i_lock);
-- 
1.8.5.3

