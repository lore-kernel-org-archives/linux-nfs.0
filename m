From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 3/4] nfsd: Fix leaked memory in nfs4_make_rec_clidname
Date: Mon, 20 Oct 2008 16:58:42 -0400
Message-ID: <20081020205842.GC27702@fieldses.org>
References: <20081020061709.18370.85373.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:40510 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752710AbYJTU6p (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Oct 2008 16:58:45 -0400
In-Reply-To: <20081020061709.18370.85373.sendpatchset-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 20, 2008 at 11:47:09AM +0530, Krishna Kumar wrote:
> From: Krishna Kumar <krkumar2@in.ibm.com>
> 
> cksum.data is not freed up in one error case. Compile tested.
> 

Thanks, applied.

--b.

> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> ---
> 
>  fs/nfsd/nfs4recover.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff -ruNp linux-2.6.27.org/fs/nfsd/nfs4recover.c linux-2.6.27.new/fs/nfsd/nfs4recover.c
> --- linux-2.6.27.org/fs/nfsd/nfs4recover.c	2008-10-20 10:47:15.000000000 +0530
> +++ linux-2.6.27.new/fs/nfsd/nfs4recover.c	2008-10-20 10:48:38.000000000 +0530
> @@ -110,9 +110,9 @@ nfs4_make_rec_clidname(char *dname, stru
>  
>  	md5_to_hex(dname, cksum.data);
>  
> -	kfree(cksum.data);
>  	status = nfs_ok;
>  out:
> +	kfree(cksum.data);
>  	crypto_free_hash(desc.tfm);
>  out_no_tfm:
>  	return status;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
