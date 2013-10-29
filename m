Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f178.google.com ([209.85.212.178]:41285 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753786Ab3J2Jjg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Oct 2013 05:39:36 -0400
Received: by mail-wi0-f178.google.com with SMTP id hn9so5029336wib.17
        for <linux-nfs@vger.kernel.org>; Tue, 29 Oct 2013 02:39:35 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@primarydata.com>
Subject: [PATCH 6/7] nfsd4: move nfs4_put_file from unhash to put delegation
Date: Tue, 29 Oct 2013 11:39:32 +0200
Message-Id: <1383039572-27405-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <526F81DE.6060704@primarydata.com>
References: <526F81DE.6060704@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

revoked delegations are unhashed but are kept around in nfsv4.1	and we better
hang on to dp_file in this case.

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4state.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 8840206..7f78ff5 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -411,6 +411,8 @@ static void nfs4_free_stid(struct kmem_cache *slab, struct nfs4_stid *s)
 {
 	remove_stid(&dp->dl_stid);
 	if (atomic_dec_and_test(&dp->dl_count)) {
+		if (dp->dl_file)
+			put_nfs4_file(dp->dl_file);
 		nfs4_free_stid(deleg_slab, &dp->dl_stid);
 		num_delegations--;
 	}
@@ -450,8 +452,6 @@ static void unhash_stid(struct nfs4_stid *s)
 	dp->dl_stid.sc_type = 0;
 	nfs4_put_deleg_lease(dp->dl_file);
 	spin_unlock(&recall_lock);
-	put_nfs4_file(dp->dl_file);
-	dp->dl_file = NULL;
 }
 
 
-- 
1.8.3.1

