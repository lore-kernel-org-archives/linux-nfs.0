From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 0/7] nfsstat: adding -D/--diff-stat to nfsstat
Date: Wed, 01 Aug 2007 13:46:24 -0400
Message-ID: <1185990384.6700.188.camel@localhost>
References: <Pine.BSO.4.64.0707311651120.13370@citi.umich.edu>
	<46B074A2.4010909@redhat.com>
	<Pine.BSO.4.64.0708011149240.25204@citi.umich.edu>
	<20070801165033.GA13441@fieldses.org>
	<Pine.BSO.4.64.0708011333100.25204@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Peter Staubach <staubach@redhat.com>, Neil Brown <neilb@suse.de>,
	Alex Soule <soule@umich.edu>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Andrew Richardson <chardson@umich.edu>, nfs@lists.sourceforge.net
To: "david m. richter" <richterd@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IGIHR-0007lP-Va
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 10:46:42 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1/l+OcmH4I12T6kJJmfCLSva+ix2E4O6vk=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IGIHT-0002aJ-VZ
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 10:46:45 -0700
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

On Wed, 2007-08-01 at 13:35 -0400, david m. richter wrote:
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

Exactly. Being able to zero out the stats is way more flexible than the
-D stuff...

> 	
> 	just curious: would you be satisfied if the --since file's ctime 
> were used as the beginning of the time interval?

What time interval? nfsstat doesn't output any time intervals, and I
can't see how these proposals introduce one.

Is it perhaps Bruce's choice of the word '--since' that is confusing?

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
