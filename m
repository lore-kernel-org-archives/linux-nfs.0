From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/6] NFS: Clean up NFSROOT command line parsing
Date: Tue, 11 May 2010 13:16:24 -0400
Message-ID: <20100511171623.2167.59607.stgit@matisse.1015granger.net>
References: <20100511170754.2167.72681.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f183.google.com ([209.85.221.183]:60854 "EHLO
	mail-qy0-f183.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756111Ab0EKRQ3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 May 2010 13:16:29 -0400
Received: by mail-qy0-f183.google.com with SMTP id 13so8473395qyk.1
        for <linux-nfs@vger.kernel.org>; Tue, 11 May 2010 10:16:29 -0700 (PDT)
In-Reply-To: <20100511170754.2167.72681.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: To reduce confusion, rename nfs_root_name as nfs_root_parms,
as this buffer contains more than just the name of the remote server.

Introduce documenting comments around nfs_root_setup().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfsroot.c |   32 +++++++++++++++++++++++---------
 1 files changed, 23 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
index 8c55b27..baed2aa 100644
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
 

