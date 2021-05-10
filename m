Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.3 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6375C433ED
	for <linux-nfs@archiver.kernel.org>; Mon, 10 May 2021 20:27:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 7C19961139
	for <linux-nfs@archiver.kernel.org>; Mon, 10 May 2021 20:27:24 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232035AbhEJU20 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 10 May 2021 16:28:26 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:59798 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231264AbhEJU20 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 May 2021 16:28:26 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 0B5DAC061574
        for <linux-nfs@vger.kernel.org>; Mon, 10 May 2021 13:27:21 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id 7042E50EC; Mon, 10 May 2021 16:27:19 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 7042E50EC
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1620678439;
        bh=bkKeoeV24uNMA2raueQBWZwP+C8VfTT+AeK6r/08E6k=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=ieFxQTGCFQNWBLlObbno28yW57lH6wDCvqpzJF32qLYGy1JuKEdWlqReCaCjdnRSs
         3rxyIzqIzP8XguhXDIMHX/RfeUTC2zQPN+20JrwsyGO2ucQ8BJe3mBYqkt2VtsAMCh
         iuL+8uIFkZO2wPcIL2tqdYP7gYRKA7uQbQ4kOW0U=
Date:   Mon, 10 May 2021 16:27:19 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     dwysocha@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC 06/21] NFSD: Remove spurious cb_setup_err tracepoint
Message-ID: <20210510202719.GB11188@fieldses.org>
References: <162066179690.94415.203187037032448300.stgit@klimt.1015granger.net>
 <162066193457.94415.10829735588517134118.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <162066193457.94415.10829735588517134118.stgit@klimt.1015granger.net>
User-Agent: Mutt/1.5.21 (2010-09-15)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, May 10, 2021 at 11:52:14AM -0400, Chuck Lever wrote:
> This path is not really an error path,

What's the non-error case for this path?

On a quick look it seems like that'd mean a 4.1 client doesn't have a
connection available for the backchannel, which sounds bad.

But I'm probably overlooking something....

--b.

> so the tracepoint I added
> there is just noise.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  fs/nfsd/nfs4callback.c |    4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index ab1836381e22..15ba16c54793 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -915,10 +915,8 @@ static int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *c
>  		args.authflavor = clp->cl_cred.cr_flavor;
>  		clp->cl_cb_ident = conn->cb_ident;
>  	} else {
> -		if (!conn->cb_xprt) {
> -			trace_nfsd_cb_setup_err(clp, -EINVAL);
> +		if (!conn->cb_xprt)
>  			return -EINVAL;
> -		}
>  		clp->cl_cb_conn.cb_xprt = conn->cb_xprt;
>  		clp->cl_cb_session = ses;
>  		args.bc_xprt = conn->cb_xprt;
> 
