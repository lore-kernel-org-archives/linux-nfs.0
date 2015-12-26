Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:35148 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751578AbbLZXVl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 26 Dec 2015 18:21:41 -0500
Received: by mail-io0-f179.google.com with SMTP id q126so279965857iof.2
        for <linux-nfs@vger.kernel.org>; Sat, 26 Dec 2015 15:21:40 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 03/14] nfs: clean up rest of reqs when failing to add one
Date: Sat, 26 Dec 2015 18:20:49 -0500
Message-Id: <1451172060-28238-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1451172060-28238-2-git-send-email-trond.myklebust@primarydata.com>
References: <1451172060-28238-1-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

If we fail to set up things before sending anything over wire,
we need to clean up the reqs that are still attached to the
IO descriptor.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pagelist.c | 17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 871ba5df5ca9..f66021663645 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -1120,6 +1120,7 @@ static int nfs_do_recoalesce(struct nfs_pageio_descriptor *desc)
 static int nfs_pageio_add_request_mirror(struct nfs_pageio_descriptor *desc,
 		struct nfs_page *req)
 {
+	struct nfs_pgio_mirror *mirror = nfs_pgio_current_mirror(desc);
 	int ret;
 
 	do {
@@ -1147,7 +1148,7 @@ int nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 
 	nfs_pageio_setup_mirroring(desc, req);
 	if (desc->pg_error < 0)
-		return 0;
+		goto out_failed;
 
 	for (midx = 0; midx < desc->pg_mirror_count; midx++) {
 		if (midx) {
@@ -1164,7 +1165,8 @@ int nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 
 			if (IS_ERR(dupreq)) {
 				nfs_page_group_unlock(req);
-				return 0;
+				desc->pg_error = PTR_ERR(dupreq);
+				goto out_failed;
 			}
 
 			nfs_lock_request(dupreq);
@@ -1177,10 +1179,19 @@ int nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 		if (nfs_pgio_has_mirroring(desc))
 			desc->pg_mirror_idx = midx;
 		if (!nfs_pageio_add_request_mirror(desc, dupreq))
-			return 0;
+			goto out_failed;
 	}
 
 	return 1;
+
+out_failed:
+	/*
+	 * We might have failed before sending any reqs over wire.
+	 * clean up rest of the reqs in mirror pg_list
+	 */
+	if (desc->pg_error)
+		desc->pg_completion_ops->error_cleanup(&mirror->pg_list);
+	return 0;
 }
 
 /*
-- 
2.5.0

