Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f43.google.com ([209.85.160.43]:42106 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753467Ab3CKAlj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 10 Mar 2013 20:41:39 -0400
From: ycnian@gmail.com
To: bfields@fieldses.org
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: fix bug on nfs4 stateid deallocation
Date: Mon, 11 Mar 2013 08:29:46 +0800
Message-Id: <1362961786-4452-1-git-send-email-ycnian@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS4_OO_PURGE_CLOSE is not handled properly. To avoid memory leak, nfs4 
stateid which is pointed by oo_last_closed_stid is freed in nfsd4_close(),
but NFS4_OO_PURGE_CLOSE isn't cleared meanwhile. So the stateid released 
in THIS close procedure may be freed immediately in the coming encoding
function.

---
 fs/nfsd/nfs4state.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 75c873d..7499c91 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3850,6 +3850,7 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	nfsd4_close_open_stateid(stp);
 	release_last_closed_stateid(oo);
+	oo->oo_flags &= ~NFS4_OO_PURGE_CLOSE;
 	oo->oo_last_closed_stid = stp;
 
 	if (list_empty(&oo->oo_owner.so_stateids)) {
-- 
1.8.0.1

