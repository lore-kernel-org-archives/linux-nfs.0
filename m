From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Subject: [PATCH] nfs: remove superfluous BUG_ON()s
Date: Tue, 28 Jul 2009 17:04:56 +0200
Message-ID: <200907281704.56870.bzolnier@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	Dan Carpenter <error27@gmail.com>, corbet-T1hC0tSOHrs@public.gmane.org,
	eteo@redhat.com, Julia Lawall <julia@diku.dk>
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f221.google.com ([209.85.218.221]:59316 "EHLO
	mail-bw0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754167AbZG1PG6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jul 2009 11:06:58 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Subject: [PATCH] nfs: remove superfluous BUG_ON()s

Remove duplicated BUG_ON()s from nfs[4]_create_server()
(we make the same checks earlier in both functions).

This takes care of the following entries from Dan's list:

fs/nfs/client.c +1078 nfs_create_server(47) warning: variable derefenced before check 'server->nfs_client'
fs/nfs/client.c +1079 nfs_create_server(48) warning: variable derefenced before check 'server->nfs_client->rpc_ops'
fs/nfs/client.c +1363 nfs4_create_server(43) warning: variable derefenced before check 'server->nfs_client'
fs/nfs/client.c +1364 nfs4_create_server(44) warning: variable derefenced before check 'server->nfs_

Reported-by: Dan Carpenter <error27@gmail.com>
Cc: corbet-T1hC0tSOHrs@public.gmane.org
Cc: eteo@redhat.com
Cc: Julia Lawall <julia@diku.dk>
Signed-off-by: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
---
 fs/nfs/client.c |    8 --------
 1 file changed, 8 deletions(-)

Index: b/fs/nfs/client.c
===================================================================
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1075,10 +1075,6 @@ struct nfs_server *nfs_create_server(con
 		(unsigned long long) server->fsid.major,
 		(unsigned long long) server->fsid.minor);
 
-	BUG_ON(!server->nfs_client);
-	BUG_ON(!server->nfs_client->rpc_ops);
-	BUG_ON(!server->nfs_client->rpc_ops->file_inode_ops);
-
 	spin_lock(&nfs_client_lock);
 	list_add_tail(&server->client_link, &server->nfs_client->cl_superblocks);
 	list_add_tail(&server->master_link, &nfs_volume_list);
@@ -1360,10 +1356,6 @@ struct nfs_server *nfs4_create_server(co
 	if (server->namelen == 0 || server->namelen > NFS4_MAXNAMLEN)
 		server->namelen = NFS4_MAXNAMLEN;
 
-	BUG_ON(!server->nfs_client);
-	BUG_ON(!server->nfs_client->rpc_ops);
-	BUG_ON(!server->nfs_client->rpc_ops->file_inode_ops);
-
 	spin_lock(&nfs_client_lock);
 	list_add_tail(&server->client_link, &server->nfs_client->cl_superblocks);
 	list_add_tail(&server->master_link, &nfs_volume_list);
