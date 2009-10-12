From: Mikael Pettersson <mikpe-1zs4UD6AkMk@public.gmane.org>
Subject: [PATCH 2.6.32-rc4] fix nfs_compare_remount_data() compile warnings
Date: Mon, 12 Oct 2009 12:23:53 +0200
Message-ID: <19155.953.47831.379190@pilspetsen.it.uu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fanny.its.uu.se ([130.238.4.241]:60157 "EHLO fanny.its.uu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751888AbZJLK2S (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Oct 2009 06:28:18 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit bcd2ea17da6a329a7276cde7286d802f009af332
"NFS: Fix port initialisation in nfs_remount()"
replaced a memcmp() with a call to rpc_cmp_addr(),
resulting in the following compile warnings:

fs/nfs/super.c: In function 'nfs_compare_remount_data':
fs/nfs/super.c:1852: warning: passing argument 1 of 'rpc_cmp_addr' from incompatible pointer type
fs/nfs/super.c:1852: warning: passing argument 2 of 'rpc_cmp_addr' from incompatible pointer type

The operands are of type 'struct sockaddr_storage*' while
rpc_cmp_addr() expects 'struct sockaddr*'. Those operands
are often cast to 'struct sockaddr*' elsewhere in super.c,
so doing the same here seems reasonable.

Signed-off-by: Mikael Pettersson <mikpe-1zs4UD6AkMk@public.gmane.org>
---
 fs/nfs/super.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- linux-2.6.32-rc4/fs/nfs/super.c.~1~	2009-10-12 10:43:45.000000000 +0200
+++ linux-2.6.32-rc4/fs/nfs/super.c	2009-10-12 11:44:13.000000000 +0200
@@ -1848,8 +1848,8 @@ nfs_compare_remount_data(struct nfs_serv
 	    data->timeo != (10U * nfss->client->cl_timeout->to_initval / HZ) ||
 	    data->nfs_server.port != nfss->port ||
 	    data->nfs_server.addrlen != nfss->nfs_client->cl_addrlen ||
-	    !rpc_cmp_addr(&data->nfs_server.address,
-		    &nfss->nfs_client->cl_addr))
+	    !rpc_cmp_addr((struct sockaddr *)&data->nfs_server.address,
+		    (struct sockaddr *)&nfss->nfs_client->cl_addr))
 		return -EINVAL;
 
 	return 0;
