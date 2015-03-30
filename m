Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:46143 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752701AbbC3Oi2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2015 10:38:28 -0400
Date: Mon, 30 Mar 2015 16:38:23 +0200
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] debugfs: debugfs_create_* shouldn't be checking
 permissions
Message-ID: <20150330143823.GA10992@kroah.com>
References: <20150330142310.GB6901@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150330142310.GB6901@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 30, 2015 at 10:23:10AM -0400, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> Subject: [PATCH] debugfs: debugfs_create_* shouldn't be checking permissions
> 
> Debugfs files and and directories are created by kernel subsystems not
> directly by users, so we shouldn't be using lookup_one_len, which checks
> permissions.
> 
> This was causing krb5 mounts to fail to Fedora servers using gss-proxy
> if selinux was enabled, on kernels since 388f0c776781 "sunrpc: add a
> debugfs rpc_xprt directory with an info file in it", which creates a new
> debugfs directory for each new rpc client.

No kernel code should care / fail if a debugfs function fails, so please
fix up the sunrpc code first.



> 
> Reported-by: Anthony Messina <amessina@messinet.com>
> Reported-by: Jason Tibbits <tibbs@math.uh.edu>
> Cc: Jeff Layton <jlayton@primarydata.com>
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  fs/debugfs/inode.c | 17 +++++++++++++----
>  1 file changed, 13 insertions(+), 4 deletions(-)
> 
> I swiped this code fragment from net/sunrpc/rpc_pipe.c, and it's gotten
> only minimal testing.  (It does fix krb5 mounts, though.)
> 
> diff --git a/fs/debugfs/inode.c b/fs/debugfs/inode.c
> index 96400ab42d13..75e5daa6a63f 100644
> --- a/fs/debugfs/inode.c
> +++ b/fs/debugfs/inode.c
> @@ -251,6 +251,7 @@ static struct dentry *start_creating(const char *name, struct dentry *parent)
>  {
>  	struct dentry *dentry;
>  	int error;
> +	struct qstr q = QSTR_INIT(name, strlen(name));
>  
>  	pr_debug("debugfs: creating file '%s'\n",name);
>  
> @@ -268,11 +269,19 @@ static struct dentry *start_creating(const char *name, struct dentry *parent)
>  		parent = debugfs_mount->mnt_root;
>  
>  	mutex_lock(&parent->d_inode->i_mutex);
> -	dentry = lookup_one_len(name, parent, strlen(name));
> -	if (!IS_ERR(dentry) && dentry->d_inode) {
> +	dentry = d_hash_and_lookup(parent, &q);
> +	if (!dentry) {
> +		dentry = d_alloc(parent, &q);
> +		if (!dentry) {
> +			dentry = ERR_PTR(-ENOMEM);
> +			goto out;
> +		}
> +	}
> +	if (dentry->d_inode) {


No, I'd rather not "open code" lookup_one_len() if at all possible
please.

What exactly is the problem here that the sunrpc code is failing from?
Is it just interacting with selinux?  How is the debugfs code to blame
here?

thanks,

greg k-h
