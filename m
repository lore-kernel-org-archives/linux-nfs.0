From: Wendy Cheng <s.wendy.cheng@gmail.com>
Subject: Re: [NFS] Sudden high load average and abnormal behavior
Date: Mon, 16 Jun 2008 11:18:04 -0400
Message-ID: <4856842C.3040807@gmail.com>
References: <b66ddc900806152225o3a7f2bccrf4e83e70c992847a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: howard chen <howachen@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:36031 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752313AbYFPPPE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Jun 2008 11:15:04 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1K8GQ9-0002Wa-Pg
	for linux-nfs@vger.kernel.org; Tue, 17 Jun 2008 01:15:01 +1000
In-Reply-To: <b66ddc900806152225o3a7f2bccrf4e83e70c992847a-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

howard chen wrote:
>
>
> top - 13:17:53 up 382 days, 23:44,  6 users,  load average: 20.53, 20.21, 18.93
> Tasks: 286 total,   1 running, 285 sleeping,   0 stopped,   0 zombie
> Cpu(s):  0.1% us,  1.1% sy,  0.0% ni, 68.4% id, 29.9% wa,  0.0% hi,  0.5% si
> Mem:   4045256k total,  4028028k used,    17228k free,   437428k buffers
> Swap:  9775512k total,      160k used,  9775352k free,  2814332k cached
>
>   PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
>  2049 root      15   0     0    0    0 S    1  0.0 861:21.26 kjournald
> 26094 root      15   0     0    0    0 S    0  0.0  85:02.82 nfsd
> 26106 root      15   0     0    0    0 S    0  0.0  83:49.86 nfsd
> 26110 root      15   0     0    0    0 S    0  0.0  84:33.23 nfsd
> 26124 root      15   0     0    0    0 S    0  0.0  84:37.47 nfsd
>  2839 root      16   0  6280 1172  780 R    0  0.0   0:00.02 top
>   

I haven't used ext3 for a very long time so not sure whether there are 
changes. IIRC, if kjournald is up and runnning (implying ext3 is 
flushing its data to the disk), it holds the journal lock so the access 
to that particular filesystem is temporarily suspended. So the issue 
here is to check why kjournald takes such a long time to do the flushing.

Normally we want to see the thread backtrace of "kjournald" by asking 
for a "sysrq-t" output via:

shell> cd /proc
shell> echo t > sysrq-trigger

This will write all the thread backtraces into the system file 
/var/log/messages file so people can have a rough idea of what goes 
wrong. The *trick* here is to make sure the /var/log/messages file 
doesn't live on the particular filesystem that has the high load issue 
(otherwise the writing to the /var/log/messages will hang as well). So 
you may want to configure the /var on a separate filesystem. Remember 
each ext3 filesystem has its own kjournald (again, I have not touched 
ext3 for a while so this is from my old memory).

Another option is to google to see whether other people on the same 
kernel level has the same issue as yours and pull their fix into your 
system - however, it is more of a long shot (since you're doing the 
guessing).

-- Wendy



-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

