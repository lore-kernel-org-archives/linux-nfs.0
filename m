Return-Path: <SRS0=Ohau=NM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91145C0044C
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 20:37:29 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 40E7920657
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 20:37:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 40E7920657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725961AbeKBFmA (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 2 Nov 2018 01:42:00 -0400
Received: from fieldses.org ([173.255.197.46]:56544 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725937AbeKBFmA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 2 Nov 2018 01:42:00 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id CE64D201C; Thu,  1 Nov 2018 16:37:27 -0400 (EDT)
Date:   Thu, 1 Nov 2018 16:37:27 -0400
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 06/13] NFSD fill-in netloc4 structure
Message-ID: <20181101203727.GC12930@fieldses.org>
References: <20181019152905.32418-1-olga.kornievskaia@gmail.com>
 <20181019152905.32418-7-olga.kornievskaia@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181019152905.32418-7-olga.kornievskaia@gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Oct 19, 2018 at 11:28:58AM -0400, Olga Kornievskaia wrote:
> From: Olga Kornievskaia <kolga@netapp.com>
> 
> nfs.4 defines nfs42_netaddr structure that represents netloc4.
> 
> Populate needed fields from the sockaddr structure.
> 
> This will be used by flexfiles and 4.2 inter copy
> 
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  fs/nfsd/nfsd.h | 31 ++++++++++++++++++++++++++++++-
>  1 file changed, 30 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
> index 0668999..030fccb 100644
> --- a/fs/nfsd/nfsd.h
> +++ b/fs/nfsd/nfsd.h
> @@ -18,7 +18,7 @@
>  #include <linux/nfs4.h>
>  #include <linux/sunrpc/svc.h>
>  #include <linux/sunrpc/msg_prot.h>
> -
> +#include <linux/sunrpc/addr.h>
>  #include <uapi/linux/nfsd/debug.h>
>  
>  #include "stats.h"
> @@ -366,6 +366,35 @@ static inline bool nfsd4_spo_must_allow(struct svc_rqst *rqstp)
>  
>  extern const u32 nfsd_suppattrs[3][3];
>  
> +static inline u32 nfsd4_set_netaddr(struct sockaddr *addr, struct nfs42_netaddr *netaddr)
> +{
> +	struct sockaddr_in *sin = (struct sockaddr_in *)addr;
> +	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)addr;
> +	unsigned int port;
> +	size_t ret;
> +
> +	switch (addr->sa_family) {
> +	case AF_INET:
> +		port = ntohs(sin->sin_port);
> +		sprintf(netaddr->netid, "tcp");
> +		netaddr->netid_len = 3;
> +		break;
> +	case AF_INET6:
> +		port = ntohs(sin6->sin6_port);
> +		sprintf(netaddr->netid, "tcp6");
> +		netaddr->netid_len = 4;
> +		break;
> +	default:
> +		return nfserrno(-EINVAL);

Let's just write that nfserr_inval;

> +	}
> +	ret = rpc_ntop(addr, netaddr->addr, sizeof(netaddr->addr));
> +	netaddr->addr_len = ret + snprintf(netaddr->addr + ret,
> +				     RPCBIND_MAXUADDRLEN + 1,
> +				     ".%u.%u", port >> 8, port & 0xff);

Isn't the remaining space RPCBIND_MAXUADDRLEN + 1 - ret ?

But really I think we're depending on RPCBIND_MAXUADDRLEN being large
enough that there will never be overlow, in which case we may as well
just use sprintf.

And maybe add a WARN_ON() in case of overflow, if we want to be
paranoid about it.

--b.

> +
> +	return 0;
> +}
> +
>  static inline bool bmval_is_subset(const u32 *bm1, const u32 *bm2)
>  {
>  	return !((bm1[0] & ~bm2[0]) ||
> -- 
> 1.8.3.1
