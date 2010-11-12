Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60876 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932417Ab0KLUpz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Nov 2010 15:45:55 -0500
Date: Fri, 12 Nov 2010 15:45:54 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: NFSv3 list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS4.1: Fix bug server don't reply the right
 fore_channel to client at create_session
Message-ID: <20101112204554.GF32745@fieldses.org>
References: <4CDBBF7C.90108@cn.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4CDBBF7C.90108@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Nov 11, 2010 at 06:03:40PM +0800, Mi Jinlong wrote:
> At the latest kernel(2.6.37-rc1), server just initialize the forechannel
> at init_forechannel_attrs, but don't reflect it to reply.
> 
> After initialize the session success, we should copy the forechannel info
> to nfsd4_create_session struct.

Thanks!

Is there a chance you could write a pynfs test for this?

--b.

> 
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> ---
>  fs/nfsd/nfs4state.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index f1e5ec6..3876a9c 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1556,6 +1556,8 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>  	status = nfs_ok;
>  	memcpy(cr_ses->sessionid.data, new->se_sessionid.data,
>  	       NFS4_MAX_SESSIONID_LEN);
> +	memcpy(&cr_ses->fore_channel, &new->se_fchannel,
> +		sizeof(struct nfsd4_channel_attrs));
>  	cs_slot->sl_seqid++;
>  	cr_ses->seqid = cs_slot->sl_seqid;
>  
> -- 
> 1.7.0.1
> 
> 
