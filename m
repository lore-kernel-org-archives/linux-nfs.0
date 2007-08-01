From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/7] nfsstat: adding -D/--diff-stat to nfsstat
Date: Wed, 1 Aug 2007 12:50:33 -0400
Message-ID: <20070801165033.GA13441@fieldses.org>
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
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IGHP9-0001QQ-Mi
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 09:50:35 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IGHPC-0005dO-FF
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 09:50:39 -0700
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

On Wed, Aug 01, 2007 at 11:59:45AM -0400, david m. richter wrote:
> 	yes.  :)  right now, there's no easy way to run a test and get 
> stats for just that test, since the counters persist -- so you have to do 
> things like run a test, unmount, remount, etc.  this is a quick way to get 
> stats collected over an arbitrary period.  and it's not very complicated, 
> really.

Yah.  Especially for debugging other peoples' problems over email, it'd
be helpful to have simple one-line commands that use programs that are
installed everywhere by default.  In this case adding on to nfsstat
looks like the simplest way to achieve that.  But a simpler
implementation would be welcome, of course, if you want to have a go at
it.

> 	i don't think a shell/perl/python/etc script would be anywhere as 
> useful a substitute.  and with neil's suggestion about adding an optional 
> timeout to make it easier to use -in- scripts, i think we're on the right 
> track with this approach.
> 
> 	.. thoughts/ideas?

Can I make one more attempt to interest someone in implementing the
--since=baseline-file approach?  It'd be fun, and would make some more
flexible use cases very simple.  You could still get a time interval:

	nfsstat >tmp
	sleep 30
	nfsstat --since=tmp

or you could do other stuff:

	nfsstat >tmp
	run-my-weird-test-case-here
	nfsstat --since=tmp

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
