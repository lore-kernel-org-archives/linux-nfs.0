Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:48155 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751253Ab0GMLg3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Jul 2010 07:36:29 -0400
Date: Tue, 13 Jul 2010 13:34:59 +0200
From: Dan Carpenter <error27@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: [patch] nfs: include space for the NULL in root path
Message-ID: <20100713113459.GI5658@bicker>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

In root_nfs_name() it does the following:

        if (strlen(buf) + strlen(cp) > NFS_MAXPATHLEN) {
                printk(KERN_ERR "Root-NFS: Pathname for remote directory too long.\n");
                return -1;
        }
        sprintf(nfs_export_path, buf, cp);

In the original code if (strlen(buf) + strlen(cp) == NFS_MAXPATHLEN)
then the sprintf() would lead to an overflow.  Generally the rest of the
code assumes that the path can have NFS_MAXPATHLEN (1024) characters and
a NULL terminator so the fix is to add space to the nfs_export_path[]
buffer.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
index 6bd19d8..5c4f7cf 100644
--- a/fs/nfs/nfsroot.c
+++ b/fs/nfs/nfsroot.c
@@ -105,7 +105,7 @@ static char nfs_root_name[256] __initdata = "";
 static __be32 servaddr __initdata = 0;
 
 /* Name of directory to mount */
-static char nfs_export_path[NFS_MAXPATHLEN] __initdata = { 0, };
+static char nfs_export_path[NFS_MAXPATHLEN + 1] __initdata = { 0, };
 
 /* NFS-related data */
 static struct nfs_mount_data nfs_data __initdata = { 0, };/* NFS mount info */
