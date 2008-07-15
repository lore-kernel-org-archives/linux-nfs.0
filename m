From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 01/16] lockd: Pass "struct sockaddr *" to new
	failover-by-IP function
Date: Tue, 15 Jul 2008 16:12:58 -0400
Message-ID: <20080715201257.GA25803@fieldses.org>
References: <20080630225011.25407.61357.stgit@ellison.1015granger.net> <20080630225813.25407.29856.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:45412 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754730AbYGOUNK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jul 2008 16:13:10 -0400
In-Reply-To: <20080630225813.25407.29856.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 30, 2008 at 06:58:14PM -0400, Chuck Lever wrote:
> Pass a more generic socket address type to nlmsvc_unlock_all_by_ip() to
> allow for future support of IPv6.  Also provide additional sanity
> checking in failover_unlock_ip() when constructing the server's IP
> address.
> 
> As an added bonus, provide clean kerneldoc comments on related NLM
> interfaces which were recently added.

Looks good to me, thanks--applied, with one minor change:

> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/lockd/svcsubs.c          |   39 +++++++++++++++++++++++++--------------
>  fs/nfsd/nfsctl.c            |   15 ++++++++++-----
>  include/linux/lockd/lockd.h |    2 +-
>  3 files changed, 36 insertions(+), 20 deletions(-)
> 
> 
> diff --git a/fs/lockd/svcsubs.c b/fs/lockd/svcsubs.c
> index d1c48b5..723b6d5 100644
> --- a/fs/lockd/svcsubs.c
> +++ b/fs/lockd/svcsubs.c
> @@ -373,18 +373,18 @@ nlmsvc_free_host_resources(struct nlm_host *host)
>  	}
>  }
>  
> -/*
> - * Remove all locks held for clients
> +/**
> + * nlmsvc_invalidate_all - remove all locks held for clients
> + *
> + * Release all locks held by NFS clients.  Previously, the code
> + * would call nlmsvc_free_host_resources for each client in turn,
> + * which is about as inefficient as it gets.
> + *
> + * Now we just do it once in nlm_traverse_files.
>   */
>  void
>  nlmsvc_invalidate_all(void)
>  {
> -	/* Release all locks held by NFS clients.
> -	 * Previously, the code would call
> -	 * nlmsvc_free_host_resources for each client in
> -	 * turn, which is about as inefficient as it gets.
> -	 * Now we just do it once in nlm_traverse_files.
> -	 */

Mind if I keep the "Previously..." part in the body of the function?
I'd rather the kerneldoc comments be about the interface and leave
implementation details to the body of the function.

Also, one more minor question--

> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index 5ac00c4..5b4a412 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -310,9 +310,12 @@ static ssize_t write_getfd(struct file *file, char *buf, size_t size)
>  
>  static ssize_t failover_unlock_ip(struct file *file, char *buf, size_t size)
>  {
> -	__be32 server_ip;
> -	char *fo_path, c;
> +	struct sockaddr_in sin = {
> +		.sin_family	= AF_INET,
> +	};
>  	int b1, b2, b3, b4;
> +	char c;
> +	char *fo_path;
>  
>  	/* sanity check */
>  	if (size == 0)
> @@ -326,11 +329,13 @@ static ssize_t failover_unlock_ip(struct file *file, char *buf, size_t size)
>  		return -EINVAL;
>  
>  	/* get ipv4 address */
> -	if (sscanf(fo_path, "%u.%u.%u.%u%c", &b1, &b2, &b3, &b4, &c) != 4)
> +	if (sscanf(fo_path, NIPQUAD_FMT "%c", &b1, &b2, &b3, &b4, &c) != 4)
> +		return -EINVAL;
> +	if (b1 > 255 || b2 > 255 || b3 > 255 || b4 > 255)

Should b1, b2, b3, b4 be unsigned?

--b.

>  		return -EINVAL;
> -	server_ip = htonl((((((b1<<8)|b2)<<8)|b3)<<8)|b4);
> +	sin.sin_addr.s_addr = htonl((b1 << 24) | (b2 << 16) | (b3 << 8) | b4);
>  
> -	return nlmsvc_unlock_all_by_ip(server_ip);
> +	return nlmsvc_unlock_all_by_ip((struct sockaddr *)&sin);
>  }
