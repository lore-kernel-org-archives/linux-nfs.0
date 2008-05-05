From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] NFS: Ensure that 'noac' and/or 'actimeo=0' turn off
	attribute caching
Date: Mon, 05 May 2008 11:23:53 -0400
Message-ID: <1210001033.7409.1.camel@localhost>
References: <20080502202502.29449.81285.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
	 <6A5A94A9-6F7A-469C-926D-A39B18381FFE@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:40607 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759435AbYEEPX5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 May 2008 11:23:57 -0400
In-Reply-To: <6A5A94A9-6F7A-469C-926D-A39B18381FFE@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2008-05-05 at 11:02 -0400, Chuck Lever wrote:
> Hi Trond-
> 
> On May 2, 2008, at 4:25 PM, Trond Myklebust wrote:
> > Both the 'noac' and 'actimeo=0' mount options should ensure that  
> > attributes
> > are not cached, however a bug in nfs_attribute_timeout() means that
> > currently, the attributes may in fact get cached for up to one  
> > jiffy. This
> > has been seen to cause corruption in some applications.
> >
> > The reason for the bug is that the time_in_range() test returns  
> > 'true' as
> > long as the current time lies between nfsi->read_cache_jiffies and
> > nfsi->read_cache_jiffies + nfsi->attrtimeo. In other words, if jiffies
> > equals nfsi->read_cache_jiffies, then we still cache the attribute  
> > data.
> >
> > Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> > ---
> >
> > fs/nfs/inode.c |    7 +++++++
> > 1 files changed, 7 insertions(+), 0 deletions(-)
> >
> > diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> > index 5cb3345..38f06d3 100644
> > --- a/fs/nfs/inode.c
> > +++ b/fs/nfs/inode.c
> > @@ -707,6 +707,13 @@ int nfs_attribute_timeout(struct inode *inode)
> >
> > 	if (nfs_have_delegation(inode, FMODE_READ))
> > 		return 0;
> > +	/*
> > +	 * Special case: if the attribute timeout is set to 0, then we
> > +	 * 		 treat the cache as having expired (unless we
> > +	 * 		 have a delegation).
> > +	 */
> > +	if (nfsi->attrtimeo == 0)
> > +		return 1;
> > 	return !time_in_range(jiffies, nfsi->read_cache_jiffies, nfsi- 
> > >read_cache_jiffies + nfsi->attrtimeo);
> > }
> 
> Do nfs_access_get_cached() and nfs_update_inode() have the same issue?

nfs_access_get_cached() probably has the same issue, but I can't see how
nfs_update_inode() would. Could you explain?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
