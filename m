Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f174.google.com ([209.85.212.174]:59986 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753786Ab3J2Jjc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Oct 2013 05:39:32 -0400
Received: by mail-wi0-f174.google.com with SMTP id cb5so4875235wib.7
        for <linux-nfs@vger.kernel.org>; Tue, 29 Oct 2013 02:39:30 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@primarydata.com>
Subject: [PATCH 5/7] nfsd4: cleanup hash and unhash delegation
Date: Tue, 29 Oct 2013 11:39:27 +0200
Message-Id: <1383039567-27356-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <526F81DE.6060704@primarydata.com>
References: <526F81DE.6060704@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

make sure all atomic ops are under the recall_lock

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4state.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 64fcdd6..8840206 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -436,6 +436,7 @@ static void unhash_stid(struct nfs4_stid *s)
 {
 	list_add(&dp->dl_perfile, &fp->fi_delegations);
 	list_add(&dp->dl_perclnt, &dp->dl_stid.sc_client->cl_delegations);
+	dp->dl_stid.sc_type = NFS4_DELEG_STID;
 }
 
 /* Called under the state lock. */
@@ -446,8 +447,9 @@ static void unhash_stid(struct nfs4_stid *s)
 	list_del_init(&dp->dl_perclnt);
 	list_del_init(&dp->dl_perfile);
 	list_del_init(&dp->dl_recall_lru);
-	spin_unlock(&recall_lock);
+	dp->dl_stid.sc_type = 0;
 	nfs4_put_deleg_lease(dp->dl_file);
+	spin_unlock(&recall_lock);
 	put_nfs4_file(dp->dl_file);
 	dp->dl_file = NULL;
 }
@@ -3078,7 +3080,6 @@ static int nfs4_set_delegation(struct nfs4_delegation *dp, struct nfs4_file *fp)
 	atomic_inc(&fp->fi_delegees);
 	hash_delegation_locked(dp, fp);
 	spin_unlock(&recall_lock);
-	dp->dl_stid.sc_type = NFS4_DELEG_STID;
 	return 0;
 out_free:
 	put_nfs4_file(fp);
-- 
1.8.3.1

