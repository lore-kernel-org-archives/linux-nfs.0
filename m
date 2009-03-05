From: Tom Talpey <tmtalpey@gmail.com>
Subject: [PATCH 4/4] NFS: load the rpc/rdma transport module automatically
Date: Thu, 05 Mar 2009 16:18:05 -0500
Message-ID: <20090305211805.6517.71207.stgit@localhost.localdomain>
References: <20090305210738.6517.67862.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, Tom Talpey <tmtalpey@gmail.com>,
	Chuck Lever <chuck.lever@oracle.com>
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from qmta06.westchester.pa.mail.comcast.net ([76.96.62.56]:52484
	"EHLO QMTA06.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754205AbZCEVSH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Mar 2009 16:18:07 -0500
In-Reply-To: <20090305210738.6517.67862.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When mounting an NFS/RDMA server with the "-o proto=rdma" or
"-o rdma" options, attempt to dynamically load the necessary
"xprtrdma" client transport module. Doing so improves usability,
while avoiding a static module dependency and any unnecesary
resources.

Signed-off-by: Tom Talpey <tmtalpey@gmail.com>
Cc: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index d6686f4..4e7f879 100644
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
@@ -1190,7 +1191,6 @@ static int nfs_parse_mount_options(char *raw,
 				goto out_nomem;
 			token = match_token(string,
 					    nfs_xprt_protocol_tokens, args);
-			kfree(string);
 
 			switch (token) {
 			case Opt_xprt_udp:
@@ -1205,12 +1205,14 @@ static int nfs_parse_mount_options(char *raw,
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

