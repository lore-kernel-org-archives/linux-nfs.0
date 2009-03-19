From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: atomic rename buggy on NFS?
Date: Thu, 19 Mar 2009 10:09:57 -0400
Message-ID: <1237471797.7534.1.camel@heimdal.trondhjem.org>
References: <alpine.OSF.1.99.0903191403140.384018@replicant.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Timo Aaltonen <tjaalton@cc.hut.fi>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <alpine.OSF.1.99.0903191403140.384018@replicant.hut.fi>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-03-19 at 14:23 +0200, Timo Aaltonen wrote:
> * http://bugzilla.gnome.org/show_bug.cgi?id=575684
> 

Does the appended patch fix it?

Cheers
  Trond
-------------------------------------------------------------------------
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: NFS: Fix the notifications when renaming onto an existing file

NFS appears to be returning an unnecessary "delete" notification when
we're doing an atomic rename. See

  http://bugzilla.gnome.org/show_bug.cgi?id=575684

The fix is to get rid of the redundant call to d_delete().

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/dir.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)


diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 672368f..3b2f697 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1624,8 +1624,7 @@ static int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 		} else if (atomic_read(&new_dentry->d_count) > 1)
 			/* dentry still busy? */
 			goto out;
-	} else
-		nfs_drop_nlink(new_inode);
+	}
 
 go_ahead:
 	/*
@@ -1638,10 +1637,8 @@ go_ahead:
 	}
 	nfs_inode_return_delegation(old_inode);
 
-	if (new_inode != NULL) {
+	if (new_inode != NULL)
 		nfs_inode_return_delegation(new_inode);
-		d_delete(new_dentry);
-	}
 
 	error = NFS_PROTO(old_dir)->rename(old_dir, &old_dentry->d_name,
 					   new_dir, &new_dentry->d_name);
@@ -1650,6 +1647,8 @@ out:
 	if (rehash)
 		d_rehash(rehash);
 	if (!error) {
+		if (new_inode != NULL)
+			nfs_drop_nlink(new_inode);
 		d_move(old_dentry, new_dentry);
 		nfs_set_verifier(new_dentry,
 					nfs_save_change_attribute(new_dir));
