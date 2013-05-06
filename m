Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55390 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754592Ab3EFPEb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 May 2013 11:04:31 -0400
Date: Mon, 6 May 2013 11:04:28 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: Steve Dickson <SteveD@redhat.com>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] mountd: Fix is_subdirectory again.
Message-ID: <20130506150428.GD15476@fieldses.org>
References: <20130502170511.646e2717@notabene.brown>
 <20130502151634.GE15728@fieldses.org>
 <20130506144413.46b6f37b@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130506144413.46b6f37b@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 06, 2013 at 02:44:13PM +1000, NeilBrown wrote:
> On Thu, 2 May 2013 11:16:34 -0400 "J. Bruce Fields" <bfields@fieldses.org>
> wrote:
> 
> > On Thu, May 02, 2013 at 05:05:11PM +1000, NeilBrown wrote:
> > > 
> > > 
> > > Hi Steve,
> > >  I just noticed
> > > 
> > > commit ebe2826ca571a3959c3b5c8e29686c621f2775cf
> > > Author: Steve Dickson <steved@redhat.com>
> > > Date:   Sat Mar 23 10:30:17 2013 -0400
> > > 
> > >     mountd: regression in crossmounts
> > > 
> > > Sorry I missed the email you presumably sent me to let me know
> > > that I had caused a regression.
> > 
> > Yup.  The strategy around here is to bury people in email and trust they
> > have industrial-strength filtering.
> > 
> > And I could have added Neil on the cc: too and forgot, oops:
> > 
> > 	http://marc.info/?l=linux-nfs&m=136404930104976&w=2
> > 
> > > Here is the proper fix.
> > 
> > I'm dense.  I still had to scratch my head a while:
> > 
> > So: in a case like the one steved gives:
> > 
> > 	/home *(rw,fsid=0,crossmnt)
> > 	/home/fs1 *(rw,crossmnt)
> > 	/home/fs1/fs2/fs3 *(rw,nohide)
> > 
> > where nfsd_fh is asked to look for an export with fsid=0, it gets a
> > match on the export of /home.  But that loop there keeps going in case
> > it finds some better match.  In particular it considers any mountpoints
> > under /home as candidates, since /home has "crossmnt".  And they all
> > match too.  So it considers in sequence the possibilities:
> > 
> > 	(found=/export of /home, found_path=/home)
> > 	(found=/export of /home, found_path=/home/fs1)
> > 	(found=/export of /home, found_path=/home/fs1/fs2/fs3)
> > 
> > The subexport() test--designed to favor crossmnt exports which are
> > "closer" to the target filesystem--passes in each case, so we end up
> > taking the last.
> > 
> > So we pass down the longest path to the kernel, it does an export upcall
> > for that path, the hilarity ensues.
> > 
> > Anyway:
> > 
> > 	Acked-by: J. Bruce Fields <bfields@redhat.com>
> 
> Thanks.
> 
> > 
> > But this all still gives me a mild headache:
> > 
> > 	- it only works if we iterate through the submounts in the
> > 	  correct order?
> 
> Does it?  nfsd_fh() is trying to find the export for a given file handle.
>   For every export it tries that filesystem and (if CROSSMOUNT) ever
>   filesystem mounted below there.
>   It only considers filesystem for which the fsid matches.
>   Of those, it chooses the exp which is 'lowest' in the hierarchy.
> 
> I don't think the result of that can be dependant on order.

Well, my only point was that we depend on first trying the main export
and then the filesystems mounted below--as that's probably how it would
work under any reasonable organization of the code, I suppose that's not
so fragile.

> > 	- should fsid= be inherited by crossmnt anyway?
> 
> No...
> If you have an export with fsid=N,crossmnt and a filehandle arrives for
> fsid=N, then when we first look at that export match_fsid() will report a
> match and 'found' will be set.
> nfsd_fh() will loop around and try again for the next entry in /etc/mtab
> which is under that same filesystem.  It will get a match_fsid() as well but
> as subexport() will report "no" (as it is the same export), no change will be
> made to found.  It also will not report that "X and Y have same file handle
> for Z, using first" as the e_paths will match.

Oh, I see--you're right.

> So it works as is.  Maybe the code could be made clearer though.
> 
> 
> > 	- nfsd_fh() is too long, and the logic (with those extra loop
> > 	  control variables declared static inside the CROSSMOUNT case)
> > 	  could be more straightforward.
> 
> You have a history of taking my too-long functions and breaking them up into
> manageable bits (kernel commit 3211af1119174fbe8b).  Maybe you could try
> again :-)

Yeah, yeah, yeah.  Maybe the compulsion will take me some day.  For the
sake of several other pressing projects, hopefully not today.

--b.
