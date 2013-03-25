Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58090 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932521Ab3CYSNP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Mar 2013 14:13:15 -0400
Date: Mon, 25 Mar 2013 14:13:14 -0400
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] mountd: regression in crossmounts
Message-ID: <20130325181314.GA10120@fieldses.org>
References: <1364049149-3751-1-git-send-email-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1364049149-3751-1-git-send-email-steved@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Mar 23, 2013 at 10:32:29AM -0400, Steve Dickson wrote:
> commit 8e2fb3fc cause a regression in mount export
> that are on different local file system.
> Exports like (all on different filesystems)
> 
> /home *(rw,fsid=0,crossmnt)
> /home/fs1 *(rw,crossmnt)
> /home/fs1/fs2/fs3 *(rw,nohide)
> 
> and then a mount of the root 'mount /home /mnt'
> would end up mounting /home/fs1/fs2/fs3 not /home

That's strange.

> Reverting the logic of commit 8e2fb3fc until
> a better solution can be found for the original
> problem.

I can't figure out why the patch below would help.  The only change I
can see is to the way that an export of "/" would be handled.

--b.

> 
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  utils/mountd/cache.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> index c8aa46f..978698d 100644
> --- a/utils/mountd/cache.c
> +++ b/utils/mountd/cache.c
> @@ -371,8 +371,11 @@ export_matches(nfs_export *exp, char *dom, char *path, struct addrinfo *ai)
>  static bool subexport(struct exportent *e1, struct exportent *e2)
>  {
>  	char *p1 = e1->e_path, *p2 = e2->e_path;
> +	size_t l2 = strlen(p2);
> +
>  	return e2->e_flags & NFSEXP_CROSSMOUNT
> -		&& is_subdirectory(p1, p2);
> +		&& strncmp(p1, p2, l2) == 0
> +		&& p1[l2] == '/';
>  }
>  
>  struct parsed_fsid {
> -- 
> 1.8.1.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
