Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56775 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753790AbaHKQIl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Aug 2014 12:08:41 -0400
Date: Mon, 11 Aug 2014 12:08:40 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/3] nfsd: allow find_any_file to return a fi_deleg_file
 reference
Message-ID: <20140811160840.GB9095@fieldses.org>
References: <1407594162-28342-1-git-send-email-jlayton@primarydata.com>
 <1407594162-28342-4-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1407594162-28342-4-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Aug 09, 2014 at 10:22:42AM -0400, Jeff Layton wrote:
> It's possible that we'll have a nfs4_file that has nothing in its fds
> array, but that has a populated fi_deleg_file field.

Is it really possible?  On a quick skim it looks like this is only used
in the presence of lock stateid's, when we should have an open.

OK with the cleanup I'm just not seeing a reason either one way or the
other for the fi_deleg_file change.

--b.

> Since that function
> is generally happy with any file reference, allow it to find and take
> a reference to it in that situation. Also, clean up find_any_file for
> better readability.
> 
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c | 19 ++++++++++++++-----
>  1 file changed, 14 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 4356d32479b2..5c5873811bd9 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -355,11 +355,20 @@ find_any_file(struct nfs4_file *f)
>  
>  	spin_lock(&f->fi_lock);
>  	ret = __nfs4_get_fd(f, O_RDWR);
> -	if (!ret) {
> -		ret = __nfs4_get_fd(f, O_WRONLY);
> -		if (!ret)
> -			ret = __nfs4_get_fd(f, O_RDONLY);
> -	}
> +	if (ret)
> +		goto out;
> +
> +	ret = __nfs4_get_fd(f, O_WRONLY);
> +	if (ret)
> +		goto out;
> +
> +	ret = __nfs4_get_fd(f, O_RDONLY);
> +	if (ret)
> +		goto out;
> +
> +	if (f->fi_deleg_file)
> +		ret = get_file(f->fi_deleg_file);
> +out:
>  	spin_unlock(&f->fi_lock);
>  	return ret;
>  }
> -- 
> 1.9.3
> 
