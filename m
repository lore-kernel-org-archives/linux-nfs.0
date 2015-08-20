Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f176.google.com ([209.85.160.176]:36824 "EHLO
	mail-yk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751741AbbHTLR2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Aug 2015 07:17:28 -0400
Received: by ykfw73 with SMTP id w73so33702681ykf.3
        for <linux-nfs@vger.kernel.org>; Thu, 20 Aug 2015 04:17:28 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@lst.de, kinglongmee@gmail.com
Subject: [PATCH v3 01/20] nfsd: allow more than one laundry job to run at a time
Date: Thu, 20 Aug 2015 07:17:01 -0400
Message-Id: <1440069440-27454-2-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1440069440-27454-1-git-send-email-jeff.layton@primarydata.com>
References: <1440069440-27454-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We can potentially have several nfs4_laundromat jobs running if there
are multiple namespaces running nfsd on the box. Those are effectively
separated from one another though, so I don't see any reason to
serialize them.

Also, create_singlethread_workqueue automatically adds the
WQ_MEM_RECLAIM flag. Since we run this job on a timer, it's not really
involved in any reclaim paths. I see no need for a rescuer thread.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c0c47a878cc6..af88d1d7ccae 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -6598,7 +6598,7 @@ nfs4_state_start(void)
 	ret = set_callback_cred();
 	if (ret)
 		return -ENOMEM;
-	laundry_wq = create_singlethread_workqueue("nfsd4");
+	laundry_wq = alloc_workqueue("%s", WQ_UNBOUND, 0, "nfsd4");
 	if (laundry_wq == NULL) {
 		ret = -ENOMEM;
 		goto out_recovery;
-- 
2.4.3

