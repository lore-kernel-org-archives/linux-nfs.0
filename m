From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 0/7] nfsstat: adding -D/--diff-stat to nfsstat
Date: Wed, 01 Aug 2007 12:49:14 -0400
Message-ID: <1185986954.6700.145.camel@localhost>
References: <Pine.BSO.4.64.0707311651120.13370@citi.umich.edu>
	<46B074A2.4010909@redhat.com>
	<Pine.BSO.4.64.0708011149240.25204@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, Peter Staubach <staubach@redhat.com>,
	Andrew Richardson <chardson@umich.edu>, nfs@lists.sourceforge.net,
	Alex Soule <soule@umich.edu>
To: "david m. richter" <richterd@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IGHO1-0001IW-SQ
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 09:49:26 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX194jN3HLuCEt8X+1BhLY1l/QlhjJkp1dAY=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IGHO4-0000Fa-3l
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 09:49:29 -0700
In-Reply-To: <Pine.BSO.4.64.0708011149240.25204@citi.umich.edu>
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

On Wed, 2007-08-01 at 11:59 -0400, david m. richter wrote:
> > david m. richter wrote:
> > > 	Hello, Neil,
> > > 
> > > 	This set of patches adds -D/--diff-stat to nfsstat.  When this flag is
> > > used, instead of printing out the current total statistics and exiting,
> > > nfsstat takes a snapshot of the current statistics and pauses until the user
> > > types ^C, at which point a second snapshot is taken and only the difference
> > > between the two is printed; i.e., only the statistics gathered during the
> > > pause.
> > 
> > Hi.
> > 
> > Perhaps I am missing something, but is something that we really need
> > to complicate the nfsstat support with?  Is this not easy enough to
> > do with already existing tools or some easily written support in sh
> > or perl or awk or name your favorite administrative scripting language?
> > 
> >    Thanx...
> > 
> >       ps
> 
> 	
> 	hello, peter,
> 
> 	yes.  :)  right now, there's no easy way to run a test and get 
> stats for just that test, since the counters persist -- so you have to do 
> things like run a test, unmount, remount, etc.  this is a quick way to get 
> stats collected over an arbitrary period.  and it's not very complicated, 
> really.
> 
> 	i don't think a shell/perl/python/etc script would be anywhere as 
> useful a substitute.  and with neil's suggestion about adding an optional 
> timeout to make it easier to use -in- scripts, i think we're on the right 
> track with this approach.
> 
> 	.. thoughts/ideas?

How about instead just adding support for the 'nfsstat -z' option that
Solaris offers? That would make it easy to set up the type of script
that Peter is advocating.

All you need to do is to save a snapshot of the current /proc counters
in a file, then use that as the baseline for the output of future
nfsstat commands.
It might be an idea to also save /proc/sys/kernel/random/boot_id
somewhere in this 'baseline file' in order to be able to avoid files
that were created in a past boot instance.

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
