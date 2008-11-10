From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 15/85] nfs41: Proper initialization of nfs_client_initdata.rpc_ops
Date: Mon, 10 Nov 2008 22:20:27 +0200
Message-ID: <1226348427-7684-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:60745 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751227AbYKJUUd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:20:33 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ricardo Labiaga <ricardo.labiaga@netapp.com>

The rpc_ops needs to be initialized to the proper minor version clientops
so that nfs_get_client() can find an existing nfs_client structure if
a mount to the same server has already occurred.

This enables the traditional sharing of nfs_client structures, as well
as fixes the problem where mounts of the same filesystem on the same
mountpoint were not being detected correctly.

Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/client.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 4e8c641..11c845d 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1028,6 +1028,8 @@ static int nfs4_set_client(struct nfs_server *server,
 		.hostname = hostname,
 		.addr = addr,
 		.addrlen = addrlen,
+		.rpc_ops =
+			nfsv4_minorversion_clientops[server->minorversion],
 		.proto = proto,
 	};
 	struct nfs_client *clp;
-- 
1.6.0.2

