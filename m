From: "J.Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] - avoid permission checks on EXCLUSIVE_CREATE replay
Date: Thu, 22 Apr 2010 12:25:33 -0400
Message-ID: <20100422162533.GH5926@fieldses.org>
References: <20100422101042.226f71d6@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52646 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754326Ab0DVQZe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Apr 2010 12:25:34 -0400
In-Reply-To: <20100422101042.226f71d6-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 22, 2010 at 10:10:42AM +1000, Neil Brown wrote:
> 
> With NFSv4, if we create a file then open it we explicit avoid checking the
> permissions on the file during the open because the fact that we created it
> ensures we should be allow to open it (the create and the open should appear
> to be a single operation).
> 
> However if the reply to an EXCLUSIVE create gets lots and the client resends
> the create, the current code will perform the permission check - because it
> doesn't realise that it did the open already..
> 
> This patch should fix this.

Thanks, but: hm, does this leave a loophole for a clever attacker?
They'll still have to get past the initial

	fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE)

but that just checks the parent directory; if the existing file is
actually owned by someone else, do we allow an open that we shouldn't?

Maybe when "created" is set we should keep the permission check but add
NFSD_ALLOW_OWNER_OVERRIDE?

--b.

> 
> Note that I haven't actually seen this cause a problem.  I was just looking
> at the code trying to figure out a different EXCLUSIVE open related issue,
> and this looked wrong.
> 
> NeilBrown
> 
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 6dd5f19..ec40b36 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -1451,8 +1451,11 @@ nfsd_create_v3(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  		case NFS3_CREATE_EXCLUSIVE:
>  			if (   dchild->d_inode->i_mtime.tv_sec == v_mtime
>  			    && dchild->d_inode->i_atime.tv_sec == v_atime
> -			    && dchild->d_inode->i_size  == 0 )
> +			    && dchild->d_inode->i_size  == 0 ) {
> +				if (created)
> +					*created = 1;
>  				break;
> +			}
>  			 /* fallthru */
>  		case NFS3_CREATE_GUARDED:
>  			err = nfserr_exist;
