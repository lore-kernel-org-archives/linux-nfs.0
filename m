Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59686 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751125AbbGIQTY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Jul 2015 12:19:24 -0400
Date: Thu, 9 Jul 2015 12:19:24 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2] nfsd: Fix a file leak of ls_file if
 nfsd4_layout_setlease fail
Message-ID: <20150709161924.GB29703@fieldses.org>
References: <559672B7.4010802@gmail.com>
 <20150708213015.GG19084@fieldses.org>
 <20150709081239.GB19291@infradead.org>
 <559E3F68.6090205@gmail.com>
 <559E4112.3070902@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <559E4112.3070902@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 09, 2015 at 05:38:26PM +0800, Kinglong Mee wrote:
> If nfsd4_layout_setlease fail, nfsd will not put ls->ls_file.
> 
> Fix commit c5c707f96f "nfsd: implement pNFS layout recalls".
> 
> v2, just put file using fput

OK, thanks.--b.

> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfs4layouts.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
> index 6904213..ebf90e4 100644
> --- a/fs/nfsd/nfs4layouts.c
> +++ b/fs/nfsd/nfs4layouts.c
> @@ -212,6 +212,7 @@ nfsd4_alloc_layout_stateid(struct nfsd4_compound_state *cstate,
>  	BUG_ON(!ls->ls_file);
>  
>  	if (nfsd4_layout_setlease(ls)) {
> +		fput(ls->ls_file);
>  		put_nfs4_file(fp);
>  		kmem_cache_free(nfs4_layout_stateid_cache, ls);
>  		return NULL;
> -- 
> 2.4.3
