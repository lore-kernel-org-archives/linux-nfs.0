From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 1/4] NFS: Introduce nlm client setup function
Date: Thu, 03 Jan 2008 16:50:16 -0500
Message-ID: <1199397016.1913.12.camel@heimdal.trondhjem.org>
References: <20071220200358.3358.57402.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:60646 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752691AbYACVuV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Jan 2008 16:50:21 -0500
In-Reply-To: <20071220200358.3358.57402.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Thu, 2007-12-20 at 15:03 -0500, Chuck Lever wrote:
> Add a function that will handle mount-time NLM set up for the NFS client.
> 
> Note this patch also prevents NLM activation on a mount point when the
> server address is an IPv6 address, until such a time that the NLM
> supports IPv6.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/lockd/clntlock.c        |   45 ++++++++++++++++++++++++++++++++++++++++++++
>  include/linux/lockd/bind.h |    6 ++++++
>  2 files changed, 51 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/lockd/clntlock.c b/fs/lockd/clntlock.c
> index d070b18..9aeea53 100644
> --- a/fs/lockd/clntlock.c
> +++ b/fs/lockd/clntlock.c
> @@ -41,6 +41,51 @@ struct nlm_wait {
>  
>  static LIST_HEAD(nlm_blocked);
>  
> +/**
> + * nlmclnt_init - Set up per-NFS mount point lockd data structures
> + * @server_address: server's network address
> + * @server_addrlen: length of server's address
> + * @server_name: server's hostname
> + * @nfs_version: NFS protocol version for this mount point
> + * @protocol: transport protocol lockd should use
> + *
> + * Returns pointer to an appropriate nlm_host struct,
> + * or an error value.
> + */
> +struct nlm_host *nlmclnt_init(struct sockaddr *server_address,
> +			      size_t server_addrlen,
> +			      char *server_name, u32 nfs_version,
> +			      unsigned short protocol)
> +{
> +	struct nlm_host *host;
> +	u32 nlm_version;
> +	int status;
> +
> +	/* NLM doesn't support non-AF_INET addresses yet. */
> +	if (server_address->sa_family != AF_INET)
> +		return ERR_PTR(-EAFNOSUPPORT);
              ^^^^^^^^^^^^ Please could you make this a BUG_ON?

The address family needs to be checked in the mount parsing code, and
_only_ there.

> +	/* Assert client is not trying to use NLM for NFSv4 */
> +	if (nfs_version > 3)
> +		return ERR_PTR(-EPROTONOSUPPORT);
              ^^^^^^^^^^^^ Please could you make this a BUG_ON?

This isn't something that is _ever_ supposed to occur at runtime.

> +	status = lockd_up(protocol);
> +	if (status < 0)
> +		return ERR_PTR(status);
> +
> +	nlm_version = (nfs_version == 3) ? 4 : 1;
> +	host = nlmclnt_lookup_host((struct sockaddr_in *)server_address,
> +				   protocol, nlm_version,
> +				   server_name, strlen(server_name));
> +	if (host == NULL) {
> +		lockd_down();
> +		return ERR_PTR(-ENOLCK);
> +	}
> +
> +	return host;
> +}
> +EXPORT_SYMBOL(nlmclnt_init);
> +
>  /*
>   * Queue up a lock for blocking so that the GRANTED request can see it
>   */
> diff --git a/include/linux/lockd/bind.h b/include/linux/lockd/bind.h
> index 6f1637c..d8b7149 100644
> --- a/include/linux/lockd/bind.h
> +++ b/include/linux/lockd/bind.h
> @@ -35,6 +35,12 @@ extern struct nlmsvc_binding *	nlmsvc_ops;
>  /*
>   * Functions exported by the lockd module
>   */
> +extern struct nlm_host *nlmclnt_init(struct sockaddr *server_address,
> +					size_t server_addrlen,
> +					char *server_name,
> +					u32 nfs_version,
> +					unsigned short protocol);
> +
>  extern int	nlmclnt_proc(struct inode *, int, struct file_lock *);
>  extern int	lockd_up(int proto);
>  extern void	lockd_down(void);
> 

