Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:31633 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752476AbaAQKKR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Jan 2014 05:10:17 -0500
Subject: Re: [PATCH] dcache: fix d_splice_alias handling of aliases
From: Steven Whitehouse <swhiteho@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Bob Peterson <rpeterso@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, Miklos Szeredi <mszeredi@suse.cz>
In-Reply-To: <20140116185107.GE16829@fieldses.org>
References: <20140115151749.GF23999@fieldses.org>
	 <20140116161015.GC16829@fieldses.org> <1389888942.2779.34.camel@menhir>
	 <20140116164411.GD16829@fieldses.org>
	 <1875464309.3327883.1389891247171.JavaMail.root@redhat.com>
	 <20140116185107.GE16829@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 17 Jan 2014 10:04:30 +0000
Message-ID: <1389953070.2734.17.camel@menhir>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

On Thu, 2014-01-16 at 13:51 -0500, J. Bruce Fields wrote:
> On Thu, Jan 16, 2014 at 11:54:07AM -0500, Bob Peterson wrote:
> > ----- Original Message -----
> > | Something like this?
> > (snip)
> > | @@ -779,6 +782,11 @@ static struct dentry *__gfs2_lookup(struct inode *dir,
> > | struct dentry *dentry,
> > |  	}
> > |  
> > |  	d = d_splice_alias(inode, dentry);
> > | +	if (IS_ERR(d)) {
> > | +		iput(inode);
> > | +		gfs2_glock_dq_uninit(&gh);
> > | +		return ERR_PTR(error);
> > 
> > ---------------------------------^
> > Shouldn't that be ERR_PTR(d)?
> 
> Oops, yeah--well, actually just "d" I guess.
> 
> This is what I've got for what it's worth.
> 
> --b.
> 

I think the patch looks ok to me. Did you give it a spin to test it? If
so then I will put it in the GFS2 -nmw tree,

Steve.

> commit 6fba5295019b52a03d76c9e9570952466051a7a6
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Thu Jan 16 11:44:53 2014 -0500
> 
>     gfs2: revert "GFS2: d_splice_alias() can't return error"
>     
>     0d0d110720d7960b77c03c9f2597faaff4b484ae asserts that "d_splice_alias()
>     can't return error unless it was given an IS_ERR(inode)".
>     
>     That was true of the implementation of d_splice_alias, but this is
>     really a problem with d_splice_alias: at a minimum it should be able to
>     return -ELOOP in the case where inserting the given dentry would cause a
>     directory loop.
>     
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> diff --git a/fs/gfs2/inode.c b/fs/gfs2/inode.c
> index 7119504..3f44902 100644
> --- a/fs/gfs2/inode.c
> +++ b/fs/gfs2/inode.c
> @@ -585,6 +585,9 @@ static int gfs2_create_inode(struct inode *dir, struct dentry *dentry,
>  	error = PTR_ERR(inode);
>  	if (!IS_ERR(inode)) {
>  		d = d_splice_alias(inode, dentry);
> +		error = PTR_ERR(d);
> +		if (IS_ERR(d))
> +			goto fail_gunlock;
>  		error = 0;
>  		if (file) {
>  			if (S_ISREG(inode->i_mode)) {
> @@ -779,6 +782,11 @@ static struct dentry *__gfs2_lookup(struct inode *dir, struct dentry *dentry,
>  	}
>  
>  	d = d_splice_alias(inode, dentry);
> +	if (IS_ERR(d)) {
> +		iput(inode);
> +		gfs2_glock_dq_uninit(&gh);
> +		return d;
> +	}
>  	if (file && S_ISREG(inode->i_mode))
>  		error = finish_open(file, dentry, gfs2_open_common, opened);
>  


