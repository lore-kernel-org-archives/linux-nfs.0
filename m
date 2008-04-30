From: Chuck Lever <chucklever@gmail.com>
Subject: [PATCH 5/6] NFS: "proto=tcp" implies "mountproto=tcp"
Date: Wed, 30 Apr 2008 12:00:11 -0400
Message-ID: <20080430160011.32402.7262.stgit@manray.1015granger.net>
References: <20080430154011.32402.42101.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: jlayton@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.242]:59334 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760483AbYD3QAO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Apr 2008 12:00:14 -0400
Received: by an-out-0708.google.com with SMTP id d40so120817and.103
        for <linux-nfs@vger.kernel.org>; Wed, 30 Apr 2008 09:00:14 -0700 (PDT)
In-Reply-To: <20080430154011.32402.42101.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If a user specifies "proto=tcp" via the legacy mount API, the mount command
also uses TCP to contact the server's mount daemon.  Ditto for "proto=udp".
This makes it easier to mount through firewalls that block one or the other
transport protocol.

Make the in-kernel NFS mount option parser emulate this behavior.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |   16 ++++++++++++++--
 1 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 1f3fa91..e2cadd9 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -749,6 +749,7 @@ static int nfs_parse_mount_options(char *raw,
 {
 	char *p, *string, *secdata;
 	int timeo = 0, retrans = 0;
+	unsigned short mount_protocol = 0;
 	int rc;
 
 	if (!raw) {
@@ -821,6 +822,8 @@ static int nfs_parse_mount_options(char *raw,
 		case Opt_udp:
 			mnt->flags &= ~NFS_MOUNT_TCP;
 			mnt->nfs_server.protocol = XPRT_TRANSPORT_UDP;
+			if (mount_protocol == 0)
+				mount_protocol = XPRT_TRANSPORT_UDP;
 			if (timeo == 0)
 				timeo = NFS_DEF_UDP_TIMEO;
 			if (retrans == 0)
@@ -829,6 +832,8 @@ static int nfs_parse_mount_options(char *raw,
 		case Opt_tcp:
 			mnt->flags |= NFS_MOUNT_TCP;
 			mnt->nfs_server.protocol = XPRT_TRANSPORT_TCP;
+			if (mount_protocol == 0)
+				mount_protocol = XPRT_TRANSPORT_TCP;
 			if (timeo == 0)
 				timeo = NFS_DEF_TCP_TIMEO;
 			if (retrans == 0)
@@ -1040,6 +1045,8 @@ static int nfs_parse_mount_options(char *raw,
 			case Opt_xprt_udp:
 				mnt->flags &= ~NFS_MOUNT_TCP;
 				mnt->nfs_server.protocol = XPRT_TRANSPORT_UDP;
+				if (mount_protocol == 0)
+					mount_protocol = XPRT_TRANSPORT_UDP;
 				if (timeo == 0)
 					timeo = NFS_DEF_UDP_TIMEO;
 				if (retrans == 0)
@@ -1048,6 +1055,8 @@ static int nfs_parse_mount_options(char *raw,
 			case Opt_xprt_tcp:
 				mnt->flags |= NFS_MOUNT_TCP;
 				mnt->nfs_server.protocol = XPRT_TRANSPORT_TCP;
+				if (mount_protocol == 0)
+					mount_protocol = XPRT_TRANSPORT_TCP;
 				if (timeo == 0)
 					timeo = NFS_DEF_TCP_TIMEO;
 				if (retrans == 0)
@@ -1076,10 +1085,10 @@ static int nfs_parse_mount_options(char *raw,
 
 			switch (token) {
 			case Opt_xprt_udp:
-				mnt->mount_server.protocol = XPRT_TRANSPORT_UDP;
+				mount_protocol = XPRT_TRANSPORT_UDP;
 				break;
 			case Opt_xprt_tcp:
-				mnt->mount_server.protocol = XPRT_TRANSPORT_TCP;
+				mount_protocol = XPRT_TRANSPORT_TCP;
 				break;
 			case Opt_xprt_rdma: /* not used for side protocols */
 			default:
@@ -1137,6 +1146,9 @@ static int nfs_parse_mount_options(char *raw,
 	if (retrans != 0)
 		mnt->retrans = retrans;
 
+	if (mount_protocol)
+		mnt->mount_server.protocol = mount_protocol;
+
 	return 1;
 
 out_nomem:

