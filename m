Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ea0-f169.google.com ([209.85.215.169]:40082 "EHLO
	mail-ea0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750731Ab3JNGCB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Oct 2013 02:02:01 -0400
Received: by mail-ea0-f169.google.com with SMTP id k11so3139996eaj.14
        for <linux-nfs@vger.kernel.org>; Sun, 13 Oct 2013 23:02:00 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@primarydata.com>
Subject: [PATCH] nfsd: no need to unhash_stid before free
Date: Mon, 14 Oct 2013 09:01:55 +0300
Message-Id: <1381730515-18045-1-git-send-email-bhalevy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

idr_remove is about to be called before kmem_cache_free so unhashing it
is redundant

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4state.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0874998..06984e3 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -668,7 +668,6 @@ static void unhash_open_stateid(struct nfs4_ol_stateid *stp)
 static void release_open_stateid(struct nfs4_ol_stateid *stp)
 {
 	unhash_open_stateid(stp);
-	unhash_stid(&stp->st_stid);
 	free_generic_stateid(stp);
 }
 
@@ -690,7 +689,6 @@ static void release_last_closed_stateid(struct nfs4_openowner *oo)
 	struct nfs4_ol_stateid *s = oo->oo_last_closed_stid;
 
 	if (s) {
-		unhash_stid(&s->st_stid);
 		free_generic_stateid(s);
 		oo->oo_last_closed_stid = NULL;
 	}
@@ -3998,10 +3996,9 @@ static void nfsd4_close_open_stateid(struct nfs4_ol_stateid *s)
 
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

