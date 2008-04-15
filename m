From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [NFS] How to set-up a Linux NFS server to handle	massive	number
	of requests
Date: Mon, 14 Apr 2008 23:48:33 -0500
Message-ID: <1208234913.17169.50.camel@trinity.ogc.int>
References: <47FE044A.7020008@aei.mpg.de> <20080411230754.GI24830@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Carsten Aulbert <carsten.aulbert-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:58349 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753023AbYDOEsN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Apr 2008 00:48:13 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1Jld5X-0000dJ-1C
	for linux-nfs@vger.kernel.org; Tue, 15 Apr 2008 14:48:11 +1000
In-Reply-To: <20080411230754.GI24830@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Maybe this this is a TCP_BACKLOG issue?

BTW, with that many mounts won't you run out of "secure" ports (< 1024),
so you'll need to use 'insecure' as a mount option.


On Fri, 2008-04-11 at 19:07 -0400, J. Bruce Fields wrote:
> On Thu, Apr 10, 2008 at 02:12:58PM +0200, Carsten Aulbert wrote:
> > Hi all,
> > 
> > we have a pretty extreme problem here and I try to figure out how to get 
> > it done right.
> > 
> > We have a large cluster consisting of 1340 compute nodes who have a 
> > automount directory which will subsequently trigger a NFS mount (read-only):
> > 
> > $ ypcat auto.data
> > -fstype=nfs,nfsvers=3,hard,intr,rsize=8192,wsize=8192,tcp       &:/data
> > 
> > $ grep auto.data /etc/auto.master
> > /atlas/data          yp:auto.data      --timeout=5
> > 
> > So far so good.
> > 
> > When submitting 1000 jobs just doing a md5sum of the very same file from 
> > one single data server, I see very weird effects.
> > 
> > In the standard set-up many connections get into the box (tcp connection 
> > status SYN_RECV) but those fall over after some time and stay in 
> > CLOSE_WAIT state until I restart the nfs-kernel-server. Typically that 
> > looks like (netstat -an):
> 
> That's interesting!  But I'm not sure how to figure this out.
> 
> Is it possible to get a network trace that shows what's going on?
> 
> What happens on the clients?
> 
> What kernel version are you using?--b.
> 
> > 
> > tcp        0      0 10.20.10.14:687         10.10.2.87:799          SYN_RECV
> > tcp        0      0 10.20.10.14:687         10.10.4.1:823           SYN_RECV
> > tcp        0      0 10.20.10.14:687         10.10.1.65:656          SYN_RECV
> > tcp        0      0 10.20.10.14:687         10.10.1.30:650          SYN_RECV
> > tcp        0      0 10.20.10.14:687         10.10.0.71:789          SYN_RECV
> > tcp        0      0 10.20.10.14:687         10.10.1.4:602           SYN_RECV
> > tcp        0      0 10.20.10.14:687         10.10.1.1:967           SYN_RECV
> > tcp        0      0 10.20.10.14:687         10.10.3.66:915          SYN_RECV
> > tcp        0      0 10.20.10.14:687         10.10.0.55:620          SYN_RECV
> > tcp        0      0 10.20.10.14:687         10.10.1.41:835          SYN_RECV
> > tcp        0      0 10.20.10.14:687         10.10.2.29:958          SYN_RECV
> > tcp        0      0 10.20.10.14:687         10.10.1.12:998          SYN_RECV
> > tcp        0      0 10.20.10.14:687         10.10.1.30:651          SYN_RECV
> > tcp        0      0 10.20.10.14:687         10.10.1.4:601           SYN_RECV
> > tcp        0      0 10.20.10.14:2049        10.10.1.19:846 
> > ESTABLISHED
> > tcp       45      0 10.20.10.14:687         10.10.0.68:979 
> > CLOSE_WAIT
> > tcp       45      0 10.20.10.14:687         10.10.3.83:680 
> > CLOSE_WAIT
> > tcp       89      0 10.20.10.14:687         10.10.0.79:604 
> > CLOSE_WAIT
> > tcp        0      0 10.20.10.14:2049        10.10.2.6:676 
> > ESTABLISHED
> > tcp       45      0 10.20.10.14:687         10.10.2.56:913 
> > CLOSE_WAIT
> > tcp       45      0 10.20.10.14:687         10.10.0.60:827 
> > CLOSE_WAIT
> > tcp        0      0 10.20.10.14:2049        10.10.3.55:778 
> > ESTABLISHED
> > tcp       45      0 10.20.10.14:687         10.10.2.86:981 
> > CLOSE_WAIT
> > tcp       45      0 10.20.10.14:687         10.10.9.13:792 
> > CLOSE_WAIT
> > tcp       89      0 10.20.10.14:687         10.10.2.93:728 
> > CLOSE_WAIT
> > tcp       45      0 10.20.10.14:687         10.10.0.20:742 
> > CLOSE_WAIT
> > tcp       45      0 10.20.10.14:687         10.10.3.44:982 
> > CLOSE_WAIT
> > 
> > 
> > I played with different numbers of of nfsd (ranging from 8-1024) and 
> > increasing the number of threads for rpc.mountd from 1 to 64, in quite a 
> > few combinations, but so far I have not found a consistent set of 
> > parameters where 1000 nodes are able to read this file at the same time.
> > 
> > Any ideas from anyone or do you need more input from me?
> > 
> > TIA
> > 
> > Carsten
> > 
> > PS: Please Cc me, I'm not yet subscribed.
> > 
> > -------------------------------------------------------------------------
> > This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
> > Don't miss this year's exciting event. There's still time to save $100. 
> > Use priority code J8TL2D2. 
> > http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs
> > _______________________________________________
> > Please note that nfs@lists.sourceforge.net is being discontinued.
> > Please subscribe to linux-nfs@vger.kernel.org instead.
> >     http://vger.kernel.org/vger-lists.html#linux-nfs
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
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

