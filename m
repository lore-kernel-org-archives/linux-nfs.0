Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:47138 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750764Ab1CFFxB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 6 Mar 2011 00:53:01 -0500
Date: Sun, 6 Mar 2011 16:52:42 +1100
From: NeilBrown <neilb@suse.de>
To: Jesper Juhl <jj@chaosbits.net>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] NFSD, VFS: Remove dead code in nfsd_rename()
Message-ID: <20110306165242.0cafd68a@notabene.brown>
In-Reply-To: <alpine.LNX.2.00.1103060024380.6297@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1103060024380.6297@swampdragon.chaosbits.net>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, 6 Mar 2011 00:30:35 +0100 (CET) Jesper Juhl <jj@chaosbits.net> wrote:

> Currently we have the following code in fs/nfsd/vfs.c::nfsd_rename() :
> 
> 	...
> 	host_err = nfsd_break_lease(odentry->d_inode);
> 	if (host_err)
> 		goto out_drop_write;
> 	if (ndentry->d_inode) {
> 		host_err = nfsd_break_lease(ndentry->d_inode);
> 		if (host_err)
> 			goto out_drop_write;
> 	}
> 	if (host_err)
> 		goto out_drop_write;
> 	...
> 
> 'host_err' is guaranteed to be 0 by the time we test 'ndentry->d_inode'. 
> If 'host_err' becomes != 0 inside the 'if' statement, then we goto 
> 'out_drop_write'. So, after the 'if' statement there is no way that 
> 'host_err' can be anything but 0, so the test afterwards is just dead 
> code.
> This patch removes the dead code.

I would probably have gone for:

  host_err = nfsd_break_lease(odentry->d_inode);
  if (!host_err && ndentry->d_inode)
        host_err = nfsd_break_lease(ndentry->d_inode);
  if (host_err)
        goto out_drop_write;

or even
  host_err = nfsd_break_lease(odentry->d_inode);
  if (ndentry->d_inode)
        host_err = hosterr ?: nfsd_break_lease(ndentry->d_inode);
  if (host_err)
        goto out_drop_write;


but it is largely a matter of taste.  I agree there is redundant code there
and your's is a suitable fix.

NeilBrown

> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>
> ---
>  vfs.c |    2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index da1d970..9cc626b 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -1749,8 +1749,6 @@ nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char *fname, int flen,
>  		if (host_err)
>  			goto out_drop_write;
>  	}
> -	if (host_err)
> -		goto out_drop_write;
>  	host_err = vfs_rename(fdir, odentry, tdir, ndentry);
>  	if (!host_err) {
>  		host_err = commit_metadata(tfhp);
> 
> 

