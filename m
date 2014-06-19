Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f181.google.com ([209.85.216.181]:63288 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932778AbaFSOxX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:53:23 -0400
Received: by mail-qc0-f181.google.com with SMTP id x13so2235251qcv.40
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:53:22 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 101/104] nfsd: remove nfs4_lock_state: nfs4_laundromat
Date: Thu, 19 Jun 2014 10:50:47 -0400
Message-Id: <1403189450-18729-102-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6000da3285d7..55a5c238bb94 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3987,8 +3987,6 @@ nfs4_laundromat(struct nfsd_net *nn)
 	time_t cutoff = get_seconds() - nn->nfsd4_lease;
 	time_t t, new_timeo = nn->nfsd4_lease;
 
-	nfs4_lock_state();
-
 	dprintk("NFSD: laundromat service - starting\n");
 	nfsd4_end_grace(nn);
 	INIT_LIST_HEAD(&reaplist);
@@ -4052,7 +4050,6 @@ nfs4_laundromat(struct nfsd_net *nn)
 	spin_unlock(&nn->client_lock);
 
 	new_timeo = max_t(time_t, new_timeo, NFSD_LAUNDROMAT_MINTIMEOUT);
-	nfs4_unlock_state();
 	return new_timeo;
 }
 
-- 
1.9.3

