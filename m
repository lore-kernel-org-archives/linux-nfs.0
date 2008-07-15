From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 02/16] lockd: address-family independent printable
	addresses
Date: Tue, 15 Jul 2008 16:25:16 -0400
Message-ID: <20080715202516.GB25803@fieldses.org>
References: <20080630225011.25407.61357.stgit@ellison.1015granger.net> <20080630225821.25407.58530.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:57392 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762680AbYGOUZb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jul 2008 16:25:31 -0400
In-Reply-To: <20080630225821.25407.58530.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 30, 2008 at 06:58:22PM -0400, Chuck Lever wrote:
> Knowing which source address is used for communicating with remote NLM
> services can be helpful for debugging configuration problems on hosts
> with multiple addresses.
> 
> Keep the dprintk debugging here, but adapt it so it displays AF_INET6
> addresses properly.  There are also a couple of dprintk clean-ups as
> well.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/lockd/host.c             |   79 +++++++++++++++++++++++++++++++------------
>  include/linux/lockd/lockd.h |    3 ++
>  2 files changed, 60 insertions(+), 22 deletions(-)
> 
> 
> diff --git a/fs/lockd/host.c b/fs/lockd/host.c
> index a17664c..350d757 100644
> --- a/fs/lockd/host.c
> +++ b/fs/lockd/host.c
> @@ -11,6 +11,7 @@
>  #include <linux/types.h>
>  #include <linux/slab.h>
>  #include <linux/in.h>
> +#include <linux/in6.h>
>  #include <linux/sunrpc/clnt.h>
>  #include <linux/sunrpc/svc.h>
>  #include <linux/lockd/lockd.h>
> @@ -38,6 +39,28 @@ static struct nsm_handle *	nsm_find(const struct sockaddr_in *sin,
>  					 const char *hostname,
>  					 unsigned int hostname_len);
>  
> +static void nlm_display_address(const struct sockaddr *sap,
> +				char *buf, const size_t len)
> +{
> +	const struct sockaddr_in *sin = (struct sockaddr_in *)sap;
> +	const struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
> +
> +	switch (sap->sa_family) {
> +	case AF_UNSPEC:
> +		snprintf(buf, len, "unspecified");
> +		break;
> +	case AF_INET:
> +		snprintf(buf, len, NIPQUAD_FMT, NIPQUAD(sin->sin_addr.s_addr));
> +		break;
> +	case AF_INET6:
> +		snprintf(buf, len, NIP6_FMT, NIP6(sin6->sin6_addr));
> +		break;
> +	default:
> +		snprintf(buf, len, "unsupported address family");
> +		break;
> +	}
> +}

Is there code we could reuse from someplace else?

