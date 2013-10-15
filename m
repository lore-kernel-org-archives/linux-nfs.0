Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f44.google.com ([74.125.82.44]:59938 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752206Ab3JOG6E (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Oct 2013 02:58:04 -0400
Received: by mail-wg0-f44.google.com with SMTP id n12so6963209wgh.11
        for <linux-nfs@vger.kernel.org>; Mon, 14 Oct 2013 23:58:03 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@primarydata.com>
Subject: [PATCH 2/2] nfsd: remove_stid can be incorporated into nfs4_put_delegation
Date: Tue, 15 Oct 2013 09:58:00 +0300
Message-Id: <1381820280-14120-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <525CE711.1040107@primarydata.com>
References: <525CE711.1040107@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All calls to nfs4_put_delegation are preceded with remove_stid.

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4state.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b8f3c7e..93160b6 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -410,6 +410,7 @@ static void nfs4_free_stid(struct kmem_cache *slab, struct nfs4_stid *s)
 void
 nfs4_put_delegation(struct nfs4_delegation *dp)
 {
+	remove_stid(&dp->dl_stid);
 	if (atomic_dec_and_test(&dp->dl_count)) {
 		nfs4_free_stid(deleg_slab, &dp->dl_stid);
 		num_delegations--;
@@ -450,14 +451,12 @@ static void unhash_stid(struct nfs4_stid *s)
 static void destroy_revoked_delegation(struct nfs4_delegation *dp)
 {
 	list_del_init(&dp->dl_recall_lru);
-	remove_stid(&dp->dl_stid);
 	nfs4_put_delegation(dp);
 }
 
 static void destroy_delegation(struct nfs4_delegation *dp)
 {
 	unhash_delegation(dp);
-	remove_stid(&dp->dl_stid);
 	nfs4_put_delegation(dp);
 }
 
@@ -3157,7 +3156,6 @@ static void nfsd4_open_deleg_none_ext(struct nfsd4_open *open, int status)
 	open->op_delegate_type = NFS4_OPEN_DELEGATE_READ;
 	return;
 out_free:
-	remove_stid(&dp->dl_stid);
 	nfs4_put_delegation(dp);
 out_no_deleg:
 	open->op_delegate_type = NFS4_OPEN_DELEGATE_NONE;
-- 
1.8.3.1

