Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:35354 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751181AbaLPXxD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Dec 2014 18:53:03 -0500
Date: Wed, 17 Dec 2014 02:52:26 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: [patch] NFS: a couple off by ones
Message-ID: <20141216235225.GB31467@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These tests are off by one because if len == sizeof(nfs_export_path)
then we have truncated the name.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
index cd3c910..9bc9f04 100644
--- a/fs/nfs/nfsroot.c
+++ b/fs/nfs/nfsroot.c
@@ -261,11 +261,11 @@ static int __init root_nfs_data(char *cmdline)
 	 */
 	len = snprintf(nfs_export_path, sizeof(nfs_export_path),
 				tmp, utsname()->nodename);
-	if (len > (int)sizeof(nfs_export_path))
+	if (len >= (int)sizeof(nfs_export_path))
 		goto out_devnametoolong;
 	len = snprintf(nfs_root_device, sizeof(nfs_root_device),
 				"%pI4:%s", &servaddr, nfs_export_path);
-	if (len > (int)sizeof(nfs_root_device))
+	if (len >= (int)sizeof(nfs_root_device))
 		goto out_devnametoolong;
 
 	retval = 0;
