From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: [PATCH 7/7] nfsstat: add -D/--diff-stat
Date: Tue, 7 Aug 2007 19:31:46 -0400
Message-ID: <4d569c330708071631k3e2dd076o8c165f8792ac520e@mail.gmail.com>
References: <Pine.BSO.4.64.0707311719160.13370@citi.umich.edu>
	<20070807211920.GA16557@uio.no>
	<Pine.BSO.4.64.0708071721280.26009@citi.umich.edu>
	<20070807215359.GA16870@uio.no>
	<4d569c330708071508l37c03338x5f4d77f9182ed04e@mail.gmail.com>
	<Pine.BSO.4.64.0708071810420.26009@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Andrew Richardson <chardson@umich.edu>, nfs@lists.sourceforge.net,
	Alex Soule <soule@umich.edu>
To: "david m. richter" <richterd@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IIYWc-0004GB-SB
	for nfs@lists.sourceforge.net; Tue, 07 Aug 2007 16:31:43 -0700
Received: from rv-out-0910.google.com ([209.85.198.190])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IIYWg-0007Yf-SM
	for nfs@lists.sourceforge.net; Tue, 07 Aug 2007 16:31:47 -0700
Received: by rv-out-0910.google.com with SMTP id k15so1644411rvb
	for <nfs@lists.sourceforge.net>; Tue, 07 Aug 2007 16:31:46 -0700 (PDT)
In-Reply-To: <Pine.BSO.4.64.0708071810420.26009@citi.umich.edu>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On 8/7/07, david m. richter <richterd@citi.umich.edu> wrote:
> On Tue, 7 Aug 2007, Kevin Coffman wrote:
>
> > On 8/7/07, Steinar H. Gunderson <sgunderson@bigfoot.com> wrote:
> > > On Tue, Aug 07, 2007 at 05:26:13PM -0400, david m. richter wrote:
> > > >       does anyone know the reason behind no-floating-point-on-Alpha?
> > >
> > > It seems to have been added as part of this changelog entry (slightly munged
> > > in git, perhaps something went wrong from the CVS import):
> > >
> > >   2005-12-20 Kevin Coffman <kwc@citi.umich.edu> NeilBrown <neilb@suse.de>
> > >           Substantial Makefile/configure rewrite.
> > >           Run 'autogen.sh' to create "Makefile.in" etc.
> > >
> > >           Also add -D_FILE_OFFSET_BITS=64 to CPP_FLAGS so that mountd can
> > >           stat and export files larger than 2Gig.
> > >
> > >           1.0.8-rc2 released
> > >
> > > I sort of suspect it was just copied blindly from somewhere...
> >
> > Actually, it was copied carefully from the old config.mk.in :-)
> > It was in config.mk.in from the beginning, AFAICT.
>
>         i'm curious -- is this something that can be removed from the
> build stuff, then?  (i haven't an Alpha on which to test..)

I've been looking back at the history.  These alpha flags came from
the knfsd code.  Looking at today's linux kernel code, it still has
these flags in arch/alpha/Makefile.  Whether they are required for
user-land code, I don't know.  (Whether they are req'd or really used
for kernel code, or are just some LCD thing, I don't know.)

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
