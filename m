Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34437 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751302AbbGMJa2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 05:30:28 -0400
Received: by pacan13 with SMTP id an13so13040791pac.1
        for <linux-nfs@vger.kernel.org>; Mon, 13 Jul 2015 02:30:27 -0700 (PDT)
Message-ID: <55A3852D.8080106@gmail.com>
Date: Mon, 13 Jul 2015 17:30:21 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: kinglongmee@gmail.com
Subject: [PATCH 03/14] nfsd: Fix memory leak of so_owner.data in nfs4_stateowner
References: <55A384B1.8030207@gmail.com>
In-Reply-To: <55A384B1.8030207@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4state.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b1f84fc..e5e14fa 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3316,8 +3316,10 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfsd4_open *open,
 	if (ret == NULL) {
 		hash_openowner(oo, clp, strhashval);
 		ret = oo;
-	} else
+	} else {
+		kfree(oo->oo_owner.so_owner.data);
 		nfs4_free_openowner(&oo->oo_owner);
+	}
 	spin_unlock(&clp->cl_lock);
 	return ret;
 }
@@ -5217,8 +5219,10 @@ alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp,
 		list_add(&lo->lo_owner.so_strhash,
 			 &clp->cl_ownerstr_hashtbl[strhashval]);
 		ret = lo;
-	} else
-		nfs4_free_lockowner(&lo->lo_owner);
+	} else {
+		kfree(lo->lo_owner.so_owner.data);
+		nfs4_free_openowner(&lo->lo_owner);
+	}
 	spin_unlock(&clp->cl_lock);
 	return ret;
 }
-- 
2.4.3

