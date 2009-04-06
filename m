From: Geert Uytterhoeven <Geert.Uytterhoeven-osDt5Q4Chk1BDgjK7y7TUQ@public.gmane.org>
Subject: Re: bus errors on nfs writes in latest git
Date: Mon, 6 Apr 2009 17:37:03 +0200 (CEST)
Message-ID: <alpine.LRH.2.00.0904061731260.11076@vixen.sonytel.be>
References: <20090404161447.GE495@fieldses.org> <1238861949.8114.3.camel@heimdal.trondhjem.org> <1238862470.8114.5.camel@heimdal.trondhjem.org> <20090405202233.GA16937@fieldses.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org, Nick Piggin <npiggin@suse.de>,
	linux-kernel@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from vervifontaine.sonytel.be ([80.88.33.193]:42470 "EHLO
	pophost.sonytel.be" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756963AbZDFPhI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Apr 2009 11:37:08 -0400
In-Reply-To: <20090405202233.GA16937@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 5 Apr 2009, J. Bruce Fields wrote:
> On Sat, Apr 04, 2009 at 12:27:50PM -0400, Trond Myklebust wrote:
> > On Sat, 2009-04-04 at 12:19 -0400, Trond Myklebust wrote:
> > > On Sat, 2009-04-04 at 12:14 -0400, J. Bruce Fields wrote:
> > > > My regular connecthon tests are reporting bus errors on the "wr=
ite/read
> > > > 30 MB file" on recent upstream kernels.  I'm travelling and hav=
en't had
> > > > a chance to do anything beyond kick off a dumb git-bisect, whic=
h pointed
> > > > the blame at the following commit.  Any ideas?
> >=20
> > The following patch should fix it.
>=20
> Thanks--confirmed.  For what it's worth:
>=20
> 	Tested-by: J. Bruce Fields <bfields@citi.umich.edu>

JFYI, I was also seeing bus errors and read() returning EFAULT with cur=
rent
mainline on both PS3 (ppc64) and Sequoia (ppc32). So far I only saw it
happening doing:
  - apt-get update
  - apt-get upgrade
  - apt-get install

I tried bisecting it, but unfortunately it was not 100% reproducible.
So far the oldest version where I saw it fail was 2.6.29-07100-g833bb30=
=2E
It _looks_ like 2.6.29-06619-ge5824c9 is OK, but I'm not 100% sure.

At first I didn't think of NFS (I'm indeed using nfsroot), but when sea=
rching
for `bus error' I noticed this thread.

Your patch seems to fix it (I added a printk so I would notice when the=
 bad
case got triggered), and the commit that introduced the problem lies wi=
thin
the works/fails range I discovered, so

Tested-by: Geert Uytterhoeven <Geert.Uytterhoeven-osDt5Q4Chk1BDgjK7y7TUQ@public.gmane.org>

Thanks!

With kind regards,

Geert Uytterhoeven
Software Architect

Sony Techsoft Centre Europe
The Corporate Village =B7 Da Vincilaan 7-D1 =B7 B-1935 Zaventem =B7 Bel=
gium

Phone:    +32 (0)2 700 8453
=46ax:      +32 (0)2 700 8622
E-mail:   Geert.Uytterhoeven-osDt5Q4Chk1BDgjK7y7TUQ@public.gmane.org
Internet: http://www.sony-europe.com/

A division of Sony Europe (Belgium) N.V.
VAT BE 0413.825.160 =B7 RPR Brussels
=46ortis =B7 BIC GEBABEBB =B7 IBAN BE41293037680010

> >=20
> > Cheers
> >  Trond
> > ---------------------------------------------------------------
> > >From b7a178f4fab331821b8cff384e1954e62aa63e52 Mon Sep 17 00:00:00 =
2001
> > From: Trond Myklebust <Trond.Myklebust@netapp.com>
> > Date: Sat, 4 Apr 2009 12:22:57 -0400
> > Subject: [PATCH] NFS: Fix the return value in nfs_page_mkwrite()
> >=20
> > Commit c2ec175c39f62949438354f603f4aa170846aabb (mm: page_mkwrite c=
hange
> > prototype to match fault) exposed a bug in the NFS implementation o=
f
> > page_mkwrite. We should be returning 0 on success...
> >=20
> > Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> > ---
> >  fs/nfs/file.c |    2 --
> >  1 files changed, 0 insertions(+), 2 deletions(-)
> >=20
> > diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> > index 3523b89..5a97bcf 100644
> > --- a/fs/nfs/file.c
> > +++ b/fs/nfs/file.c
> > @@ -516,8 +516,6 @@ static int nfs_vm_page_mkwrite(struct vm_area_s=
truct *vma, struct vm_fault *vmf)
> >  		goto out_unlock;
> > =20
> >  	ret =3D nfs_updatepage(filp, page, 0, pagelen);
> > -	if (ret =3D=3D 0)
> > -		ret =3D pagelen;
> >  out_unlock:
> >  	unlock_page(page);
> >  	if (ret)
> > --=20
> > 1.6.0.4
> >=20
> >=20
> > --=20
> > Trond Myklebust
> > Linux NFS client maintainer
> >=20
> > NetApp
> > Trond.Myklebust@netapp.com
> > www.netapp.com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>=20

With kind regards,

Geert Uytterhoeven
Software Architect

Sony Techsoft Centre Europe
The Corporate Village =B7 Da Vincilaan 7-D1 =B7 B-1935 Zaventem =B7 Bel=
gium

Phone:    +32 (0)2 700 8453
=46ax:      +32 (0)2 700 8622
E-mail:   Geert.Uytterhoeven-osDt5Q4Chk1BDgjK7y7TUQ@public.gmane.org
Internet: http://www.sony-europe.com/

A division of Sony Europe (Belgium) N.V.
VAT BE 0413.825.160 =B7 RPR Brussels
=46ortis =B7 BIC GEBABEBB =B7 IBAN BE41293037680010
