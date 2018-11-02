Return-Path: <SRS0=leyo=NN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07C25C32789
	for <linux-nfs@archiver.kernel.org>; Fri,  2 Nov 2018 14:03:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BF12320685
	for <linux-nfs@archiver.kernel.org>; Fri,  2 Nov 2018 14:03:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF12320685
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726265AbeKBXKv (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 2 Nov 2018 19:10:51 -0400
Received: from fieldses.org ([173.255.197.46]:57504 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726026AbeKBXKv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 2 Nov 2018 19:10:51 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 2CA6C1E19; Fri,  2 Nov 2018 10:03:36 -0400 (EDT)
Date:   Fri, 2 Nov 2018 10:03:36 -0400
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 07/13] NFSD add ca_source_server<> to COPY
Message-ID: <20181102140336.GB19655@fieldses.org>
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

The client could pass an arbitrarily large count here.  I don't know if
the ability to force the server to attempt a large kmalloc() is really
useful to an attacker, but I'd definitely rather not allow it.

Possibly more serious: if that multiplication overflows, then in theory
it might be possible to make the kmalloc() succeed and allocate too
little memory, after which the following loop could overwrite memory
past the end of the allocation.

As long as we're only using the first address, maybe it's simplest just
not to bother allocating memory for the rest.  Just copy the first one,
and for the rest call nfsd4_decode_nl4_server() with a dummy struct
nl4_server.

--b.

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
