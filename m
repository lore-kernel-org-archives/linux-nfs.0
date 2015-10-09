Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44814 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752064AbbJIP2F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Oct 2015 11:28:05 -0400
Date: Fri, 9 Oct 2015 11:28:03 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-nfs@vger.kernel.org, stable@vger.kernel.org
Subject: Re: [PATCH] nfsd/blocklayout: accept any minlength
Message-ID: <20151009152803.GC6825@fieldses.org>
References: <1444395806-32111-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1444395806-32111-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 09, 2015 at 03:03:26PM +0200, Christoph Hellwig wrote:
> Recent Linux clients have started to send less than blocksize minglength
> requests.  Given that minlength is just a hint except for the magic value
> of zero just don't check for it except for same zero value.  Without
> this we'll hang forever during fsx runs.

OK, planning to apply for 4.3 just on the assumption that you know what
you're doing, but: I don't get it--it looks like the worst that can
happen here is we just reuturn LAYOUTUNAVAILABLE to LAYOUTGET.
Shouldn't the client then just fall back on normal NFS IO?  Why the
hang?

--b.

> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfsd/blocklayout.c | 8 --------
>  1 file changed, 8 deletions(-)
> 
> diff --git a/fs/nfsd/blocklayout.c b/fs/nfsd/blocklayout.c
> index cdefaa3..c29d942 100644
> --- a/fs/nfsd/blocklayout.c
> +++ b/fs/nfsd/blocklayout.c
> @@ -56,14 +56,6 @@ nfsd4_block_proc_layoutget(struct inode *inode, const struct svc_fh *fhp,
>  	u32 device_generation = 0;
>  	int error;
>  
> -	/*
> -	 * We do not attempt to support I/O smaller than the fs block size,
> -	 * or not aligned to it.
> -	 */
> -	if (args->lg_minlength < block_size) {
> -		dprintk("pnfsd: I/O too small\n");
> -		goto out_layoutunavailable;
> -	}
>  	if (seg->offset & (block_size - 1)) {
>  		dprintk("pnfsd: I/O misaligned\n");
>  		goto out_layoutunavailable;
> -- 
> 1.9.1
