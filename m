Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32548 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934182Ab1IORsc convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Sep 2011 13:48:32 -0400
Subject: Re: [PATCH] nfs4: serialize layoutcommit
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Peng Tao <bergwolf@gmail.com>
Cc: bhalevy@tonian.com, Vitaliy Gusev <gusev.vitaliy@nexenta.com>,
        linux-nfs@vger.kernel.org, Peng Tao <peng_tao@emc.com>
Date: Thu, 15 Sep 2011 13:48:17 -0400
In-Reply-To: <1316108327.5271.4.camel@lade.trondhjem.org.localdomain>
References: <1315802900-1548-1-git-send-email-bergwolf@gmail.com>
	 <1316108327.5271.4.camel@lade.trondhjem.org.localdomain>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1316108897.5271.6.camel@lade.trondhjem.org.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-09-15 at 13:38 -0400, Trond Myklebust wrote: 
> On Sun, 2011-09-11 at 21:48 -0700, Peng Tao wrote: 
> > Current pnfs_layoutcommit_inode can not handle parallel layoutcommit.
> > As Trond suggested, there is no need for client to optimize for
> > parallel layoutcommit. The patch add NFS_INO_LAYOUTCOMMITTING flag to
> > mark inflight layoutcommit and serialize lalyoutcommit with it.
> > It also fixes the pls_lc_list corruption that Vitaliy found.
> > 
> > Reported-by: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
> > Signed-off-by: Peng Tao <peng_tao@emc.com>
> > ---
> >  fs/nfs/nfs4proc.c      |    6 ++++++
> >  fs/nfs/pnfs.c          |    9 +++++++++
> >  include/linux/nfs_fs.h |    1 +
> >  3 files changed, 16 insertions(+), 0 deletions(-)
> > 
> > diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> > index 4700fae..a7ce210 100644
> > --- a/fs/nfs/nfs4proc.c
> > +++ b/fs/nfs/nfs4proc.c
> > @@ -5970,6 +5970,7 @@ static void nfs4_layoutcommit_release(void *calldata)
> >  {
> >  	struct nfs4_layoutcommit_data *data = calldata;
> >  	struct pnfs_layout_segment *lseg, *tmp;
> > +	unsigned long *bitlock = &NFS_I(data->args.inode)->flags;
> >  
> >  	pnfs_cleanup_layoutcommit(data);
> >  	/* Matched by references in pnfs_set_layoutcommit */
> > @@ -5979,6 +5980,11 @@ static void nfs4_layoutcommit_release(void *calldata)
> >  				       &lseg->pls_flags))
> >  			put_lseg(lseg);
> >  	}
> > +
> > +	clear_bit_unlock(NFS_INO_LAYOUTCOMMITTING, bitlock);
> > +	smp_mb__after_clear_bit();
> > +	wake_up_bit(bitlock, NFS_INO_LAYOUTCOMMITTING);
> > +
> >  	put_rpccred(data->cred);
> >  	kfree(data);
> >  }
> > diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> > index b483bbc..fb71def 100644
> > --- a/fs/nfs/pnfs.c
> > +++ b/fs/nfs/pnfs.c
> > @@ -1451,10 +1451,19 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
> >  		goto out;
> >  	}
> >  
> > +	if (!test_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags) ||
> > +	    (status = wait_on_bit_lock(&nfsi->flags, NFS_INO_LAYOUTCOMMITTING,
> > +				nfs_wait_bit_killable, TASK_KILLABLE))) {
> 
> You want the sleeping behaviour above to be subject to the 'sync' flag
> (in the same way we do for regular commit). If !sync, then try to grab
> the bit lock anyway, and exit on failure.

By the way. Shouldn't pnfs_layoutcommit_inode() also be marking the
inode as dirty on failure?


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

