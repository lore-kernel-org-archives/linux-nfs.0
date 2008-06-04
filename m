From: "David Konerding" <dakoner@gmail.com>
Subject: Re: [NFS] I/O Errors with hard mounts
Date: Wed, 4 Jun 2008 10:00:16 -0700
Message-ID: <4f0f0cb0806041000m7926d1e7m93f71ebaacd6c976@mail.gmail.com>
References: <4f0f0cb0806040633x74fd0afbm94866cf85810f242@mail.gmail.com>
	<20080604121723.5b6a53e6@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Jeff Layton" <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:52039 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752253AbYFDRAc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Jun 2008 13:00:32 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1K3wLb-0001NG-C0
	for linux-nfs@vger.kernel.org; Thu, 05 Jun 2008 03:00:27 +1000
In-Reply-To: <20080604121723.5b6a53e6-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>> Although we are using hard mounts, some users report that during the
>> hammering period, some of their
>> file operations produce "I/O Error" messages on their terminal.
>>
>> We checked, and the hosts are indeed using hard mounting.  From our
>> reading, I/O Errors
>> should only ever make it back to the user if are using soft mounting.
>>
> hard/soft only governs what happens when there is a major timeout (i.e.
> the server doesn't respond within a given time). If there are other
> errors (for instance, client side memory shortage, server starts
> refusing connections, etc), then there can be errors returned to the
> application.
>

OK; we're already using TCP mounts, so I don't think that any new
client->server connections
should occur after the mount is established.

Second, memory is not an issue; this happens on lightly loaded clients
with 64Gbytes RAM,
and RAM is all cache and buffer.


> EIO is pretty generic, and is often what you see when a more obscure
> error is translated into what a syscall would expect. It can happen for
> other reasons besides an RPC timeout.


OK, so, our best bet to debug this, is to:
1) reproduce the problem
2) when the problem occurs, make sure the command that run that got an
EIO was running
under strace, so we know what syscall was being made
3) when we know what syscall was being made, backtrack to the kernel
source for that syscall
4) inspect the source to see what paths generate EIO

Dave
>
> --
> Jeff Layton <jlayton@redhat.com>
>

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

