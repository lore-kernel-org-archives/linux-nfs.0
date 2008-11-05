From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/8] NFS: rename nfs_path variable
Date: Wed, 05 Nov 2008 15:24:51 -0500
Message-ID: <20081105202451.14469.28701.stgit@ingres.1015granger.net>
References: <20081105202040.14469.32458.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:38247 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752956AbYKEUZK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 15:25:10 -0500
In-Reply-To: <20081105202040.14469.32458.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: I'm about to move the declaration of nfs_mount into
fs/nfs/internal.h and include it in fs/nfs/nfsroot.c.  There's a
conflicting definition of nfs_path in fs/nfs/internal.h and
fs/nfs/nfsroot.c, so rename the private one.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfsroot.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
index 8478fc2..f1c0a06 100644
--- a/fs/nfs/nfsroot.c
+++ b/fs/nfs/nfsroot.c
@@ -100,7 +100,7 @@ static char nfs_root_name[256] __initdata = "";
 static __be32 servaddr __initdata = 0;
 
 /* Name of directory to mount */
-static char nfs_path[NFS_MAXPATHLEN] __initdata = { 0, };
+static char nfs_export_path[NFS_MAXPATHLEN] __initdata = { 0, };
 
 /* NFS-related data */
 static struct nfs_mount_data nfs_data __initdata = { 0, };/* NFS mount info */
@@ -312,7 +312,7 @@ static int __init root_nfs_name(char *name)
 		printk(KERN_ERR "Root-NFS: Pathname for remote directory too long.\n");
 		return -1;
 	}
-	sprintf(nfs_path, buf, cp);
+	sprintf(nfs_export_path, buf, cp);
 
 	return 1;
 }
@@ -340,7 +340,7 @@ static int __init root_nfs_addr(void)
 static void __init root_nfs_print(void)
 {
 	printk(KERN_NOTICE "Root-NFS: Mounting %s on server %s as root\n",
-		nfs_path, nfs_data.hostname);
+		nfs_export_path, nfs_data.hostname);
 	printk(KERN_NOTICE "Root-NFS:     rsize = %d, wsize = %d, timeo = %d, retrans = %d\n",
 		nfs_data.rsize, nfs_data.wsize, nfs_data.timeo, nfs_data.retrans);
 	printk(KERN_NOTICE "Root-NFS:     acreg (min,max) = (%d,%d), acdir (min,max) = (%d,%d)\n",
@@ -493,10 +493,10 @@ static int __init root_nfs_get_handle(void)
 
 	set_sockaddr(&sin, servaddr, htons(mount_port));
 	status = nfs_mount((struct sockaddr *) &sin, sizeof(sin), NULL,
-			   nfs_path, version, protocol, &fh);
+			   nfs_export_path, version, protocol, &fh);
 	if (status < 0)
 		printk(KERN_ERR "Root-NFS: Server returned error %d "
-				"while mounting %s\n", status, nfs_path);
+				"while mounting %s\n", status, nfs_export_path);
 	else {
 		nfs_data.root.size = fh.size;
 		memcpy(nfs_data.root.data, fh.data, fh.size);

