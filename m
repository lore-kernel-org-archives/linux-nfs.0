Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:33515 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753473Ab0EXG6H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 May 2010 02:58:07 -0400
Date: Mon, 24 May 2010 16:57:56 +1000
From: Neil Brown <neilb@suse.de>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH] VFS: fix recent breakage of FS_REVAL_DOT
Message-ID: <20100524165756.2cfa54c4@notabene.brown>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Commit 1f36f774b22a0ceb7dd33eca626746c81a97b6a5 broke FS_REVAL_DOT semantics.

In particular, before this patch, the command
   ls -l
in an NFS mounted directory would always check if the directory on the server
had changed and if so would flush and refill the pagecache for the dir.
After this patch, the same "ls -l" will repeatedly return stale date until
the cached attributes for the directory time out.

The following patch fixes this by ensuring the d_revalidate is called by
do_last when "." is being looked-up.
link_path_walk has already called d_revalidate, but in that case LOOKUP_OPEN
is not set so nfs_lookup_verify_inode chooses not to do any validation.

The following patch restores the original behaviour.

Cc: stable@kernel.org
Signed-off-by: NeilBrown <neilb@suse.de>

---
As an aside the whole "FS_REVAL_DOT" concept seems deeply flawed to me.
The apparent purpose for d_revalidate is to ensure that the given name in the
given directory still points to the given inode.  For '.' this is pointless
as '.' in a given directory has a very well defined and unchangeable value.

It seems that d_revalidate is also used to update the cached attributes for
the target as well.  While that is reasonable side effect it seems wrong to
expect it as is the basis for FS_REVAL_DOT.

Surely ->open should perform any final validation of cached attributes.

NeilBrown

(Yes, I have posted this before but I didn't seem to be getting any real
progress, so I split this more obviously correct patch out from the other
less obvious one relating to mountpoints.  Once I succeed with this I'll try
again with the other).

diff --git a/fs/namei.c b/fs/namei.c
index 48e1f60..868d0cb 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -1621,6 +1621,7 @@ static struct file *do_last(struct nameidata *nd, struct path *path,
 	case LAST_DOTDOT:
 		follow_dotdot(nd);
 		dir = nd->path.dentry;
+	case LAST_DOT:
 		if (nd->path.mnt->mnt_sb->s_type->fs_flags & FS_REVAL_DOT) {
 			if (!dir->d_op->d_revalidate(dir, nd)) {
 				error = -ESTALE;
@@ -1628,7 +1629,6 @@ static struct file *do_last(struct nameidata *nd, struct path *path,
 			}
 		}
 		/* fallthrough */
-	case LAST_DOT:
 	case LAST_ROOT:
 		if (open_flag & O_CREAT)
 			goto exit;
