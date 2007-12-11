From: Neil Brown <neilb@suse.de>
Subject: [PATCH] memory leak when mounting and unmounting -onolock filesystems
Date: Tue, 11 Dec 2007 15:57:32 +1100
Message-ID: <18270.6332.188836.995133@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:42738 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752112AbXLKE5h (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Dec 2007 23:57:37 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Hi Trond,

We found that a machine which made moderately heavy use of
'automount' was leaking some nfs data structures - particularly the
4K allocated by rpc_alloc_iostats.
It turns out that this only happens with filesystems with -onolock
set.

The problem is that if NFS_MOUNT_NONLM is set, nfs_start_lockd doesn't
set server->destroy, so when the filesystem is unmounted, the
->client_acl is not shutdown, and so several resources are still
held.  Multiple mount/umount cycles will slowly eat away memory
several pages at a time.

The following patch seems the simplest fix, but it may not be what you
prefer.  Arguably nfs_start_lockd isn't really the right place to set
server->destroy as it relates to both lockd and client_acl.  Maybe
->destroy could be set at the end of nfs_init_server in the no-error
case.

It looks like this bug was introduced by 
   54ceac4515986030c2502960be620198dd8fe25b
so has been present since 2.6.19 (we found it in 2.6.22).

NeilBrown



Signed-off-by: NeilBrown <neilb@suse.de>

diff .prev/fs/nfs/client.c ./fs/nfs/client.c
--- .prev/fs/nfs/client.c	2007-12-11 15:42:54.000000000 +1100
+++ ./fs/nfs/client.c	2007-12-11 15:44:19.000000000 +1100
@@ -432,9 +432,9 @@ static int nfs_start_lockd(struct nfs_se
 			IPPROTO_TCP : IPPROTO_UDP);
 	if (error < 0)
 		server->flags |= NFS_MOUNT_NONLM;
-	else
-		server->destroy = nfs_destroy_server;
 out:
+	if (! error)
+		server->destroy = nfs_destroy_server;
 	return error;
 }
 

