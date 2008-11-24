From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] NLM: client-side nlm_lookup_host() should avoid
	matching on srcaddr
Date: Mon, 24 Nov 2008 14:31:57 -0500
Message-ID: <20081124193157.GB13323@fieldses.org>
References: <20081124175112.2828.84326.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:44183 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752878AbYKXTb7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Nov 2008 14:31:59 -0500
In-Reply-To: <20081124175112.2828.84326.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 24, 2008 at 12:51:55PM -0500, Chuck Lever wrote:
> Since commit c98451bd, the loop in nlm_lookup_host() unconditionally
> compares the host's h_srcaddr field to the incoming source address.
> For client-side nlm_host entries, both are always AF_UNSPEC, so this
> check is unnecessary.
> 
> Since commit 781b61a6, which added support for AF_INET6 addresses to
> nlm_cmp_addr(), nlm_cmp_addr() now returns FALSE for AF_UNSPEC
> addresses, which causes nlm_lookup_host() to create a fresh nlm_host
> entry every time it is called on the client.
> 
> These extra entries will eventually expire once the server is
> unmounted, so the impact of this regression, introduced with lockd
> IPv6 support in 2.6.28, should be minor.
> 
> We could fix this by adding an arm in nlm_cmp_addr() for AF_UNSPEC
> addresses, but really, nlm_lookup_host() shouldn't be matching on the
> srcaddr field for client-side nlm_host lookups.

Applied, thanks.

(Possible future improvement: names like memcmp() have left me
terminally confused about what the return value from a function like
nlm_cmp_addr() is likely to mean--I always have to check the
implementation.  A name like nlm_same_addr() would make them
unambiguous.)

--b.

> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/lockd/host.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/lockd/host.c b/fs/lockd/host.c
> index 9fd8889..70fc63a 100644
> --- a/fs/lockd/host.c
> +++ b/fs/lockd/host.c
> @@ -167,7 +167,8 @@ static struct nlm_host *nlm_lookup_host(struct nlm_lookup_host_info *ni)
>  			continue;
>  		if (host->h_server != ni->server)
>  			continue;
> -		if (!nlm_cmp_addr(nlm_srcaddr(host), ni->src_sap))
> +		if (ni->server &&
> +		    !nlm_cmp_addr(nlm_srcaddr(host), ni->src_sap))
>  			continue;
>  
>  		/* Move to head of hash chain. */
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
