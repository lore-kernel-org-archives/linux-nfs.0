Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f173.google.com ([209.85.216.173]:53209 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755439AbaGHSGr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 14:06:47 -0400
Received: by mail-qc0-f173.google.com with SMTP id l6so5532580qcy.32
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 11:06:47 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 098/100] nfsd: remove nfs4_lock_state: nfs4_state_shutdown_net
Date: Tue,  8 Jul 2014 14:04:26 -0400
Message-Id: <1404842668-22521-99-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 34496bb3badc..4a5bcf256a1d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -6390,7 +6390,6 @@ nfs4_state_shutdown_net(struct net *net)
 	cancel_delayed_work_sync(&nn->laundromat_work);
 	locks_end_grace(&nn->nfsd4_manager);
 
-	nfs4_lock_state();
 	INIT_LIST_HEAD(&reaplist);
 	spin_lock(&state_lock);
 	list_for_each_safe(pos, next, &nn->del_recall_lru) {
@@ -6407,7 +6406,6 @@ nfs4_state_shutdown_net(struct net *net)
 
 	nfsd4_client_tracking_exit(net);
 	nfs4_state_destroy_net(net);
-	nfs4_unlock_state();
 }
 
 void
-- 
1.9.3

