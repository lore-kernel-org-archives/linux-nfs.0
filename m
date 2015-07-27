Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:37096 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753666AbbG0OeU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Jul 2015 10:34:20 -0400
Received: by igbpg9 with SMTP id pg9so79401220igb.0
        for <linux-nfs@vger.kernel.org>; Mon, 27 Jul 2015 07:34:20 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Weston Andros Adamson <dros@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFS: Don't clear desc->pg_moreio in nfs_do_recoalesce()
Date: Mon, 27 Jul 2015 10:34:16 -0400
Message-Id: <1438007656-11662-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1438007656-11662-1-git-send-email-trond.myklebust@primarydata.com>
References: <1438007656-11662-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Recoalescing does not affect whether or not we've already sent off
I/O, and doing so means that we end up sending a bunch of synchronous
for cases where we actually need to be using unstable writes.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pagelist.c | 2 --
 1 file changed, 2 deletions(-)

diff --git PATCH v2fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 8ea5920fb777..4984bbe55ff1 100644
--- PATCH v2fs/nfs/pagelist.c	
+++ b/fs/nfs/pagelist.c
@@ -1100,8 +1100,6 @@ static int nfs_do_recoalesce(struct nfs_pageio_descriptor *desc)
 		mirror->pg_base = 0;
 		mirror->pg_recoalesce = 0;
 
-		desc->pg_moreio = 0;
-
 		while (!list_empty(&head)) {
 			struct nfs_page *req;
 
-- 
2.4.3

