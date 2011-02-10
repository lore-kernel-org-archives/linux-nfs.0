Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay03.bluemeaney.com ([205.234.16.187]:56235 "EHLO
	relay03.bluemeaney.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895Ab1BJMVQ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Feb 2011 07:21:16 -0500
Subject: [PATCH 2/2] nfsv4: Fix dereference i_op->lookup and call NULL
 pointer at d_alloc_and_lookup()
From: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        David Howells <dhowells@redhat.com>, linux-nfs@vger.kernel.org
In-Reply-To: <1297338894.3667.0.camel@vT510>
References: <1297338894.3667.0.camel@vT510>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 10 Feb 2011 15:21:14 +0300
Message-ID: <1297340474.3667.13.camel@vT510>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

During mount if rootfh changes fsid then fs-core layer
dereferences and calls NULL pointer.

nfs_fhget() sets rootinode->i_op to nfs_mountpoint_inode_operations.
Then d_alloc_and_lookup() calls i_op->lookup() that is NULL.

The problem is:  rpc_ops->getroot() and rpc_ops->getattr()
return different fsid due to server replies.

So just refresh fsid, as RFC3530 doesn't specify behavior
in case of rootfh changes fsid.

Oops:

   BUG: unable to handle kernel NULL pointer dereference at (null)
   IP: [<          (null)>]           (null)

stack trace:

     d_alloc_and_lookup+0x4c/0x74
     do_lookup+0x1e3/0x280
     link_path_walk+0x12e/0xab0
     nfs4_remote_get_sb+0x56/0x2c0 [nfs]
     path_walk+0x67/0xe0
     vfs_path_lookup+0x8e/0x100
     nfs_follow_remote_path+0x16f/0x3e0 [nfs]
     nfs4_try_mount+0x6f/0xd0 [nfs]
     nfs_get_sb+0x269/0x400 [nfs]
     vfs_kern_mount+0x8a/0x1f0
     do_kern_mount+0x52/0x130
     do_mount+0x20a/0x260
     sys_mount+0x90/0xe0
     system_call_fastpath+0x16/0x1b

Signed-off-by: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
---
 fs/nfs/getroot.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/getroot.c b/fs/nfs/getroot.c
index b5ffe8f..7979652 100644
--- a/fs/nfs/getroot.c
+++ b/fs/nfs/getroot.c
@@ -199,6 +199,10 @@ struct dentry *nfs4_get_root(struct super_block
*sb, struct nfs_fh *mntfh)
 		goto out;
 	}
 
+	if (fattr->valid & NFS_ATTR_FATTR_FSID &&
+	    !nfs_fsid_equal(&server->fsid, &fattr->fsid))
+		memcpy(&server->fsid, &fattr->fsid, sizeof(server->fsid));
+
 	inode = nfs_fhget(sb, mntfh, fattr);
 	if (IS_ERR(inode)) {
 		dprintk("nfs_get_root: get root inode failed\n");
-- 
1.7.1


