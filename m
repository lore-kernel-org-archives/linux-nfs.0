From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/2] nfsd4: fix break_lease flags on nfsd open
Date: Sun, 12 Jun 2011 14:26:43 -0400
Message-ID: <20110612182643.GH12149@fieldses.org>
References: <20110609224459.GA22215@fieldses.org>
 <4DF1944D.50806@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, Casey Bodley <cbodley@citi.umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33431 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751638Ab1FLS0o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 12 Jun 2011 14:26:44 -0400
In-Reply-To: <4DF1944D.50806@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 09, 2011 at 11:49:33PM -0400, Benny Halevy wrote:
> On 2011-06-09 18:44, J. Bruce Fields wrote:
> > From: J. Bruce Fields <bfields@redhat.com>
> > 
> > Thanks to Casey Bodley for pointing out that on a read open we pass 0,
> > instead of O_RDONLY, to break_lease, with the result that a read open is
> > treated like a write open for the purposes of lease breaking!
> > 
> > Reported-by: Casey Bodley <cbodley@citi.umich.edu>
> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > ---
> >  fs/nfsd/vfs.c |   15 +++++++++------
> >  1 files changed, 9 insertions(+), 6 deletions(-)
> > 
> > diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> > index f3fb61b..848a4af 100644
> > --- a/fs/nfsd/vfs.c
> > +++ b/fs/nfsd/vfs.c
> > @@ -696,7 +696,15 @@ nfsd_access(struct svc_rqst *rqstp, struct svc_fh *fhp, u32 *access, u32 *suppor
> >  }
> >  #endif /* CONFIG_NFSD_V3 */
> >  
> > +static int nfsd_open_break_lease(struct inode *inode, int access)
> > +{
> > +	unsigned int mode;
> >  
> > +	if (access & NFSD_MAY_NOT_BREAK_LEASE)
> > +		return 0;
> > +	mode = (access & NFSD_MAY_WRITE) ? O_WRONLY : O_RDONLY;
> > +	return break_lease(inode, mode | O_NONBLOCK);
> > +}
> >  
> >  /*
> >   * Open an existing file or directory.
> > @@ -744,12 +752,7 @@ nfsd_open(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
> >  	if (!inode->i_fop)
> >  		goto out;
> >  
> > -	/*
> > -	 * Check to see if there are any leases on this file.
> > -	 * This may block while leases are broken.
> > -	 */
> > -	if (!(access & NFSD_MAY_NOT_BREAK_LEASE))
> > -		host_err = break_lease(inode, O_NONBLOCK | ((access & NFSD_MAY_WRITE) ? O_WRONLY : 0));
> > +	 host_err = nfsd_open_break_lease(inode, access);
> 
> nit: looks like there's an extra space before "host_err ="...

Whoops, yup; fixed.--b.

> 
> Benny
> 
> >  	if (host_err) /* NOMEM or WOULDBLOCK */
> >  		goto out_nfserr;
> >  
