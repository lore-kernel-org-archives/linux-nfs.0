Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:42426 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752612Ab3AUOyc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jan 2013 09:54:32 -0500
Received: by mail-ee0-f46.google.com with SMTP id e49so2982560eek.33
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jan 2013 06:54:30 -0800 (PST)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Cc: Benny Halevy <bhalevy@tonian.com>
Subject: [PATCH 3/9] SQUASHME: pnfsd: do not dequeue layout state on destroy_layout
Date: Mon, 21 Jan 2013 16:54:28 +0200
Message-Id: <1358780068-5983-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <50FD5646.4020206@tonian.com>
References: <50FD5646.4020206@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

the layout state may be shared by a number of layout segments,
each held by struct nfs4_layout and we may be destroying just one of them
e.g. on layoutreturn.

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4pnfsd.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index fe3f693..c62af3d 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -345,7 +345,6 @@ static void update_layout_roc(struct nfs4_layout_state *ls, bool roc)
 		__func__, lp, clp, fp, fp->fi_inode);
 
 	kmem_cache_free(pnfs_layout_slab, lp);
-	list_del_init(&ls->ls_perfile);
 	/* release references taken by init_layout */
 	put_layout_state(ls);
 	put_nfs4_file(fp);
@@ -1249,6 +1248,7 @@ void pnfsd_roc(struct nfs4_client *clp, struct nfs4_file *fp)
 		memset(&lr, 0, sizeof(lr));
 		lr.args.lr_return_type = RETURN_FILE;
 		lr.args.lr_seg = lo->lo_seg;
+		list_del_init(&lo->lo_state->ls_perfile);	/* just to be on the safe side */
 		dequeue_layout(lo);
 		destroy_layout(lo); /* do not access lp after this */
 
@@ -1301,6 +1301,7 @@ void pnfs_expire_client(struct nfs4_client *clp)
 			lr.args.lr_seg = lp->lo_seg;
 			empty = list_empty(&lp->lo_file->fi_layouts);
 			BUG_ON(lp->lo_client != clp);
+			list_del_init(&lp->lo_state->ls_perfile);	/* just to be on the safe side */
 			dequeue_layout(lp);
 			destroy_layout(lp); /* do not access lp after this */
 		}
-- 
1.7.11.7

