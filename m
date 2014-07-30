Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f53.google.com ([209.85.192.53]:61192 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754725AbaG3Bfr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jul 2014 21:35:47 -0400
Received: by mail-qg0-f53.google.com with SMTP id q107so656363qgd.40
        for <linux-nfs@vger.kernel.org>; Tue, 29 Jul 2014 18:35:47 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH v3 38/38] nfsd: rename unhash_generic_stateid to unhash_ol_stateid
Date: Tue, 29 Jul 2014 21:34:43 -0400
Message-Id: <1406684083-19736-39-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
References: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...to better match other functions that deal with open/lock stateids.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1f67a96c4941..52ec47de1185 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -949,7 +949,7 @@ static void nfs4_put_stateowner(struct nfs4_stateowner *sop)
 	sop->so_ops->so_free(sop);
 }
 
-static void unhash_generic_stateid(struct nfs4_ol_stateid *stp)
+static void unhash_ol_stateid(struct nfs4_ol_stateid *stp)
 {
 	struct nfs4_file *fp = stp->st_stid.sc_file;
 
@@ -1014,7 +1014,7 @@ static void unhash_lock_stateid(struct nfs4_ol_stateid *stp)
 	lockdep_assert_held(&oo->oo_owner.so_client->cl_lock);
 
 	list_del_init(&stp->st_locks);
-	unhash_generic_stateid(stp);
+	unhash_ol_stateid(stp);
 	unhash_stid(&stp->st_stid);
 }
 
@@ -1095,7 +1095,7 @@ static void unhash_open_stateid(struct nfs4_ol_stateid *stp,
 {
 	lockdep_assert_held(&stp->st_stid.sc_client->cl_lock);
 
-	unhash_generic_stateid(stp);
+	unhash_ol_stateid(stp);
 	release_open_stateid_locks(stp, reaplist);
 }
 
-- 
1.9.3

