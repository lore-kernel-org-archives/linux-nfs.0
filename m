From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 18/30] NFS: load the rpc/rdma transport module automatically
Date: Wed, 11 Mar 2009 14:41:08 -0400
Message-ID: <20090311184108.5578.92479.stgit@heimdal.trondhjem.org>
References: <20090311184105.5578.22131.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Tom Talpey <tmtalpey@gmail.com>,
	Chuck Lever <chuck.lever@oracle.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51671 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754251AbZCKSoI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2009 14:44:08 -0400
In-Reply-To: <20090311184105.5578.22131.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tom Talpey <tmtalpey@gmail.com>

When mounting an NFS/RDMA server with the "-o proto=rdma" or
"-o rdma" options, attempt to dynamically load the necessary
"xprtrdma" client transport module. Doing so improves usability,
while avoiding a static module dependency and any unnecesary
resources.

Signed-off-by: Tom Talpey <tmtalpey@gmail.com>
Cc: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/super.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)


diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index d6686f4..0942fcb 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1018,6 +1018,7 @@ static int nfs_parse_mount_options(char *raw,
 		case Opt_rdma:
 			mnt->flags |= NFS_MOUNT_TCP; /* for side protocols */
 			mnt->nfs_server.protocol = XPRT_TRANSPORT_RDMA;
+			xprt_load_transport(p);
 			break;
 		case Opt_acl:
 			mnt->flags &= ~NFS_MOUNT_NOACL;
@@ -1205,12 +1206,14 @@ static int nfs_parse_mount_options(char *raw,
 				/* vector side protocols to TCP */
 				mnt->flags |= NFS_MOUNT_TCP;
 				mnt->nfs_server.protocol = XPRT_TRANSPORT_RDMA;
+				xprt_load_transport(string);
 				break;
 			default:
 				errors++;
 				dfprintk(MOUNT, "NFS:   unrecognized "
 						"transport protocol\n");
 			}
+			kfree(string);
 			break;
 		case Opt_mountproto:
 			string = match_strdup(args);
@@ -1218,7 +1221,6 @@ static int nfs_parse_mount_options(char *raw,
 				goto out_nomem;
 			token = match_token(string,
 					    nfs_xprt_protocol_tokens, args);
-			kfree(string);
 
 			switch (token) {
 			case Opt_xprt_udp:

