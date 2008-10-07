From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 04/30] NFS: Don't apply NFS_MOUNT_FLAGMASK to text-based
	mounts
Date: Tue, 07 Oct 2008 18:19:53 -0400
Message-ID: <20081007221953.20945.93937.stgit@localhost.localdomain>
References: <20081007221952.20945.69529.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35670 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756074AbYJGWcw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Oct 2008 18:32:52 -0400
Received: from sacexrs02.hq.netapp.com (sacexrs02.hq.netapp.com [10.99.190.106])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m97MWi0d025764
	for <linux-nfs@vger.kernel.org>; Tue, 7 Oct 2008 15:32:48 -0700 (PDT)
In-Reply-To: <20081007221952.20945.69529.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The point of introducing text-based mounts was to allow us to add
functionality without having to worry about legacy binary mount formats.
The mask should be there in order to ensure that binary formats don't start
enabling features that they cannot support. There is no justification for
applying it to the text mount path.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/client.c |    4 ++--
 fs/nfs/super.c  |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 2accb67..7547600 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -675,7 +675,7 @@ static int nfs_init_server(struct nfs_server *server,
 	server->nfs_client = clp;
 
 	/* Initialise the client representation from the mount data */
-	server->flags = data->flags & NFS_MOUNT_FLAGMASK;
+	server->flags = data->flags;
 
 	if (data->rsize)
 		server->rsize = nfs_block_size(data->rsize, NULL);
@@ -1072,7 +1072,7 @@ static int nfs4_init_server(struct nfs_server *server,
 		goto error;
 
 	/* Initialise the client representation from the mount data */
-	server->flags = data->flags & NFS_MOUNT_FLAGMASK;
+	server->flags = data->flags;
 	server->caps |= NFS_CAP_ATOMIC_OPEN;
 
 	if (data->rsize)
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index e527fab..81686ae 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1550,7 +1550,7 @@ static int nfs_validate_mount_data(void *options,
 		 * Translate to nfs_parsed_mount_data, which nfs_fill_super
 		 * can deal with.
 		 */
-		args->flags		= data->flags;
+		args->flags		= data->flags & NFS_MOUNT_FLAGMASK;
 		args->rsize		= data->rsize;
 		args->wsize		= data->wsize;
 		args->timeo		= data->timeo;

