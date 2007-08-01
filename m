From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/7] nfsstat: adding -D/--diff-stat to nfsstat
Date: Wed, 1 Aug 2007 13:52:06 -0400
Message-ID: <20070801175206.GD13441@fieldses.org>
References: <Pine.BSO.4.64.0707311651120.13370@citi.umich.edu>
	<46B074A2.4010909@redhat.com>
	<Pine.BSO.4.64.0708011149240.25204@citi.umich.edu>
	<20070801165033.GA13441@fieldses.org>
	<Pine.BSO.4.64.0708011333100.25204@citi.umich.edu>
	<1185990384.6700.188.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Peter Staubach <staubach@redhat.com>, Neil Brown <neilb@suse.de>,
	Alex Soule <soule@umich.edu>,
	"david m. richter" <richterd@citi.umich.edu>,
	Andrew Richardson <chardson@umich.edu>, nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IGIMj-0008QN-MJ
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 10:52:09 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IGIMm-0008T0-D7
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 10:52:13 -0700
In-Reply-To: <1185990384.6700.188.camel@localhost>
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

On Wed, Aug 01, 2007 at 01:46:24PM -0400, Trond Myklebust wrote:
> Exactly. Being able to zero out the stats is way more flexible than the
> -D stuff...

It's definitely a better primitive for building scripts.  I think
-D/--sleep/whatever is what I'd personally end up using most of the time
for quick troubleshooting, if only because it's less typing.

> Is it perhaps Bruce's choice of the word '--since' that is confusing?

I'm not sure what'd be better: --previous? --baseline?

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
