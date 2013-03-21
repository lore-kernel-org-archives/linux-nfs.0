Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:39814 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755858Ab3CUN7e convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Mar 2013 09:59:34 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Benny Halevy <bhalevy@tonian.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Boaz Harrosh <bharrosh@panasas.com>, Peng Tao <bergwolf@gmail.com>
Subject: Re: [PATCH 3/3] NFSv4.1: Add a helper pnfs_commit_and_return_layout
Date: Thu, 21 Mar 2013 13:59:32 +0000
Message-ID: <1363874371.3557.3.camel@leira.trondhjem.org>
References: <1363801148-29998-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1363801148-29998-2-git-send-email-Trond.Myklebust@netapp.com>
	 <1363801148-29998-3-git-send-email-Trond.Myklebust@netapp.com>
	 <514AEE9A.3090907@tonian.com>
In-Reply-To: <514AEE9A.3090907@tonian.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-03-21 at 13:27 +0200, Benny Halevy wrote:
> On 2013-03-20 19:39, Trond Myklebust wrote:
> > In order to be able to safely return the layout in nfs4_proc_setattr,
> > we need to block new uses of the layout, wait for all outstanding
> > users of the layout to complete, commit the layout and then return it.
> > 
> > This patch adds a helper in order to do all this safely.
> > 
> > Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> > Cc: Boaz Harrosh <bharrosh@panasas.com>
> > ---
> >  fs/nfs/nfs4proc.c |  2 +-
> >  fs/nfs/pnfs.c     | 22 ++++++++++++++++++++++
> >  fs/nfs/pnfs.h     |  6 ++++++
> >  3 files changed, 29 insertions(+), 1 deletion(-)
> > 
> > diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> > index 5122753..c560c8f 100644
> > --- a/fs/nfs/nfs4proc.c
> > +++ b/fs/nfs/nfs4proc.c
> > @@ -2695,7 +2695,7 @@ nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
> >  	int status;
> >  
> >  	if (pnfs_ld_layoutret_on_setattr(inode))
> > -		pnfs_return_layout(inode);
> > +		pnfs_commit_and_return_layout(inode);
> >  
> >  	nfs_fattr_init(fattr);
> >  	
> > diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> > index 45badca..5a5e14d 100644
> > --- a/fs/nfs/pnfs.c
> > +++ b/fs/nfs/pnfs.c
> > @@ -868,6 +868,28 @@ out:
> >  }
> >  EXPORT_SYMBOL_GPL(_pnfs_return_layout);
> >  
> > +int
> > +pnfs_commit_and_return_layout(struct inode *inode)
> > +{
> > +	struct pnfs_layout_hdr *lo;
> > +	int ret;
> > +
> > +	spin_lock(&inode->i_lock);
> > +	lo = NFS_I(inode)->layout;
> > +	if (lo == NULL) {
> > +		spin_unlock(&inode->i_lock);
> > +		return 0;
> > +	}
> > +	/* Block new layoutgets and read/write to ds */
> > +	lo->plh_block_lgets++;
> > +	spin_unlock(&inode->i_lock);
> > +	filemap_fdatawait(inode->i_mapping);
> > +	ret = pnfs_layoutcommit_inode(inode, true);
> > +	if (ret == 0)
> > +		ret = _pnfs_return_layout(inode);
> 
> else {
> 	spin_lock(&inode->i_lock);
> 	lo->plh_block_lgets--;
> 	spin_unlock(&inode->i_lock);
> }
> 
> ?

Yeah... We should probably do that unconditionally. That means we need
to pin the layout, though. I'll fix and resend.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
