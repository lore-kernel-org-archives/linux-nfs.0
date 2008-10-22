From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 3/3] nfsd4: end grace only once
Date: Wed, 22 Oct 2008 17:03:22 -0400
Message-ID: <1224709402-6976-4-git-send-email-bfields@citi.umich.edu>
References: <1224709402-6976-1-git-send-email-bfields@citi.umich.edu>
 <1224709402-6976-2-git-send-email-bfields@citi.umich.edu>
 <1224709402-6976-3-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:42798 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752947AbYJVVDX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Oct 2008 17:03:23 -0400
In-Reply-To: <1224709402-6976-3-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

With the newly coordinated v4 and lockd grace period code, it's possible
nfsd4 could end its grace period while lockd is still holding onto its
own--which would mean we could call end_grace() here twice.

That's not really a huge deal, but I'd rather not.  Also, the grace
period is eventually going to become more of a per-filesystem notion, at
which point in_grace() calls that aren't associated with a filesystem
will become awkward.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4state.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 7ef42f4..43c83be 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1836,12 +1836,15 @@ nfs4_laundromat(void)
 	time_t cutoff = get_seconds() - NFSD_LEASE_TIME;
 	time_t t, clientid_val = NFSD_LEASE_TIME;
 	time_t u, test_val = NFSD_LEASE_TIME;
+	static int grace_ended = 0;
 
 	nfs4_lock_state();
 
 	dprintk("NFSD: laundromat service - starting\n");
-	if (locks_in_grace())
+	if (!grace_ended) {
+		grace_ended = 1;
 		nfsd4_end_grace();
+	}
 	list_for_each_safe(pos, next, &client_lru) {
 		clp = list_entry(pos, struct nfs4_client, cl_lru);
 		if (time_after((unsigned long)clp->cl_time, (unsigned long)cutoff)) {
-- 
1.5.5.rc1

