Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f181.google.com ([209.85.216.181]:60519 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751284AbaGMTVQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Jul 2014 15:21:16 -0400
Received: by mail-qc0-f181.google.com with SMTP id x13so2739143qcv.40
        for <linux-nfs@vger.kernel.org>; Sun, 13 Jul 2014 12:21:15 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Don't reset pg_moreio in __nfs_pageio_add_request
Date: Sun, 13 Jul 2014 15:21:12 -0400
Message-Id: <1405279272-3337-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Once we've started sending unstable NFS writes, we do not want to
clear pg_moreio, or we may end up sending the very last request as
a stable write if the commit lists are still empty.

Do, however, reset pg_moreio in the case where we end up having to
recoalesce the write if an attempt to use pNFS failed.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pagelist.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 0aefc8102b6b..17fab89f6358 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -935,7 +935,6 @@ static int __nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 			nfs_pageio_doio(desc);
 			if (desc->pg_error < 0)
 				return 0;
-			desc->pg_moreio = 0;
 			if (desc->pg_recoalesce)
 				return 0;
 			/* retry add_request for this subreq */
@@ -982,6 +981,7 @@ static int nfs_do_recoalesce(struct nfs_pageio_descriptor *desc)
 		desc->pg_count = 0;
 		desc->pg_base = 0;
 		desc->pg_recoalesce = 0;
+		desc->pg_moreio = 0;
 
 		while (!list_empty(&head)) {
 			struct nfs_page *req;
-- 
1.9.3

