Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46122 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751099Ab2KJTwm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 10 Nov 2012 14:52:42 -0500
Date: Sat, 10 Nov 2012 14:52:40 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: fix error handling in nfsd4_remove_clid_dir
Message-ID: <20121110195240.GA534@fieldses.org>
References: <1352493113-22005-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1352493113-22005-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 09, 2012 at 03:31:53PM -0500, Jeff Layton wrote:
> If the credential save fails, then we'll leak our mnt_want_write_file
> reference.

Thanks, applying.--b.

> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfsd/nfs4recover.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
> index 43295d4..0f1e2e2 100644
> --- a/fs/nfsd/nfs4recover.c
> +++ b/fs/nfsd/nfs4recover.c
> @@ -301,12 +301,13 @@ nfsd4_remove_clid_dir(struct nfs4_client *clp)
>  
>  	status = nfs4_save_creds(&original_cred);
>  	if (status < 0)
> -		goto out;
> +		goto out_drop_write;
>  
>  	status = nfsd4_unlink_clid_dir(clp->cl_recdir, HEXDIR_LEN-1);
>  	nfs4_reset_creds(original_cred);
>  	if (status == 0)
>  		vfs_fsync(rec_file, 0);
> +out_drop_write:
>  	mnt_drop_write_file(rec_file);
>  out:
>  	if (status)
> -- 
> 1.7.11.7
> 
