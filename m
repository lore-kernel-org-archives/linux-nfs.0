From: Neil Brown <neilb@suse.de>
Subject: Re: [Fwd: Re: [2/3] 2.6.23-rc2: known regressions v2]
Date: Tue, 21 Aug 2007 09:09:57 +1000
Message-ID: <18122.8005.196262.339710@notabene.brown>
References: <1186594872.6699.39.camel@heimdal.trondhjem.org>
	<18106.22383.551248.118418@notabene.brown>
	<20070820152606.GB31368@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1INGNo-000112-Hb
	for nfs@lists.sourceforge.net; Mon, 20 Aug 2007 16:10:04 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1INGNr-0004ld-FR
	for nfs@lists.sourceforge.net; Mon, 20 Aug 2007 16:10:08 -0700
In-Reply-To: message from J. Bruce Fields on Monday August 20
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

On Monday August 20, bfields@fieldses.org wrote:
> 
> Help!  I've lost track.  What do we need to here?  (And is the original
> problem actually a regression, or is it a preexisting bug that's just
> very hard to hit?)

I don't think the original problem is a regression, but I'm not
completely sure.
There is some race between shutdown and startup.  We recently (though
not very recently) spread out the 'startup' sequence by allowing the
version list and port list to be written to nfsdfs file before
actually starting the threads.  It is possible that doing that made
the race easier to lose, but I'm not convinced of that.

What needs to be done there is identify exactly what the race is, and
close it.

Separately from that is the issue that Trond identified where it is
conceivable that an ->sk_data_ready or similar callback happens after
svsk has been freed.  I think that possibilities is extremely
unlikely, but then it is the sort of thing that it is easy to guess
wrongly about.  The sk_destruct patch should fix that, but it should
probably sit in -mm for a while to get a bit of testing.

These issue are on my todo list and I do mean to follow them up, but I
don't see them as a priority at the moment.

Thanks,
NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
