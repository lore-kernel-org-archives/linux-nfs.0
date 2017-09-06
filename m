Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59464 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752404AbdIFVeW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 6 Sep 2017 17:34:22 -0400
Date: Wed, 6 Sep 2017 17:34:21 -0400
To: Olga Kornievskaia <kolga@netapp.com>
Cc: Trond.Myklebust@primarydata.com, anna.schumaker@netapp.com,
        bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [RFC v3 25/42] NFSD add COPY_NOTIFY operation
Message-ID: <20170906213421.GD24694@fieldses.org>
References: <20170711164416.1982-1-kolga@netapp.com>
 <20170711164416.1982-26-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170711164416.1982-26-kolga@netapp.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 11, 2017 at 12:43:59PM -0400, Olga Kornievskaia wrote:
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfsd/nfs4proc.c |  98 ++++++++++++++++++++++++++++++++++++++++++++++
>  fs/nfsd/nfs4xdr.c  | 112 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
>  fs/nfsd/xdr4.h     |  13 +++++++
>  3 files changed, 221 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index dadb3bf..ed6b9f2 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -35,6 +35,7 @@
>  #include <linux/file.h>
>  #include <linux/falloc.h>
>  #include <linux/slab.h>
> +#include <linux/sunrpc/addr.h>
>  
>  #include "idmap.h"
>  #include "cache.h"
> @@ -1087,6 +1088,82 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
>  }
>  
>  static __be32
> +nfsd4_set_src_nl4_netaddr(struct svc_rqst *rqstp, struct nl4_servers *svrs)
> +{
> +	const struct sockaddr *addr = (struct sockaddr *)&rqstp->rq_daddr;
> +	const struct sockaddr_in *sin = (const struct sockaddr_in *)addr;
> +	const struct sockaddr_in6 *sin6 = (const struct sockaddr_in6 *)addr;
> +	int uaddr_len = rqstp->rq_daddrlen + 4 + 1; /* port (4) and '\0' (1) */
> +	struct nfs42_netaddr *naddr;
> +	size_t ret;
> +	unsigned short port;
> +
> +	/* freed in nfsd4_encode_copy_notify */
> +	svrs->nl_svr = kmalloc_array(svrs->nl_nsvr, sizeof(struct nl4_server),
> +				GFP_KERNEL);
> +	if (svrs->nl_svr == NULL)
> +		return nfserrno(-ENOMEM);
> +
> +	svrs->nl_svr->nl4_type = NL4_NETADDR;
> +	naddr = &svrs->nl_svr->u.nl4_addr;
> +
> +	switch (addr->sa_family) {
> +	case AF_INET:
> +		port = ntohs(sin->sin_port);
> +		sprintf(naddr->na_netid, "tcp");
> +		naddr->na_netid_len = 3;
> +		break;
> +	case AF_INET6:
> +		port = ntohs(sin6->sin6_port);
> +		sprintf(naddr->na_netid, "tcp6");
> +		naddr->na_netid_len = 4;
> +		break;
> +	default:
> +		dprintk("NFSD  nfsd4_set_notify_src: unknown address type: %d",
> +			addr->sa_family);
> +		kfree(svrs->nl_svr);
> +		return nfserrno(-EINVAL);
> +	}
> +	ret = rpc_ntop(addr, naddr->na_uaddr, sizeof(naddr->na_uaddr));
> +	snprintf(naddr->na_uaddr + ret, uaddr_len, ".%u.%u",
> +		 port >> 8, port & 255);
> +	naddr->na_uaddr_len = strlen(naddr->na_uaddr);
> +	return 0;
> +}
> +
> +static __be32
> +nfsd4_copy_notify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> +		  struct nfsd4_copy_notify *cn)
> +{
> +	__be32 status;
> +	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
> +
> +	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
> +					&cn->cpn_src_stateid, RD_STATE, NULL,
> +					NULL);
> +	if (status)
> +		return status;
> +
> +	cn->cpn_sec = nn->nfsd4_lease;
> +	cn->cpn_nsec = 0;
> +
> +
> +	/** XXX Save cpn_src_statid, cpn_src, and any other returned source
> +	 * server addresses on which the source server is williing to accept
> +	 * connections from the destination e.g. what is returned in cpn_src,
> +	 * to verify READ from dest server.
> +	 */

Either we should fix the stuff mentioned in the comment or figure out
why it's not necessary.

I guess I don't see what the value would be of verifying the IP address.
Our choice of IP address to return here is a little arbitrary anyway.
And I assume the eventualy READ calls are going to be verified with all
the usual export and file permission checks.

If we don't save the cna_src_stateid, then I guess that means the COPY
might still succeed after the original OPEN/LOCK stateid is no longer
valid?  I can't decide if that will cause problems in practice or not.

>  static __be32
> +nfsd42_encode_nl4_server(struct nfsd4_compoundres *resp, struct nl4_server *ns)
> +{
> +	struct xdr_stream *xdr = &resp->xdr;
> +	struct nfs42_netaddr *addr;
> +	__be32 *p;
> +
> +	p = xdr_reserve_space(xdr, 4);
> +	*p++ = cpu_to_be32(ns->nl4_type);
> +
> +	switch (ns->nl4_type) {
> +	case NL4_NAME:
> +	case NL4_URL:
> +		p = xdr_reserve_space(xdr, 4 /* url or name len */ +
> +				      (XDR_QUADLEN(ns->u.nl4_str_sz) * 4));
> +		if (!p)
> +			return nfserr_resource;
> +		*p++ = cpu_to_be32(ns->u.nl4_str_sz);
> +		p = xdr_encode_opaque_fixed(p, ns->u.nl4_str, ns->u.nl4_str_sz);
> +			break;

This code will never be used as far as I can tell.  We could
BUG_ON(nl4_type != NL4_NETADDR) (or even just remove nl4_type).

--b.
