Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:51202 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754352Ab2CAWBY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Mar 2012 17:01:24 -0500
Received: by mail-iy0-f174.google.com with SMTP id z16so1389945iag.19
        for <linux-nfs@vger.kernel.org>; Thu, 01 Mar 2012 14:01:24 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/15] commit 6f38b4ba433ac6494f83cb73dd07dcbde797e1e0
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 01 Mar 2012 17:01:23 -0500
Message-ID: <20120301220122.2138.64772.stgit@degas.1015granger.net>
In-Reply-To: <20120301215755.2138.73488.stgit@degas.1015granger.net>
References: <20120301215755.2138.73488.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS: Make clientaddr= optional

    For NFSv4 mounts, the clientaddr= mount option has always been
    required.  Now we have rpc_localaddr() in the kernel, which was
    modeled after the same logic in the mount.nfs command that constructs
    the clientaddr= mount option.  If user space doesn't provide a
    clientaddr= mount option, the kernel can now construct its own.

    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/client.c |   15 +++++++++++++++
 fs/nfs/super.c  |    6 ------
 2 files changed, 15 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 994899d..add92d9 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1344,6 +1344,7 @@ int nfs4_init_client(struct nfs_client *clp,
 		     rpc_authflavor_t authflavour,
 		     int noresvport)
 {
+	char buf[INET6_ADDRSTRLEN + 1];
 	int error;
 
 	if (clp->cl_cons_state == NFS_CS_READY) {
@@ -1359,6 +1360,20 @@ int nfs4_init_client(struct nfs_client *clp,
 				      1, noresvport);
 	if (error < 0)
 		goto error;
+
+	/* If no clientaddr= option was specified, find a usable cb address */
+	if (ip_addr == NULL) {
+		struct sockaddr_storage cb_addr;
+		struct sockaddr *sap = (struct sockaddr *)&cb_addr;
+
+		error = rpc_localaddr(clp->cl_rpcclient, sap, sizeof(cb_addr));
+		if (error < 0)
+			goto error;
+		error = rpc_ntop(sap, buf, sizeof(buf));
+		if (error < 0)
+			goto error;
+		ip_addr = (const char *)buf;
+	}
 	strlcpy(clp->cl_ipaddr, ip_addr, sizeof(clp->cl_ipaddr));
 
 	error = nfs_idmap_new(clp);
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 72c7f63..8ae8fb2 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2526,12 +2526,6 @@ static int nfs4_validate_text_mount_data(void *options,
 		return -EINVAL;
 	}
 
-	if (args->client_address == NULL) {
-		dfprintk(MOUNT,
-			 "NFS4: mount program didn't pass callback address\n");
-		return -EINVAL;
-	}
-
 	return nfs_parse_devname(dev_name,
 				   &args->nfs_server.hostname,
 				   NFS4_MAXNAMLEN,

