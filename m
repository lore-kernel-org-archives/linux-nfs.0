From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 28/32] nfs: remove superfluous BUG_ON()s
Date: Wed, 19 Aug 2009 19:38:51 -0400
Message-ID: <1250725135-14632-29-git-send-email-Trond.Myklebust@netapp.com>
References: <1250725135-14632-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-2-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-3-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-4-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-5-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-6-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-7-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-8-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-9-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-10-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-11-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-12-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-13-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-14-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-15-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-16-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-17-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-18-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-19-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-20-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-21-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-22-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-23-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-24-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-25-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-26-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-27-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-28-git-send-email-Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Cc: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32245 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754117AbZHSXk6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Aug 2009 19:40:58 -0400
In-Reply-To: <1250725135-14632-28-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>

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
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/client.c |    8 --------
 1 files changed, 0 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 8f34fd8..d36925f 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1077,10 +1077,6 @@ struct nfs_server *nfs_create_server(const struct nfs_parsed_mount_data *data,
 		(unsigned long long) server->fsid.major,
 		(unsigned long long) server->fsid.minor);
 
-	BUG_ON(!server->nfs_client);
-	BUG_ON(!server->nfs_client->rpc_ops);
-	BUG_ON(!server->nfs_client->rpc_ops->file_inode_ops);
-
 	spin_lock(&nfs_client_lock);
 	list_add_tail(&server->client_link, &server->nfs_client->cl_superblocks);
 	list_add_tail(&server->master_link, &nfs_volume_list);
@@ -1362,10 +1358,6 @@ struct nfs_server *nfs4_create_server(const struct nfs_parsed_mount_data *data,
 	if (server->namelen == 0 || server->namelen > NFS4_MAXNAMLEN)
 		server->namelen = NFS4_MAXNAMLEN;
 
-	BUG_ON(!server->nfs_client);
-	BUG_ON(!server->nfs_client->rpc_ops);
-	BUG_ON(!server->nfs_client->rpc_ops->file_inode_ops);
-
 	spin_lock(&nfs_client_lock);
 	list_add_tail(&server->client_link, &server->nfs_client->cl_superblocks);
 	list_add_tail(&server->master_link, &nfs_volume_list);
-- 
1.6.0.4
