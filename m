Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45538 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751715AbdIATwb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 1 Sep 2017 15:52:31 -0400
Date: Fri, 1 Sep 2017 15:52:29 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [RFC v1 01/18] NFSD add ca_source_server<> to COPY
Message-ID: <20170901195229.GC27922@parsley.fieldses.org>
References: <20170302160142.30413-1-kolga@netapp.com>
 <20170302160142.30413-2-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170302160142.30413-2-kolga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 02, 2017 at 11:01:25AM -0500, Olga Kornievskaia wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Note: followed conventions and have struct nfsd4_compoundargs pointer as a
> parameter even though it is unused.

I'd understand if nfsd4_decode_nl4_server was an op decoder, but it
looks like it's called by some other decoder?  In which case, there's no
need for the unused argument.

I can't find the definition for struct nl4_server anyway, was this
supposed to apply on top of another set of patches?

So if you send a COPY request with a source server list to the current
(unpatched) server, it looks like you just get back BADXDR?  That sounds
like a bug in the current server.  But I suppose the client may be stuck
with that behavior.  How does the client handle that error from COPY?

--b.

> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfsd/nfs4xdr.c | 75 +++++++++++++++++++++++++++++++++++++++++++++++++++++--
>  fs/nfsd/xdr4.h    |  4 +++
>  2 files changed, 77 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 382c1fd..f62cbad 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -41,6 +41,7 @@
>  #include <linux/utsname.h>
>  #include <linux/pagemap.h>
>  #include <linux/sunrpc/svcauth_gss.h>
> +#include <linux/sunrpc/addr.h>
>  
>  #include "idmap.h"
>  #include "acl.h"
> @@ -1726,11 +1727,58 @@ static __be32 nfsd4_decode_reclaim_complete(struct nfsd4_compoundargs *argp, str
>  	DECODE_TAIL;
>  }
>  
> +static __be32 nfsd4_decode_nl4_server(struct nfsd4_compoundargs *argp,
> +				      struct nl4_server *ns)
> +{
> +	DECODE_HEAD;
> +	struct nfs42_netaddr *naddr;
> +
> +	READ_BUF(4);
> +	ns->nl4_type = be32_to_cpup(p++);
> +
> +	/* currently support for 1 inter-server source server */
> +	switch (ns->nl4_type) {
> +	case NL4_NAME:
> +	case NL4_URL:
> +		READ_BUF(4);
> +		ns->u.nl4_str_sz = be32_to_cpup(p++);
> +		if (ns->u.nl4_str_sz > NFS4_OPAQUE_LIMIT)
> +			goto xdr_error;
> +
> +		READ_BUF(ns->u.nl4_str_sz);
> +		COPYMEM(ns->u.nl4_str,
> +			ns->u.nl4_str_sz);
> +		break;
> +	case NL4_NETADDR:
> +		naddr = &ns->u.nl4_addr;
> +
> +		READ_BUF(4);
> +		naddr->na_netid_len = be32_to_cpup(p++);
> +		if (naddr->na_netid_len > RPCBIND_MAXNETIDLEN)
> +			goto xdr_error;
> +
> +		READ_BUF(naddr->na_netid_len + 4); /* 4 for uaddr len */
> +		COPYMEM(naddr->na_netid, naddr->na_netid_len);
> +
> +		naddr->na_uaddr_len = be32_to_cpup(p++);
> +		if (naddr->na_uaddr_len > RPCBIND_MAXUADDRLEN)
> +			goto xdr_error;
> +
> +		READ_BUF(naddr->na_uaddr_len);
> +		COPYMEM(naddr->na_uaddr, naddr->na_uaddr_len);
> +		break;
> +	default:
> +		goto xdr_error;
> +	}
> +	DECODE_TAIL;
> +}
> +
>  static __be32
>  nfsd4_decode_copy(struct nfsd4_compoundargs *argp, struct nfsd4_copy *copy)
>  {
>  	DECODE_HEAD;
> -	unsigned int tmp;
> +	struct nl4_server *ns;
> +	int i;
>  
>  	status = nfsd4_decode_stateid(argp, &copy->cp_src_stateid);
>  	if (status)
> @@ -1745,8 +1793,29 @@ static __be32 nfsd4_decode_reclaim_complete(struct nfsd4_compoundargs *argp, str
>  	p = xdr_decode_hyper(p, &copy->cp_count);
>  	copy->cp_consecutive = be32_to_cpup(p++);
>  	copy->cp_synchronous = be32_to_cpup(p++);
> -	tmp = be32_to_cpup(p); /* Source server list not supported */
> +	copy->cp_src.nl_nsvr = be32_to_cpup(p++);
>  
> +	if (copy->cp_src.nl_nsvr == 0) /* intra-server copy */
> +		goto intra;
> +
> +	/** Support NFSD4_MAX_SSC_SRC number of source servers.
> +	 * freed in nfsd4_encode_copy
> +	 */
> +	if (copy->cp_src.nl_nsvr > NFSD4_MAX_SSC_SRC)
> +		copy->cp_src.nl_nsvr = NFSD4_MAX_SSC_SRC;
> +	copy->cp_src.nl_svr = kmalloc(copy->cp_src.nl_nsvr *
> +					sizeof(struct nl4_server), GFP_KERNEL);
> +	if (copy->cp_src.nl_svr == NULL)
> +		return nfserrno(-ENOMEM);
> +
> +	ns = copy->cp_src.nl_svr;
> +	for (i = 0; i < copy->cp_src.nl_nsvr; i++) {
> +		status = nfsd4_decode_nl4_server(argp, ns);
> +		if (status)
> +			return status;
> +		ns++;
> +	}
> +intra:
>  	DECODE_TAIL;
>  }
>  
> @@ -4295,6 +4364,8 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
>  		*p++ = cpu_to_be32(copy->cp_consecutive);
>  		*p++ = cpu_to_be32(copy->cp_synchronous);
>  	}
> +	/* allocated in nfsd4_decode_copy */
> +	kfree(copy->cp_src.nl_svr);
>  	return nfserr;
>  }
>  
> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> index 8fda4ab..6b1a61fc 100644
> --- a/fs/nfsd/xdr4.h
> +++ b/fs/nfsd/xdr4.h
> @@ -509,6 +509,9 @@ struct nfsd42_write_res {
>  	nfs4_verifier		wr_verifier;
>  };
>  
> +/*  support 1 source server for now */
> +#define NFSD4_MAX_SSC_SRC       1
> +
>  struct nfsd4_copy {
>  	/* request */
>  	stateid_t	cp_src_stateid;
> @@ -516,6 +519,7 @@ struct nfsd4_copy {
>  	u64		cp_src_pos;
>  	u64		cp_dst_pos;
>  	u64		cp_count;
> +	struct nl4_servers cp_src;
>  
>  	/* both */
>  	bool		cp_consecutive;
> -- 
> 1.8.3.1
> 
