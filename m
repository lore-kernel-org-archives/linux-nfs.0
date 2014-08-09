Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f41.google.com ([209.85.192.41]:39839 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751650AbaHIOWy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 9 Aug 2014 10:22:54 -0400
Received: by mail-qg0-f41.google.com with SMTP id q107so7313229qgd.28
        for <linux-nfs@vger.kernel.org>; Sat, 09 Aug 2014 07:22:54 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] nfsd: call nfs4_put_deleg_lease outside of state_lock
Date: Sat,  9 Aug 2014 10:22:41 -0400
Message-Id: <1407594162-28342-3-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1407594162-28342-1-git-send-email-jlayton@primarydata.com>
References: <1407594162-28342-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, we hold the state_lock when releasing the lease. That's
potentially problematic in the future if we allow for setlease methods
that can sleep. Move the nfs4_put_deleg_lease call out of the delegation
unhashing routine (which was always a bit goofy anyway), and into the
unlocked sections of the callers of unhash_delegation_locked.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 309ec3b1090a..4356d32479b2 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -722,7 +722,6 @@ unhash_delegation_locked(struct nfs4_delegation *dp)
 	list_del_init(&dp->dl_recall_lru);
 	list_del_init(&dp->dl_perfile);
 	spin_unlock(&fp->fi_lock);
-	nfs4_put_deleg_lease(fp);
 }
 
 static void destroy_delegation(struct nfs4_delegation *dp)
@@ -730,6 +729,7 @@ static void destroy_delegation(struct nfs4_delegation *dp)
 	spin_lock(&state_lock);
 	unhash_delegation_locked(dp);
 	spin_unlock(&state_lock);
+	nfs4_put_deleg_lease(dp->dl_stid.sc_file);
 	nfs4_put_stid(&dp->dl_stid);
 }
 
@@ -739,6 +739,8 @@ static void revoke_delegation(struct nfs4_delegation *dp)
 
 	WARN_ON(!list_empty(&dp->dl_recall_lru));
 
+	nfs4_put_deleg_lease(dp->dl_stid.sc_file);
+
 	if (clp->cl_minorversion == 0)
 		nfs4_put_stid(&dp->dl_stid);
 	else {
@@ -1639,6 +1641,7 @@ __destroy_client(struct nfs4_client *clp)
 	while (!list_empty(&reaplist)) {
 		dp = list_entry(reaplist.next, struct nfs4_delegation, dl_recall_lru);
 		list_del_init(&dp->dl_recall_lru);
+		nfs4_put_deleg_lease(dp->dl_stid.sc_file);
 		nfs4_put_stid(&dp->dl_stid);
 	}
 	while (!list_empty(&clp->cl_revoked)) {
@@ -6406,6 +6409,7 @@ nfs4_state_shutdown_net(struct net *net)
 	list_for_each_safe(pos, next, &reaplist) {
 		dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
 		list_del_init(&dp->dl_recall_lru);
+		nfs4_put_deleg_lease(dp->dl_stid.sc_file);
 		nfs4_put_stid(&dp->dl_stid);
 	}
 
-- 
1.9.3

