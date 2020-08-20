Return-Path: <SRS0=3r48=B6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.3 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10472C433DF
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Aug 2020 21:04:15 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id DFE592078D
	for <linux-nfs@archiver.kernel.org>; Thu, 20 Aug 2020 21:04:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fieldses.org header.i=@fieldses.org header.b="F0FvG5HC"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726938AbgHTVEO (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 20 Aug 2020 17:04:14 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:51402 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726716AbgHTVEL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Aug 2020 17:04:11 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 000C1C061385;
        Thu, 20 Aug 2020 14:04:10 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id 70EF679CA; Thu, 20 Aug 2020 17:04:10 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 70EF679CA
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1597957450;
        bh=zxVXR96zM1wvqlJPFJpCJztvWZXAITo4XjPq56VHqQg=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=F0FvG5HCcbm5vUXYUMW6vOd9QU05+kQWtXPZOvi1y1xLFHKqxHKXQww34Lz32PCbs
         tz0omCeSIUCdIYdbvGyMFZJjzjUK3V9x3Re5CJznRjenaqnkzGPjs0/fSQ9Ol5Oa+q
         mKvGVNy3Enmkhr+d8l4GSw57D3pQ/wotNzr65yfE=
Date:   Thu, 20 Aug 2020 17:04:10 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Alex Dewar <alex.dewar90@gmail.com>
Cc:     Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfsd: Fix typo in comment
Message-ID: <20200820210410.GF28555@fieldses.org>
References: <20200817175125.6441-1-alex.dewar90@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200817175125.6441-1-alex.dewar90@gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Applying, thanks.--b.

On Mon, Aug 17, 2020 at 06:51:26PM +0100, Alex Dewar wrote:
> Missing "is".
> 
> Signed-off-by: Alex Dewar <alex.dewar90@gmail.com>
> ---
> Ahh I see. Is this better?
> ---
>  fs/nfsd/nfs4xdr.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 259d5ad0e3f47..309a6d5f895ae 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -4828,7 +4828,7 @@ nfsd4_encode_listxattrs(struct nfsd4_compoundres *resp, __be32 nfserr,
>  		slen = strlen(sp);
>  
>  		/*
> -		 * Check if this a user. attribute, skip it if not.
> +		 * Check if this is a user. attribute, skip it if not.
>  		 */
>  		if (strncmp(sp, XATTR_USER_PREFIX, XATTR_USER_PREFIX_LEN))
>  			goto contloop;
> -- 
> 2.28.0
