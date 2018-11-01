Return-Path: <SRS0=Ohau=NM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63333C0044C
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 20:48:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0FC2920657
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 20:48:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0FC2920657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725843AbeKBFxE (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 2 Nov 2018 01:53:04 -0400
Received: from fieldses.org ([173.255.197.46]:56584 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725780AbeKBFxD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 2 Nov 2018 01:53:03 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 34346201C; Thu,  1 Nov 2018 16:48:29 -0400 (EDT)
Date:   Thu, 1 Nov 2018 16:48:29 -0400
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 07/13] NFSD add ca_source_server<> to COPY
Message-ID: <20181101204829.GD12930@fieldses.org>
References: <20181019152905.32418-1-olga.kornievskaia@gmail.com>
 <20181019152905.32418-8-olga.kornievskaia@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181019152905.32418-8-olga.kornievskaia@gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Oct 19, 2018 at 11:28:59AM -0400, Olga Kornievskaia wrote:
> Note: followed conventions and have struct nfsd4_compoundargs pointer as a
> parameter even though it is unused.

It's used--see the definition of READ_BUF.

(I'm not a fan of those macros and they'll probably be replaced some
day.)

--b.

> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  fs/nfsd/nfs4xdr.c | 71 +++++++++++++++++++++++++++++++++++++++++++++++++++++--
>  fs/nfsd/xdr4.h    |  1 +
>  2 files changed, 70 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 3de42a7..9f6886f 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -40,6 +40,7 @@
>  #include <linux/utsname.h>
>  #include <linux/pagemap.h>
>  #include <linux/sunrpc/svcauth_gss.h>
> +#include <linux/sunrpc/addr.h>
>  
>  #include "idmap.h"
>  #include "acl.h"
> @@ -1743,11 +1744,58 @@ static __be32 nfsd4_decode_reclaim_complete(struct nfsd4_compoundargs *argp, str
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
> +		naddr->netid_len = be32_to_cpup(p++);
> +		if (naddr->netid_len > RPCBIND_MAXNETIDLEN)
> +			goto xdr_error;
> +
> +		READ_BUF(naddr->netid_len + 4); /* 4 for uaddr len */
> +		COPYMEM(naddr->netid, naddr->netid_len);
> +
> +		naddr->addr_len = be32_to_cpup(p++);
> +		if (naddr->addr_len > RPCBIND_MAXUADDRLEN)
> +			goto xdr_error;
> +
> +		READ_BUF(naddr->addr_len);
> +		COPYMEM(naddr->addr, naddr->addr_len);
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
> +	int i, count;
>  
>  	status = nfsd4_decode_stateid(argp, &copy->cp_src_stateid);
>  	if (status)
> @@ -1762,8 +1810,24 @@ static __be32 nfsd4_decode_reclaim_complete(struct nfsd4_compoundargs *argp, str
>  	p = xdr_decode_hyper(p, &copy->cp_count);
>  	p++; /* ca_consecutive: we always do consecutive copies */
>  	copy->cp_synchronous = be32_to_cpup(p++);
> -	tmp = be32_to_cpup(p); /* Source server list not supported */
> +	count = be32_to_cpup(p++);
> +
> +	if (count == 0) /* intra-server copy */
> +		goto intra;
>  
> +	/* decode all the supplied server addresses but use first */
> +	copy->cp_src = kmalloc(count * sizeof(struct nl4_server), GFP_KERNEL);
> +	if (copy->cp_src == NULL)
> +		return nfserrno(-ENOMEM);
> +
> +	ns = copy->cp_src;
> +	for (i = 0; i < count; i++) {
> +		status = nfsd4_decode_nl4_server(argp, ns);
> +		if (status)
> +			return status;
> +		ns++;
> +	}
> +intra:
>  	DECODE_TAIL;
>  }
>  
> @@ -4273,6 +4337,9 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
>  	p = xdr_reserve_space(&resp->xdr, 4 + 4);
>  	*p++ = xdr_one; /* cr_consecutive */
>  	*p++ = cpu_to_be32(copy->cp_synchronous);
> +
> +	/* allocated in nfsd4_decode_copy */
> +	kfree(copy->cp_src);
>  	return 0;
>  }
>  
> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> index feeb6d4..b4d1140 100644
> --- a/fs/nfsd/xdr4.h
> +++ b/fs/nfsd/xdr4.h
> @@ -521,6 +521,7 @@ struct nfsd4_copy {
>  	u64		cp_src_pos;
>  	u64		cp_dst_pos;
>  	u64		cp_count;
> +	struct nl4_server *cp_src;
>  
>  	/* both */
>  	bool		cp_synchronous;
> -- 
> 1.8.3.1
