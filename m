Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34413 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755810Ab3J1T4r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Oct 2013 15:56:47 -0400
Date: Mon, 28 Oct 2013 15:56:45 -0400
To: Benny Halevy <bhalevy@primarydata.com>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] nfsd: nfs4_open_delegation needs to remove_stid
 rather than unhash_stid
Message-ID: <20131028195645.GJ31322@fieldses.org>
References: <525CE711.1040107@primarydata.com>
 <1381820275-14078-1-git-send-email-bhalevy@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1381820275-14078-1-git-send-email-bhalevy@primarydata.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 15, 2013 at 09:57:55AM +0300, Benny Halevy wrote:
> In the out_free: path, the newly allocated stid must be removed rather
> than unhashed so it can never be found.

Applying, thanks.--b.

> 
> Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 64c167f..b8f3c7e 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -3157,7 +3157,7 @@ static void nfsd4_open_deleg_none_ext(struct nfsd4_open *open, int status)
>  	open->op_delegate_type = NFS4_OPEN_DELEGATE_READ;
>  	return;
>  out_free:
> -	unhash_stid(&dp->dl_stid);
> +	remove_stid(&dp->dl_stid);
>  	nfs4_put_delegation(dp);
>  out_no_deleg:
>  	open->op_delegate_type = NFS4_OPEN_DELEGATE_NONE;
> -- 
> 1.8.3.1
> 
