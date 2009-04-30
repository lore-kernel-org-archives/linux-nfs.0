From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 08/31] nfsd41: sanity check client drc maxreqs
Date: Thu, 30 Apr 2009 20:34:02 +0300
Message-ID: <49F9E10A.60801@panasas.com>
References: <1240938005-23778-1-git-send-email-andros@netapp.com> <1240938005-23778-2-git-send-email-andros@netapp.com> <1240938005-23778-3-git-send-email-andros@netapp.com> <1240938005-23778-4-git-send-email-andros@netapp.com> <1240938005-23778-5-git-send-email-andros@netapp.com> <1240938005-23778-6-git-send-email-andros@netapp.com> <1240938005-23778-7-git-send-email-andros@netapp.com> <1240938005-23778-8-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: bfields@fieldses.org, pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:6631 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933437AbZD3Rfx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 13:35:53 -0400
In-Reply-To: <1240938005-23778-8-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr. 28, 2009, 19:59 +0300, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Ensure the client requested maximum requests are between 1 and
> NFSD_MAX_SLOTS_PER_SESSION
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfsd/nfs4state.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index e216169..59b601b 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -427,6 +427,11 @@ static int set_forechannel_maxreqs(struct nfsd4_channel_attrs *fchan)
>  {
>  	int status = 0, np = fchan->maxreqs * NFSD_PAGES_PER_SLOT;
>  
> +	if (fchan->maxreqs < 1)
> +		return nfserr_inval;

Is 0 prohibited by the protocol?
The server can set it to whatever value it wants,
or if we can live with it, it actually provides a
nice way to test the server end-cases.

Benny

> +	else if (fchan->maxreqs > NFSD_MAX_SLOTS_PER_SESSION)
> +		fchan->maxreqs = NFSD_MAX_SLOTS_PER_SESSION;
> +
>  	spin_lock(&nfsd_serv->sv_lock);
>  	if (np + nfsd_serv->sv_drc_pages_used > nfsd_serv->sv_drc_max_pages)
>  		np = nfsd_serv->sv_drc_max_pages - nfsd_serv->sv_drc_pages_used;
