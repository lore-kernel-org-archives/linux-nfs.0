From: "Marcelo Leal" <diversos-roWltSPQdMkZWYhx5MAOMFAUjnlXr6A1@public.gmane.org>
Subject: Re: [NFS] sync, async, write speeds.
Date: Wed, 17 Sep 2008 08:15:02 -0300
Message-ID: <42996ba90809170415h7df91524le94505c20df859eb@mail.gmail.com>
References: <215ff4410809170035s38183fe3r51aeea62939b6327@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: "Chris Fanning" <christopher.fanning@gmail.com>,
	nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:49187 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751788AbYIQLPO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Sep 2008 07:15:14 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1Kfv04-0002ux-EN
	for linux-nfs@vger.kernel.org; Wed, 17 Sep 2008 21:15:12 +1000
In-Reply-To: <215ff4410809170035s38183fe3r51aeea62939b6327-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,
 I did not get any performance improvement with block sizes bigger
than 8192... are you using jumbo frame?
 Second, i think you should use tcp just if you network is not
reliable, i mean, you are not using a NAS isolated network. And
timeo,retrans you should use just if you see problems. If you want,
you can try with the values above, and see what happens..

 Leal.

2008/9/17 Chris Fanning <christopher.fanning@gmail.com>:
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
>
> Thanks.
> Chris.
>
> -------------------------------------------------------------------------
> This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
> Build the coolest Linux based applications with Moblin SDK & win great prizes
> Grand prize is a trip for two to an Open Source event anywhere in the world
> http://moblin-contest.org/redirect.php?banner_id=100&url=/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> _______________________________________________
> Please note that nfs@lists.sourceforge.net is being discontinued.
> Please subscribe to linux-nfs@vger.kernel.org instead.
>    http://vger.kernel.org/vger-lists.html#linux-nfs
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>



-- 

[http://www.posix.brte.com.br/blog]
--------==== pOSix rules ====-------

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

