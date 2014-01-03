Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37577 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753105AbaACVe5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Jan 2014 16:34:57 -0500
Date: Fri, 3 Jan 2014 16:34:55 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSD: fix a bug which causing nfsd deny CREATE_SESSION
Message-ID: <20140103213455.GB5164@fieldses.org>
References: <52B802E9.4070607@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <52B802E9.4070607@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 23, 2013 at 05:31:21PM +0800, Kinglong Mee wrote:
> check_forechannel_attrs have get drc memory, 
> nfsd must put it when check_backchannel_attrs failed.
> 
> After many requests with bad back channel attrs, 
> nfsd will deny any client's CREATE_SESSION forever.

Thanks, applying.--b.

> 
> A new test case named CSESS29 for pynfs will send in another mail.
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfs4state.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 105d6fa..4e2c9ba 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1913,7 +1913,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>  		return status;
>  	status = check_backchannel_attrs(&cr_ses->back_channel);
>  	if (status)
> -		return status;
> +		goto out_release_drc_mem;
>  	status = nfserr_jukebox;
>  	new = alloc_session(&cr_ses->fore_channel);
>  	if (!new)
> -- 
> 1.8.4.2
