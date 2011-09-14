Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60183 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932246Ab1INLp2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Sep 2011 07:45:28 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 18/25] nfsd4: remove redundant stateid initialization
Date: Wed, 14 Sep 2011 07:45:14 -0400
Message-Id: <1316000721-3289-19-git-send-email-bfields@redhat.com>
In-Reply-To: <1316000721-3289-1-git-send-email-bfields@redhat.com>
References: <1316000721-3289-1-git-send-email-bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 73b5e1e..768382d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2318,10 +2318,7 @@ init_open_stateid(struct nfs4_stateid *stp, struct nfs4_file *fp, struct nfsd4_o
 	struct nfs4_openowner *oo = open->op_openowner;
 	unsigned int hashval = stateid_hashval(oo->oo_owner.so_id, fp->fi_id);
 
-	INIT_LIST_HEAD(&stp->st_hash);
-	INIT_LIST_HEAD(&stp->st_perstateowner);
 	INIT_LIST_HEAD(&stp->st_lockowners);
-	INIT_LIST_HEAD(&stp->st_perfile);
 	list_add(&stp->st_hash, &stateid_hashtbl[hashval]);
 	list_add(&stp->st_perstateowner, &oo->oo_owner.so_stateids);
 	list_add(&stp->st_perfile, &fp->fi_stateids);
@@ -3874,10 +3871,6 @@ alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct
 	stp = nfs4_alloc_stateid();
 	if (stp == NULL)
 		goto out;
-	INIT_LIST_HEAD(&stp->st_hash);
-	INIT_LIST_HEAD(&stp->st_perfile);
-	INIT_LIST_HEAD(&stp->st_perstateowner);
-	INIT_LIST_HEAD(&stp->st_lockowners); /* not used */
 	list_add(&stp->st_hash, &stateid_hashtbl[hashval]);
 	list_add(&stp->st_perfile, &fp->fi_stateids);
 	list_add(&stp->st_perstateowner, &lo->lo_owner.so_stateids);
-- 
1.7.4.1

