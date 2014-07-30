Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f46.google.com ([209.85.216.46]:42152 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753115AbaG3M2e (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jul 2014 08:28:34 -0400
Received: by mail-qa0-f46.google.com with SMTP id v10so1175803qac.33
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jul 2014 05:28:34 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH 35/37] nfsd: remove nfs4_lock_state: nfs4_state_shutdown_net
Date: Wed, 30 Jul 2014 08:27:36 -0400
Message-Id: <1406723258-8512-36-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
References: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 7eea82e1d779..a33ce55925fb 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -6402,7 +6402,6 @@ nfs4_state_shutdown_net(struct net *net)
 	cancel_delayed_work_sync(&nn->laundromat_work);
 	locks_end_grace(&nn->nfsd4_manager);
 
-	nfs4_lock_state();
 	INIT_LIST_HEAD(&reaplist);
 	spin_lock(&state_lock);
 	list_for_each_safe(pos, next, &nn->del_recall_lru) {
@@ -6419,7 +6418,6 @@ nfs4_state_shutdown_net(struct net *net)
 
 	nfsd4_client_tracking_exit(net);
 	nfs4_state_destroy_net(net);
-	nfs4_unlock_state();
 }
 
 void
-- 
1.9.3

