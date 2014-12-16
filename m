Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f170.google.com ([209.85.192.170]:44507 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751044AbaLPWDC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Dec 2014 17:03:02 -0500
Received: by mail-pd0-f170.google.com with SMTP id v10so14682008pde.15
        for <linux-nfs@vger.kernel.org>; Tue, 16 Dec 2014 14:03:00 -0800 (PST)
Date: Tue, 16 Dec 2014 14:02:58 -0800
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Trond Myklebust <Trond.Myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 39/50] nfs/flexfiles: send layoutreturn before freeing
 lseg
Message-ID: <20141216220258.GE95519@kitty>
References: <1418756513-95187-1-git-send-email-loghyr@primarydata.com>
 <1418756513-95187-40-git-send-email-loghyr@primarydata.com>
 <5490A020.1060000@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5490A020.1060000@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 16, 2014 at 04:12:00PM -0500, Anna Schumaker wrote:
> On 12/16/2014 02:01 PM, Tom Haynes wrote:
> > From: Peng Tao <tao.peng@primarydata.com>
> > 
> > Otherwise we'll lose error tracking information when
> > encoding layoutreturn.
> > 
> > Signed-off-by: Peng Tao <tao.peng@primarydata.com>
> > Signed-off-by: Tom Haynes <loghyr@primarydata.com>
> > ---
> >  fs/nfs/pnfs.c | 19 +++++++++++++------
> >  1 file changed, 13 insertions(+), 6 deletions(-)
> > 
> > diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> > index e123cfc..35465cb 100644
> > --- a/fs/nfs/pnfs.c
> > +++ b/fs/nfs/pnfs.c
> > @@ -355,7 +355,7 @@ pnfs_layout_need_return(struct pnfs_layout_hdr *lo,
> >  		return false;
> >  
> >  	list_for_each_entry(s, &lo->plh_segs, pls_list)
> > -		if (test_bit(NFS_LSEG_LAYOUTRETURN, &lseg->pls_flags))
> > +		if (s != lseg && test_bit(NFS_LSEG_LAYOUTRETURN, &s->pls_flags))
> >  			return false;
> >  
> >  	*stateid = lo->plh_stateid;
> > @@ -386,15 +386,22 @@ pnfs_put_lseg(struct pnfs_layout_segment *lseg)
> >  		enum pnfs_iomode iomode;
> >  
> >  		pnfs_get_layout_hdr(lo);
> > -		pnfs_layout_remove_lseg(lo, lseg);
> >  		need_return = pnfs_layout_need_return(lo, lseg,
> >  						      &stateid, &iomode);
> > -		spin_unlock(&inode->i_lock);
> > -		pnfs_free_lseg(lseg);
> > -		if (need_return)
> > +		if (need_return) {
> > +			spin_unlock(&inode->i_lock);
> > +			/* hdr reference dropped in nfs4_layoutreturn_release */
> >  			pnfs_send_layoutreturn(lo, stateid, iomode);
> > -		else
> > +			spin_lock(&inode->i_lock);
> > +			pnfs_layout_remove_lseg(lo, lseg);
> > +			spin_unlock(&inode->i_lock);
> > +			pnfs_free_lseg(lseg);
> > +		} else {
> > +			pnfs_layout_remove_lseg(lo, lseg);
> > +			spin_unlock(&inode->i_lock);
> > +			pnfs_free_lseg(lseg);
> >  			pnfs_put_layout_hdr(lo);
> > +		}
> 
> Is there a way to rephrase this so we're not using every other line to either lock or unlock?

Hi Anna,

This patch:

[PATCH 46/50] nfs/flexfiles: defer sending layoutreturn in pnfs_put_lseg

does do just that.

I could look at consolidating the two patches such that we don't see this ugliness.

Thanks,
Tom

> 
> Anna
> 
> >  	}
> >  }
> >  EXPORT_SYMBOL_GPL(pnfs_put_lseg);
> > 
> 
