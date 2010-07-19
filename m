From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 1/5] nfsd: don't try to shut down nfs4 state handling unless it's up
Date: Mon, 19 Jul 2010 16:50:04 -0400
Message-ID: <1279572608-7234-2-git-send-email-jlayton@redhat.com>
References: <1279572608-7234-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44521 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966728Ab0GSUur (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Jul 2010 16:50:47 -0400
In-Reply-To: <1279572608-7234-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If someone tries to shut down the laundry_wq while it isn't up it'll
cause an oops.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4state.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 4a27347..0b396f8 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4116,6 +4116,8 @@ __nfs4_state_shutdown(void)
 void
 nfs4_state_shutdown(void)
 {
+	if (!nfs4_init)
+		return;
 	cancel_rearming_delayed_workqueue(laundry_wq, &laundromat_work);
 	destroy_workqueue(laundry_wq);
 	locks_end_grace(&nfsd4_manager);
-- 
1.5.5.6

