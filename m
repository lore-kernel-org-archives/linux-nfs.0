From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/7] nfsstat: adding -D/--diff-stat to nfsstat
Date: Tue, 31 Jul 2007 19:41:56 -0400
Message-ID: <20070731234156.GA18172@fieldses.org>
References: <Pine.BSO.4.64.0707311651120.13370@citi.umich.edu>
	<18095.45961.578381.351608@notabene.brown>
	<Pine.BSO.4.64.0707311928380.5541@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Andrew Richardson <chardson@umich.edu>, nfs@lists.sourceforge.net,
	Alex Soule <soule@umich.edu>
To: "david m. richter" <richterd@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IG1Li-0004zv-LD
	for nfs@lists.sourceforge.net; Tue, 31 Jul 2007 16:41:58 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IG1Lk-0003Jd-7K
	for nfs@lists.sourceforge.net; Tue, 31 Jul 2007 16:42:02 -0700
In-Reply-To: <Pine.BSO.4.64.0707311928380.5541@citi.umich.edu>
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

On Tue, Jul 31, 2007 at 07:29:28PM -0400, david m. richter wrote:
> > Sounds useful, though I think it would be even more useful if you
> > could specify a number of seconds rather than needing to interrupt.
> > That way you could use it in a script.
> > Maybe even get it to repeat every n seconds?
> > 
> > Thanks. I'll look through the patches.
> > 
> > NeilBrown
> 
> 	roger -- i'll look at adding an optional timeout w/ optional 
> repeat.  good idea. 

Sure, I agree that it'd be more convenient for scripting.  Alternatively
(or also) we could allow the user to pass in a file with previous
nfsstat output, so you could do something like

	nfsstat >tmp
	sleep 60
	nfsstat --since=tmp

But personally the ctrl-C thing is what I expect to use 99% of the
time, so I'm happy to see that done first.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
