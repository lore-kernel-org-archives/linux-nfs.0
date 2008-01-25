From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 042/112] NFS: Ensure that NFS version 4 mounts use NFS_PORT
	if nfsport wasn't set
Date: Fri, 25 Jan 2008 11:37:36 -0500
Message-ID: <20080125163736.31887.95780.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50284 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754502AbYAYRCL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:02:11 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH22tu011015
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:02:02 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Text-based mount option parsing introduced a minor regression in the
behavior of NFS version 4 mounts.  NFS version 4 is not supposed to require
a running rpcbind service on the server in order for a mount to succeed.

In other words, if the mount options don't specify a port number, the port
number is supposed to default to 2049.  For earlier versions of NFS, the
default port number was zero in order to cause the RPC client to autobind
to the server's NFS service.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/super.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index fda1635..7d84d94 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1643,6 +1643,8 @@ static int nfs4_validate_mount_data(void *options,
 		if (nfs_parse_mount_options((char *)options, args) == 0)
 			return -EINVAL;
 
+		if (args->nfs_server.address.sin_port == 0)
+			args->nfs_server.address.sin_port = htons(NFS_PORT);
 		if (!nfs_verify_server_address((struct sockaddr *)
 						&args->nfs_server.address))
 			return -EINVAL;
