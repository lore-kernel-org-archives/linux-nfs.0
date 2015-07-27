Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:34651 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750883AbbG0Oap (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Jul 2015 10:30:45 -0400
Received: by igk11 with SMTP id 11so64006872igk.1
        for <linux-nfs@vger.kernel.org>; Mon, 27 Jul 2015 07:30:45 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Weston Andros Adamson <dros@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFS: Don't clear desc->pg_moreio in nfs_do_recoalesce()
Date: Mon, 27 Jul 2015 10:30:40 -0400
Message-Id: <1438007440-7045-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1438007440-7045-1-git-send-email-trond.myklebust@primarydata.com>
References: <1438007440-7045-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Recoalescing does not affect whether or not we've already sent off
I/O, and doing so means that we end up sending a bunch of synchronous
for cases where we actually need to be using unstable writes.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pagelist.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 8b15d98192c5..88c4d4914bbb 100644
--- a/fs/nfs/pagelist.c
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

