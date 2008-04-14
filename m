From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] How to set-up a Linux NFS server to handle massive	number
	of requests
Date: Mon, 14 Apr 2008 13:06:07 -0400
Message-ID: <20080414170607.GC15950@fieldses.org>
References: <47FE044A.7020008@aei.mpg.de> <20080411230754.GI24830@fieldses.org>
	<48005A78.9090609@aei.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Carsten Aulbert <carsten.aulbert-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:42917 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751880AbYDNR1B (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Apr 2008 13:27:01 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JlSS9-000720-2q
	for linux-nfs@vger.kernel.org; Tue, 15 Apr 2008 03:26:49 +1000
In-Reply-To: <48005A78.9090609-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Apr 12, 2008 at 08:45:12AM +0200, Carsten Aulbert wrote:
> 2.6.24.Hi,
>
> J. Bruce Fields wrote:
>>> In the standard set-up many connections get into the box (tcp 
>>> connection status SYN_RECV) but those fall over after some time and 
>>> stay in CLOSE_WAIT state until I restart the nfs-kernel-server. 
>>> Typically that looks like (netstat -an):
>>
>> That's interesting!  But I'm not sure how to figure this out.
>>
>> Is it possible to get a network trace that shows what's going on?
>>
>
> In principle yes, but
> (1) it's huge. I only get this when doing this with 500-1000 clients  
> starting at about the same time
> (2) It seems that I don't get a full trace, i.e. the session seem to be  
> incomplete - sometimes I only see a single packet with FIN set. I tried  
> doing this both with wireshark running locally and with ntap's capturing  
> device.

Yeah, that's not surprising.  You'd probably want to dedicate a machine
to doing the capture, and then I'm not sure what kind of hardware you'd
need for a given network to get everything.  Probably it's not worth it.

>> What happens on the clients?
>>
> In the logs (/var/log/daemon.log) I only see that the mount request  
> fails in different ways.
>
> Apr  9 12:07:55 n0078 automount[26838]: >> mount: RPC: Timed out
> Apr  9 12:07:55 n0078 automount[26838]: mount(nfs): nfs: mount failure  
> d14:/data on /atlas/data/d14
> Apr  9 12:07:55 n0078 automount[26838]: failed to mount /atlas/data/d14
> Apr  9 12:18:56 n0078 automount[27977]: >> mount: RPC: Remote system  
> error - Connection timed out
> Apr  9 12:18:56 n0078 automount[27977]: mount(nfs): nfs: mount failure  
> d14:/data on /atlas/data/d14
>
> I have not yet run tshark in the background on many nodes to see if I  
> can capture the client's view. Would that be beneficial?

Couldn't hurt.

Hauling out TCP/IP Illustrated and refreshing my memory of the tcp state
transition diagram....  So if the server has a lot of connections stuck
in CLOSE_WAIT, that means it got FIN's from the clients (perhaps after
they timed out), but never shut down its side of the connection.  Sounds
like a bug in some server-side rpc code.  (Hm.  But all those SYN_RECV's
are somebody waiting for a client to ACK a SYN.  Why are there so many
of those?)

Those connections are actually to port 687, which I assume is mountd
(what does rpcinfo -p say?).  (And probably if you just killed and
restarted mountd, instead of doing a complete
"/etc/init.d/nfs-kernel-server restart", that'd also clear those out.)
In fact, in the example you gave only three out of about 27 connections
(the only ESTABLISHED connections) were to port 2049 (nfsd itself).

So it looks like it's mountd that's not keeping up (and that's leaving
connections sitting around too long), and the mountd processes are
probably what we should be debugging.

>> What kernel version are you using?--b.
>
> 2.6.24.4 on Debian Etch
>
> Right now, it seems that running 196 nfsd plus 64 threads for mountd  
> solves the problem for the time being. Although it would be nice to  
> understand these "magic" numbers ;)

Yes, definitely.  I'm surprised the number of nfsd threads matters much
at all, actually, if mountd is the bottleneck.

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

