Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ot0-f194.google.com ([74.125.82.194]:36367 "EHLO
        mail-ot0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752385AbdLVBLj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Dec 2017 20:11:39 -0500
MIME-Version: 1.0
In-Reply-To: <20171222003551.11110-1-colin.king@canonical.com>
References: <20171222003551.11110-1-colin.king@canonical.com>
From: Kinglong Mee <kinglongmee@gmail.com>
Date: Fri, 22 Dec 2017 09:11:38 +0800
Message-ID: <CAB6yy36XSS0p1sQw3UJqS-c9xZCzebARFtQTLBpnn75D82iMNg@mail.gmail.com>
Subject: Re: [PATCH] nfsd: fix incorrect indentation on goto statement
To: Colin King <colin.king@canonical.com>
Cc: "J . Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 22, 2017 at 8:35 AM, Colin King <colin.king@canonical.com> wrote:
> From: Colin Ian King <colin.king@canonical.com>
>
> The goto statement requires one more level of indentation, add it.

Those "break" in this switch need one more level too,
it's nice to add them in this patch.

thanks,
Kinglong Mee

>
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  fs/nfsd/nfs4state.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index b29b5a185a2c..3bb720a59b49 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -6159,7 +6159,7 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>                 default:
>                         dprintk("NFSD: nfs4_lockt: bad lock type!\n");
>                         status = nfserr_inval;
> -               goto out;
> +                       goto out;
>         }
>
>         lo = find_lockowner_str(cstate->clp, &lockt->lt_owner);
> --
> 2.14.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
