Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f53.google.com ([209.85.220.53]:48513 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752438Ab3AXAYI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jan 2013 19:24:08 -0500
Subject: Re: 3.7.3+:  Bad paging request in ip_rcv_finish while running NFS
 traffic.
From: Eric Dumazet <eric.dumazet@gmail.com>
To: Ben Greear <greearb@candelatech.com>
Cc: netdev <netdev@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <51007CA8.2050105@candelatech.com>
References: <50FDADF4.3060601@candelatech.com>
	 <50FDDE35.7070806@candelatech.com>
	 <1358829606.3464.3151.camel@edumazet-glaptop>
	 <50FE2A57.3040804@candelatech.com>  <50FEC796.5090404@candelatech.com>
	 <1358875020.3464.4006.camel@edumazet-glaptop>
	 <1358875607.3464.4020.camel@edumazet-glaptop>
	 <50FF102F.2050008@candelatech.com> <50FF4BC9.1060206@candelatech.com>
	 <5100785D.8040101@candelatech.com>
	 <1358985688.12374.1247.camel@edumazet-glaptop>
	 <51007CA8.2050105@candelatech.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 23 Jan 2013 16:23:51 -0800
Message-ID: <1358987031.12374.1276.camel@edumazet-glaptop>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2013-01-23 at 16:13 -0800, Ben Greear wrote:
> On 01/23/2013 04:01 PM, Eric Dumazet wrote:
> > On Wed, 2013-01-23 at 15:55 -0800, Ben Greear wrote:
> >> On 01/22/2013 06:32 PM, Ben Greear wrote:
> >>
> >> So, I'm slowly making some progress.  I've verified that the skb
> >> has bogus dst (0xdeadbeef) at the top of the ip_rcv_finish
> >> method.  I'm trying to track it backwards and figure out which
> >> device it belongs to, etc....takes a while to reproduce though.
> >>
> >> One thing about this stack trace below...the dev_seq_stop() does
> >> a rcu read-unlock.  Now, I can't figure out exactly how ip_rcv()
> >> can cause dev_seq_stop() to run, but if this stack is legit,
> >> then maybe by the time we enter the ip_rcv_finish() code we are
> >> running without rcu_readlock() held?
> >>
> >> If so, that would probably explain the bug.
> >>
> >
> > The whole thing is run under rcu_read_lock() done in
> > __netif_receive_skb()
> 
> I was worried that the dev_seq_stop might be called
> incorrectly causing an asymetric unlock.  I have no
> idea how that might happened, but several crashes
> have that dev_seq_stop method listed, so it got me suspicious.

dev_seq_stop() is some word in the kernel stack, result of a prior
system call. Stack is not cleanup.

Each function reserves an amount of stack but not always write on all
reserved space (some automatic variables might be not set)

Note the "? " before the name : linux printed the symbol but this was
not a call site for this particular call graph. Its only an extra
indication, that can be useful sometimes.



