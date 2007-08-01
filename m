From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/7] nfsstat: adding -D/--diff-stat to nfsstat
Date: Wed, 1 Aug 2007 13:07:01 -0400
Message-ID: <20070801170701.GB13441@fieldses.org>
References: <Pine.BSO.4.64.0707311651120.13370@citi.umich.edu>
	<46B074A2.4010909@redhat.com>
	<Pine.BSO.4.64.0708011149240.25204@citi.umich.edu>
	<1185986954.6700.145.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Peter Staubach <staubach@redhat.com>, Neil Brown <neilb@suse.de>,
	Alex Soule <soule@umich.edu>,
	"david m. richter" <richterd@citi.umich.edu>,
	Andrew Richardson <chardson@umich.edu>, nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IGHf9-0003Td-0P
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 10:07:07 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IGHfB-000430-KZ
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 10:07:11 -0700
In-Reply-To: <1185986954.6700.145.camel@localhost>
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

On Wed, Aug 01, 2007 at 12:49:14PM -0400, Trond Myklebust wrote:
> How about instead just adding support for the 'nfsstat -z' option that
> Solaris offers? That would make it easy to set up the type of script
> that Peter is advocating.
> 
> All you need to do is to save a snapshot of the current /proc counters
> in a file, then use that as the baseline for the output of future
> nfsstat commands.

I kinda prefer an explicit path, so

	nfsstat --since=baseline

as opposed to an interface that hides the fact that we're storing the
baseline in a file, and possibly confuses Solaris users if e.g.

	nfsstat -z
	su
	nfsstat

doesn't do what's expected.  I dunno.

My one (very minor) complaint about the current implementation is the
name; -D and --diff-stat don't do it for me.

My honest preference would be for --sleep, with -z for short.  Partly
because it seems more descriptive.  Partly because it would trip up
Solaris users, but in a way that would make it obvious what's going on.
("I run nfsstat -z and it hangs?  Interrupt it, then----ohhh, I see.")
But mainly because I think it's funnier.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
