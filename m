From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] NFS4.1: server gets drc mem fail should reply error at
 create_session
Date: Fri, 12 Nov 2010 15:13:56 -0500
Message-ID: <20101112201356.GE32745@fieldses.org>
References: <4CDBBF86.6080800@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFSv3 list <linux-nfs@vger.kernel.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33789 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932368Ab0KLUN6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Nov 2010 15:13:58 -0500
In-Reply-To: <4CDBBF86.6080800@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 11, 2010 at 06:03:50PM +0800, Mi Jinlong wrote:
> When server gets drc mem fail, it should reply error to client.

Whoops, thanks--applying.

--b.

> 
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> ---
>  fs/nfsd/nfs4state.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 3876a9c..ea6466c 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -745,6 +745,8 @@ static struct nfsd4_session *alloc_init_session(struct svc_rqst *rqstp, struct n
>  	 */
>  	slotsize = nfsd4_sanitize_slot_size(fchan->maxresp_cached);
>  	numslots = nfsd4_get_drc_mem(slotsize, fchan->maxreqs);
> +	if (numslots < 1)
> +		return NULL;
>  
>  	new = alloc_session(slotsize, numslots);
>  	if (!new) {
> -- 
> 1.7.0.1
> 
> 
> 
