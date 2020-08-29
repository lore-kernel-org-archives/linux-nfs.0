Return-Path: <SRS0=1cnt=CH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.3 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A5D0C433E2
	for <linux-nfs@archiver.kernel.org>; Sat, 29 Aug 2020 15:36:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 50E7D20BED
	for <linux-nfs@archiver.kernel.org>; Sat, 29 Aug 2020 15:36:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fieldses.org header.i=@fieldses.org header.b="BykLjcYC"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728310AbgH2Pgu (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 29 Aug 2020 11:36:50 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:34714 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728196AbgH2Pgu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 29 Aug 2020 11:36:50 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id B1AC8C061236;
        Sat, 29 Aug 2020 08:36:49 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id CC5BB2012; Sat, 29 Aug 2020 11:36:48 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org CC5BB2012
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1598715408;
        bh=HoxjoWKowd57pYE4VNh/VDpZ9rlhexlsY3h8n+CNiFk=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=BykLjcYCG5uqv3qjo3r9Knn4dTzZWZzkMBx3C4yef/gVTZs4f2yTcvB4qqbUhZuh1
         //Ef5iMZdn0xKZ1IQsPZAZo+ErDc7++qisotGIGO/zqCAY0RbBURsP22XOwk2IlwOB
         4pBtDGTgzMYjVH4SNHxzod83PjdtzJciH1oL+Udo=
Date:   Sat, 29 Aug 2020 11:36:48 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Dinghao Liu <dinghao.liu@zju.edu.cn>
Cc:     kjlu@umn.edu, Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jakub Kicinski <kuba@kernel.org>,
        Scott Mayhew <smayhew@redhat.com>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Ard Biesheuvel <ardb@kernel.org>
Subject: Re: [PATCH] gss_krb5: Fix memleak in krb5_make_rc4_seq_num
Message-ID: <20200829153648.GB20499@fieldses.org>
References: <20200827080252.26396-1-dinghao.liu@zju.edu.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200827080252.26396-1-dinghao.liu@zju.edu.cn>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This code is rarely if ever used, and there are pending patches to
remove it completely, so I don't think it's worth trying to fix a rare
memory leak at this point.

--b.

On Thu, Aug 27, 2020 at 04:02:50PM +0800, Dinghao Liu wrote:
> When kmalloc() fails, cipher should be freed
> just like when krb5_rc4_setup_seq_key() fails.
> 
> Fixes: e7afe6c1d486b ("sunrpc: fix 4 more call sites that were using stack memory with a scatterlist")
> Signed-off-by: Dinghao Liu <dinghao.liu@zju.edu.cn>
> ---
>  net/sunrpc/auth_gss/gss_krb5_seqnum.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/auth_gss/gss_krb5_seqnum.c b/net/sunrpc/auth_gss/gss_krb5_seqnum.c
> index 507105127095..88ca58d11082 100644
> --- a/net/sunrpc/auth_gss/gss_krb5_seqnum.c
> +++ b/net/sunrpc/auth_gss/gss_krb5_seqnum.c
> @@ -53,8 +53,10 @@ krb5_make_rc4_seq_num(struct krb5_ctx *kctx, int direction, s32 seqnum,
>  		return PTR_ERR(cipher);
>  
>  	plain = kmalloc(8, GFP_NOFS);
> -	if (!plain)
> -		return -ENOMEM;
> +	if (!plain) {
> +		code = -ENOMEM;
> +		goto out;
> +	}
>  
>  	plain[0] = (unsigned char) ((seqnum >> 24) & 0xff);
>  	plain[1] = (unsigned char) ((seqnum >> 16) & 0xff);
> -- 
> 2.17.1
