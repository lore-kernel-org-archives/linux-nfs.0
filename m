Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:36173 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753673AbcEDOnp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 May 2016 10:43:45 -0400
Received: by mail-io0-f179.google.com with SMTP id u185so64266676iod.3
        for <linux-nfs@vger.kernel.org>; Wed, 04 May 2016 07:43:44 -0700 (PDT)
Subject: [PATCH] gssd: Convert 'rdma' to 'tcp' protocol
From: Chuck Lever <chuck.lever@oracle.com>
To: SteveD@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 04 May 2016 10:43:42 -0400
Message-ID: <20160504144342.15837.19874.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The kernel NFS client specifies 'rdma' as the transport protocol for
NFS/RDMA mounts. This is a generic display token, probably not
something the kernel should lie about. The kernel uses it to form
NFSv4 client IDs, for example.

Until gssd can speak RPC-over-RDMA, convert 'rdma' to 'tcp' in
kernel gss upcalls.

This means that the Linux NFS client requires an NFS/TCP service on
an NFS/RDMA server when establishing a GSS context for proto=rdma
mount points. This is probably not an onerous requirement for the
time being.

Eventually user space support for RPC-over-RDMA might be introduced,
and gssd can use that for context establishment.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 utils/gssd/gssd.c |   16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index 7ba27b1..51b2cd7 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -301,6 +301,22 @@ gssd_read_service_info(int dirfd, struct clnt_info *clp)
 		goto fail;
 	}
 
+	/*
+	 * The user space RPC library has no support for
+	 * RPC-over-RDMA at this time, so change 'rdma'
+	 * to 'tcp', and '20049' to '2049'.
+	 */
+	if (strcmp(protoname, "rdma") == 0) {
+		free(protoname);
+		protoname = strdup("tcp");
+		if (!protoname)
+			goto fail;
+		free(port);
+		port = strdup("2049");
+		if (!port)
+			goto fail;
+	}
+
 	if (!gssd_addrstr_to_sockaddr((struct sockaddr *)&clp->addr,
 				 address, port ? port : ""))
 		goto fail;

