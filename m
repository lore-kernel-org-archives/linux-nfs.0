Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f179.google.com ([209.85.223.179]:54887 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752241AbaCLQwJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Mar 2014 12:52:09 -0400
Received: by mail-ie0-f179.google.com with SMTP id lx4so10545052iec.24
        for <linux-nfs@vger.kernel.org>; Wed, 12 Mar 2014 09:52:08 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/6] NFS: Use port 20049 by default for NFS/RDMA mounts
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 12 Mar 2014 12:52:07 -0400
Message-ID: <20140312165207.15349.79532.stgit@manet.1015granger.net>
In-Reply-To: <20140312164620.15349.22643.stgit@manet.1015granger.net>
References: <20140312164620.15349.22643.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When providing NFSv2 and v3 service via RDMA, NFS servers MAY use an
alternative well-known port number, 20049.  They are not required to
register the service with their local rpcbind.  At least one server
implementation I am aware of does not register it's NFS/RDMA service
with rpcbind.

When providing NFSv4 service via RDMA, the server MUST use the
alternative port number, 20049.  As with NFSv4 on IP-based
transports, clients SHOULD connect to this port without consulting
the server's rpcbind, so we can't expect rpcbind to help here
either.

See section 6 of RFC 5667 for details.

Today, admins are required to specify "port=" when mounting an
NFS/RDMA server.  To comply with RFC 5667 and for cross-
compatibility with heterogenous automounter maps, provide the proper
default port when mounting with "proto=rdma".

If the server does not use port 20049, the "port=" mount option is
still required to mount successfully. But clients today are forced
to specify this option anyway.

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=68401
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c           |    2 ++
 include/uapi/linux/nfs.h |    1 +
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 910ed90..6432600 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2157,6 +2157,8 @@ static int nfs_validate_text_mount_data(void *options,
 	} else
 		nfs_set_mount_transport_protocol(args);
 
+	if (args->nfs_server.protocol == XPRT_TRANSPORT_RDMA)
+		port = NFS_RDMA_PORT;
 	nfs_set_port(sap, &args->nfs_server.port, port);
 
 	return nfs_parse_devname(dev_name,
diff --git a/include/uapi/linux/nfs.h b/include/uapi/linux/nfs.h
index 5199a36..ccc6f8d 100644
--- a/include/uapi/linux/nfs.h
+++ b/include/uapi/linux/nfs.h
@@ -9,6 +9,7 @@
 
 #define NFS_PROGRAM	100003
 #define NFS_PORT	2049
+#define NFS_RDMA_PORT	20049
 #define NFS_MAXDATA	8192
 #define NFS_MAXPATHLEN	1024
 #define NFS_MAXNAMLEN	255

