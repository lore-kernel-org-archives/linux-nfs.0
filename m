Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:43204 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752320AbdLKO1P (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Dec 2017 09:27:15 -0500
Date: Mon, 11 Dec 2017 06:27:08 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Thiago Rafael Becker <thiago.becker@gmail.com>
Cc: viro@zeniv.linux.org.uk, schwidefsky@de.ibm.com,
        bfields@fieldses.org, neilb@suse.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v4] kernel: make groups_sort calling a responsibility
 group_info allocators
Message-ID: <20171211142708.GA23284@bombadil.infradead.org>
References: <20171205140512.13349-1-thiago.becker@gmail.com>
 <20171211132806.16962-1-thiago.becker@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20171211132806.16962-1-thiago.becker@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 11, 2017 at 11:28:06AM -0200, Thiago Rafael Becker wrote:
> +++ b/fs/nfsd/auth.c
> @@ -60,6 +60,9 @@ int nfsd_setuser(struct svc_rqst *rqstp, struct svc_export *exp)
>  				gi->gid[i] = exp->ex_anon_gid;
>  			else
>  				gi->gid[i] = rqgi->gid[i];
> +
> +			/* Should be race free as long as each thread allocates a new gi */
> +			groups_sort(gi);
>  		}

Overlong line.  Would recommend:

			/* Each thread has its own gi, so no race */

> +++ b/kernel/groups.c
> @@ -86,11 +86,13 @@ static int gid_cmp(const void *_a, const void *_b)
>  	return gid_gt(a, b) - gid_lt(a, b);
>  }
>  
> -static void groups_sort(struct group_info *group_info)
> +void groups_sort(struct group_info *group_info)
>  {
>  	sort(group_info->gid, group_info->ngroups, sizeof(*group_info->gid),
>  	     gid_cmp, NULL);
>  }
> +EXPORT_SYMBOL(groups_sort);
> +
>  

Spurious extra line

> diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
> index 740b67d..7154dab 100644
> --- a/net/sunrpc/svcauth_unix.c
> +++ b/net/sunrpc/svcauth_unix.c
> @@ -520,6 +520,12 @@ static int unix_gid_parse(struct cache_detail *cd,
>  		ug.gi->gid[i] = kgid;
>  	}
>  
> +	/* Sort the groups before inserting this entry
> +	 * into the cache to avoid future corrutpions
> +	 * by multiple simultaneous attempts to sort this
> +	 * entry.
> +	 */
> +	groups_sort(ug.gi);
>  	ugp = unix_gid_lookup(cd, uid);
>  	if (ugp) {
>  		struct cache_head *ch;

Why comment this call and not the other ones?  I appreciate this is the
call-site where you discovered the bug, but that's not going to make it
special to someone who's reading this code in ten years time.  I would
leave this comment out entirely; it's just the new way we do things.

I can't find anything else to critique; nice job.
