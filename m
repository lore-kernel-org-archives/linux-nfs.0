From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [PATCH 06/22] SQUASHME: nfsd41 remove sl_session from
 nfsd4_open
Date: Fri, 03 Apr 2009 04:46:42 +0300
Message-ID: <49D56A82.1030506@panasas.com>
References: <1238718003-8764-1-git-send-email-andros@netapp.com>	<1238718003-8764-2-git-send-email-andros@netapp.com>	<1238718003-8764-3-git-send-email-andros@netapp.com>	<1238718003-8764-4-git-send-email-andros@netapp.com>	<1238718003-8764-5-git-send-email-andros@netapp.com> <1238718003-8764-6-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: bfields@citi.umich.edu, linux-nfs@vger.kernel.org,
	pnfs@linux-nfs.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:18485 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751238AbZDCBsM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 21:48:12 -0400
In-Reply-To: <1238718003-8764-6-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr. 03, 2009, 3:19 +0300, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> March 31 review by Bruce
> squash into nfsd41: create_session operation

Hmm, Isn't it nfsd41: clientid handling?

Benny

> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfsd/nfs4proc.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index a393d38..29428ab 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -201,7 +201,7 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  		return nfserr_inval;
>  
>  	if (nfsd4_has_session(cstate))
> -		copy_clientid(&open->op_clientid, cstate->slot->sl_session);
> +		copy_clientid(&open->op_clientid, cstate->session);
>  
>  	nfs4_lock_state();
>  
