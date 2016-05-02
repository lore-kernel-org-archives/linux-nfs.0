Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f194.google.com ([209.85.213.194]:34274 "EHLO
	mail-ig0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754665AbcEBSkZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 May 2016 14:40:25 -0400
Subject: [PATCH v3 01/20] xprtrdma: Add rdma6 option to support NFS/RDMA IPv6
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 02 May 2016 14:40:23 -0400
Message-ID: <20160502184022.10798.85913.stgit@manet.1015granger.net>
In-Reply-To: <20160502183144.10798.99847.stgit@manet.1015granger.net>
References: <20160502183144.10798.99847.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Shirley Ma <shirley.ma@oracle.com>

RFC 5666: The "rdma" netid is to be used when IPv4 addressing
is employed by the underlying transport, and "rdma6" for IPv6
addressing.

Add mount -o proto=rdma6 option to support NFS/RDMA IPv6 addressing.

Changes from v2:
 - Integrated comments from Chuck Level, Anna Schumaker, Trodt Myklebust
 - Add a little more to the patch description to describe NFS/RDMA
   IPv6 suggested by Chuck Level and Anna Schumaker
 - Removed duplicated rdma6 define
 - Remove Opt_xprt_rdma mountfamily since it doesn't support

Signed-off-by: Shirley Ma <shirley.ma@oracle.com>
Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/super.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index f126828..c884155 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -191,6 +191,7 @@ static const match_table_t nfs_mount_option_tokens = {
 
 enum {
 	Opt_xprt_udp, Opt_xprt_udp6, Opt_xprt_tcp, Opt_xprt_tcp6, Opt_xprt_rdma,
+	Opt_xprt_rdma6,
 
 	Opt_xprt_err
 };
@@ -201,6 +202,7 @@ static const match_table_t nfs_xprt_protocol_tokens = {
 	{ Opt_xprt_tcp, "tcp" },
 	{ Opt_xprt_tcp6, "tcp6" },
 	{ Opt_xprt_rdma, "rdma" },
+	{ Opt_xprt_rdma6, "rdma6" },
 
 	{ Opt_xprt_err, NULL }
 };
@@ -1456,6 +1458,8 @@ static int nfs_parse_mount_options(char *raw,
 				mnt->flags |= NFS_MOUNT_TCP;
 				mnt->nfs_server.protocol = XPRT_TRANSPORT_TCP;
 				break;
+			case Opt_xprt_rdma6:
+				protofamily = AF_INET6;
 			case Opt_xprt_rdma:
 				/* vector side protocols to TCP */
 				mnt->flags |= NFS_MOUNT_TCP;

