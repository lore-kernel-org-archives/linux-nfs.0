From: "Muntz, Daniel" <Dan.Muntz@netapp.com>
Subject: Re: [PATCH 0/7] nfsstat: adding -D/--diff-stat to nfsstat
Date: Wed, 1 Aug 2007 11:15:23 -0700
Message-ID: <01AE8AF878612047A442668306EAEB05DD298B@SACEXMV01.hq.netapp.com>
References: <Pine.BSO.4.64.0707311651120.13370@citi.umich.edu>
	<46B074A2.4010909@redhat.com><Pine.BSO.4.64.0708011149240.25204@citi.umich.edu><20070801165033.GA13441@fieldses.org><Pine.BSO.4.64.0708011333100.25204@citi.umich.edu><1185990384.6700.188.camel@localhost>
	<Pine.BSO.4.64.0708011347200.25204@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Peter Staubach <staubach@redhat.com>, Neil Brown <neilb@suse.de>,
	Alex Soule <soule@umich.edu>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Andrew Richardson <chardson@umich.edu>, nfs@lists.sourceforge.net
To: "david m. richter" <richterd@citi.umich.edu>,
	"Trond Myklebust" <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IGIkl-0002YC-4O
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 11:16:59 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IGIko-0003vD-Iz
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 11:17:03 -0700
In-Reply-To: <Pine.BSO.4.64.0708011347200.25204@citi.umich.edu>
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

>perhaps i don't follow: how is zeroing the stats address the same
>use-case as --diff-stat/--sleep?  one can already zero the stats
>by unmounting, e.g., but that's a pain.  ?  i'm missing something.

i think you're answering your own question.  being able to zero the
stats with 'nfsstat -z' allows you to avoid unmounting, while giving you
the ability to, um, zero the stats...  instead of being a pain, it's
trivial.

if you don't want to zero your stats, i agree with others here, that a
simple script accomplishes the same thing without adding a lot of extra
baggage to the command.  it's the unix way.

-----Original Message-----
From: david m. richter [mailto:richterd@citi.umich.edu] 
Sent: Wednesday, August 01, 2007 10:49 AM
To: Trond Myklebust
Cc: Peter Staubach; Neil Brown; Alex Soule; J. Bruce Fields; Andrew
Richardson; nfs@lists.sourceforge.net
Subject: Re: [NFS] [PATCH 0/7] nfsstat: adding -D/--diff-stat to nfsstat

On Wed, 1 Aug 2007, Trond Myklebust wrote:

> On Wed, 2007-08-01 at 13:35 -0400, david m. richter wrote:
> > > Can I make one more attempt to interest someone in implementing 
> > > the --since=baseline-file approach?  It'd be fun, and would make 
> > > some more flexible use cases very simple.  You could still get a
time interval:
> > > 
> > > 	nfsstat >tmp
> > > 	sleep 30
> > > 	nfsstat --since=tmp
> > > 
> > > or you could do other stuff:
> > > 
> > > 	nfsstat >tmp
> > > 	run-my-weird-test-case-here
> > > 	nfsstat --since=tmp
> 
> Exactly. Being able to zero out the stats is way more flexible than 
> the -D stuff...

	perhaps i don't follow: how is zeroing the stats address the
same use-case as --diff-stat/--sleep?  one can already zero the stats by
unmounting, e.g., but that's a pain.  ?  i'm missing something.


> > 	just curious: would you be satisfied if the --since file's ctime

> > were used as the beginning of the time interval?
> 
> What time interval? nfsstat doesn't output any time intervals, and I 
> can't see how these proposals introduce one.
> 
> Is it perhaps Bruce's choice of the word '--since' that is confusing?

	right -- like i said in another letter, i was just being dumb.
:)


	thanks,
	
	d
	.

------------------------------------------------------------------------
-
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