> +
>  /*
>   * Common host lookup routine for server & client
>   */
> @@ -54,14 +77,10 @@ static struct nlm_host *nlm_lookup_host(int server,
>  	struct nsm_handle *nsm = NULL;
>  	int		hash;
>  
> -	dprintk("lockd: nlm_lookup_host("NIPQUAD_FMT"->"NIPQUAD_FMT
> -			", p=%d, v=%u, my role=%s, name=%.*s)\n",
> -			NIPQUAD(ssin->sin_addr.s_addr),
> -			NIPQUAD(sin->sin_addr.s_addr), proto, version,
> -			server? "server" : "client",
> -			hostname_len,
> -			hostname? hostname : "<none>");
> -
> +	dprintk("lockd: nlm_lookup_host(proto=%d, vers=%u,"
> +			" my role is %s, hostname=%.*s)\n",
> +			proto, version, server? "server" : "client",
> +			hostname_len, hostname? hostname : "<none>");
>  
>  	hash = NLM_ADDRHASH(sin->sin_addr.s_addr);
>  
> @@ -101,22 +120,31 @@ static struct nlm_host *nlm_lookup_host(int server,
>  		hlist_add_head(&host->h_hash, chain);
>  
>  		nlm_get_host(host);
> +		dprintk("lockd: nlm_lookup_host found host %s (%s)\n",
> +				host->h_name, host->h_addrbuf);
>  		goto out;
>  	}
> -	if (nsm)
> -		atomic_inc(&nsm->sm_count);
>  
> -	host = NULL;
> -
> -	/* Sadly, the host isn't in our hash table yet. See if
> -	 * we have an NSM handle for it. If not, create one.
> +	/*
> +	 * The host wasn't in our hash table.  If we don't
> +	 * have an NSM handle for it yet, create one.
>  	 */
> -	if (!nsm && !(nsm = nsm_find(sin, hostname, hostname_len)))
> -		goto out;
> +	if (nsm)
> +		atomic_inc(&nsm->sm_count);
> +	else {
> +		host = NULL;
> +		nsm = nsm_find(sin, hostname, hostname_len);
> +		if (!nsm) {
> +			dprintk("lockd: nlm_lookup_host failed; "
> +				"no nsm handle\n");
> +			goto out;
> +		}
> +	}

This seems like an odd mixture of unrelated changes; I've lost track of
the rationale.  Maybe split out another patch?

--b.

>  
>  	host = kzalloc(sizeof(*host), GFP_KERNEL);
>  	if (!host) {
>  		nsm_release(nsm);
> +		dprintk("lockd: nlm_lookup_host failed; no memory\n");
>  		goto out;
>  	}
>  	host->h_name	   = nsm->sm_name;
> @@ -143,6 +171,15 @@ static struct nlm_host *nlm_lookup_host(int server,
>  	INIT_LIST_HEAD(&host->h_reclaim);
>  
>  	nrhosts++;
> +
> +	nlm_display_address((struct sockaddr *)&host->h_addr,
> +				host->h_addrbuf, sizeof(host->h_addrbuf));
> +	nlm_display_address((struct sockaddr *)&host->h_saddr,
> +				host->h_saddrbuf, sizeof(host->h_saddrbuf));
> +
> +	dprintk("lockd: nlm_lookup_host created host %s\n",
> +			host->h_name);
> +
>  out:
>  	mutex_unlock(&nlm_host_mutex);
>  	return host;
> @@ -207,9 +244,8 @@ nlm_bind_host(struct nlm_host *host)
>  {
>  	struct rpc_clnt	*clnt;
>  
> -	dprintk("lockd: nlm_bind_host("NIPQUAD_FMT"->"NIPQUAD_FMT")\n",
> -			NIPQUAD(host->h_saddr.sin_addr),
> -			NIPQUAD(host->h_addr.sin_addr));
> +	dprintk("lockd: nlm_bind_host %s (%s), my addr=%s\n",
> +			host->h_name, host->h_addrbuf, host->h_saddrbuf);
>  
>  	/* Lock host handle */
>  	mutex_lock(&host->h_mutex);
> @@ -221,7 +257,7 @@ nlm_bind_host(struct nlm_host *host)
>  		if (time_after_eq(jiffies, host->h_nextrebind)) {
>  			rpc_force_rebind(clnt);
>  			host->h_nextrebind = jiffies + NLM_HOST_REBIND;
> -			dprintk("lockd: next rebind in %ld jiffies\n",
> +			dprintk("lockd: next rebind in %lu jiffies\n",
>  					host->h_nextrebind - jiffies);
>  		}
>  	} else {
> @@ -324,8 +360,7 @@ void nlm_host_rebooted(const struct sockaddr_in *sin,
>  	struct nsm_handle *nsm;
>  	struct nlm_host	*host;
>  
> -	dprintk("lockd: nlm_host_rebooted(%s, %u.%u.%u.%u)\n",
> -			hostname, NIPQUAD(sin->sin_addr));
> +	dprintk("lockd: nlm_host_rebooted(%s)\n", hostname);
>  
>  	/* Find the NSM handle for this peer */
>  	if (!(nsm = __nsm_find(sin, hostname, hostname_len, 0)))
> diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
> index a6d1215..5774d6e 100644
> --- a/include/linux/lockd/lockd.h
> +++ b/include/linux/lockd/lockd.h
> @@ -61,6 +61,9 @@ struct nlm_host {
>  	struct list_head	h_granted;	/* Locks in GRANTED state */
>  	struct list_head	h_reclaim;	/* Locks in RECLAIM state */
>  	struct nsm_handle *	h_nsmhandle;	/* NSM status handle */
> +
> +	char			h_addrbuf[48],	/* address eyecatchers */
> +				h_saddrbuf[48];
>  };
>  
>  struct nsm_handle {
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
