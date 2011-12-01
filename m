Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp1.onthe.net.au ([203.22.196.249]:58874 "EHLO
	smtp1.onthe.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750703Ab1LAFfB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2011 00:35:01 -0500
Date: Thu, 1 Dec 2011 16:34:57 +1100
From: Chris Dunlop <chris@onthe.net.au>
To: David Howells <dhowells@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        Eric Van Hensbergen <ericvh@gmail.com>,
        Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>,
        Jan Harkes <jaharkes@cs.cmu.edu>,
        "maintainer:CODA FILE SYSTEM" <coda@cs.cmu.edu>,
        Dave Kleikamp <shaggy@kernel.org>,
        Petr Vandrovec <petr@vandrovec.name>,
        Greg Kroah-Hartman <gregkh@suse.de>,
        v9fs-developer@lists.sourceforge.net, linux-afs@lists.infradead.org,
        codalist@TELEMANN.coda.cs.cmu.edu,
        jfs-discussion@lists.sourceforge.net, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/1] fix d_revalidate oopsen on NFS exports
Message-ID: <20111201053457.GA7154@onthe.net.au>
References: <20111130071319.GA16711@onthe.net.au>
 <1321861008-20611-1-git-send-email-chris@onthe.net.au>
 <20111129082501.GA569@onthe.net.au>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430C3CBC20@SACMVEXC2-PRD.hq.netapp.com>
 <24960.1322643283@redhat.com>
 <20111201004709.GA26085@onthe.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111201004709.GA26085@onthe.net.au>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 01, 2011 at 11:47:09AM +1100, Chris Dunlop wrote:
> On Wed, Nov 30, 2011 at 08:54:43AM +0000, David Howells wrote:
>> Chris Dunlop <chris@onthe.net.au> wrote:
>> 
>>> To avoid other people further wasting their and your time on
>>> exactly the same thing future, how something like the following
>>> patch, based on your comment in:
>>> 
>>> http://article.gmane.org/gmane.linux.nfs/40370
>>> 
>>> ...and, if that's acceptable, is it worthwhile doing for the
>>> other file systems which are likewise currently vulnerable when
>>> abused by broken layered file systems?
>> 
>> It's also worth printing a message - this *is* a kernel bug of some description
>> if it happens.
> 
> Like the below?  This covers the d_revalidate for 9p, afs, coda,
> hfs, ncpfs, proc, sysfs.

...and nfs.

