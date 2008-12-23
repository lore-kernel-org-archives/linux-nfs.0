From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 08/69] NFS: rename nfs_path variable
Date: Tue, 23 Dec 2008 18:02:07 -0500
Message-ID: <20081223230207.13743.40693.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:45954 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752302AbYLWXXl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:23:41 -0500
Received: from svlrsexc2-prd.hq.netapp.com ([10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNNa7M021304
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:23:39 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Clean up: I'm about to move the declaration of nfs_mount into
fs/nfs/internal.h and include it in fs/nfs/nfsroot.c.  There's a
conflicting definition of nfs_path in fs/nfs/internal.h and
fs/nfs/nfsroot.c, so rename the private one.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
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

