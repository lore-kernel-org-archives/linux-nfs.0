From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [PATCH 4/5] lockd: Remove unused nfsd headers #includes
Date: Wed, 25 Nov 2009 15:23:24 -0500
Message-ID: <20091125202323.GJ32502@fieldses.org>
References: <4B0C1EB7.50508@panasas.com> <4B0C1FE0.8040105@panasas.com> <20091125201011.GG32502@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	linux-parisc <linux-parisc@vger.kernel.org>,
	sparclinux <sparclinux@vger.kernel.org>,
	linux-s390 <linux-s390@vger.kernel.org>,
	NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53216 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753574AbZKYUWf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Nov 2009 15:22:35 -0500
In-Reply-To: <20091125201011.GG32502@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 25, 2009 at 03:10:11PM -0500, J. Bruce Fields wrote:
> On Tue, Nov 24, 2009 at 08:03:12PM +0200, Boaz Harrosh wrote:
> > 
> > In what history where these ever needed? Well not
> > any more.
> 
> Applied, thanks.--b.

Um, I said that before I actually tried to compile it....  OK, dropping
for now (assuming I'm missing some earlier patch).

--b.

> 
> > 
> > Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> > ---
> >  fs/lockd/svc4proc.c |    4 ----
> >  fs/lockd/svcproc.c  |    4 ----
> >  2 files changed, 0 insertions(+), 8 deletions(-)
> > 
> > diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
> > index bd173a6..a7966ee 100644
> > --- a/fs/lockd/svc4proc.c
> > +++ b/fs/lockd/svc4proc.c
> > @@ -11,10 +11,6 @@
> >  #include <linux/time.h>
> >  #include <linux/slab.h>
> >  #include <linux/smp_lock.h>
> > -#include <linux/in.h>
> > -#include <linux/sunrpc/svc.h>
> > -#include <linux/sunrpc/clnt.h>
> > -#include <linux/nfsd/nfsd.h>
> >  #include <linux/lockd/lockd.h>
> >  #include <linux/lockd/share.h>
> >  
> > diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
> > index e1d28dd..56c9519 100644
> > --- a/fs/lockd/svcproc.c
> > +++ b/fs/lockd/svcproc.c
> > @@ -11,10 +11,6 @@
> >  #include <linux/time.h>
> >  #include <linux/slab.h>
> >  #include <linux/smp_lock.h>
> > -#include <linux/in.h>
> > -#include <linux/sunrpc/svc.h>
> > -#include <linux/sunrpc/clnt.h>
> > -#include <linux/nfsd/nfsd.h>
> >  #include <linux/lockd/lockd.h>
> >  #include <linux/lockd/share.h>
> >  
> > -- 
> > 1.6.5.2
> > 
> > 
