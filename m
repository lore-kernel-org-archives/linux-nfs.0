Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25804 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752665Ab1AYPxK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Jan 2011 10:53:10 -0500
Date: Tue, 25 Jan 2011 10:53:04 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Bryan Schumaker <bjschuma@netapp.com>, Benny Halevy <bhalevy@panasas.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Thomas Haynes <thomas@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: Patched up cthon source?
Message-ID: <20110125105304.0b300c57@tlielax.poochiereds.net>
In-Reply-To: <1295969912.6867.2.camel@heimdal.trondhjem.org>
References: <E5AAF04F-8A0E-4506-A29D-A0CD4098AA64@netapp.com>
	<83EC814B-1043-46B2-8F5E-E1FB1F5B56BF@oracle.com>
	<4D3DFE40.1070605@panasas.com>
	<4D3ED37D.6020606@netapp.com>
	<20110125095649.446212fd@tlielax.poochiereds.net>
	<1295969912.6867.2.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 25 Jan 2011 10:38:32 -0500
Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> On Tue, 2011-01-25 at 09:56 -0500, Jeff Layton wrote: 
> > On Tue, 25 Jan 2011 08:43:25 -0500
> > Bryan Schumaker <bjschuma@netapp.com> wrote:
> > 
> > > On 01/24/2011 05:33 PM, Benny Halevy wrote:
> > > > this is a problem with the version of nroff on newer distributions.
> > > 
> > > My version of groff (1.21) is splitting the error into two lines, so I am using the following patch.
> > > 
> > > Bryan
> > > 
> > 
> > Yep, this workaround stopped working around for me on my rawhide box
> > broke yesterday for the same reason.
> > 
> > I think this patch may be a better approach than trying to grep out
> > random stuff, but I don't know whether non-GNU tbl programs will barf
> > on it. If anyone has a solaris box handy, could you let me know if
> > this breaks on it?
> > 
> > ----------------------[snip]------------------
> > [PATCH] cthon04: add "nowarn" option to nroff.in tables
> > 
> > This prevents the tbl preprocessor from stuffing warnings into the
> > resulting file, which subsequently can make nroff spew warnings like
> > this on stderr:
> > 
> >     warning: file `nroff.in', around line 47:
> >       table wider than line width
> > 
> > Unfortunately, I'm not sure how non-gnu tbl programs will react to
> > this option, so YMMV.
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  general/nroff.in |    4 ++--
> >  1 files changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/general/nroff.in b/general/nroff.in
> > index 522ac80..a8acb3a 100644
> > --- a/general/nroff.in
> > +++ b/general/nroff.in
> > @@ -18,7 +18,7 @@ benchmarks.
> >  .LP
> >  I ran the benchmarks on the following configurations:
> >  .TS
> > -center;
> > +center nowarn;
> >  l l l l.
> >  CPU	Unix	Fortran	Memory
> >  .sp 4p
> > @@ -38,7 +38,7 @@ A bubble sort of integers.
> >  A prime number generator.
> >  .LP
> >  .TS
> > -center;
> > +center nowarn;
> >   c|c|c s|c s|
> >   c|c|c s|c s|
> >   c|c|c s|c s|
> 
> Here's a radical idea: what say we change the nroff.in file so that it
> no longer tries to fit a 130ish character wide table into an 80
> character wide page?
> 

Agreed...

I actually gave that a try first, but after wasting a half hour or so
on it, I just went "nowarn". I'd be all for fixing it the right way if
someone can suggest a patch...

An even more radical idea that Peter S. suggested a while back would be
to update this test to use something more modern than nroff (XML
parsing maybe?)...

-- 
Jeff Layton <jlayton@redhat.com>
