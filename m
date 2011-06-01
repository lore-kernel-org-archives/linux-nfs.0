Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:42912 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752657Ab1FAMOO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Jun 2011 08:14:14 -0400
Subject: Re: [PATCH] NFS: filelayout should use nfs_generic_pg_test
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Weston Andros Adamson <dros@netapp.com>, trond@netapp.com,
        linux-nfs@vger.kernel.org
Date: Wed, 01 Jun 2011 08:14:12 -0400
In-Reply-To: <4DE5D287.603@panasas.com>
References: <1306898310-9229-1-git-send-email-dros@netapp.com>
	 <4DE5D287.603@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1306930452.25992.61.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-06-01 at 08:47 +0300, Boaz Harrosh wrote: 
> On 06/01/2011 06:18 AM, Weston Andros Adamson wrote:
> > Use nfs_generic_pg_test instead of pnfs_generic_pg_test.
> > 
> > This fixes the BUG at fs/nfs/write.c:941 introduced by
> > 89a58e32d9105c01022a757fb32ddc3b51bf0025.
> > 
> > I was able to trigger this BUG reliably using pynfs in pnfs mode,
> > by using dd(1) to write many small blocks.
> > 
> > Signed-off-by: Weston Andros Adamson <dros@netapp.com>
> > ---
> > Fix proposed by Trond.
> > 
> > Benny- Does this make sense?
> > 
> >  fs/nfs/nfs4filelayout.c  |    2 +-
> >  fs/nfs/pagelist.c        |    5 ++++-
> >  include/linux/nfs_page.h |    3 ++-
> >  3 files changed, 7 insertions(+), 3 deletions(-)
> > 
> > diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> > index 4269088..1c3bb72 100644
> > --- a/fs/nfs/nfs4filelayout.c
> > +++ b/fs/nfs/nfs4filelayout.c
> > @@ -661,7 +661,7 @@ filelayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
> >  	u64 p_stripe, r_stripe;
> >  	u32 stripe_unit;
> >  
> > -	if (!pnfs_generic_pg_test(pgio, prev, req))
> > +	if (!nfs_generic_pg_test(pgio, prev, req))
> >  		return 0;
> >  
> 
> pnfs_generic_pg_test is the one that gets the layout.
> 
> What you've done is revert to MDS IO

The "files" layout type always gets the layout in the pg_doio() method
instead of the pg_test().

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

