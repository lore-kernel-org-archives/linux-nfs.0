Return-Path: <SRS0=leyo=NN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86028C32789
	for <linux-nfs@archiver.kernel.org>; Fri,  2 Nov 2018 15:46:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3BB322081F
	for <linux-nfs@archiver.kernel.org>; Fri,  2 Nov 2018 15:46:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3BB322081F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726229AbeKCAxy (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 2 Nov 2018 20:53:54 -0400
Received: from fieldses.org ([173.255.197.46]:57584 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726098AbeKCAxy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 2 Nov 2018 20:53:54 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 07C561CB3; Fri,  2 Nov 2018 11:46:23 -0400 (EDT)
Date:   Fri, 2 Nov 2018 11:46:23 -0400
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 07/13] NFSD add ca_source_server<> to COPY
Message-ID: <20181102154623.GA20367@fieldses.org>
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
> @@ -4273,6 +4337,9 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
>  	p = xdr_reserve_space(&resp->xdr, 4 + 4);
>  	*p++ = xdr_one; /* cr_consecutive */
>  	*p++ = cpu_to_be32(copy->cp_synchronous);
> +
> +	/* allocated in nfsd4_decode_copy */
> +	kfree(copy->cp_src);

This can result in a leak--for example, if we decode the compound
succesfully, but processing fails before we could to this op, then we'll
never call this encoder, so we'll allocate without freeing.

I think simplest would be to replace this:

> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> index feeb6d4..b4d1140 100644
> --- a/fs/nfsd/xdr4.h
> +++ b/fs/nfsd/xdr4.h
> @@ -521,6 +521,7 @@ struct nfsd4_copy {
>  	u64		cp_src_pos;
>  	u64		cp_dst_pos;
>  	u64		cp_count;
> +	struct nl4_server *cp_src;

by just a

	struct nl4_server cp_src;

since it sounds like you really only need one of them, not a whole array
(at least for now).

--b.

>  
>  	/* both */
>  	bool		cp_synchronous;
> -- 
> 1.8.3.1
