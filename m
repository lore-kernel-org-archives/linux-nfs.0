From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] sync, async, write speeds.
Date: Wed, 24 Sep 2008 18:32:11 -0400
Message-ID: <20080924223211.GA14353@fieldses.org>
References: <215ff4410809170035s38183fe3r51aeea62939b6327@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chris Fanning <christopher.fanning@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:57277 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754374AbYIXXFN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Sep 2008 19:05:13 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1KidPz-0007ub-Mz
	for linux-nfs@vger.kernel.org; Thu, 25 Sep 2008 09:05:11 +1000
In-Reply-To: <215ff4410809170035s38183fe3r51aeea62939b6327-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 17, 2008 at 09:35:15AM +0200, Chris Fanning wrote:
> Hello all,
> 
> I'm using NFS to mount /home on a gigabit network.
> /etc/exports on the server
> /home  192.168.2.48/255.255.255.248(rw,no_root_squash,sync,no_subtree_check)
> 
> /proc/mount on the client
> home_server:/home /home nfs
> rw,vers=3,rsize=32768,wsize=32768,hard,nointr,proto=tcp,timeo=600,retrans=2,sec=sys,addr=192.168.2.22
> 0 0
> 
> Write performance is not good.
> 
> dd if=/dev/zero of=/home/testfile bs=16k count=16384
> 268435456 bytes (268 MB) copied, 45.0461 seconds, 6.0 MB/s
> 
> If I change the export to async, it improves a lot.
> 
> dd if=/dev/zero of=./testfile bs=16k count=16384
> 268435456 bytes (268 MB) copied, 3.6 seconds, 74.4 MB/s
> 
> But the recommendation is not to use async, right?
> 
> I've tried the same thing on two different servers (one xenified
> kernel, one stock etch kernel) and two different clients (ubuntu 7.10
> y debian etch), with the same results. :(
> Where should I start looking to fix this?

What's the maximum sustained bandwidth to the server's disk?  With
enough server memory, a 268MB write could just be going straight to
memory in the async case.

--b.

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

