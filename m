From: Shehjar Tikoo <shehjart-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org>
Subject: Re: [NFS] sync, async, write speeds.
Date: Wed, 17 Sep 2008 20:32:41 +1000
Message-ID: <48D0DCC9.3090208@cse.unsw.edu.au>
References: <215ff4410809170035s38183fe3r51aeea62939b6327@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chris Fanning <christopher.fanning@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:35602 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752441AbYIQKul (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Sep 2008 06:50:41 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1KfucI-0002r4-AL
	for linux-nfs@vger.kernel.org; Wed, 17 Sep 2008 20:50:39 +1000
In-Reply-To: <215ff4410809170035s38183fe3r51aeea62939b6327-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chris Fanning wrote:
> I'm using NFS to mount /home on a gigabit network.

First off, if its possible for you to change the configuration on the
clients as well as the server, try bumping up the ethernet frame
size/MTU to 9000, i.e. use jumbo frames. Of course, this depends on
whether your switches and NICs support jumbo frames. To do so, use
ifconfig or specify it in /etc/network/interfaces using the "mtu" option.

> /etc/exports on the server /home 
> 192.168.2.48/255.255.255.248(rw,no_root_squash,sync,no_subtree_check)
> 
> 
> 
> 
> 
> /proc/mount on the client home_server:/home /home nfs 
> rw,vers=3,rsize=32768,wsize=32768,hard,nointr,proto=tcp,timeo=600,retrans=2,sec=sys,addr=192.168.2.22
>  0 0
> 

Second, try the same dd tests with larger values for rsize and wsize.
These two parameters have a significant affect on NFS throughput, for
read and write respectively.

> Write performance is not good.
> 
> dd if=/dev/zero of=/home/testfile bs=16k count=16384 268435456 
> bytes (268 MB) copied, 45.0461 seconds, 6.0 MB/s

Try bs=<wsize> or bs=<rsize>( i.e. the values that you specified in
the mount config..), this reduces the number of system calls
that translate to an equivalent NFS rsize of wsize messages. Although, 
system calls generally will have negligible overhead when compared to 
network latency overhead.

> 
> If I change the export to async, it improves a lot.
If you can assure uninterrupted power to the server, I dont see any
reason why you cant use the "async" option.

> 
> dd if=/dev/zero of=./testfile bs=16k count=16384 268435456 bytes 
> (268 MB) copied, 3.6 seconds, 74.4 MB/s
> 
> But the recommendation is not to use async, right?
> 
> I've tried the same thing on two different servers (one xenified 
> kernel, one stock etch kernel) and two different clients (ubuntu 
> 7.10 y debian etch), with the same results. :( Where should I start
>  looking to fix this?
> 
> Thanks. Chris.


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

