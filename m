Return-Path: <SRS0=dMO4=PA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82583C43387
	for <linux-nfs@archiver.kernel.org>; Sun, 23 Dec 2018 21:27:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 587EA217D7
	for <linux-nfs@archiver.kernel.org>; Sun, 23 Dec 2018 21:27:02 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725866AbeLWV0K (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 23 Dec 2018 16:26:10 -0500
Received: from fieldses.org ([173.255.197.46]:53572 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725828AbeLWV0K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 23 Dec 2018 16:26:10 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 38DA6C57; Sun, 23 Dec 2018 16:26:10 -0500 (EST)
Date:   Sun, 23 Dec 2018 16:26:10 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Julia Lawall <Julia.Lawall@lip6.fr>
Cc:     kernel-janitors@vger.kernel.org, Jeff Layton <jlayton@kernel.org>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 01/20] nfsd: drop useless LIST_HEAD
Message-ID: <20181223212610.GB3183@fieldses.org>
References: <1545555435-24576-1-git-send-email-Julia.Lawall@lip6.fr>
 <1545555435-24576-2-git-send-email-Julia.Lawall@lip6.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1545555435-24576-2-git-send-email-Julia.Lawall@lip6.fr>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Applied, thanks.--b.

On Sun, Dec 23, 2018 at 09:56:56AM +0100, Julia Lawall wrote:
> Drop LIST_HEAD where the variable it declares is never used.
> 
> This was introduced in c5c707f96fc9a ("nfsd: implement pNFS
> layout recalls"), but was not used even in that commit.
> 
> The semantic patch that fixes this problem is as follows:
> (http://coccinelle.lip6.fr/)
> 
> // <smpl>
> @@
> identifier x;
> @@
> - LIST_HEAD(x);
>   ... when != x
> // </smpl>
> 
> Fixes: c5c707f96fc9a ("nfsd: implement pNFS layout recalls")
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> ---
> Successfully 0-day tested on 151 configurations.
> 
>  fs/nfsd/nfs4layouts.c |    1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
> index 2b36aa037ce0..44517fb5c0de 100644
> --- a/fs/nfsd/nfs4layouts.c
> +++ b/fs/nfsd/nfs4layouts.c
> @@ -656,7 +656,6 @@ nfsd4_cb_layout_done(struct nfsd4_callback *cb, struct rpc_task *task)
>  	struct nfsd_net *nn;
>  	ktime_t now, cutoff;
>  	const struct nfsd4_layout_ops *ops;
> -	LIST_HEAD(reaplist);
>  
>  
>  	switch (task->tk_status) {
