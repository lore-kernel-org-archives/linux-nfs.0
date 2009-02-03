From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] Bug 11061, NFS mounts dropped
Date: Tue, 03 Feb 2009 17:16:31 -0500
Message-ID: <1233699391.7161.11.camel@heimdal.trondhjem.org>
References: <1233459927.3112.54.camel@sibyl.beware.dropbear.id.au>
	 <BD6791E5-9D82-4D42-8016-4731792CA5DA@oracle.com>
	 <1233610918.3077.50.camel@sibyl.beware.dropbear.id.au>
	 <157D0C13-65A3-412D-A266-EDFCF487F632@oracle.com>
	 <1233698189.13862.16.camel@sibyl.beware.dropbear.id.au>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Ian Dall <ian-Xg6/AsmM8Z5B3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:51167 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752084AbZBCWQm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Feb 2009 17:16:42 -0500
In-Reply-To: <1233698189.13862.16.camel-+Zt617Lp5ASbJVK1MCa92ZvzqaJJnU0YunOrhLTifxA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-02-04 at 08:26 +1030, Ian Dall wrote:
> On Mon, 2009-02-02 at 16:52 -0500, Chuck Lever wrote:
> 
> > Simply define a helper near nfs_sockaddr_match_ipaddr(), included  
> > inside the "#if defined(CONFIG_IPV6)," that handles port comparison,  
> > and call that from nfs_match_client().
> > 
> > Eventually we will probably extract all of this address family- 
> > specific kruft into something that can be shared amongst all of the  
> > NFS-related components, so it will likely end up split out this way in  
> > any event.
> 
> OK here is version 2 of the patch. It is half the size of version 1,
> although the resultant client.c is slightly bigger and IMO slightly
> inferior than for version 1, but certainly it is around the margin.
> 
> 
> Log:
> ======================
> Don't compare sock_addr structures using memcmp().
> 
> Signed-off-by: Ian Dall <ian-Xg6/AsmM8Z5B3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>
> ======================
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 9b728f3..ee5e211 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -255,6 +255,22 @@ static int nfs_sockaddr_match_ipaddr(const struct
> sockaddr *sa1,
>  	}
>  	return 0;
>  }
> +
> +static int nfs_sockaddr_match_port(const struct sockaddr *sa1,
> +				   const struct sockaddr *sa2)
> +{
> +	switch (sa1->sa_family) {
> +	default:
> +		return 0;

The "default:" case here should be unnecessary.

> +	case AF_INET:
> +		return (((const struct sockaddr_in *)sa1)->sin_port ==
> +			((const struct sockaddr_in *)sa2)->sin_port);
> +	case AF_INET6:
> +		return (((const struct sockaddr_in6 *)sa1)->sin6_port ==
> +			((const struct sockaddr_in6 *)sa2)->sin6_port);
> +	}
> +	return 0;
> +}
>  #else
>  static int nfs_sockaddr_match_ipaddr4(const struct sockaddr_in *sa1,
>  				 const struct sockaddr_in *sa2)
> @@ -270,6 +286,13 @@ static int nfs_sockaddr_match_ipaddr(const struct
> sockaddr *sa1,
>  	return nfs_sockaddr_match_ipaddr4((const struct sockaddr_in *)sa1,
>  			(const struct sockaddr_in *)sa2);
>  }
> +
> +static int nfs_sockaddr_match_port(const struct sockaddr *sa1,
> +				   const struct sockaddr *sa2)
> +{
> +	return (((const struct sockaddr_in *)sa1)->sin_port ==
> +		((const struct sockaddr_in *)sa2)->sin_port);
> +}
>  #endif
>  
>  /*
> @@ -344,8 +367,10 @@ struct nfs_client *nfs_find_client_next(struct
> nfs_client *clp)
>  static struct nfs_client *nfs_match_client(const struct
> nfs_client_initdata *data)
>  {
>  	struct nfs_client *clp;
> +	const struct sockaddr *sap = data->addr;
>  
>  	list_for_each_entry(clp, &nfs_client_list, cl_share_link) {
> +	        struct sockaddr *clap = (struct sockaddr *)&clp->cl_addr;

       Might as well make that a 'const struct sockaddr *', since we'll
never want this code to modify anything here...


>  		/* Don't match clients that failed to initialise properly */
>  		if (clp->cl_cons_state < 0)
>  			continue;
> @@ -358,9 +383,13 @@ static struct nfs_client *nfs_match_client(const
> struct nfs_client_initdata *dat
>  			continue;
>  
>  		/* Match the full socket address */
> -		if (memcmp(&clp->cl_addr, data->addr, sizeof(clp->cl_addr)) != 0)
> +		if (!nfs_sockaddr_match_ipaddr(sap, clap))
> +			continue;
> +		/* including the port number */
> +		if (!nfs_sockaddr_match_port(sap, clap))
>  			continue;
>  
> +
>  		atomic_inc(&clp->cl_count);
>  		return clp;
>  	}
> 
> 

