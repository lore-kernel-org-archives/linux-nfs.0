Return-Path: <SRS0=F+UG=PM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18539C43387
	for <linux-nfs@archiver.kernel.org>; Fri,  4 Jan 2019 15:03:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DCFF82087F
	for <linux-nfs@archiver.kernel.org>; Fri,  4 Jan 2019 15:03:45 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726299AbfADPDp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 4 Jan 2019 10:03:45 -0500
Received: from fieldses.org ([173.255.197.46]:40414 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726117AbfADPDp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 4 Jan 2019 10:03:45 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id CC9EE1F67; Fri,  4 Jan 2019 10:03:44 -0500 (EST)
Date:   Fri, 4 Jan 2019 10:03:44 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Dan Carpenter <dan.carpenter@oracle.com>
Cc:     NeilBrown <neilb@suse.com>, Jeff Layton <jlayton@kernel.org>,
        linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: Re: [PATCH] nfsd: fix an IS_ERR() vs NULL check
Message-ID: <20190104150344.GA11787@fieldses.org>
References: <20190104064703.GB30627@kadam>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190104064703.GB30627@kadam>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Jan 04, 2019 at 09:47:03AM +0300, Dan Carpenter wrote:
> The get_backchannel_cred() used to return error pointers on error but
> now it returns NULL pointers.

Thanks!  Queueing up for 4.21 and stable.

Off the top of my head I don't recall bug reports that could be
explained by this.  Perhaps it's hard to get a failure at this point
without failing somewhere earlier?  But I think it's likely possible to
trigger a NULL dereference somehow.

--b.

> 
> Fixes: 97f68c6b02e0 ("SUNRPC: add 'struct cred *' to auth_cred and rpc_cre")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
>  fs/nfsd/nfs4callback.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index c74e4538d0eb..9b38dab1c21b 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -913,9 +913,9 @@ static int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *c
>  		return PTR_ERR(client);
>  	}
>  	cred = get_backchannel_cred(clp, client, ses);
> -	if (IS_ERR(cred)) {
> +	if (!cred) {
>  		rpc_shutdown_client(client);
> -		return PTR_ERR(cred);
> +		return -ENOMEM;
>  	}
>  	clp->cl_cb_client = client;
>  	clp->cl_cb_cred = cred;
> -- 
> 2.17.1
