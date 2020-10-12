Return-Path: <SRS0=IBnY=DT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.3 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98751C433E7
	for <linux-nfs@archiver.kernel.org>; Mon, 12 Oct 2020 14:28:44 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 2AE232076C
	for <linux-nfs@archiver.kernel.org>; Mon, 12 Oct 2020 14:28:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fieldses.org header.i=@fieldses.org header.b="n2JqBxVC"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2389775AbgJLO2n (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 12 Oct 2020 10:28:43 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:38584 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2388921AbgJLO2n (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Oct 2020 10:28:43 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 349A2C0613D0
        for <linux-nfs@vger.kernel.org>; Mon, 12 Oct 2020 07:28:43 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id A83911E50; Mon, 12 Oct 2020 10:28:42 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org A83911E50
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1602512922;
        bh=/YOyIFOUqRtG8nqsQThzt5byjqjOgp1Buhxw5vikabM=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=n2JqBxVC90kuIF7YB7JeL1DqBf8+OPQBSpG/GlzjKGQTRqlmuar2dNmo7iCN7VIwJ
         vQXYWZMwuL1UF/imFC8UbDKQcBLuXtoErRe4lsLn7hOruZfBIAo2Y/DN1UDkqKy748
         TMJAzvaXddS4EycpBerBugtY1m13h/sHVdszDFGY=
Date:   Mon, 12 Oct 2020 10:28:42 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSD: Fix oversight in .pc_func conversion
Message-ID: <20201012142842.GE26571@fieldses.org>
References: <160235898066.206859.15214008370147838310.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <160235898066.206859.15214008370147838310.stgit@klimt.1015granger.net>
User-Agent: Mutt/1.5.21 (2010-09-15)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sat, Oct 10, 2020 at 03:43:15PM -0400, Chuck Lever wrote:
> nfsd_proc_setattr() needs to return an accept_stat value, not an
> nfserr status code, when fh_verify() fails.

Thanks!  I'll fold that into "NFSD: Hoist status code encoding into XDR
encoder functions".

--b.

> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  fs/nfsd/nfsproc.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Oops.
> 
> diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
> index f2450c719032..0d71549f9d42 100644
> --- a/fs/nfsd/nfsproc.c
> +++ b/fs/nfsd/nfsproc.c
> @@ -85,7 +85,7 @@ nfsd_proc_setattr(struct svc_rqst *rqstp)
>  
>  		resp->status = fh_verify(rqstp, fhp, 0, NFSD_MAY_NOP);
>  		if (resp->status != nfs_ok)
> -			return resp->status;
> +			goto out;
>  
>  		if (delta < 0)
>  			delta = -delta;
> 
