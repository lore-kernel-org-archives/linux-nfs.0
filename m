Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:44741 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751444Ab3JURKW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Oct 2013 13:10:22 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: <Trond.Myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 3/5] NFSv4: clean up state ref counting in open recover
Date: Mon, 21 Oct 2013 13:10:12 -0400
Message-ID: <1382375414-5854-4-git-send-email-dros@netapp.com>
In-Reply-To: <1382375414-5854-1-git-send-email-dros@netapp.com>
References: <1382375414-5854-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There's already a valid state (the one being recovered), so just
reference it. Also clean up error paths to avoid ref leaks.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/nfs4proc.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8140366..8ae1589 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1323,14 +1323,14 @@ _nfs4_opendata_reclaim_to_nfs4_state(struct nfs4_opendata *data)
 		goto err;
 	}
 
-	ret = -ENOMEM;
-	state = nfs4_get_open_state(inode, data->owner);
-	if (state == NULL)
+	/* referenced the passed state */
+	ret = -EINVAL;
+	if (state == NULL || !atomic_inc_not_zero(&state->count))
 		goto err;
 
 	ret = nfs_refresh_inode(inode, &data->f_attr);
 	if (ret)
-		goto err;
+		goto err_put;
 
 	nfs_setsecurity(inode, &data->f_attr, data->f_label);
 
@@ -1340,9 +1340,12 @@ _nfs4_opendata_reclaim_to_nfs4_state(struct nfs4_opendata *data)
 			    data->o_arg.fmode);
 
 	return state;
+
+err_put:
+	nfs4_put_open_state(state);
+
 err:
 	return ERR_PTR(ret);
-
 }
 
 static struct nfs4_state *
-- 
1.7.12.4 (Apple Git-37)

