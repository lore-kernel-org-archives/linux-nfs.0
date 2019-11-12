Return-Path: <SRS0=Um0H=ZE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D1BDC43331
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Nov 2019 20:00:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E2FC2214E0
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Nov 2019 20:00:37 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726912AbfKLUAh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 12 Nov 2019 15:00:37 -0500
Received: from fieldses.org ([173.255.197.46]:41356 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726376AbfKLUAh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 12 Nov 2019 15:00:37 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id C96141C83; Tue, 12 Nov 2019 15:00:36 -0500 (EST)
Date:   Tue, 12 Nov 2019 15:00:36 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Scott Mayhew <smayhew@redhat.com>
Cc:     chuck.lever@oracle.com, jamie@audible.transient.net,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3] nfsd: Fix cld_net->cn_tfm initialization
Message-ID: <20191112200036.GC8095@fieldses.org>
References: <20191112190143.12624-1-smayhew@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20191112190143.12624-1-smayhew@redhat.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Thanks, applied.--b.

On Tue, Nov 12, 2019 at 02:01:43PM -0500, Scott Mayhew wrote:
> Don't assign an error pointer to cld_net->cn_tfm, otherwise an oops will
> occur in nfsd4_remove_cld_pipe().
> 
> Also, move the initialization of cld_net->cn_tfm so that it occurs after
> the check to see if nfsdcld is running.  This is necessary because
> nfsd4_client_tracking_init() looks for -ETIMEDOUT to determine whether
> to use the "old" nfsdcld tracking ops.
> 
> Fixes: 6ee95d1c8991 ("nfsd: add support for upcall version 2")
> Reported-by: Jamie Heilman <jamie@audible.transient.net>
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> ---
>  fs/nfsd/nfs4recover.c | 12 +++++++-----
>  1 file changed, 7 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
> index cdc75ad4438b..c35c0ebaf722 100644
> --- a/fs/nfsd/nfs4recover.c
> +++ b/fs/nfsd/nfs4recover.c
> @@ -1578,6 +1578,7 @@ nfsd4_cld_tracking_init(struct net *net)
>  	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
>  	bool running;
>  	int retries = 10;
> +	struct crypto_shash *tfm;
>  
>  	status = nfs4_cld_state_init(net);
>  	if (status)
> @@ -1586,11 +1587,6 @@ nfsd4_cld_tracking_init(struct net *net)
>  	status = __nfsd4_init_cld_pipe(net);
>  	if (status)
>  		goto err_shutdown;
> -	nn->cld_net->cn_tfm = crypto_alloc_shash("sha256", 0, 0);
> -	if (IS_ERR(nn->cld_net->cn_tfm)) {
> -		status = PTR_ERR(nn->cld_net->cn_tfm);
> -		goto err_remove;
> -	}
>  
>  	/*
>  	 * rpc pipe upcalls take 30 seconds to time out, so we don't want to
> @@ -1607,6 +1603,12 @@ nfsd4_cld_tracking_init(struct net *net)
>  		status = -ETIMEDOUT;
>  		goto err_remove;
>  	}
> +	tfm = crypto_alloc_shash("sha256", 0, 0);
> +	if (IS_ERR(tfm)) {
> +		status = PTR_ERR(tfm);
> +		goto err_remove;
> +	}
> +	nn->cld_net->cn_tfm = tfm;
>  
>  	status = nfsd4_cld_get_version(nn);
>  	if (status == -EOPNOTSUPP)
> -- 
> 2.17.2
