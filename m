Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25700 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752163Ab0JHXmH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Oct 2010 19:42:07 -0400
Date: Fri, 8 Oct 2010 19:41:30 -0400
From: Valerie Aurora <vaurora@redhat.com>
To: David Howells <dhowells@redhat.com>
Cc: viro@ftp.linux.org.uk, jmoyer@redhat.com, linux-fs@vger.kernel.org,
        autofs@linux.kernel.org, linux-kernel@vger.kernel.org,
        linux-afs@lists.infradead.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, Ian Kent <raven@themaw.net>
Subject: Re: [PATCH 05/17] Remove the automount through follow_link() kludge code from pathwalk
Message-ID: <20101008234130.GE30846@shell>
References: <20100930181455.30939.53914.stgit@warthog.procyon.org.uk> <20100930181521.30939.31415.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100930181521.30939.31415.stgit@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Sep 30, 2010 at 07:15:21PM +0100, David Howells wrote:
> Remove the automount through follow_link() kludge code from pathwalk in favour
> of using d_automount().
> 
> Signed-off-by: David Howells <dhowells@redhat.com>
> Acked-by: Ian Kent <raven@themaw.net>
> ---
> 
>  fs/namei.c |   17 +++--------------
>  1 files changed, 3 insertions(+), 14 deletions(-)
> 
> diff --git a/fs/namei.c b/fs/namei.c
> index c50b9d7..86421f9 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -861,17 +861,6 @@ fail:
>  }
>  
>  /*
> - * This is a temporary kludge to deal with "automount" symlinks; proper
> - * solution is to trigger them on follow_mount(), so that do_lookup()
> - * would DTRT.  To be killed before 2.6.34-final.
> - */
> -static inline int follow_on_final(struct inode *inode, unsigned lookup_flags)
> -{
> -	return inode && unlikely(inode->i_op->follow_link) &&
> -		((lookup_flags & LOOKUP_FOLLOW) || S_ISDIR(inode->i_mode));
> -}
> -
> -/*
>   * Name resolution.
>   * This is the basic name resolution function, turning a pathname into
>   * the final dentry. We expect 'base' to be positive and a directory.
> @@ -991,7 +980,8 @@ last_component:
>  		if (err)
>  			break;
>  		inode = next.dentry->d_inode;
> -		if (follow_on_final(inode, lookup_flags)) {
> +		if (inode && unlikely(inode->i_op->follow_link) &&
> +		    (lookup_flags & LOOKUP_FOLLOW)) {
>  			err = do_follow_link(&next, nd);
>  			if (err)
>  				goto return_err;
> @@ -1882,8 +1872,7 @@ reval:
>  		struct inode *inode = path.dentry->d_inode;
>  		void *cookie;
>  		error = -ELOOP;
> -		/* S_ISDIR part is a temporary automount kludge */
> -		if (!(nd.flags & LOOKUP_FOLLOW) && !S_ISDIR(inode->i_mode))
> +		if (!(nd.flags & LOOKUP_FOLLOW))
>  			goto exit_dput;
>  		if (count++ == 32)
>  			goto exit_dput;

While you're removing kludges, I bet you can also remove this from
__follow_link():

       if (path->mnt != nd->mnt) {
               path_to_nameidata(path, nd);
               dget(dentry);
       }
       mntget(path->mnt);

And replace with:

       if (path->mnt == nd->mnt)
               mntget(path->mnt);

This reverts the non-helper-function parts of
051d381259eb57d6074d02a6ba6e90e744f1a29f, which breaks union mounts.

-VAL
