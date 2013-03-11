Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-da0-f41.google.com ([209.85.210.41]:43742 "EHLO
	mail-da0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753317Ab3CKA6R (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 10 Mar 2013 20:58:17 -0400
From: ycnian@gmail.com
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Yanchuan Nian <ycnian@gmail.com>
Subject: [PATCH v2] nfsd: fix bug on nfs4 stateid deallocation
Date: Mon, 11 Mar 2013 08:46:14 +0800
Message-Id: <1362962774-5141-1-git-send-email-ycnian@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS4_OO_PURGE_CLOSE is not handled properly. To avoid memory leak, nfs4 
stateid which is pointed by oo_last_closed_stid is freed in nfsd4_close(), 
but NFS4_OO_PURGE_CLOSE isn't cleared meanwhile. So the stateid released in 
THIS close procedure may be freed immediately in the coming encoding function.
Sorry that Signed-off-by was forgotten in last version.

Signed-off-by: Yanchuan Nian <ycnian@gmail.com>
---
 fs/nfsd/nfs4state.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index cc41bf4..d972db8 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3827,6 +3827,7 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	nfsd4_close_open_stateid(stp);
 	release_last_closed_stateid(oo);
+	oo->oo_flags &= ~NFS4_OO_PURGE_CLOSE;
 	oo->oo_last_closed_stid = stp;
 
 	if (list_empty(&oo->oo_owner.so_stateids)) {
-- 
1.7.4.4

