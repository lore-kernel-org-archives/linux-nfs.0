Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2130.oracle.com ([141.146.126.79]:57602 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728720AbeGQKCB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Jul 2018 06:02:01 -0400
Date: Tue, 17 Jul 2018 12:30:05 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: Colin King <colin.king@canonical.com>
Cc: "J . Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfsd: fix memory leak of async_copy
Message-ID: <20180717093005.3ggy24fskb3bxtni@mwanda>
References: <20180716120954.6720-1-colin.king@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180716120954.6720-1-colin.king@canonical.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 16, 2018 at 01:09:54PM +0100, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> In the case where async_copy is successfully allocated but
> the call to nfs4_init_cp_state fails, async_copy is not
> currently freed and the memory is leaked. Fix this by kfree'ing
> it before returning.
> 
> Detected by CoverityScan, CID#1471823 ("Resource leak")
> 
> Fixes: beb1814d5a8a ("NFSD create new stateid for async copy")
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  fs/nfsd/nfs4proc.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 8f3368353aaf..3fb96a2708b9 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1295,8 +1295,10 @@ nfsd4_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  		async_copy = kzalloc(sizeof(struct nfsd4_copy), GFP_KERNEL);
>  		if (!async_copy)
>  			goto out;
> -		if (!nfs4_init_cp_state(nn, copy))
> +		if (!nfs4_init_cp_state(nn, copy)) {
> +			kfree(async_copy);
>  			goto out;

It really feels like both this and the kzalloc() failure should be doing
an of fput() of copy->file_src and copy->file_dst.  The goto out_err
does an list_del(&copy->copies); but it happens before the
"list_add(&async_copy->copies ..." so that's likely wrong as well.

regards,
dan carpenter

