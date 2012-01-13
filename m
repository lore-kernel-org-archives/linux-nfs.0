Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:21401 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932739Ab2AMULX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 15:11:23 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 24/44] NFS: Create a separate valadet_text_mount_data() function
Date: Fri, 13 Jan 2012 15:10:33 -0500
Message-Id: <1326485453-1350-25-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
References: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This allows for a separate function in the v4 case, which can evenutally
be called from a pointer in the struct nfs_subversion.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/super.c |   46 ++++++++++++++++++++++++++--------------------
 1 files changed, 26 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 861d31e..b5ffc6a 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1744,6 +1744,30 @@ out_path:
 	return -ENAMETOOLONG;
 }
 
+int nfs_validate_text_mount_data(void *options,
+				 struct nfs_parsed_mount_data *args,
+				 struct nfs_fh *mntfh,
+				 const char *dev_name)
+{
+	int status;
+	struct sockaddr *sap = (struct sockaddr *)&args->nfs_server.address;
+
+	nfs_set_port(sap, &args->nfs_server.port, 0);
+	nfs_set_mount_transport_protocol(args);
+	status = nfs_parse_devname(dev_name,
+				   &args->nfs_server.hostname,
+				   PAGE_SIZE,
+				   &args->nfs_server.export_path,
+				   NFS_MAXPATHLEN);
+	if (!status)
+		status = nfs_try_mount(args, mntfh);
+
+	kfree(args->nfs_server.export_path);
+	args->nfs_server.export_path = NULL;
+
+	return status;
+}
+
 /*
  * Validate the NFS2/NFS3 mount data
  * - fills in the mount root filehandle
@@ -1869,8 +1893,6 @@ static int nfs_validate_mount_data(void *options,
 
 		break;
 	default: {
-		int status;
-
 		if (nfs_parse_mount_options((char *)options, args) == 0)
 			return -EINVAL;
 
@@ -1884,24 +1906,8 @@ static int nfs_validate_mount_data(void *options,
 #else
 			goto out_v4_not_compiled;
 #endif
-
-		nfs_set_port(sap, &args->nfs_server.port, 0);
-
-		nfs_set_mount_transport_protocol(args);
-
-		status = nfs_parse_devname(dev_name,
-					   &args->nfs_server.hostname,
-					   PAGE_SIZE,
-					   &args->nfs_server.export_path,
-					   NFS_MAXPATHLEN);
-		if (!status)
-			status = nfs_try_mount(args, mntfh);
-
-		kfree(args->nfs_server.export_path);
-		args->nfs_server.export_path = NULL;
-
-		if (status)
-			return status;
+		else
+			return nfs_validate_text_mount_data(options, args, mntfh, dev_name);
 
 		break;
 		}
-- 
1.7.8.3

