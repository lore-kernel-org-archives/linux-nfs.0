From: NeilBrown <neilb@suse.de>
Subject: [PATCH 012 of 16] knfsd: nfsd4: fix laundromat shutdown race
Date: Mon, 3 Apr 2006 15:19:05 +1000
Message-ID: <1060403051905.1869@suse.de>
References: <20060403151452.1567.patches@notabene>
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751417AbWDCFWv@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


We need to make sure the laundromat work doesn't reschedule itself just when
we try to cancel it.  Also, we shouldn't be waiting for it to finish running
while holding the state lock, as that's a potential deadlock.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4state.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2006-04-03 15:12:03.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2006-04-03 15:12:16.000000000 +1000
@@ -3238,8 +3238,6 @@ __nfs4_state_shutdown(void)
 	}
 
 	cancel_delayed_work(&laundromat_work);
-	flush_workqueue(laundry_wq);
-	destroy_workqueue(laundry_wq);
 	nfsd4_shutdown_recdir();
 	nfs4_init = 0;
 }
@@ -3247,6 +3245,8 @@ __nfs4_state_shutdown(void)
 void
 nfs4_state_shutdown(void)
 {
+	cancel_rearming_delayed_workqueue(laundry_wq, &laundromat_work);
+	destroy_workqueue(laundry_wq);
 	nfs4_lock_state();
 	nfs4_release_reclaim();
 	__nfs4_state_shutdown();
