Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f179.google.com ([209.85.216.179]:50048 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752440Ab3IZSlU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:41:20 -0400
Received: by mail-qc0-f179.google.com with SMTP id l4so1034908qcv.38
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:41:19 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC v0 21/49] nfsd: no need to unhash_stid before free
Date: Thu, 26 Sep 2013 14:41:16 -0400
Message-Id: <1380220876-13642-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52447EA0.7070004@primarydata.com>
References: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

idr_remove is about to be called before kmem_cache_free so unhashing it
is redundant

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4state.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a8a18d4..214e42d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -677,7 +677,6 @@ static void unhash_open_stateid(struct nfs4_ol_stateid *stp)
 static void release_open_stateid(struct nfs4_ol_stateid *stp)
 {
 	unhash_open_stateid(stp);
-	unhash_stid(&stp->st_stid);
 	free_generic_stateid(stp);
 }
 
@@ -699,7 +698,6 @@ static void release_last_closed_stateid(struct nfs4_openowner *oo)
 	struct nfs4_ol_stateid *s = oo->oo_last_closed_stid;
 
 	if (s) {
-		unhash_stid(&s->st_stid);
 		free_generic_stateid(s);
 		oo->oo_last_closed_stid = NULL;
 	}
@@ -4043,10 +4041,9 @@ static void nfsd4_close_open_stateid(struct nfs4_ol_stateid *s)
 
 	nfsd4_close_open_stateid(stp);
 
-	if (cstate->minorversion) {
-		unhash_stid(&stp->st_stid);
+	if (cstate->minorversion)
 		free_generic_stateid(stp);
-	} else
+	else
 		oo->oo_last_closed_stid = stp;
 
 	if (list_empty(&oo->oo_owner.so_stateids)) {
-- 
1.8.3.1

