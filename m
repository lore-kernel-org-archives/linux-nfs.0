Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:35368 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753195AbbLHMX6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Dec 2015 07:23:58 -0500
Received: by qgec40 with SMTP id c40so13692108qge.2
        for <linux-nfs@vger.kernel.org>; Tue, 08 Dec 2015 04:23:57 -0800 (PST)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@lst.de>,
        Kinglong Mee <kinglongmee@gmail.com>
Subject: [RFC PATCH 1/2] nfsd: don't hold ls_mutex across a layout recall
Date: Tue,  8 Dec 2015 07:23:47 -0500
Message-Id: <1449577428-13181-2-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1449577428-13181-1-git-send-email-jeff.layton@primarydata.com>
References: <1449577428-13181-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We do need to serialize layout stateid morphing operations, but we
currently hold the ls_mutex across a layout recall which is pretty
ugly. It's also unnecessary -- once we've bumped the seqid and
copied it, we don't need to serialize the rest of the CB_LAYOUTRECALL
vs. anything else. Just drop the mutex once the copy is done.

Fixes: cc8a55320b5f "nfsd: serialize layout stateid morphing operations"
Cc: stable@vger.kernel.org
Reported-and-Tested-by: Kinglong Mee <kinglongmee@gmail.com>
Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/nfs4layouts.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index 9ffef06b30d5..c9d6c715c0fb 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -616,6 +616,7 @@ nfsd4_cb_layout_prepare(struct nfsd4_callback *cb)
 
 	mutex_lock(&ls->ls_mutex);
 	nfs4_inc_and_copy_stateid(&ls->ls_recall_sid, &ls->ls_stid);
+	mutex_unlock(&ls->ls_mutex);
 }
 
 static int
@@ -659,7 +660,6 @@ nfsd4_cb_layout_release(struct nfsd4_callback *cb)
 
 	trace_layout_recall_release(&ls->ls_stid.sc_stateid);
 
-	mutex_unlock(&ls->ls_mutex);
 	nfsd4_return_all_layouts(ls, &reaplist);
 	nfsd4_free_layouts(&reaplist);
 	nfs4_put_stid(&ls->ls_stid);
-- 
2.5.0

