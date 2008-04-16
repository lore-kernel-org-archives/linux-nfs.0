From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [NFS] How to set-up a Linux NFS server to	handle	massive	number
	of requests
Date: Tue, 15 Apr 2008 21:49:57 -0500
Message-ID: <1208314197.3521.35.camel@trinity.ogc.int>
References: <47FE044A.7020008@aei.mpg.de> <20080411230754.GI24830@fieldses.org>
	<1208234913.17169.50.camel@trinity.ogc.int>
	<48044055.2060500@aei.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>, nfs@lists.sourceforge.net
To: Carsten Aulbert <carsten.aulbert-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:48561 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753043AbYDPCt3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Apr 2008 22:49:29 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JlxiB-0003yI-SP
	for linux-nfs@vger.kernel.org; Wed, 16 Apr 2008 12:49:27 +1000
In-Reply-To: <48044055.2060500-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Tue, 2008-04-15 at 07:42 +0200, Carsten Aulbert wrote:
> 
> Tom Tucker wrote:
> > Maybe this this is a TCP_BACKLOG issue?
> > 
> 
> Hmm, Google does not yield much information about this. I think I know 
> what that would be, is there a cure or some kernel switches for tuning that?
> 
> > BTW, with that many mounts won't you run out of "secure" ports (< 1024),
> > so you'll need to use 'insecure' as a mount option.

> Not to my knowledge. All connections go to a single port onto the server 
> box (well, one port per service).  Only the clients may run out of 
> privileged ports of they do too much mounting, but mostly this option is 
> just for "security" reasons. At least that's my understanding.

Yes, you're right...I was being dumb here. Sorry. 

> 
> By the ways, discussing this issue with my colleague cluster admins, the 
> question popped up, if there is a guideline/rule of thump of how many 
> nfsd one should run - or asking the other way round, how to arrive at a 
> good compromise.
> 
> Our server boxes are pretty big (8 cores, 16 GB memory, 16 disk 
> Areca1261 RAID6), so the resources used by the nfsd are not much of an 
> issue - I even tested with 1024 nfsd idling around. AT some point 
> increasing the number does not make much sense because I cannot get the 
> data out fast enough or the seeks will likely "kill" the box^Wperformance.
> 
> Any thoughts on that?
> 
> Cheers
> 
> Carsten
> 
> -------------------------------------------------------------------------
> This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
> Don't miss this year's exciting event. There's still time to save $100. 
> Use priority code J8TL2D2. 
> http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> _______________________________________________
> Please note that nfs@lists.sourceforge.net is being discontinued.
> Please subscribe to linux-nfs@vger.kernel.org instead.
>     http://vger.kernel.org/vger-lists.html#linux-nfs
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Don't miss this year's exciting event. There's still time to save $100. 
Use priority code J8TL2D2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

