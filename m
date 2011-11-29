Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp1.onthe.net.au ([203.22.196.249]:42684 "EHLO
	smtp1.onthe.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752055Ab1K2IZD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2011 03:25:03 -0500
Date: Tue, 29 Nov 2011 19:25:01 +1100
From: Chris Dunlop <chris@onthe.net.au>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        Eric Van Hensbergen <ericvh@gmail.com>,
        Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>,
        David Howells <dhowells@redhat.com>, Jan Harkes <jaharkes@cs.cmu.edu>,
        "maintainer:CODA FILE SYSTEM" <coda@cs.cmu.edu>,
        Dave Kleikamp <shaggy@kernel.org>,
        Petr Vandrovec <petr@vandrovec.name>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Greg Kroah-Hartman <gregkh@suse.de>, Al Viro <viro@zeniv.linux.org.uk>,
        v9fs-developer@lists.sourceforge.net, linux-afs@lists.infradead.org,
        codalist@TELEMANN.coda.cs.cmu.edu,
        jfs-discussion@lists.sourceforge.net, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/1] fix d_revalidate oopsen on NFS exports
Message-ID: <20111129082501.GA569@onthe.net.au>
References: <1321861008-20611-1-git-send-email-chris@onthe.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1321861008-20611-1-git-send-email-chris@onthe.net.au>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I haven't seen any response to this patch which fixes an Oops in
d_revalidate. I hit this using NFS, but various other file
systems look to be likewise vulnerable, hence the broadness of
the patch. The sequence leading to the Oops is:

lookup_one_len() [fs/namei.c]
   calls __lookup_hash() [fs/namei.c] with nd == NULL,
      which can then call the file system specific d_revalidate(), passing in nd == NULL
         which will then Oops if nd is used without checking

Any suggestions on how to better bring this to the attention of
the relevant people? E.g. be patient, and/or provide separate
patches for each file system, and/or provide a better
explanation of the issue in the patch?

Note: in the patch version provided I missed the d_revalidate for
NFSv4, I'll respin that once I can get an idea of how to better
provide the patches.

Cheers,

Chris.

