Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:53263 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751520Ab0IJUDe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Sep 2010 16:03:34 -0400
Received: by gwj17 with SMTP id 17so1310419gwj.19
        for <linux-nfs@vger.kernel.org>; Fri, 10 Sep 2010 13:03:33 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/6] NFS: Clean up NFSROOT command line parsing
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 10 Sep 2010 16:03:30 -0400
Message-ID: <20100910200330.13167.80707.stgit@seurat.1015granger.net>
In-Reply-To: <20100910200001.13167.61153.stgit@seurat.1015granger.net>
References: <20100910200001.13167.61153.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up: To reduce confusion, rename nfs_root_name as nfs_root_parms,
as this buffer contains more than just the name of the remote server.

Introduce documenting comments around nfs_root_setup().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfsroot.c |   32 +++++++++++++++++++++++---------
 1 files changed, 23 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
index df101d9..169b679 100644
--- a/fs/nfs/nfsroot.c
+++ b/fs/nfs/nfsroot.c
@@ -99,7 +99,7 @@
 #define NFS_ROOT		"/tftpboot/%s"
 
 /* Parameters passed from the kernel command line */
-static char nfs_root_name[256] __initdata = "";
+static char nfs_root_parms[256] __initdata = "";
 
 /* Address of NFS server */
 static __be32 servaddr __initdata = 0;
@@ -369,7 +369,7 @@ static int __init root_nfs_init(void)
 	 * be able to use the client IP address for the remote root
 	 * directory (necessary for pure RARP booting).
 	 */
-	if (root_nfs_name(nfs_root_name) < 0 ||
+	if (root_nfs_name(nfs_root_parms) < 0 ||
 	    root_nfs_addr() < 0)
 		return -1;
 
@@ -380,23 +380,37 @@ static int __init root_nfs_init(void)
 	return 0;
 }
 
-
 /*
  *  Parse NFS server and directory information passed on the kernel
  *  command line.
+ *
+ *  nfsroot=[<server-ip>:]<root-dir>[,<nfs-options>]
+ *
+ *  If there is a "%s" token in the <root-dir> string, it is replaced
+ *  by the ASCII-representation of the client's IP address.
  */
 static int __init nfs_root_setup(char *line)
 {
 	ROOT_DEV = Root_NFS;
+
 	if (line[0] == '/' || line[0] == ',' || (line[0] >= '0' && line[0] <= '9')) {
-		strlcpy(nfs_root_name, line, sizeof(nfs_root_name));
+		strlcpy(nfs_root_parms, line, sizeof(nfs_root_parms));
 	} else {
-		int n = strlen(line) + sizeof(NFS_ROOT) - 1;
-		if (n >= sizeof(nfs_root_name))
-			line[sizeof(nfs_root_name) - sizeof(NFS_ROOT) - 2] = '\0';
-		sprintf(nfs_root_name, NFS_ROOT, line);
+		size_t n = strlen(line) + sizeof(NFS_ROOT) - 1;
+		if (n >= sizeof(nfs_root_parms))
+			line[sizeof(nfs_root_parms) - sizeof(NFS_ROOT) - 2] = '\0';
+		sprintf(nfs_root_parms, NFS_ROOT, line);
 	}
-	root_server_addr = root_nfs_parse_addr(nfs_root_name);
+
+	/*
+	 * Extract the IP address of the NFS server containing our
+	 * root file system, if one was specified.
+	 *
+	 * Note: root_nfs_parse_addr() removes the server-ip from
+	 *	 nfs_root_parms, if it exists.
+	 */
+	root_server_addr = root_nfs_parse_addr(nfs_root_parms);
+
 	return 1;
 }
 

