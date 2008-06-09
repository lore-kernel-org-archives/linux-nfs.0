From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] I/O Errors with hard mounts
Date: Mon, 09 Jun 2008 19:20:07 -0400
Message-ID: <1213053607.7361.4.camel@localhost>
References: <505115.86554.qm@web31405.mail.mud.yahoo.com>
	<4f0f0cb0806061638i35ae4f9bp423148d6acbb953b@mail.gmail.com>
	<4f0f0cb0806091002w7f0110fh17e40568c7eb5bb8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Ricardo Labiaga <labiaga@yahoo.com>
To: David Konerding <dakoner@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:46676 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755327AbYFJAXl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Jun 2008 20:23:41 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1K5reE-0008Rm-Lu
	for linux-nfs@vger.kernel.org; Tue, 10 Jun 2008 10:23:38 +1000
In-Reply-To: <4f0f0cb0806091002w7f0110fh17e40568c7eb5bb8-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2008-06-09 at 10:02 -0700, David Konerding wrote:
> I collected some more information on the problem we are seeing.
> 
> Here's what I've got:
> 
> 1) SuSE 10.1 (2.6.16 kernel): running ls -R, hit Control-C-- often see
> an "I/O Error", for example:
> 
> /gne/home/aa/barfod.files/mac.backup/Avi's/TNFR-IgG/Mutants/mAbs:
> 11.15.91
> /bin/ls: reading directory
> /gne/home/aa/barfod.files/mac.backup/Avi's/TNFR-IgG/Mutants/mAbs/11.15.91:
> Input/output error
> 
> Here's what I captured from RPC and NFS debugging.  No "disconnect"
> message like I saw before, but:
> 
> Jun  9 09:50:30 lablnx01 kernel: RPC: 46206 xprt_transmit(136)
> Jun  9 09:50:30 lablnx01 kernel: RPC:      xs_tcp_send_request(136) = 136
> Jun  9 09:50:30 lablnx01 kernel: RPC: 46206 xmit complete
> Jun  9 09:50:30 lablnx01 kernel: RPC: 46206 sleep_on(queue
> "xprt_pending" time 4340153030)
> Jun  9 09:50:30 lablnx01 kernel: RPC: 46206 added to queue
> ffff81046bca5d20 "xprt_pending"
> Jun  9 09:50:30 lablnx01 kernel: RPC: 46206 setting alarm for 60000 ms
> Jun  9 09:50:30 lablnx01 kernel: RPC:
> wake_up_next(ffff81046bca5cd0 "xprt_resend")
> Jun  9 09:50:30 lablnx01 kernel: RPC:
> wake_up_next(ffff81046bca5c80 "xprt_sending")
> Jun  9 09:50:30 lablnx01 kernel: RPC: 46206 sync task going to sleep
> Jun  9 09:50:30 lablnx01 kernel: RPC: 46206 got signal
> Jun  9 09:50:30 lablnx01 kernel: RPC: 46206 __rpc_wake_up_task (now 4340153035)
> Jun  9 09:50:30 lablnx01 kernel: RPC: 46206 disabling timer
> Jun  9 09:50:30 lablnx01 kernel: RPC: 46206 removed from queue
> ffff81046bca5d20 "xprt_pending"
> Jun  9 09:50:30 lablnx01 kernel: RPC:      __rpc_wake_up_task done
> Jun  9 09:50:30 lablnx01 kernel: RPC: 46206 sync task resuming
> Jun  9 09:50:30 lablnx01 kernel: RPC: 46206 deleting timer
> Jun  9 09:50:30 lablnx01 kernel: RPC: 46206, return -512, status -512

That would be ERESTARTSYS, in other words, a fatal signal. Just out of
interest, could you send us the results of

  cat /proc/mounts

please?

Cheers
  Trond


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

