Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f169.google.com ([209.85.216.169]:37445 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751927AbaFZTWL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:22:11 -0400
Received: by mail-qc0-f169.google.com with SMTP id c9so3604852qcz.28
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:22:11 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 114/117] nfsd: remove nfs4_lock_state: nfs4_laundromat
Date: Thu, 26 Jun 2014 15:21:22 -0400
Message-Id: <1403810485-16497-31-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ccf6bb390fbb..b49c43c40832 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4110,8 +4110,6 @@ nfs4_laundromat(struct nfsd_net *nn)
 	time_t cutoff = get_seconds() - nn->nfsd4_lease;
 	time_t t, new_timeo = nn->nfsd4_lease;
 
-	nfs4_lock_state();
-
 	dprintk("NFSD: laundromat service - starting\n");
 	nfsd4_end_grace(nn);
 	INIT_LIST_HEAD(&reaplist);
@@ -4179,7 +4177,6 @@ nfs4_laundromat(struct nfsd_net *nn)
 	spin_unlock(&nn->client_lock);
 
 	new_timeo = max_t(time_t, new_timeo, NFSD_LAUNDROMAT_MINTIMEOUT);
-	nfs4_unlock_state();
 	return new_timeo;
 }
 
-- 
1.9.3

