Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from www17.your-server.de ([213.133.104.17]:44238 "EHLO
        www17.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753200AbdJGOYN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 7 Oct 2017 10:24:13 -0400
Subject: [PATCH] NFS: Fix bool initialization/comparison
From: Thomas Meyer <thomas@m3y3r.de>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Message-ID: <1507383097084-201334057-10-diffsplit-thomas@m3y3r.de>
References: <1507383097081-778026979-0-diffsplit-thomas@m3y3r.de>
In-Reply-To: <1507383097081-778026979-0-diffsplit-thomas@m3y3r.de>
Date: Sat, 07 Oct 2017 16:02:21 +0200
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bool initializations should use true and false. Bool tests don't need
comparisons.

Signed-off-by: Thomas Meyer <thomas@m3y3r.de>
---

diff -u -p a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -439,7 +439,7 @@ static bool referring_call_exists(struct
 				  uint32_t nrclists,
 				  struct referring_call_list *rclists)
 {
-	bool status = 0;
+	bool status = false;
 	int i, j;
 	struct nfs4_session *session;
 	struct nfs4_slot_table *tbl;
diff -u -p a/fs/nfs/dir.c b/fs/nfs/dir.c
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -253,7 +253,7 @@ int nfs_readdir_search_for_pos(struct nf
 	desc->cache_entry_index = index;
 	return 0;
 out_eof:
-	desc->eof = 1;
+	desc->eof = true;
 	return -EBADCOOKIE;
 }
 
@@ -307,7 +307,7 @@ int nfs_readdir_search_for_cookie(struct
 	if (array->eof_index >= 0) {
 		status = -EBADCOOKIE;
 		if (*desc->dir_cookie == array->last_cookie)
-			desc->eof = 1;
+			desc->eof = true;
 	}
 out:
 	return status;
@@ -761,7 +761,7 @@ int nfs_do_filldir(nfs_readdir_descripto
 		ent = &array->array[i];
 		if (!dir_emit(desc->ctx, ent->string.name, ent->string.len,
 		    nfs_compat_user_ino64(ent->ino), ent->d_type)) {
-			desc->eof = 1;
+			desc->eof = true;
 			break;
 		}
 		desc->ctx->pos++;
@@ -773,7 +773,7 @@ int nfs_do_filldir(nfs_readdir_descripto
 			ctx->duped = 1;
 	}
 	if (array->eof_index >= 0)
-		desc->eof = 1;
+		desc->eof = true;
 
 	kunmap(desc->page);
 	cache_page_release(desc);
@@ -873,7 +873,7 @@ static int nfs_readdir(struct file *file
 		if (res == -EBADCOOKIE) {
 			res = 0;
 			/* This means either end of directory */
-			if (*desc->dir_cookie && desc->eof == 0) {
+			if (*desc->dir_cookie && !desc->eof) {
 				/* Or that the server has 'lost' a cookie */
 				res = uncached_readdir(desc);
 				if (res == 0)
diff -u -p a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -793,7 +793,7 @@ nfs4_find_client_sessionid(struct net *n
 
 	spin_lock(&nn->nfs_client_lock);
 	list_for_each_entry(clp, &nn->nfs_client_list, cl_share_link) {
-		if (nfs4_cb_match_client(addr, clp, minorversion) == false)
+		if (!nfs4_cb_match_client(addr, clp, minorversion))
 			continue;
 
 		if (!nfs4_has_session(clp))
diff -u -p a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1513,7 +1513,7 @@ pnfs_lseg_range_match(const struct pnfs_
 	if ((range->iomode == IOMODE_RW &&
 	     ls_range->iomode != IOMODE_RW) ||
 	    (range->iomode != ls_range->iomode &&
-	     strict_iomode == true) ||
+	     strict_iomode) ||
 	    !pnfs_lseg_range_intersecting(ls_range, range))
 		return 0;
 
