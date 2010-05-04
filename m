From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 3/8] nfsd4: use list_move in move_to_confirmed
Date: Wed,  5 May 2010 01:44:05 +0300
Message-ID: <1273013045-32425-1-git-send-email-bhalevy@panasas.com>
References: <4BE0A1AE.4040905@panasas.com>
Cc: linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:59420 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760225Ab0EDWoH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 May 2010 18:44:07 -0400
In-Reply-To: <4BE0A1AE.4040905@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

rather than list_del_init, list_add

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 388d244..53cb5e4 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -858,10 +858,9 @@ move_to_confirmed(struct nfs4_client *clp)
 	unsigned int strhashval;
 
 	dprintk("NFSD: move_to_confirm nfs4_client %p\n", clp);
-	list_del_init(&clp->cl_strhash);
 	list_move(&clp->cl_idhash, &conf_id_hashtbl[idhashval]);
 	strhashval = clientstr_hashval(clp->cl_recdir);
-	list_add(&clp->cl_strhash, &conf_str_hashtbl[strhashval]);
+	list_move(&clp->cl_strhash, &conf_str_hashtbl[strhashval]);
 	renew_client(clp);
 }
 
-- 
1.6.5.1

