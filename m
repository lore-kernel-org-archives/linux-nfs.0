Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:34680 "EHLO
	mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752260AbcFFW6p (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Jun 2016 18:58:45 -0400
Received: by mail-yw0-f195.google.com with SMTP id j74so20934616ywg.1
        for <linux-nfs@vger.kernel.org>; Mon, 06 Jun 2016 15:58:44 -0700 (PDT)
To: linux-kernel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org
From: Rob Landley <rob@landley.net>
Subject: [PATCH] Fix NFS option parsing bit-rot.
Message-ID: <57560021.5030708@landley.net>
Date: Mon, 6 Jun 2016 17:58:41 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Rob Landley <rob@landley.net>

The kernel has string parsing code for NFS mount options, but it seems
to have bit-rotted over the years, so toybox mount needs the following
patch to be able to mount nfs. Without it, the kernel returns "invalid
argument" before sending any network traffic.

For more information, see
http://lists.landley.net/pipermail/toybox-landley.net/2016-March/004790.html

Signed-off-by: Rob Landley <rob@landley.net>
---

 fs/nfs/super.c |   18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 2137e02..863585d 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2130,11 +2130,23 @@ static int nfs_validate_text_mount_data(void *options,
 	int port = 0;
 	int max_namelen = PAGE_SIZE;
 	int max_pathlen = NFS_MAXPATHLEN;
+	int rc;
 	struct sockaddr *sap = (struct sockaddr *)&args->nfs_server.address;
 
 	if (nfs_parse_mount_options((char *)options, args) == 0)
 		return -EINVAL;
 
+	rc = nfs_parse_devname(dev_name,
+				   &args->nfs_server.hostname,
+				   max_namelen,
+				   &args->nfs_server.export_path,
+				   max_pathlen);
+
+	args->nfs_server.addrlen = rpc_pton(args->net,
+			args->nfs_server.hostname,
+			strlen(args->nfs_server.hostname),
+			sap, sizeof(args->nfs_server.address));
+
 	if (!nfs_verify_server_address(sap))
 		goto out_no_address;
 
@@ -2155,11 +2167,7 @@ static int nfs_validate_text_mount_data(void *options,
 
 	nfs_set_port(sap, &args->nfs_server.port, port);
 
-	return nfs_parse_devname(dev_name,
-				   &args->nfs_server.hostname,
-				   max_namelen,
-				   &args->nfs_server.export_path,
-				   max_pathlen);
+	return rc;
 
 #if !IS_ENABLED(CONFIG_NFS_V4)
 out_v4_not_compiled:

