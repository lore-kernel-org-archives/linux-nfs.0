Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 8bytes.org ([85.214.48.195]:57353 "EHLO
	h2027444.stratoserver.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755284Ab2FHNau (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jun 2012 09:30:50 -0400
Received: from localhost (localhost [127.0.0.1])
	by h2027444.stratoserver.net (Postfix) with SMTP id 9D8AD12B094
	for <linux-nfs@vger.kernel.org>; Fri,  8 Jun 2012 15:30:48 +0200 (CEST)
Date: Fri, 8 Jun 2012 15:30:47 +0200
From: Joerg Roedel <joro@8bytes.org>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: NFS regression in v3.5-rc1: mount.nfs yells about incorrect
 mount option
Message-ID: <20120608133047.GV12795@8bytes.org>
References: <20120607150456.GO12795@8bytes.org>
 <4FD0C4C2.8020605@netapp.com>
 <20120607155006.GR12795@8bytes.org>
 <4FD0CEB0.9040804@netapp.com>
 <20120608130352.GU12795@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120608130352.GU12795@8bytes.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 08, 2012 at 03:03:52PM +0200, Joerg Roedel wrote:
> Patch attached.

Hmm, since nfs_fs_mount is now shared between nfs23 and nfs4, a better
"revert" is probably this one:

>From 3517158fc3bc5d778dcba987ac73eea6bb7a889a Mon Sep 17 00:00:00 2001
From: Joerg Roedel <joerg.roedel@amd.com>
Date: Fri, 8 Jun 2012 14:51:01 +0200
Subject: [PATCH] Revert "NFS: Let mount data parsing set the NFS version"

This reverts commit db8333519187d5974cf2ff33910c893bf8727d9f.

The original commit message says, that the version field is
"unconditionally set while parsing mount data".
Unfortunatly this is not the case and the version field may
stay 0 so that nfs_init_server returns -EPROTONOSUPPORT
causing the mount to fail.  Reverting this commit fixes the
issue.

Conflicts:

	fs/nfs/super.c

Signed-off-by: Joerg Roedel <joerg.roedel@amd.com>
---
 fs/nfs/super.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index ff656c0..d7a237d 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -948,7 +948,7 @@ static void nfs_umount_begin(struct super_block *sb)
 		rpc_killall_tasks(rpc);
 }
 
-static struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(void)
+static struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(unsigned int version)
 {
 	struct nfs_parsed_mount_data *data;
 
@@ -963,6 +963,7 @@ static struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(void)
 		data->nfs_server.protocol = XPRT_TRANSPORT_TCP;
 		data->auth_flavors[0]	= RPC_AUTH_UNIX;
 		data->auth_flavor_len	= 1;
+		data->version		= version;
 		data->minorversion	= 0;
 		data->need_mount	= true;
 		data->net		= current->nsproxy->net_ns;
@@ -2472,6 +2473,7 @@ error_splat_bdi:
 static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *raw_data)
 {
+	int version = (fs_type == &nfs_fs_type) ? NFS_DEFAULT_VERSION : 4;
 	struct nfs_mount_info mount_info = {
 		.fill_super = nfs_fill_super,
 		.set_security = nfs_set_sb_security,
@@ -2479,7 +2481,7 @@ static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
 	struct dentry *mntroot = ERR_PTR(-ENOMEM);
 	int error;
 
-	mount_info.parsed = nfs_alloc_parsed_mount_data();
+	mount_info.parsed = nfs_alloc_parsed_mount_data(version);
 	mount_info.mntfh = nfs_alloc_fhandle();
 	if (mount_info.parsed == NULL || mount_info.mntfh == NULL)
 		goto out;
-- 
1.7.9.5


