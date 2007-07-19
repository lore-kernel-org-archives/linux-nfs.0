From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [NFS] [PATCH 4/5] knfsd: move EX_RDONLY out of header
Date: Thu, 19 Jul 2007 01:36:59 -0700
Message-ID: <20070719013659.5f8d6c7a.akpm@linux-foundation.org>
References: <2ac9f179334dc7894bb58b1c2fb62837a07fbbdf.1184798679.git.bfields@citi.umich.edu>
	<fbbdd23e675df0288cf80243fdcd5e211fff855b.1184798679.git.bfields@citi.umich.edu>
	<20070719082838.GA2507@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	NeilBrown <neilb@suse.de>, andros@citi.umich.edu,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763656AbXGSIiQ@vger.kernel.org>
In-Reply-To: <20070719082838.GA2507@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Thu, 19 Jul 2007 09:28:38 +0100 Christoph Hellwig <hch@infradead.org> wrote:

> On Wed, Jul 18, 2007 at 06:57:29PM -0400, J. Bruce Fields wrote:
> > From: J. Bruce Fields <bfields@citi.umich.edu>
> > 
> > EX_RDONLY is only called in one place; just put it there.
> > 
> > Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
> > ---
> >  fs/nfsd/vfs.c               |   12 ++++++++++++
> >  include/linux/nfsd/export.h |   12 ------------
> >  2 files changed, 12 insertions(+), 12 deletions(-)
> > 
> > diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> > index 5c97d0e..f2684e5 100644
> > --- a/fs/nfsd/vfs.c
> > +++ b/fs/nfsd/vfs.c
> > @@ -1797,6 +1797,18 @@ nfsd_statfs(struct svc_rqst *rqstp, struct svc_fh *fhp, struct kstatfs *stat)
> >  	return err;
> >  }
> >  
> > +static inline int EX_RDONLY(struct svc_export *exp, struct svc_rqst *rqstp)
> > +{
> > +	struct exp_flavor_info *f;
> > +	struct exp_flavor_info *end = exp->ex_flavors + exp->ex_nflavors;
> > +
> > +	for (f = exp->ex_flavors; f < end; f++) {
> > +		if (f->pseudoflavor == rqstp->rq_flavor)
> > +			return f->flags & NFSEXP_READONLY;
> > +	}
> > +	return exp->ex_flags & NFSEXP_READONLY;
> > +}
> 
> As mentioned last time lease remove the inline qualifier and give it a
> lower-case name.

that's the next patch in the series.
