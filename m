From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/7] Replacements for last week's patches
Date: Fri, 3 Oct 2008 17:53:27 -0400
Message-ID: <17799EFF-FAFA-484A-A826-BF7E168B5788@oracle.com>
References: <20081003162856.10198.20451.stgit@ingres.1015granger.net> <20081003214558.GH19057@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:40866 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753470AbYJCVxk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Oct 2008 17:53:40 -0400
In-Reply-To: <20081003214558.GH19057@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Oct 3, 2008, at Oct 3, 2008, 5:45 PM, J. Bruce Fields wrote:
> On Fri, Oct 03, 2008 at 12:49:58PM -0400, Chuck Lever wrote:
>> Hi Bruce-
>>
>> Here's a patch series to replace the patches you reviewed earlier  
>> this
>> week.  I've addressed the issues you mentioned in your review  
>> comments,
>> and dropped the NSM-related patches that treat the 16-byte opaque  
>> as an
>> address, as discussed.
>>
>> The last patches I intend to submit for 2.6.28 will address the  
>> lack of
>> a client-side UDP lockd listener.  I will propose a fix later today  
>> in
>> a subsequent patch series.
>
> Thanks, applied to for-2.6.28, with the first patch adjusted as  
> follows.

OK, thanks.

>
>
> --b.
>
> diff --git a/fs/lockd/host.c b/fs/lockd/host.c
> index 1630588..3c4dc33 100644
> --- a/fs/lockd/host.c
> +++ b/fs/lockd/host.c
> @@ -38,11 +38,8 @@ static struct nsm_handle	*nsm_find(const struct  
> sockaddr *sap,
> 						const size_t hostname_len,
> 						const int create);
>
> -#define NLM_SERVER	(0)
> -#define NLM_CLIENT	(1)
> -
> struct nlm_lookup_host_info {
> -	const int		peer;		/* search for server|client */
> +	const int		server;		/* search for server|client */
> 	const struct sockaddr_in *sin;		/* address to search for */
> 	const unsigned short	protocol;	/* transport to search for*/
> 	const u32		version;	/* NLM version to search for */
> @@ -167,7 +164,7 @@ static struct nlm_host *nlm_lookup_host(struct  
> nlm_lookup_host_info *ni)
> 			continue;
> 		if (host->h_version != ni->version)
> 			continue;
> -		if (host->h_server != ni->peer)
> +		if (host->h_server != ni->server)
> 			continue;
> 		if (!nlm_cmp_addr(nlm_srcaddr(host),
> 					(struct sockaddr *)ni->src_sin))
> @@ -224,7 +221,7 @@ static struct nlm_host *nlm_lookup_host(struct  
> nlm_lookup_host_info *ni)
> 	host->h_state      = 0;			/* pseudo NSM state */
> 	host->h_nsmstate   = 0;			/* real NSM state */
> 	host->h_nsmhandle  = nsm;
> -	host->h_server	   = ni->peer;
> +	host->h_server	   = ni->server;
> 	hlist_add_head(&host->h_hash, chain);
> 	INIT_LIST_HEAD(&host->h_lockowners);
> 	spin_lock_init(&host->h_lock);
> @@ -280,7 +277,7 @@ struct nlm_host *nlmclnt_lookup_host(const  
> struct sockaddr_in *sin,
> 		.sin_family	= AF_UNSPEC,
> 	};
> 	struct nlm_lookup_host_info ni = {
> -		.peer		= NLM_SERVER,
> +		.server		= 0,
> 		.sin		= sin,
> 		.protocol	= proto,
> 		.version	= version,
> @@ -308,7 +305,7 @@ nlmsvc_lookup_host(struct svc_rqst *rqstp,
> 		.sin_addr	= rqstp->rq_daddr.addr,
> 	};
> 	struct nlm_lookup_host_info ni = {
> -		.peer		= NLM_CLIENT,
> +		.server		= 1,
> 		.sin		= svc_addr_in(rqstp),
> 		.protocol	= rqstp->rq_prot,
> 		.version	= rqstp->rq_vers,

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




