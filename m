From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] memory leak when mounting and unmounting -onolock
	filesystems
Date: Tue, 11 Dec 2007 11:09:29 -0500
Message-ID: <1197389369.11967.2.camel@heimdal.trondhjem.org>
References: <18270.6332.188836.995133@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:33529 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752517AbXLKQJd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Dec 2007 11:09:33 -0500
In-Reply-To: <18270.6332.188836.995133-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2007-12-11 at 15:57 +1100, Neil Brown wrote:
> The problem is that if NFS_MOUNT_NONLM is set, nfs_start_lockd doesn't
> set server->destroy, so when the filesystem is unmounted, the
> ->client_acl is not shutdown, and so several resources are still
> held.  Multiple mount/umount cycles will slowly eat away memory
> several pages at a time.

Hi Neil,

How about the following alternative for 2.6.24, and then we plan on
getting rid of ->destroy() altogether in 2.6.25?

Cheers
  Trond
---------------------------------------------------
commit 2c29e75b2908f760c45bbf934f81b8a8af867770
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Dec 11 11:05:19 2007 -0500

    NFSv2/v3: Fix a memory leak when using -onolock
    
    Neil Brown said:
    > Hi Trond,
    >
    > We found that a machine which made moderately heavy use of
    > 'automount' was leaking some nfs data structures - particularly the
    > 4K allocated by rpc_alloc_iostats.
    > It turns out that this only happens with filesystems with -onolock
    > set.
    
    > The problem is that if NFS_MOUNT_NONLM is set, nfs_start_lockd doesn't
    > set server->destroy, so when the filesystem is unmounted, the
    > ->client_acl is not shutdown, and so several resources are still
    > held.  Multiple mount/umount cycles will slowly eat away memory
    > several pages at a time.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 70587f3..a6f6254 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -410,9 +410,6 @@ static int nfs_create_rpc_client(struct nfs_client *clp, int proto,
  */
 static void nfs_destroy_server(struct nfs_server *server)
 {
-	if (!IS_ERR(server->client_acl))
-		rpc_shutdown_client(server->client_acl);
-
 	if (!(server->flags & NFS_MOUNT_NONLM))
 		lockd_down();	/* release rpc.lockd */
 }
@@ -755,6 +752,9 @@ void nfs_free_server(struct nfs_server *server)
 
 	if (server->destroy != NULL)
 		server->destroy(server);
+
+	if (!IS_ERR(server->client_acl))
+		rpc_shutdown_client(server->client_acl);
 	if (!IS_ERR(server->client))
 		rpc_shutdown_client(server->client);
 


