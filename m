Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:24056 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754984Ab2KUPFm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Nov 2012 10:05:42 -0500
Subject: [PATCH] nfsd4: remove state lock from nfs4_state_shutdown
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Wed, 21 Nov 2012 18:07:38 +0300
Message-ID: <20121121150730.6644.99859.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Protection of __nfs4_state_shutdown() with nfs4_lock_state() looks redundant.

This function is called by the last NFSd thread on it's exit and state lock
protects actually two functions (del_recall_lru is protected by recall_lock):
1) nfsd4_client_tracking_exit
2) __nfs4_state_shutdown_net

"nfsd4_client_tracking_exit" doesn't require state lock protection, because it's
state can be modified only by tracker callbacks.
Here a re they:
1) create: is called only from nfsd4_proc_compound.
2) remove: is called from either nfsd4_proc_compound or nfs4_laundromat.
3) check: is called only from nfsd4_proc_compound.
4) grace_done; called only from nfs4_laundromat.

nfsd4_proc_compound is called onll by NFSd kthread, which is exiting right
now.
nfs4_laundromat is called by laundry_wq. But laundromat_work was canceled
already.

"__nfs4_state_shutdown_net" also doesn't require state lock protection,
because all NFSd kthreads are dead, and no race can happen with NFSd start,
because "nfsd_up" flag is still set.
Moreover, all Nfsd shutdown is protected with global nfsd_mutex.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/nfs4state.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e75872f..d41cc71 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4926,9 +4926,7 @@ nfs4_state_shutdown(void)
 	cancel_delayed_work_sync(&nn->laundromat_work);
 	destroy_workqueue(laundry_wq);
 	locks_end_grace(&nn->nfsd4_manager);
-	nfs4_lock_state();
 	__nfs4_state_shutdown(net);
-	nfs4_unlock_state();
 	nfsd4_destroy_callback_queue();
 }
 

