Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49100 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752431AbcK2GnJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 29 Nov 2016 01:43:09 -0500
Date: Tue, 29 Nov 2016 14:43:06 +0800
From: Eryu Guan <eguan@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Andreas Dilger <adilger@dilger.ca>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>, fstests@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] dirstress: Allow ESTALE as well as ENOENT
Message-ID: <20161129064306.GL22989@eguan.usersys.redhat.com>
References: <20161123222054.GA7900@fieldses.org>
 <35420A4E-1698-4743-9523-CBF43F2A2DC6@dilger.ca>
 <20161125034706.GA20729@fieldses.org>
 <20161125113511.GI4609@eguan.usersys.redhat.com>
 <20161126013901.GA32632@fieldses.org>
 <20161126013939.GB32632@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20161126013939.GB32632@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 25, 2016 at 08:39:39PM -0500, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> In the NFS case an attempt to chdir out of a removed directory could result
> in ESTALE, and that should not cause the test to fail.
> 
> This was causing intermittent failures on generic/011 on NFS.
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  src/dirstress.c | 12 ++++++++----
>  1 file changed, 8 insertions(+), 4 deletions(-)
> 
> diff --git a/src/dirstress.c b/src/dirstress.c
> index f8f73553a1bc..33a166c51819 100644
> --- a/src/dirstress.c
> +++ b/src/dirstress.c
> @@ -203,8 +203,10 @@ dirstress(
>          if (verbose) fprintf(stderr,"** [%d] chdir ..\n", pid);
>  	error = chdir("..");
>  	if (error) {
> -		/* If this is multithreaded, then expecting a ENOENT here is fine */
> -		if (nprocs_per_dir > 1 && errno == ENOENT) {
> +		/* If this is multithreaded, then expecting a ENOENT here is fine,
> +		 * and ESTALE is normal in the NFS case. */
> +		if (nprocs_per_dir > 1 &&
> +				(errno == ENOENT || errno = ESTALE)) {
                                                         ^^^ this should be ==
>  			return 0;
>  		}
>  
> @@ -224,8 +226,10 @@ dirstress(
>          if (verbose) fprintf(stderr,"** [%d] chdir ..\n", pid);
>  	error = chdir("..");
>  	if (error) {
> -		/* If this is multithreaded, then expecting a ENOENT here is fine */
> -		if (nprocs_per_dir > 1 && errno == ENOENT) {
> +		/* If this is multithreaded, then expecting a ENOENT here is fine,
> +		 * and ESTALE is normal in the NFS case. */
> +		if (nprocs_per_dir > 1 &&
> +				(errno == ENOENT || errno = ESTALE)) {
                                                         ^^^ same here

I can fix them at commit time, no resend is needed.

Thanks,
Eryu

>  			return 0;
>  		}
>  
> -- 
> 2.9.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe fstests" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
