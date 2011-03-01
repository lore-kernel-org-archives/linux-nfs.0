Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:1570 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756286Ab1CATZz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Mar 2011 14:25:55 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH pnfs-submit-wave3 update 5/5] SQUASHME: NFSv4.1: DS only check
Date: Tue,  1 Mar 2011 14:25:34 -0500
Message-Id: <1299007534-4105-6-git-send-email-andros@netapp.com>
In-Reply-To: <1299007534-4105-5-git-send-email-andros@netapp.com>
References: <1299007534-4105-1-git-send-email-andros@netapp.com>
 <1299007534-4105-2-git-send-email-andros@netapp.com>
 <1299007534-4105-3-git-send-email-andros@netapp.com>
 <1299007534-4105-4-git-send-email-andros@netapp.com>
 <1299007534-4105-5-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

squash into fdd1e4e137c75a69a274acc680706906c72344e1
NFSv4.1: add MDS mount DS only check

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/client.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 738f624..6dd50ac 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1400,12 +1400,6 @@ static int nfs4_set_client(struct nfs_server *server,
 		goto error;
 	}
 
-	/* Cannot mount a DS only server */
-	if (is_ds_only_client(clp)) {
-		error = -ENODEV;
-		goto error;
-	}
-
 	/*
 	 * Query for the lease time on clientid setup or renewal
 	 *
@@ -1500,6 +1494,10 @@ static int nfs4_server_common_setup(struct nfs_server *server,
 	BUG_ON(!server->nfs_client->rpc_ops);
 	BUG_ON(!server->nfs_client->rpc_ops->file_inode_ops);
 
+	/* data servers support only a subset of NFSv4.1 */
+	if (is_ds_only_client(server->nfs_client))
+		return -EPROTONOSUPPORT;
+
 	fattr = nfs_alloc_fattr();
 	if (fattr == NULL)
 		return -ENOMEM;
-- 
1.6.2.5

