Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ea0-f179.google.com ([209.85.215.179]:58768 "EHLO
	mail-ea0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752697Ab3AUOnd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jan 2013 09:43:33 -0500
Received: by mail-ea0-f179.google.com with SMTP id d12so1651203eaa.10
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jan 2013 06:43:32 -0800 (PST)
Message-ID: <50FD5410.6070009@tonian.com>
Date: Mon, 21 Jan 2013 16:43:28 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: ycnian@gmail.com
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] pnfsd: Fix unlock bug on error path
References: <1358219261-19974-1-git-send-email-ycnian@gmail.com>
In-Reply-To: <1358219261-19974-1-git-send-email-ycnian@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-01-15 05:07, ycnian@gmail.com wrote:
> From: Yanchuan Nian <ycnian@gmail.com>
> 
> LAYOUTGET procedure fails if the layout requested conflicts with the recalled.
> It needs to put the reference and unlock the state before exiting.
> 
> Signed-off-by: Yanchuan Nian <ycnian@gmail.com>

Good catch. Thanks.
Committing for pnfs-all-3.7 and latest.

Benny

> ---
>  fs/nfsd/nfs4pnfsd.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
> index dd7856c..4a1e17b 100644
> --- a/fs/nfsd/nfs4pnfsd.c
> +++ b/fs/nfsd/nfs4pnfsd.c
> @@ -760,7 +760,7 @@ nfs4_pnfs_get_layout(struct nfsd4_pnfs_layoutget *lgp,
>  
>  	if (is_layout_recalled(clp, lgp->lg_fhp, &lgp->lg_seg)) {
>  		nfserr = nfserr_recallconflict;
> -		goto out;
> +		goto out_unlock;
>  	}
>  
>  	/* pre-alloc layout in case we can't merge after we call
> 
