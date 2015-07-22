Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:56709 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750771AbbGVSYw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Jul 2015 14:24:52 -0400
Date: Wed, 22 Jul 2015 14:24:52 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 06/14] nfsd: Drop duplicate locks_init_lock()
Message-ID: <20150722182452.GB3168@fieldses.org>
References: <55A384B1.8030207@gmail.com>
 <55A3857E.50104@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55A3857E.50104@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

OK.--b.

On Mon, Jul 13, 2015 at 05:31:42PM +0800, Kinglong Mee wrote:
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfs4layouts.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
> index 5c0f1d6..c5af4ccb 100644
> --- a/fs/nfsd/nfs4layouts.c
> +++ b/fs/nfsd/nfs4layouts.c
> @@ -162,7 +162,7 @@ nfsd4_layout_setlease(struct nfs4_layout_stateid *ls)
>  	fl = locks_alloc_lock();
>  	if (!fl)
>  		return -ENOMEM;
> -	locks_init_lock(fl);
> +
>  	fl->fl_lmops = &nfsd4_layouts_lm_ops;
>  	fl->fl_flags = FL_LAYOUT;
>  	fl->fl_type = F_RDLCK;
> -- 
> 2.4.3
