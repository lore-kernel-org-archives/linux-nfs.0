From: "david m. richter" <richterd@citi.umich.edu>
Subject: Re: [PATCH 1/7] nfsstat: add has_stats()
Date: Tue, 31 Jul 2007 19:30:50 -0400 (EDT)
Message-ID: <Pine.BSO.4.64.0707311930090.5541@citi.umich.edu>
References: <Pine.BSO.4.64.0707311707400.13370@citi.umich.edu>
	<18095.46044.158241.412513@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Richardson <chardson@umich.edu>,
	nfs@lists.sourceforge.net, Alex Soule <soule@umich.edu>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IG1At-0003wp-4G
	for nfs@lists.sourceforge.net; Tue, 31 Jul 2007 16:30:47 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IG1Aw-0000tY-Ul
	for nfs@lists.sourceforge.net; Tue, 31 Jul 2007 16:30:51 -0700
In-Reply-To: <18095.46044.158241.412513@notabene.brown>
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

> On Tuesday July 31, richterd@citi.umich.edu wrote:
> > 	To help readability, add has_stats() and use it when deciding 
> > whether to print.
> .....
> > +
> > +static int
> > +has_stats(const unsigned int *info)
> > +{
> > +	return (info[0] && info[info[0] + 1] != info[0]);
> > +}
> 
> To help readability even more, could you provide a comment explaining
> what this function is really testing.  I can almost see it, but a
> comment would help a lot!
> 
> Thanks,
> NeilBrown

	will-do.  yeah, it took a bit of head-scratching for us to grok 
quite how it was working.  :)

	thanks,

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
