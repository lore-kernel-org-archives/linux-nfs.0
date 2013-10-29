Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f177.google.com ([74.125.82.177]:40594 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751339Ab3J2Jj1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Oct 2013 05:39:27 -0400
Received: by mail-we0-f177.google.com with SMTP id x55so7830579wes.36
        for <linux-nfs@vger.kernel.org>; Tue, 29 Oct 2013 02:39:26 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@primarydata.com>
Subject: [PATCH 4/7] nfsd4: hash deleg stateid only on successful nfs4_set_delegation
Date: Tue, 29 Oct 2013 11:39:21 +0200
Message-Id: <1383039561-27308-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <526F81DE.6060704@primarydata.com>
References: <526F81DE.6060704@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We don't want the stateid to be found in the hash table before the delegation
is granted.

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 405649f..64fcdd6 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -375,7 +375,6 @@ static struct nfs4_ol_stateid * nfs4_alloc_stateid(struct nfs4_client *clp)
 	dp = delegstateid(nfs4_alloc_stid(clp, deleg_slab));
 	if (dp == NULL)
 		return dp;
-	dp->dl_stid.sc_type = NFS4_DELEG_STID;
 	/*
 	 * delegation seqid's are never incremented.  The 4.1 special
 	 * meaning of seqid 0 isn't meaningful, really, but let's avoid
@@ -3079,6 +3078,7 @@ static int nfs4_set_delegation(struct nfs4_delegation *dp, struct nfs4_file *fp)
 	atomic_inc(&fp->fi_delegees);
 	hash_delegation_locked(dp, fp);
 	spin_unlock(&recall_lock);
+	dp->dl_stid.sc_type = NFS4_DELEG_STID;
 	return 0;
 out_free:
 	put_nfs4_file(fp);
-- 
1.8.3.1

