Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:36436 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752461AbdEIOEd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 May 2017 10:04:33 -0400
Date: Tue, 9 May 2017 17:04:14 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: Colin King <colin.king@canonical.com>
Cc: Ari Kauppi <ari@synopsys.com>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfsd: avoid out of bounds read on array nfsd4_layout_ops
Message-ID: <20170509140414.ycw4z6zsdevbkozm@mwanda>
References: <20170509133121.26529-1-colin.king@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170509133121.26529-1-colin.king@canonical.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 09, 2017 at 02:31:21PM +0100, Colin King wrote:
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 1dbf62190bee..c453a1998e00 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1259,7 +1259,8 @@ nfsd4_layout_verify(struct svc_export *exp, unsigned int layout_type)
>  		return NULL;
>  	}
>  
> -	if (layout_type >= 32 || !(exp->ex_layout_types & (1 << layout_type))) {
> +	if (layout_type >= LAYOUT_TYPE_MAX ||
> +	    !(exp->ex_layout_types & (1 << layout_type))) {

The 32 is there to prevent a shift wrapping bug.  The bit test prevents
a buffer overflow so this can't actually overflow.  But this change
doesn't hurt and is probably cleaner.

exp->ex_layout_types  is set in nfsd4_setup_layout_type().

regards,
dan carpenter

