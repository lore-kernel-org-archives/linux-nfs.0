Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from gateway34.websitewelcome.com ([192.185.149.72]:36388 "EHLO
        gateway34.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751448AbdKIDNo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Nov 2017 22:13:44 -0500
Received: from cm15.websitewelcome.com (cm15.websitewelcome.com [100.42.49.9])
        by gateway34.websitewelcome.com (Postfix) with ESMTP id 818FA12379C1
        for <linux-nfs@vger.kernel.org>; Wed,  8 Nov 2017 20:49:22 -0600 (CST)
Date: Wed, 8 Nov 2017 20:49:19 -0600
From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] NFS: super: mark expected switch fall-throughs
Message-ID: <20171109024919.GA11083@embeddedor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In preparation to enabling -Wimplicit-fallthrough, mark switch cases
where we are expecting to fall through.

Addresses-Coverity-ID: 703509
Addresses-Coverity-ID: 703510
Addresses-Coverity-ID: 703511
Addresses-Coverity-ID: 703512
Addresses-Coverity-ID: 703513
Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
 fs/nfs/super.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index c9d24ba..da19c72 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1456,18 +1456,21 @@ static int nfs_parse_mount_options(char *raw,
 			switch (token) {
 			case Opt_xprt_udp6:
 				protofamily = AF_INET6;
+				/* fall through */
 			case Opt_xprt_udp:
 				mnt->flags &= ~NFS_MOUNT_TCP;
 				mnt->nfs_server.protocol = XPRT_TRANSPORT_UDP;
 				break;
 			case Opt_xprt_tcp6:
 				protofamily = AF_INET6;
+				/* fall through */
 			case Opt_xprt_tcp:
 				mnt->flags |= NFS_MOUNT_TCP;
 				mnt->nfs_server.protocol = XPRT_TRANSPORT_TCP;
 				break;
 			case Opt_xprt_rdma6:
 				protofamily = AF_INET6;
+				/* fall through */
 			case Opt_xprt_rdma:
 				/* vector side protocols to TCP */
 				mnt->flags |= NFS_MOUNT_TCP;
@@ -1494,11 +1497,13 @@ static int nfs_parse_mount_options(char *raw,
 			switch (token) {
 			case Opt_xprt_udp6:
 				mountfamily = AF_INET6;
+				/* fall through */
 			case Opt_xprt_udp:
 				mnt->mount_server.protocol = XPRT_TRANSPORT_UDP;
 				break;
 			case Opt_xprt_tcp6:
 				mountfamily = AF_INET6;
+				/* fall through */
 			case Opt_xprt_tcp:
 				mnt->mount_server.protocol = XPRT_TRANSPORT_TCP;
 				break;
@@ -1988,9 +1993,9 @@ static int nfs23_validate_mount_data(void *options,
 	args->version = NFS_DEFAULT_VERSION;
 	switch (data->version) {
 	case 1:
-		data->namlen = 0;
+		data->namlen = 0; /* fall through */
 	case 2:
-		data->bsize = 0;
+		data->bsize = 0; /* fall through */
 	case 3:
 		if (data->flags & NFS_MOUNT_VER3)
 			goto out_no_v3;
@@ -1998,11 +2003,14 @@ static int nfs23_validate_mount_data(void *options,
 		memcpy(data->root.data, data->old_root.data, NFS2_FHSIZE);
 		/* Turn off security negotiation */
 		extra_flags |= NFS_MOUNT_SECFLAVOUR;
+		/* fall through */
 	case 4:
 		if (data->flags & NFS_MOUNT_SECFLAVOUR)
 			goto out_no_sec;
+		/* fall through */
 	case 5:
 		memset(data->context, 0, sizeof(data->context));
+		/* fall through */
 	case 6:
 		if (data->flags & NFS_MOUNT_VER3) {
 			if (data->root.size > NFS3_FHSIZE || data->root.size == 0)
-- 
2.7.4