> ----------------------------------------------------------------------
> Don't oops when abused by broken layered file systems
> 
> Signed-off-by: Chris Dunlop <chris@onthe.net.au>
> ---
>  fs/9p/vfs_dentry.c    |    6 ++++++
>  fs/afs/dir.c          |    6 ++++++
>  fs/coda/dir.c         |    6 ++++++
>  fs/hfs/sysdep.c       |    6 ++++++
>  fs/ncpfs/dir.c        |    6 ++++++
>  fs/nfs/dir.c          |   12 ++++++++++++
>  fs/proc/proc_sysctl.c |    5 +++++
>  fs/sysfs/dir.c        |    6 ++++++
>  8 files changed, 53 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/9p/vfs_dentry.c b/fs/9p/vfs_dentry.c
> index e022890..3b082dc 100644
> --- a/fs/9p/vfs_dentry.c
> +++ b/fs/9p/vfs_dentry.c
> @@ -106,6 +106,12 @@ static int v9fs_lookup_revalidate(struct dentry *dentry, struct nameidata *nd)
>  	struct inode *inode;
>  	struct v9fs_inode *v9inode;
>  
> +	if (!nd) {
> +		printk(KERN_ERR "v9fs_lookup_revalidate:"
> +		       " called from layered filesystem without intents\n");
> +		return -EIO;
> +	}
> +
>  	if (nd->flags & LOOKUP_RCU)
>  		return -ECHILD;
>  
> diff --git a/fs/afs/dir.c b/fs/afs/dir.c
> index 1b0b195..4003d76 100644
> --- a/fs/afs/dir.c
> +++ b/fs/afs/dir.c
> @@ -607,6 +607,12 @@ static int afs_d_revalidate(struct dentry *dentry, struct nameidata *nd)
>  	void *dir_version;
>  	int ret;
>  
> +	if (!nd) {
> +		printk(KERN_ERR "afs_d_revalidate:"
> +		       " called from layered filesystem without intents\n");
> +		return -EIO;
> +	}
> +
>  	if (nd->flags & LOOKUP_RCU)
>  		return -ECHILD;
>  
> diff --git a/fs/coda/dir.c b/fs/coda/dir.c
> index 0239433..ede8e77 100644
> --- a/fs/coda/dir.c
> +++ b/fs/coda/dir.c
> @@ -544,6 +544,12 @@ static int coda_dentry_revalidate(struct dentry *de, struct nameidata *nd)
>  	struct inode *inode;
>  	struct coda_inode_info *cii;
>  
> +	if (!nd) {
> +		printk(KERN_ERR "coda_dentry_revalidate:"
> +		       " called from layered filesystem without intents\n");
> +		return -EIO;
> +	}
> +
>  	if (nd->flags & LOOKUP_RCU)
>  		return -ECHILD;
>  
> diff --git a/fs/hfs/sysdep.c b/fs/hfs/sysdep.c
> index 19cf291..b130d91 100644
> --- a/fs/hfs/sysdep.c
> +++ b/fs/hfs/sysdep.c
> @@ -18,6 +18,12 @@ static int hfs_revalidate_dentry(struct dentry *dentry, struct nameidata *nd)
>  	struct inode *inode;
>  	int diff;
>  
> +	if (!nd) {
> +		printk(KERN_ERR "hfs_revalidate_dentry:"
> +		       " called from layered filesystem without intents\n");
> +		return -EIO;
> +	}
> +
>  	if (nd->flags & LOOKUP_RCU)
>  		return -ECHILD;
>  
> diff --git a/fs/ncpfs/dir.c b/fs/ncpfs/dir.c
> index 9c51f62..6580d1d 100644
> --- a/fs/ncpfs/dir.c
> +++ b/fs/ncpfs/dir.c
> @@ -302,6 +302,12 @@ ncp_lookup_validate(struct dentry *dentry, struct nameidata *nd)
>  	if (dentry == dentry->d_sb->s_root)
>  		return 1;
>  
> +	if (!nd) {
> +		printk(KERN_ERR "ncp_lookup_validate:"
> +		       " called from layered filesystem without intents\n");
> +		return -EIO;
> +	}
> +
>  	if (nd->flags & LOOKUP_RCU)
>  		return -ECHILD;
>  
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index b238d95..51b3d54 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -1103,6 +1103,12 @@ static int nfs_lookup_revalidate(struct dentry *dentry, struct nameidata *nd)
>  	struct nfs_fattr *fattr = NULL;
>  	int error;
>  
> +	if (!nd) {
> +		printk(KERN_ERR "nfs_lookup_revalidate:"
> +		       " called from layered filesystem without intents\n");
> +		return -EIO;
> +	}
> +
>  	if (nd->flags & LOOKUP_RCU)
>  		return -ECHILD;
>  
> @@ -1508,6 +1514,12 @@ static int nfs_open_revalidate(struct dentry *dentry, struct nameidata *nd)
>  	struct nfs_open_context *ctx;
>  	int openflags, ret = 0;
>  
> +	if (!nd) {
> +		printk(KERN_ERR "nfs_open_revalidate:"
> +		       " called from layered filesystem without intents\n");
> +		return -EIO;
> +	}
> +
>  	if (nd->flags & LOOKUP_RCU)
>  		return -ECHILD;
>  
> diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
> index 1a77dbe..20ef3ab 100644
> --- a/fs/proc/proc_sysctl.c
> +++ b/fs/proc/proc_sysctl.c
> @@ -389,6 +389,11 @@ static const struct inode_operations proc_sys_dir_operations = {
>  
>  static int proc_sys_revalidate(struct dentry *dentry, struct nameidata *nd)
>  {
> +	if (!nd) {
> +		printk(KERN_ERR "proc_sys_revalidate:"
> +		       " called from layered filesystem without intents\n");
> +		return -EIO;
> +	}
>  	if (nd->flags & LOOKUP_RCU)
>  		return -ECHILD;
>  	return !PROC_I(dentry->d_inode)->sysctl->unregistering;
> diff --git a/fs/sysfs/dir.c b/fs/sysfs/dir.c
> index ea9120a..6373450 100644
> --- a/fs/sysfs/dir.c
> +++ b/fs/sysfs/dir.c
> @@ -242,6 +242,12 @@ static int sysfs_dentry_revalidate(struct dentry *dentry, struct nameidata *nd)
>  	struct sysfs_dirent *sd;
>  	int is_dir;
>  
> +	if (!nd) {
> +		printk(KERN_ERR "sysfs_dentry_revalidate:"
> +		       " called from layered filesystem without intents\n");
> +		return -EIO;
> +	}
> +
>  	if (nd->flags & LOOKUP_RCU)
>  		return -ECHILD;
>  
> -- 
> 1.7.0.4
> 
> ----------------------------------------------------------------------
