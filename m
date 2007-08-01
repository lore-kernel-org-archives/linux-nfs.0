From: "david m. richter" <richterd@citi.umich.edu>
Subject: Re: [PATCH 0/7] nfsstat: adding -D/--diff-stat to nfsstat
Date: Wed, 1 Aug 2007 13:42:01 -0400 (EDT)
Message-ID: <Pine.BSO.4.64.0708011335460.25204@citi.umich.edu>
References: <Pine.BSO.4.64.0707311651120.13370@citi.umich.edu>
	<46B074A2.4010909@redhat.com>
	<Pine.BSO.4.64.0708011149240.25204@citi.umich.edu>
	<1185986954.6700.145.camel@localhost>
	<20070801170701.GB13441@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Peter Staubach <staubach@redhat.com>, Neil Brown <neilb@suse.de>,
	Alex Soule <soule@umich.edu>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Andrew Richardson <chardson@umich.edu>, nfs@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IGICu-0007Ei-Be
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 10:42:00 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IGICy-00010C-2d
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 10:42:04 -0700
In-Reply-To: <20070801170701.GB13441@fieldses.org>
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

> I kinda prefer an explicit path, so
> 
> 	nfsstat --since=baseline

	this explicit path approach would also make troubleshooting over 
email easier.


> My one (very minor) complaint about the current implementation is the
> name; -D and --diff-stat don't do it for me.

	and they never did it for me, either.  we were having trouble 
coming up with something that described how the flag affected the 
program's behavior ..


> My honest preference would be for --sleep, with -z for short.  Partly
> because it seems more descriptive.  Partly because it would trip up
> Solaris users, but in a way that would make it obvious what's going on.
> ("I run nfsstat -z and it hangs?  Interrupt it, then----ohhh, I see.")
> But mainly because I think it's funnier.

.. and --sleep does a much better job of describing how the flag affects 
the program from the _user's_ point of view.  i like it much better.

	is -Z any less ambiguous than -z?  (--zzz ;)  or does it matter?


	d
	.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
