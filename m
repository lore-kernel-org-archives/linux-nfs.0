Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.152.1]:59374 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754405Ab0BDRTm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Feb 2010 12:19:42 -0500
Date: Thu, 4 Feb 2010 11:20:16 -0600
From: bpm@sgi.com
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [RFC PATCH 4/4] If 'wsync' pass datasync=1 to vfs_fsync().
Message-ID: <20100204172016.GJ5702@sgi.com>
References: <20100203233755.17677.96582.stgit@case> <20100203234444.17677.32390.stgit@case> <20100204151926.GA22014@infradead.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100204151926.GA22014@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Feb 04, 2010 at 10:19:26AM -0500, Christoph Hellwig wrote:
> On Wed, Feb 03, 2010 at 05:44:44PM -0600, Ben Myers wrote:
> > 
> > ---
> >  fs/nfsd/vfs.c |   39 +++++++++++++++++++++++++--------------
> >  1 files changed, 25 insertions(+), 14 deletions(-)
> > 
> > diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> > index 89eb1b2..4b1973b 100644
> > --- a/fs/nfsd/vfs.c
> > +++ b/fs/nfsd/vfs.c
> > @@ -418,7 +418,7 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
> >  	if (!err) {
> >  		if (EX_ISSYNC(fhp->fh_export)) {
> >  			if (EX_ISWSYNC(fhp->fh_export)) {
> > -				vfs_fsync(NULL, dentry, 0);
> > +				vfs_fsync(NULL, dentry, 1);
> 
> I think this is incorrect.  datasync = 1 means to only write out
> metadata that is required to access the file data.

My thinking there was that the XFS wsync mount option would have ensured
that the metadata that changed is already in the log.  I wonder if when
using the wsync xfs mount option, could one drop the vfs_fsync
altogether?  Looks to me like O_SYNC would also have taken care of any
metadata that is required to access the file data.

> The write_inode code
> makes sure all metadata goes out, which AFAIK is what the NFS protocol
> requires from us anyway for all these metadata operations.

I think only the data/metadata that changed for the rpc in question
needs to end up on stable storage.

> Note that this does not invalidate your XFS numbers as right now XFS
> doesn't actually implement the datasync == 1 optimization, although I'm
> about to send a patch to do that.  The updsize is that this will
> make your patchset quite a bit simpler :)

Cool.  ;)

-Ben
