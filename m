From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] How to set-up a Linux NFS server to handle massive	number
	of requests
Date: Tue, 15 Apr 2008 09:58:22 -0400
Message-ID: <20080415135822.GA32218@fieldses.org>
References: <47FE044A.7020008@aei.mpg.de> <20080411230754.GI24830@fieldses.org>
	<1208234913.17169.50.camel@trinity.ogc.int>
	<48044055.2060500@aei.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Carsten Aulbert <carsten.aulbert-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:43680 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754609AbYDON6x (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Apr 2008 09:58:53 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JllgR-00023x-RG
	for linux-nfs@vger.kernel.org; Tue, 15 Apr 2008 23:58:51 +1000
In-Reply-To: <48044055.2060500-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 15, 2008 at 07:42:45AM +0200, Carsten Aulbert wrote:
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

The only advice I know of is to check the "th" line in
/proc/net/rpc/nfsd and adjust the number of threads until you can verify
that they're rarely all in use; see

	http://nfs.sourceforge.net/nfs-howto/ar01s05.html#nfsd_daemon_instances

--b.

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

