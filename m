From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/7] nfsstat: adding -D/--diff-stat to nfsstat
Date: Wed, 1 Aug 2007 13:41:36 -0400
Message-ID: <20070801174136.GC13441@fieldses.org>
References: <Pine.BSO.4.64.0707311651120.13370@citi.umich.edu>
	<46B074A2.4010909@redhat.com>
	<Pine.BSO.4.64.0708011149240.25204@citi.umich.edu>
	<20070801165033.GA13441@fieldses.org>
	<Pine.BSO.4.64.0708011333100.25204@citi.umich.edu>
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
	id 1IGICW-0007E6-He
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 10:41:36 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IGICa-0004cl-AE
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 10:41:40 -0700
In-Reply-To: <Pine.BSO.4.64.0708011333100.25204@citi.umich.edu>
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

On Wed, Aug 01, 2007 at 01:35:16PM -0400, david m. richter wrote:
> > Can I make one more attempt to interest someone in implementing the
> > --since=baseline-file approach?  It'd be fun, and would make some more
> > flexible use cases very simple.  You could still get a time interval:
> > 
> > 	nfsstat >tmp
> > 	sleep 30
> > 	nfsstat --since=tmp
> > 
> > or you could do other stuff:
> > 
> > 	nfsstat >tmp
> > 	run-my-weird-test-case-here
> > 	nfsstat --since=tmp
> 
> 	
> 	just curious: would you be satisfied if the --since file's ctime 
> were used as the beginning of the time interval?

Fine by me, but what were you going to use that for?  If you're just
producing a diff, then you don't need to know the length of the time
interval.  Did you just want to add a header saying "stats since
hh:mm:ss", or did you want to calculate per-second rates?

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
