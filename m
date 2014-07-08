Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f170.google.com ([209.85.216.170]:63643 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753465AbaGHSEj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 14:04:39 -0400
Received: by mail-qc0-f170.google.com with SMTP id l6so5702905qcy.29
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 11:04:38 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 002/100] nfsd: reduce some spinlocking in put_client_renew
Date: Tue,  8 Jul 2014 14:02:50 -0400
Message-Id: <1404842668-22521-3-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

No need to take the lock unless the count goes to 0.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 633b34fd6c92..8aa57265fb08 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -193,8 +193,10 @@ static void put_client_renew(struct nfs4_client *clp)
 {
 	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 
-	spin_lock(&nn->client_lock);
-	put_client_renew_locked(clp);
+	if (!atomic_dec_and_lock(&clp->cl_refcount, &nn->client_lock))
+		return;
+	if (!is_client_expired(clp))
+		renew_client_locked(clp);
 	spin_unlock(&nn->client_lock);
 }
 
-- 
1.9.3

