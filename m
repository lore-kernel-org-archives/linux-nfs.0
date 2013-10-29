Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f175.google.com ([209.85.212.175]:39307 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753786Ab3J2Jjn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Oct 2013 05:39:43 -0400
Received: by mail-wi0-f175.google.com with SMTP id hm4so4876363wib.2
        for <linux-nfs@vger.kernel.org>; Tue, 29 Oct 2013 02:39:42 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@primarydata.com>
Subject: [PATCH 7/7] nfsd4: hold recall_lock while accessing nfs4_delegation.dl_recall_lru
Date: Tue, 29 Oct 2013 11:39:36 +0200
Message-Id: <1383039576-27451-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <526F81DE.6060704@primarydata.com>
References: <526F81DE.6060704@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4state.c | 20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 7f78ff5..d9161ea 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -441,24 +441,29 @@ static void unhash_stid(struct nfs4_stid *s)
 	dp->dl_stid.sc_type = NFS4_DELEG_STID;
 }
 
-/* Called under the state lock. */
 static void
-unhash_delegation(struct nfs4_delegation *dp)
+unhash_delegation_locked(struct nfs4_delegation *dp)
 {
-	spin_lock(&recall_lock);
 	list_del_init(&dp->dl_perclnt);
 	list_del_init(&dp->dl_perfile);
 	list_del_init(&dp->dl_recall_lru);
 	dp->dl_stid.sc_type = 0;
 	nfs4_put_deleg_lease(dp->dl_file);
-	spin_unlock(&recall_lock);
 }
 
-
+static void
+unhash_delegation(struct nfs4_delegation *dp)
+{
+	spin_lock(&recall_lock);
+	unhash_delegation_locked(dp);
+	spin_unlock(&recall_lock);
+}
 
 static void destroy_revoked_delegation(struct nfs4_delegation *dp)
 {
+	spin_lock(&recall_lock);
 	list_del_init(&dp->dl_recall_lru);
+	spin_unlock(&recall_lock);
 	nfs4_put_delegation(dp);
 }
 
@@ -475,9 +480,11 @@ static void revoke_delegation(struct nfs4_delegation *dp)
 	if (clp->cl_minorversion == 0)
 		destroy_delegation(dp);
 	else {
-		unhash_delegation(dp);
+		spin_lock(&recall_lock);
+		unhash_delegation_locked(dp);
 		dp->dl_stid.sc_type = NFS4_REVOKED_DELEG_STID;
 		list_add(&dp->dl_recall_lru, &clp->cl_revoked);
+		spin_unlock(&recall_lock);
 	}
 }
 
@@ -2729,6 +2736,7 @@ static void nfsd_break_one_deleg(struct nfs4_delegation *dp)
 	struct nfs4_client *clp = dp->dl_stid.sc_client;
 	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 
+	lockdep_assert_held(&recall_lock);
 	/* We're assuming the state code never drops its reference
 	 * without first removing the lease.  Since we're in this lease
 	 * callback (and since the lease code is serialized by the kernel
-- 
1.8.3.1

