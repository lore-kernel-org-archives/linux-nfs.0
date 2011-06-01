Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:55426 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752823Ab1FASHG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Jun 2011 14:07:06 -0400
Subject: Re: [PATCH] NFS: filelayout should use nfs_generic_pg_test
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Cc: Weston Andros Adamson <dros@netapp.com>,
        Boaz Harrosh <bharrosh@panasas.com>, trond@netapp.com,
        linux-nfs@vger.kernel.org
Date: Wed, 01 Jun 2011 14:07:01 -0400
In-Reply-To: <4DE65202.2010502@panasas.com>
References: <1306898310-9229-1-git-send-email-dros@netapp.com>
	 <4DE5D287.603@panasas.com>
	 <09816808-BA7B-4EAF-A18A-866B5A98BF25@netapp.com>
	 <4DE65202.2010502@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1306951621.3873.45.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-06-01 at 17:51 +0300, Benny Halevy wrote: 
> I think the following should work:
> 
> Benny
> 
> git diff --stat -p -M
>  fs/nfs/nfs4filelayout.c |   10 ++++++++++
>  1 files changed, 10 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> index 4269088..9f1d445 100644
> --- a/fs/nfs/nfs4filelayout.c
> +++ b/fs/nfs/nfs4filelayout.c
> @@ -661,6 +661,16 @@ filelayout_pg_test(struct nfs_pageio_descriptor
> *pgio, struct nfs_page *prev,
>  	u64 p_stripe, r_stripe;
>  	u32 stripe_unit;
> 
> +	/*
> +	 * FIXME: ideally we should be able to coalesce all requests
> +	 * that are not block boundary aligned, but currently this
> +	 * is problematic for the case of bsize < PAGE_CACHE_SIZE,
> +	 * since nfs_flush_multi and nfs_pagein_multi assume you
> +	 * can have only one struct nfs_page.
> +	 */
> +	if (desc->pg_bsize < PAGE_SIZE)
> +		return 0;
> +
>  	if (!pnfs_generic_pg_test(pgio, prev, req))
>  		return 0;

So, there are several things that bother me about pnfs_generic_pg_test()
too now that I'm looking more closely at it:

     1. If the intention is to coalesce 'prev' and 'req', shouldn't we
        be asking for a layout with req_offset(prev) instead of
        req_offset(req)? 
     2. If we're only requesting a layout of length pg_count, don't we
        still need to test the layout length that the server actually
        returned before we can allow the coalescing? 
     3. if (!pgio->lseg), shouldn't we be returning an error of some
        sort? Right now we're returning 'true', and allowing the
        coalesce to occur. 
     4. Furthermore, shouldn't that test guarding the
        pnfs_update_layout() call rather be an 'if (pgio->pg_lseg ==
        NULL)' instead of looking at the values of pg_count and
        prev->wb_bytes?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

