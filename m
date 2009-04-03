From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [PATCH 02/22] SQUASHME: nfsd41: use cstate session in
 nfsd4_replay_cache_entry
Date: Fri, 03 Apr 2009 04:50:34 +0300
Message-ID: <49D56B6A.2040806@panasas.com>
References: <1238718003-8764-1-git-send-email-andros@netapp.com> <1238718003-8764-2-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: bfields@citi.umich.edu, linux-nfs@vger.kernel.org,
	pnfs@linux-nfs.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:8737 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754552AbZDCBuj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 21:50:39 -0400
In-Reply-To: <1238718003-8764-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr. 03, 2009, 3:19 +0300, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> March 31 review by Bruce
> squash into nfsd41: DRC save, restore, and clear functions

my records show "nfsd41: non-page DRC for solo sequence responses"...
I we're in sync

Benny

> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfsd/nfs4state.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index b7c4ed0..b233efa 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1154,7 +1154,7 @@ nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
>  	 * is sent (lease renewal).
>  	 */
>  	if (seq && nfsd4_no_page_in_cache(resp)) {
> -		seq->maxslots = resp->cstate.slot->sl_session->se_fnumslots;
> +		seq->maxslots = resp->cstate.session->se_fnumslots;
>  		return nfs_ok;
>  	}
>  
