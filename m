Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:47213 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754138AbcDDSPh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Apr 2016 14:15:37 -0400
Message-ID: <5702AF3F.90500@oracle.com>
Date: Mon, 04 Apr 2016 11:15:27 -0700
From: Shirley Ma <shirley.ma@oracle.com>
MIME-Version: 1.0
To: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Chuck Lever <Chuck.Lever@oracle.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma <linux-rdma@vger.kernel.org>
Subject: [PATCH V2] nfs: add mount proto=rdma6 option for NFS/RDMA IPv6 addressing
References: <56E9A650.7060409@oracle.com> <56F19F28.9020504@Netapp.com>
In-Reply-To: <56F19F28.9020504@Netapp.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

RFC 5666: The "rdma" netid is to be used when IPv4 addressing
is employed by the underlying transport, and "rdma6" for IPv6
addressing.
Add mount -o proto=rdma6 option to support NFS/RDMA IPv6 addressing.

Changes from v1:
 - Integrated comments from Chuck Level, Anna Schumaker, Trodt Myklebust
 - Add a little more to the patch description to describe NFS/RDMA
   IPv6 usage
 - Removed duplicated rdma6 define
 - Removed Opt_xprt_rdma mountfamily since this doesn't support 

Signed-off-by: Shirley Ma <shirley.ma@oracle.com>
---

 fs/nfs/super.c | 4 ++++
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
