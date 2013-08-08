Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:64380 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758137Ab3HHSmg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Aug 2013 14:42:36 -0400
Date: Thu, 8 Aug 2013 14:42:30 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        William Dauchy <william@gandi.net>,
        Pascal Bouchareine <pascal@gandi.net>
Subject: Re: [PATCH v3] NFS: Fix writeback performance issue on cache
 invalidation
Message-ID: <20130808144230.0efdfc2d@tlielax.poochiereds.net>
In-Reply-To: <1375986094.9193.2.camel@leira.trondhjem.org>
References: <1375910064-23731-1-git-send-email-Trond.Myklebust@netapp.com>
	<20130808141130.27cf2b26@tlielax.poochiereds.net>
	<1375986094.9193.2.camel@leira.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 8 Aug 2013 18:21:35 +0000
"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Thu, 2013-08-08 at 14:11 -0400, Jeff Layton wrote:
> > On Wed, 7 Aug 2013 17:14:24 -0400
> > Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> > 
> > > If a cache invalidation is triggered, and we happen to have a lot of
> > > writebacks cached at the time, then the call to invalidate_inode_pages2()
> > > will end up calling ->launder_page() on each and every dirty page in order
> > > to sync its contents to disk, thus defeating write coalescing.
> > > The following patch ensures that we try to sync the inode to disk before
> > > calling invalidate_inode_pages2() so that we do the writeback as efficiently
> > > as possible.
> > > 
> > > Reported-by: William Dauchy <william@gandi.net>
> > > Reported-by: Pascal Bouchareine <pascal@gandi.net>
> > > Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> > > Tested-by: William Dauchy <william@gandi.net>
> > > Reviewed-by: Jeff Layton <jlayton@redhat.com>
> > > ---
> > > v2: Add check for regular file as per Jeff Layton's suggestion.
> > > v3: Minor cleanup and add Jeff as a reviewer
> > > 
> > >  fs/nfs/inode.c | 10 ++++++++--
> > >  1 file changed, 8 insertions(+), 2 deletions(-)
> > > 
> > > diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> > > index af6e806..3ea4f64 100644
> > > --- a/fs/nfs/inode.c
> > > +++ b/fs/nfs/inode.c
> > > @@ -963,9 +963,15 @@ EXPORT_SYMBOL_GPL(nfs_revalidate_inode);
> > >  static int nfs_invalidate_mapping(struct inode *inode, struct address_space *mapping)
> > >  {
> > >  	struct nfs_inode *nfsi = NFS_I(inode);
> > > -	
> > > +	int ret;
> > > +
> > >  	if (mapping->nrpages != 0) {
> > > -		int ret = invalidate_inode_pages2(mapping);
> > > +		if (S_ISREG(inode->i_mode)) {
> > > +			ret = nfs_sync_mapping(mapping);
> > > +			if (ret < 0)
> > > +				return ret;
> > > +		}
> > > +		ret = invalidate_inode_pages2(mapping);
> > >  		if (ret < 0)
> > >  			return ret;
> > >  	}
> > 
> > It occurs to me that we have several places that call nfs_sync_mapping
> > without checking S_ISREG. Are they potentially problematic?
> > 
> > Might it make more sense to move the S_ISREG test inside of
> > nfs_sync_mapping and just have it "return 0" when it's not a regular
> > file?
> 
> I see 5 callers of nfs_sync_mapping() aside from the above: 2 are in the
> O_DIRECT code, the other 3 are all in the file locking code. AFAICS,
> none of those can ever be fed to non-regular files.
> 
> Am I missing anything?
> 

You can lock a directory or device special file though, right?

In practice I don't think there's any way to end up with dirty pages on
a !S_ISREG inode, but in that case, the S_ISREG check here would be
superfluous (though checking it might be a reasonable optimization).

-- 
Jeff Layton <jlayton@redhat.com>