On Mon, Nov 21, 2011 at 06:36:48PM +1100, Chris Dunlop wrote:
> can't blindly check nd->flags in ->d_revalidate()
> 
> Has been previously done for various other file systems:
> 
> git blame -L 1768,+1 fs/proc/base.c
> 34286d66 (Nick Piggin 2011-01-07 17:49:57 +1100 1768) 	if (nd && nd->flags & LOOKUP_RCU)
> git blame -L 645,+1 fs/cifs/dir.c
> 3ca30d40 (Pavel Shilovsky 2011-07-25 17:59:10 +0400 645) 	if (nd && (nd->flags & LOOKUP_RCU))
> git blame -L 46,+1 fs/fat/namei_vfat.c
> 9177ada9 (Al Viro 2011-03-10 03:45:49 -0500 46) 	if (nd && nd->flags & LOOKUP_RCU)
> git blame -L 57,+1 fs/fat/namei_vfat.c
> 9177ada9 (Al Viro 2011-03-10 03:45:49 -0500 57) 	if (nd && nd->flags & LOOKUP_RCU)
> git blame -L 177,+1 fs/fuse/dir.c
> d2433905 (Miklos Szeredi 2011-05-10 17:35:58 +0200 177) 		if (nd && (nd->flags & LOOKUP_RCU))
> git blame -L 1036,+1 fs/ceph/dir.c
> 0eb980e3 (Al Viro 2011-03-10 03:44:05 -0500 1036) 	if (nd && nd->flags & LOOKUP_RCU)
> git blame -L 47,+1 fs/gfs2/dentry.c
> 53fe9241 (Al Viro 2011-03-10 03:44:48 -0500 47) 	if (nd && nd->flags & LOOKUP_RCU)
> git blame -L 53,+1 fs/ecryptfs/dentry.c
> 70b89021 (Tyler Hicks 2011-02-17 17:35:20 -0600 53) 	if (nd && nd->flags & LOOKUP_RCU)
> git blame -L 59,+1 fs/ocfs2/dcache.c
> 4714e637 (Al Viro 2011-03-10 03:45:07 -0500 59) 	if (nd && nd->flags & LOOKUP_RCU)
> 
> Signed-off-by: Chris Dunlop <chris@onthe.net.au>
> ---
>  fs/9p/vfs_dentry.c    |    2 +-
>  fs/afs/dir.c          |    2 +-
>  fs/coda/dir.c         |    2 +-
>  fs/hfs/sysdep.c       |    2 +-
>  fs/jfs/namei.c        |    3 +++
>  fs/ncpfs/dir.c        |    2 +-
>  fs/nfs/dir.c          |    2 +-
>  fs/proc/proc_sysctl.c |    2 +-
>  fs/sysfs/dir.c        |    2 +-
>  9 files changed, 11 insertions(+), 8 deletions(-)
> 
> diff --git a/fs/9p/vfs_dentry.c b/fs/9p/vfs_dentry.c
> index e022890..2be4b91 100644
> --- a/fs/9p/vfs_dentry.c
> +++ b/fs/9p/vfs_dentry.c
> @@ -106,7 +106,7 @@ static int v9fs_lookup_revalidate(struct dentry *dentry, struct nameidata *nd)
>  	struct inode *inode;
>  	struct v9fs_inode *v9inode;
>  
> -	if (nd->flags & LOOKUP_RCU)
> +	if (nd && nd->flags & LOOKUP_RCU)
>  		return -ECHILD;
>  
>  	inode = dentry->d_inode;
> diff --git a/fs/afs/dir.c b/fs/afs/dir.c
> index 1b0b195..4112d68 100644
> --- a/fs/afs/dir.c
> +++ b/fs/afs/dir.c
> @@ -607,7 +607,7 @@ static int afs_d_revalidate(struct dentry *dentry, struct nameidata *nd)
>  	void *dir_version;
>  	int ret;
>  
> -	if (nd->flags & LOOKUP_RCU)
> +	if (nd && nd->flags & LOOKUP_RCU)
>  		return -ECHILD;
>  
>  	vnode = AFS_FS_I(dentry->d_inode);
> diff --git a/fs/coda/dir.c b/fs/coda/dir.c
> index 28e7e13..0cf4a68 100644
> --- a/fs/coda/dir.c
> +++ b/fs/coda/dir.c
> @@ -544,7 +544,7 @@ static int coda_dentry_revalidate(struct dentry *de, struct nameidata *nd)
>  	struct inode *inode;
>  	struct coda_inode_info *cii;
>  
> -	if (nd->flags & LOOKUP_RCU)
> +	if (nd && nd->flags & LOOKUP_RCU)
>  		return -ECHILD;
>  
>  	inode = de->d_inode;
> diff --git a/fs/hfs/sysdep.c b/fs/hfs/sysdep.c
> index 19cf291..1127ea3 100644
> --- a/fs/hfs/sysdep.c
> +++ b/fs/hfs/sysdep.c
> @@ -18,7 +18,7 @@ static int hfs_revalidate_dentry(struct dentry *dentry, struct nameidata *nd)
>  	struct inode *inode;
>  	int diff;
>  
> -	if (nd->flags & LOOKUP_RCU)
> +	if (nd && nd->flags & LOOKUP_RCU)
>  		return -ECHILD;
>  
>  	inode = dentry->d_inode;
> diff --git a/fs/jfs/namei.c b/fs/jfs/namei.c
> index a112ad9..e3b65d6 100644
> --- a/fs/jfs/namei.c
> +++ b/fs/jfs/namei.c
> @@ -1585,6 +1585,9 @@ out:
>  
>  static int jfs_ci_revalidate(struct dentry *dentry, struct nameidata *nd)
>  {
> +	if (nd && (nd->flags & LOOKUP_RCU))
> +		return -ECHILD;
> +
>  	/*
>  	 * This is not negative dentry. Always valid.
>  	 *
> diff --git a/fs/ncpfs/dir.c b/fs/ncpfs/dir.c
> index 9c51f62..1fb3de3 100644
> --- a/fs/ncpfs/dir.c
> +++ b/fs/ncpfs/dir.c
> @@ -302,7 +302,7 @@ ncp_lookup_validate(struct dentry *dentry, struct nameidata *nd)
>  	if (dentry == dentry->d_sb->s_root)
>  		return 1;
>  
> -	if (nd->flags & LOOKUP_RCU)
> +	if (nd && nd->flags & LOOKUP_RCU)
>  		return -ECHILD;
>  
>  	parent = dget_parent(dentry);
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index b238d95..88c0f6e 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -1103,7 +1103,7 @@ static int nfs_lookup_revalidate(struct dentry *dentry, struct nameidata *nd)
>  	struct nfs_fattr *fattr = NULL;
>  	int error;
>  
> -	if (nd->flags & LOOKUP_RCU)
> +	if (nd && nd->flags & LOOKUP_RCU)
>  		return -ECHILD;
>  
>  	parent = dget_parent(dentry);
> diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
> index a6b6217..0437e4a 100644
> --- a/fs/proc/proc_sysctl.c
> +++ b/fs/proc/proc_sysctl.c
> @@ -435,7 +435,7 @@ static const struct inode_operations proc_sys_dir_operations = {
>  
>  static int proc_sys_revalidate(struct dentry *dentry, struct nameidata *nd)
>  {
> -	if (nd->flags & LOOKUP_RCU)
> +	if (nd && nd->flags & LOOKUP_RCU)
>  		return -ECHILD;
>  	return !PROC_I(dentry->d_inode)->sysctl->unregistering;
>  }
> diff --git a/fs/sysfs/dir.c b/fs/sysfs/dir.c
> index 7fdf6a7..8f36a13 100644
> --- a/fs/sysfs/dir.c
> +++ b/fs/sysfs/dir.c
> @@ -261,7 +261,7 @@ static int sysfs_dentry_revalidate(struct dentry *dentry, struct nameidata *nd)
>  	struct sysfs_dirent *sd;
>  	int is_dir;
>  
> -	if (nd->flags & LOOKUP_RCU)
> +	if (nd && nd->flags & LOOKUP_RCU)
>  		return -ECHILD;
>  
>  	sd = dentry->d_fsdata;
> -- 
> 1.7.0.4
> 
