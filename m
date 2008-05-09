From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] exportfs: fix incorrect EACCES in reconnect_path()
Date: Fri, 9 May 2008 00:34:25 -0400
Message-ID: <20080509043425.GD21408@fieldses.org>
References: <20080502151646.GA5515@janus> <20080502153439.GC7376@infradead.org> <20080502155617.GD18401@fieldses.org> <1209744293.8294.19.camel@heimdal.trondhjem.org> <20080502221216.GP21918@fieldses.org> <18462.17737.353976.999538@notabene.brown> <20080505174716.GA12814@fieldses.org> <18463.42978.531115.344884@notabene.brown> <20080506195041.GD13484@fieldses.org> <18466.28013.258338.485948@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Christoph Hellwig <hch@infradead.org>,
	Frank van Maarseveen <frankvm@frankvm.com>,
	Christoph Hellwig <hch@lst.de>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:37284 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750830AbYEIEev (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 May 2008 00:34:51 -0400
In-Reply-To: <18466.28013.258338.485948-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 08, 2008 at 01:03:09PM +1000, Neil Brown wrote:
> On Tuesday May 6, bfields@fieldses.org wrote:
> > On Tue, May 06, 2008 at 10:35:46AM +1000, Neil Brown wrote:
> > > 
> > > To fix the current bug properly, reconnect_path still needs to bypass
> > > normal permission checks even when subtree_check is in effect, so it
> > > can be sure of getting read permission on the parent directory.
> > 
> > OK, but why not just forget the subtree_check case?  It would be just
> > another item on the "reasons not to use subtree_check" list.
> 
> I guess so.
> 
> > 
> > If a fix for the subtree checking case were easy (or if someone else had
> > the time to do a very careful job of it), then fine, but maybe we should
> > just fix the easy case and leave the subtree checking as is for now.
> 
> So is this the proposed fix?  A bit ugly, but I guess it's OK.

Something like that, yep.  (Frank, can you confirm that this does the
job for you?)

It'd be nice if we could find a way to incorporate a little cleanup at
the same time, but I'm not sure exactly what to suggest.

--b.

> 
> NeilBrown
> 
> Signed-off-by: Neil Brown <neilb@suse.de>
> 
> ### Diffstat output
>  ./fs/nfsd/nfsfh.c |   29 ++++++++++++++++++++++++++---
>  1 file changed, 26 insertions(+), 3 deletions(-)
> 
> diff .prev/fs/nfsd/nfsfh.c ./fs/nfsd/nfsfh.c
> --- .prev/fs/nfsd/nfsfh.c	2008-05-06 10:06:59.000000000 +1000
> +++ ./fs/nfsd/nfsfh.c	2008-05-08 13:01:06.000000000 +1000
> @@ -176,9 +176,24 @@ static __be32 nfsd_set_fh_dentry(struct 
>  	if (IS_ERR(exp))
>  		return nfserrno(PTR_ERR(exp));
>  
> -	error = nfsd_setuser_and_check_port(rqstp, exp);
> -	if (error)
> -		goto out;
> +	if (exp->ex_flags & NFSEXP_NOSUBTREECHECK) {
> +		/* Elevate privileges so that the lack of 'r' or 'x'
> +		 * permission on some parent directory will
> +		 * not stop exportfs_decode_fh from being able
> +		 * to reconnect a directory into the dentry cache.
> +		 * The same problem can affect "SUBTREECHECK" exports,
> +		 * but as nfsd_acceptable depends on correct
> +		 * access control settings being in effect, we cannot
> +		 * fix that case easily - so though.
> +		 */
> +		current->cap_effective =
> +			cap_raise_nfsd_set(current->cap_effective,
> +					   current->cap_permitted);
> +	} else {
> +		error = nfsd_setuser_and_check_port(rqstp, exp);
> +		if (error)
> +			goto out;
> +	}
>  
>  	/*
>  	 * Look up the dentry using the NFS file handle.
> @@ -215,6 +230,14 @@ static __be32 nfsd_set_fh_dentry(struct 
>  		goto out;
>  	}
>  
> +	if (exp->ex_flags & NFSEXP_NOSUBTREECHECK) {
> +		error = nfsd_setuser_and_check_port(rqstp, exp);
> +		if (error) {
> +			dput(dentry);
> +			goto out;
> +		}
> +	}
> +
>  	if (S_ISDIR(dentry->d_inode->i_mode) &&
>  			(dentry->d_flags & DCACHE_DISCONNECTED)) {
>  		printk("nfsd: find_fh_dentry returned a DISCONNECTED directory: %s/%s\n",
