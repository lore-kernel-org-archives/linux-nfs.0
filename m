Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52116 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752325AbaHKTIj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Aug 2014 15:08:39 -0400
Date: Mon, 11 Aug 2014 15:08:38 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Ross Lagerwall <rosslagerwall@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd3: Check write permission after checking existence
Message-ID: <20140811190838.GE9095@fieldses.org>
References: <1407591840-19080-1-git-send-email-rosslagerwall@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1407591840-19080-1-git-send-email-rosslagerwall@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Aug 09, 2014 at 02:44:00PM +0100, Ross Lagerwall wrote:
> When creating a file that already exists in a read-only directory with
> O_EXCL, the NFSv3 server returns EACCES rather than EEXIST (which local
> files and the NFSv4 server return).  Fix this by checking the MAY_CREATE
> permission only if the file does not exist.  Since this already happens
> in do_nfsd_create, the check in nfsd3_proc_create can simply be removed.

Thanks.

>From a look at the history I believe the server has behaved this way
since the beginning.  Is this creating a practical problem for you?  How
did you notice it?

Inclined to apply it just for consistency as you suggest.  And because
it removes some unnecessary code.  But as a low priority: for 3.18 and
not stable.

--b.

> 
> Signed-off-by: Ross Lagerwall <rosslagerwall@gmail.com>
> ---
>  fs/nfsd/nfs3proc.c | 5 -----
>  1 file changed, 5 deletions(-)
> 
> diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
> index 4012899..8ebd4ac 100644
> --- a/fs/nfsd/nfs3proc.c
> +++ b/fs/nfsd/nfs3proc.c
> @@ -227,11 +227,6 @@ nfsd3_proc_create(struct svc_rqst *rqstp, struct nfsd3_createargs *argp,
>  	newfhp = fh_init(&resp->fh, NFS3_FHSIZE);
>  	attr   = &argp->attrs;
>  
> -	/* Get the directory inode */
> -	nfserr = fh_verify(rqstp, dirfhp, S_IFDIR, NFSD_MAY_CREATE);
> -	if (nfserr)
> -		RETURN_STATUS(nfserr);
> -
>  	/* Unfudge the mode bits */
>  	attr->ia_mode &= ~S_IFMT;
>  	if (!(attr->ia_valid & ATTR_MODE)) { 
> -- 
> 2.0.3
> 
