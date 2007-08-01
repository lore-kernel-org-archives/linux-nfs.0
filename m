From: "david m. richter" <richterd@citi.umich.edu>
Subject: Re: [PATCH 0/7] nfsstat: adding -D/--diff-stat to nfsstat
Date: Wed, 1 Aug 2007 14:25:48 -0400 (EDT)
Message-ID: <Pine.BSO.4.64.0708011423430.25204@citi.umich.edu>
References: <Pine.BSO.4.64.0707311651120.13370@citi.umich.edu>
	<46B074A2.4010909@redhat.com>
	<Pine.BSO.4.64.0708011149240.25204@citi.umich.edu>
	<46B0C92C.3020807@redhat.com>
	<Pine.BSO.4.64.0708011413000.25204@citi.umich.edu>
	<46B0CF5B.1000609@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Andrew Richardson <chardson@umich.edu>, nfs@lists.sourceforge.net,
	Alex Soule <soule@umich.edu>
To: Peter Staubach <staubach@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IGItH-0003SZ-PJ
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 11:25:47 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IGItJ-0002uL-Gg
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 11:25:51 -0700
In-Reply-To: <46B0CF5B.1000609@redhat.com>
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

On Wed, 1 Aug 2007, Peter Staubach wrote:

> david m. richter wrote:
> > > Now, if someone was proposing a way to do "nfsstat 5" and make the
> > > output look useful, then I would be behind that 100%.
> > > 
> > >    Thanx...
> > > 
> > >       ps
> > >     
> > 
> > 
> > 	do you mean "gather stats for the next 5 seconds"?  i don't understand
> > the arg.
> 
> Sorry, I should have been more explicit.  I have wished for
> something that would behave like "vmstat 5", ie. print nfsstat
> statistics in some sort short hand fashion once every few
> seconds, 5 in this example.
> 
> The problem has always been that there are too many operations
> for summarize them on one line in any sort of interesting way.
> This becomes particularly true for NFSv4 which has its multitude
> of operations...
> 
> Perhaps we should just bite the bullet and produce the large
> output, much like "iostat 5" seems to.
> 
>    Thanx...
> 
>       ps


	oh, i see -- yeah, neil'd suggested adding flags for both "display 
stats over a time interval" and "repeat gathering stats instead of 
exiting after one go".  cool.  maybe the args could be set up so that 
"nfsstat 5"  was shorthand for whatever the extra flags would be.


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
