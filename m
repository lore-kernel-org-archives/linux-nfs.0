From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 0/7] nfsstat: adding -D/--diff-stat to nfsstat
Date: Wed, 1 Aug 2007 08:11:21 +1000
Message-ID: <18095.45961.578381.351608@notabene.brown>
References: <Pine.BSO.4.64.0707311651120.13370@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Richardson <chardson@umich.edu>,
	nfs@lists.sourceforge.net, Alex Soule <soule@umich.edu>
To: "david m. richter" <richterd@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IFzwF-0004Wb-Lp
	for nfs@lists.sourceforge.net; Tue, 31 Jul 2007 15:11:35 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IFzwI-0003Rz-BZ
	for nfs@lists.sourceforge.net; Tue, 31 Jul 2007 15:11:39 -0700
In-Reply-To: message from david m. richter on Tuesday July 31
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

On Tuesday July 31, richterd@citi.umich.edu wrote:
> 	Hello, Neil,
> 
> 	This set of patches adds -D/--diff-stat to nfsstat.  When this 
> flag is used, instead of printing out the current total statistics and 
> exiting, nfsstat takes a snapshot of the current statistics and pauses 
> until the user types ^C, at which point a second snapshot is taken and 
> only the difference between the two is printed; i.e., only the statistics 
> gathered during the pause.

Sounds useful, though I think it would be even more useful if you
could specify a number of seconds rather than needing to interrupt.
That way you could use it in a script.
Maybe even get it to repeat every n seconds?

Thanks. I'll look through the patches.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
