From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 015 of 20] knfsd: nfsd4: make readonly access depend on
 pseudoflavor
Date: Fri, 13 Jul 2007 01:47:22 -0700
Message-ID: <20070713014722.562a8f01.akpm@linux-foundation.org>
References: <20070710121949.12548.patches@notabene>
	<1070710022749.13539@suse.de>
	<20070713001215.b4b57a5b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
To: NeilBrown <neilb@suse.de>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S936222AbXGMIrt@vger.kernel.org>
In-Reply-To: <20070713001215.b4b57a5b.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Fri, 13 Jul 2007 00:12:15 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:

> On Tue, 10 Jul 2007 12:27:49 +1000 NeilBrown <neilb@suse.de> wrote:
> 
> > 
> > From: J. Bruce Fields <bfields@citi.umich.edu>
> > 
> > Allow readonly access to vary depending on the pseudoflavor, using the
> > flag passed with each pseudoflavor in the export downcall.
> > 
> > Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
> > Signed-off-by: Neil Brown <neilb@suse.de>
> > 
> > ### Diffstat output
> >  ./include/linux/nfsd/export.h |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff .prev/include/linux/nfsd/export.h ./include/linux/nfsd/export.h
> > --- .prev/include/linux/nfsd/export.h	2007-07-10 11:40:31.000000000 +1000
> > +++ ./include/linux/nfsd/export.h	2007-07-10 11:50:43.000000000 +1000
> > @@ -43,7 +43,7 @@
> >  #define NFSEXP_ALLFLAGS		0xFE3F
> >  
> >  /* The flags that may vary depending on security flavor: */
> > -#define NFSEXP_SECINFO_FLAGS	0
> > +#define NFSEXP_SECINFO_FLAGS	NFSEXP_READONLY
> >  
> >  #ifdef __KERNEL__
> >  
> 
> You have two patches called "knfsd: nfsd4: make readonly access depend on
> pseudoflavor".  This one appears to have the wrong title and changelog.

hm, I ended up accidentally losing this patch altogether.  But
knfsd-nfsd-enforce-per-flavor-id-squashing.patch rubs out its effects, so
we end up OK.
