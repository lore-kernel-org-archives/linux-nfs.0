Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:22993 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752158Ab2JBUBk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Oct 2012 16:01:40 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Set key construction data for the legacy upcall
Date: Tue,  2 Oct 2012 16:01:38 -0400
Message-Id: <1349208098-18997-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This prevents a null pointer dereference when
nfs_idmap_complete_pipe_upcall_locked() calls complete_request_key().

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/idmap.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index 675b389c..9cc4a3f 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -707,6 +707,7 @@ static int nfs_idmap_legacy_upcall(struct key_construction *cons,
 	msg = &data->pipe_msg;
 	im = &data->idmap_msg;
 	data->idmap = idmap;
+	data->key_cons = cons;
 
 	ret = nfs_idmap_prepare_message(key->description, idmap, im, msg);
 	if (ret < 0)
-- 
1.7.12.2

