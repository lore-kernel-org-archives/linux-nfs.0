Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:56776 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751953AbdK0UKD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 27 Nov 2017 15:10:03 -0500
Date: Mon, 27 Nov 2017 15:10:03 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Thiago Rafael Becker <thiago.becker@gmail.com>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH] sunrpc: sort groups on unix_gid_parse
Message-ID: <20171127201003.GA25662@fieldses.org>
References: <20171127192508.12751-1-thiago.becker@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20171127192508.12751-1-thiago.becker@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks for the patch:

On Mon, Nov 27, 2017 at 05:25:08PM -0200, Thiago Rafael Becker wrote:
> In cases were mountd is managing the group membership for nfsd,
> if a user has several groups, multiple nfsd threads may call
> sort_groups for the same freshly created unix_gid_cache entry
> simultaneously, causing entries to be overwritten and the cache
> entry to get corrupted.

The groups_sort call is in set_groups, called from
fs/nfsd/auth.c:nfsd_setuser():

	set_groups(new, gi);

where "gi" is usually (in the absence of id squashing) a pointer to
rqstp->rq_cred.cr_group_info, which can be in use by other threads.

To me it's pretty unintuitive that set_groups() would modify the group
info passed in the second argument.  While we're here, I wonder if we
should make that the caller's responsibility?  There are basically only
three callers outside this one.

But I'm OK with this patch.  I probably need an OK from a vfs person to
take it through the nfsd tree?

--b.

> This eventually leads to the server
> replying to the client with a bogus EPERM error if the group
> overwritten is the group that would allow access.
> 
> This is a very hard bug to analyze, as a very slight change in
> timing leads to proper sorting behavior. It was first noticed
> and reproduced in kernel 3.10.0, which uses shell sort to sort
> groups. Nothing indicates that heapsort, which is used
> upstream, is thread safe.
> 
> This patch solves this issue by sorting the cache entry before
> inserting it into the cache, and thus next entries will not
> have to sort it again, avoiding the issue altogether.
> 
> Signed-off-by: Thiago Rafael Becker <thiago.becker@gmail.com>
> ---
>  kernel/groups.c           | 4 +++-
>  net/sunrpc/svcauth_unix.c | 7 +++++++
>  2 files changed, 10 insertions(+), 1 deletion(-)
> 
> diff --git a/kernel/groups.c b/kernel/groups.c
> index e357bc8..4c9c9ed 100644
> --- a/kernel/groups.c
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
>  /* a simple bsearch */
>  int groups_search(const struct group_info *group_info, kgid_t grp)
> diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
> index f81eaa8..91e3d34 100644
> --- a/net/sunrpc/svcauth_unix.c
> +++ b/net/sunrpc/svcauth_unix.c
> @@ -20,6 +20,7 @@
>  
>  
>  #include "netns.h"
> +void groups_sort(struct group_info *group_info);
>  
>  /*
>   * AUTHUNIX and AUTHNULL credentials are both handled here.
> @@ -520,6 +521,12 @@ static int unix_gid_parse(struct cache_detail *cd,
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
> -- 
> 2.9.5
