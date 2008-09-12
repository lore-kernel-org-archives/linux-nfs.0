From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 6/7] lockd: Combine __nsm_find() and nsm_find().
Date: Fri, 12 Sep 2008 17:56:37 -0400
Message-ID: <20080912215637.GF22126@fieldses.org>
References: <20080903183411.16867.33715.stgit@ingres.1015granger.net> <20080903183615.16867.58815.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:45823 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754951AbYILV4j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Sep 2008 17:56:39 -0400
In-Reply-To: <20080903183615.16867.58815.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 03, 2008 at 02:36:16PM -0400, Chuck Lever wrote:
> Clean up: Having two separate functions doesn't add clarity, so
> eliminate one of them.

Yeah, agreed, there's no way to guess what the difference between
__nsm_find(...,0) and nsm_find(...) is without looking up the prototype,
so why bother?--there's no loss here in just using nsm_find(...,0) and
nsm_find(...,1) instead.

That said, with a couple wrappers, say nsm_lookup() and nsm_create(),
you might be able to save the reader the trouble of having to go look at
the implementation.

Up to you.  I'll apply this and you can send an incremental patch if you
want.

--b.

> Use contemporary kernel coding conventions
> where appropriate.

> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/lockd/host.c |   32 +++++++++++---------------------
>  1 files changed, 11 insertions(+), 21 deletions(-)
> 
> diff --git a/fs/lockd/host.c b/fs/lockd/host.c
> index 1f9d72a..b9eeafe 100644
> --- a/fs/lockd/host.c
> +++ b/fs/lockd/host.c
> @@ -31,13 +31,11 @@ static unsigned long		next_gc;
>  static int			nrhosts;
>  static DEFINE_MUTEX(nlm_host_mutex);
>  
> -
>  static void			nlm_gc_hosts(void);
> -static struct nsm_handle *	__nsm_find(const struct sockaddr_in *,
> -					const char *, unsigned int, int);
> -static struct nsm_handle *	nsm_find(const struct sockaddr_in *sin,
> -					 const char *hostname,
> -					 unsigned int hostname_len);
> +static struct nsm_handle	*nsm_find(const struct sockaddr_in *sin,
> +						const char *hostname,
> +						const size_t hostname_len,
> +						const int create);
>  
>  /*
>   * Hash function must work well on big- and little-endian platforms
> @@ -187,7 +185,7 @@ static struct nlm_host *nlm_lookup_host(int server,
>  		atomic_inc(&nsm->sm_count);
>  	else {
>  		host = NULL;
> -		nsm = nsm_find(sin, hostname, hostname_len);
> +		nsm = nsm_find(sin, hostname, hostname_len, 1);
>  		if (!nsm) {
>  			dprintk("lockd: nlm_lookup_host failed; "
>  				"no nsm handle\n");
> @@ -419,8 +417,7 @@ void nlm_host_rebooted(const struct sockaddr_in *sin,
>  	struct nsm_handle *nsm;
>  	struct nlm_host	*host;
>  
> -	/* Find the NSM handle for this peer */
> -	nsm = __nsm_find(sin, hostname, hostname_len, 0);
> +	nsm = nsm_find(sin, hostname, hostname_len, 0);
>  	if (nsm == NULL) {
>  		dprintk("lockd: never saw rebooted peer '%.*s' before\n",
>  				hostname_len, hostname);
> @@ -560,10 +557,10 @@ nlm_gc_hosts(void)
>  static LIST_HEAD(nsm_handles);
>  static DEFINE_SPINLOCK(nsm_lock);
>  
> -static struct nsm_handle *
> -__nsm_find(const struct sockaddr_in *sin,
> -		const char *hostname, unsigned int hostname_len,
> -		int create)
> +static struct nsm_handle *nsm_find(const struct sockaddr_in *sin,
> +				   const char *hostname,
> +				   const size_t hostname_len,
> +				   const int create)
>  {
>  	struct nsm_handle *nsm = NULL;
>  	struct nsm_handle *pos;
> @@ -575,7 +572,7 @@ __nsm_find(const struct sockaddr_in *sin,
>  		if (printk_ratelimit()) {
>  			printk(KERN_WARNING "Invalid hostname \"%.*s\" "
>  					    "in NFS lock request\n",
> -				hostname_len, hostname);
> +				(int)hostname_len, hostname);
>  		}
>  		return NULL;
>  	}
> @@ -623,13 +620,6 @@ found:
>  	return nsm;
>  }
>  
> -static struct nsm_handle *
> -nsm_find(const struct sockaddr_in *sin, const char *hostname,
> -	 unsigned int hostname_len)
> -{
> -	return __nsm_find(sin, hostname, hostname_len, 1);
> -}
> -
>  /*
>   * Release an NSM handle
>   */
> 
