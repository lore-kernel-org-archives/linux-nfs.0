Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gx0-f174.google.com ([209.85.161.174]:49119 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752440Ab2CEQmn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Mar 2012 11:42:43 -0500
Received: by gghe5 with SMTP id e5so968082ggh.19
        for <linux-nfs@vger.kernel.org>; Mon, 05 Mar 2012 08:42:43 -0800 (PST)
MIME-Version: 1.0
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] nfsd: only initialize client tracking if nfs4_state_start is successful
Date: Mon,  5 Mar 2012 11:42:36 -0500
Message-Id: <1330965756-24180-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1330965756-24180-1-git-send-email-jlayton@redhat.com>
References: <1330965756-24180-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The current code never calls nfsd4_client_tracking_exit if
nfs4_state_start returns an error. Also, it's better to go ahead and
consolidate these functions since one is just a trivial wrapper around
the other.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4state.c |   26 +++++++++++++-------------
 1 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e547b27..1198fe8 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4629,21 +4629,26 @@ set_max_delegations(void)
 
 /* initialization to perform when the nfsd service is started: */
 
-static int
-__nfs4_state_start(void)
+int
+nfs4_state_start(void)
 {
 	int ret;
 
+	nfsd4_load_reboot_recovery_data();
 	boot_time = get_seconds();
 	locks_start_grace(&nfsd4_manager);
 	printk(KERN_INFO "NFSD: starting %ld-second grace period\n",
 	       nfsd4_grace);
 	ret = set_callback_cred();
-	if (ret)
-		return -ENOMEM;
+	if (ret) {
+		ret = -ENOMEM;
+		goto out_recovery;
+	}
 	laundry_wq = create_singlethread_workqueue("nfsd4");
-	if (laundry_wq == NULL)
-		return -ENOMEM;
+	if (laundry_wq == NULL) {
+		ret = -ENOMEM;
+		goto out_recovery;
+	}
 	ret = nfsd4_create_callback_queue();
 	if (ret)
 		goto out_free_laundry;
@@ -4652,16 +4657,11 @@ __nfs4_state_start(void)
 	return 0;
 out_free_laundry:
 	destroy_workqueue(laundry_wq);
+out_recovery:
+	nfsd4_shutdown_recdir();
 	return ret;
 }
 
-int
-nfs4_state_start(void)
-{
-	nfsd4_load_reboot_recovery_data();
-	return __nfs4_state_start();
-}
-
 static void
 __nfs4_state_shutdown(void)
 {
-- 
1.7.7.6

