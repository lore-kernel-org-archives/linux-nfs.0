From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH v2 03/47] nfsd: add a struct nfsd4_slot pointer to
	struct nfsd4_compound_state
Date: Sun, 29 Mar 2009 16:46:56 -0400
Message-ID: <20090329204656.GB18661@fieldses.org>
References: <49CDDFC2.4070402@panasas.com> <1238229057-7887-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:60850 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753984AbZC2Uq5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 Mar 2009 16:46:57 -0400
In-Reply-To: <1238229057-7887-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Mar 28, 2009 at 11:30:57AM +0300, Benny Halevy wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> To be used for sessions DRC replay.

It'd be more helpful to have this combined with whatever patch first
defines and/or uses nfsd4_slot.

--b.

> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  include/linux/nfsd/xdr4.h |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
> index fd15ddc..e309d55 100644
> --- a/include/linux/nfsd/xdr4.h
> +++ b/include/linux/nfsd/xdr4.h
> @@ -48,6 +48,8 @@ struct nfsd4_compound_state {
>  	struct svc_fh		current_fh;
>  	struct svc_fh		save_fh;
>  	struct nfs4_stateowner	*replay_owner;
> +	/* For sessions DRC */
> +	struct nfsd4_slot	*slot;
>  };
>  
>  struct nfsd4_change_info {
> -- 
> 1.6.2.1
> 
