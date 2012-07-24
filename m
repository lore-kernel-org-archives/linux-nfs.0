Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40035 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753683Ab2GXQxy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Jul 2012 12:53:54 -0400
Date: Tue, 24 Jul 2012 12:53:53 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Vivek Trivedi <vtrivedi018@gmail.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Namjae Jeon <linkinjeon@gmail.com>
Subject: Re: [PATCH] nfsd4: fix cr_principal comparison check in same_creds
Message-ID: <20120724165353.GH8570@fieldses.org>
References: <1343144900-4522-1-git-send-email-vtrivedi018@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1343144900-4522-1-git-send-email-vtrivedi018@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 24, 2012 at 09:18:20PM +0530, Vivek Trivedi wrote:
> This fixes a wrong check for same cr_principal in same_creds

Thanks for the fix.

Looks like I introduced that with
8fbba96e5b327665265ad02b7f331b68536828bf "nfsd4: stricter cred
comparison for setclientid/exchange_id".

Queuing for 3.6, cc'ing stable.

--b.

> 
> Signed-off-by: Vivek Trivedi <vtrivedi018@gmail.com>
> Signed-off-by: Namjae Jeon <linkinjeon@gmail.com>
> ---
>  fs/nfsd/nfs4state.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 94effd5..e8ead04 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1215,7 +1215,7 @@ static bool groups_equal(struct group_info *g1, struct group_info *g2)
>  	return true;
>  }
>  
> -static int
> +static bool
>  same_creds(struct svc_cred *cr1, struct svc_cred *cr2)
>  {
>  	if ((cr1->cr_flavor != cr2->cr_flavor)
> @@ -1227,7 +1227,7 @@ same_creds(struct svc_cred *cr1, struct svc_cred *cr2)
>  		return true;
>  	if (!cr1->cr_principal || !cr2->cr_principal)
>  		return false;
> -	return 0 == strcmp(cr1->cr_principal, cr1->cr_principal);
> +	return 0 == strcmp(cr1->cr_principal, cr2->cr_principal);
>  }
>  
>  static void gen_clid(struct nfs4_client *clp)
> -- 
> 1.7.1
> 
