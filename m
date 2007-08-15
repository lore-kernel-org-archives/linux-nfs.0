From: "david m. richter" <richterd@citi.umich.edu>
Subject: Re: [PATCH 0/5] nfsstat: adding -S/--since
Date: Wed, 15 Aug 2007 19:23:37 -0400 (EDT)
Message-ID: <Pine.BSO.4.64.0708151918430.23242@citi.umich.edu>
References: <Pine.BSO.4.64.0708131440190.6965@citi.umich.edu>
	<18115.35173.364849.564000@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ILSDD-0008Ek-9D
	for nfs@lists.sourceforge.net; Wed, 15 Aug 2007 16:23:39 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1ILSDF-0006Xz-Gy
	for nfs@lists.sourceforge.net; Wed, 15 Aug 2007 16:23:41 -0700
In-Reply-To: <18115.35173.364849.564000@notabene.brown>
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

> > $ watch "nfsstat --since /tmp/stats; nfsstat >/tmp/stats" 
> 
> This misses any changes between the two runs of nfsstat.  Normally
> that won't be significant I guess..

	i figured maybe a save-feature could be added in the future if the 
rest of the feature was accepted or whatever.  wasn't quite sure what 
format would be best, or how format-stuff in general would play out.
 

> I didn't see
> 
>   - patch 6 update nfsstat.man to document -S/--since
> 
> maybe that one got lost in the mail :-)

	:) just waiting to see if the rest of it was accepted.  i'll get 
it to you tomorrow.


> I've committed the first 5 to .git.

	thanks kindly, neil,

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
