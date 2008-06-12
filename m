From: Wendy Cheng <s.wendy.cheng@gmail.com>
Subject: Re: [NFS] Server-side locking issue
Date: Thu, 12 Jun 2008 18:17:10 -0400
Message-ID: <4851A066.8060501@gmail.com>
References: <20080508221815.GB4583@async.com.br>	<20080509154305.GA798@fieldses.org> <20080612214340.GA17293@async.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Christian Robottom Reis <kiko@canonical.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7038 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754211AbYFLWN6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 18:13:58 -0400
In-Reply-To: <20080612214340.GA17293-Zkq4WM0RTTBfJ/NunPodnw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Christian Robottom Reis wrote:
>
> This time I did a ps auxww locking for the lockd process. And guess
> what?
>
> root      6323  0.0  0.0      0     0 ?        D    Jun01   0:50 [lockd]
>
> I wonder why it's in the D state. I also wonder if there's a way to get
> it back once it's in this state -- without reloading the kernel module
> or rebooting, I guess.
>
> I've collected a trace, at any rate, but lockd isn't even listed in it --
> I can send it in if it makes sense.
>   

What kind of "trace" data you've collected ? As a rule of thumb, when a 
process is stuck inside the kernel, the best approach is to:

shell> cd /proc
shell> echo w > sysrq-trigger // do this a couple of times
shell> echo t > sysrq-trigger

The "w" will force kernel to print out threads' backtrace that are 
currently on the active CPUs. The "t" will print out all the thread 
backtraces on this machine (but sometime skip the ones spinning on the 
CPUs). These traces will give people a much better idea what went on in 
the kernel at that particular time. All the backtraces should show up in 
/var/log/messages file and/or system console.

*Warning* ... the "t" will pause system for a noticeable amount of time 
(few seconds to few minutes, depending on thread counts) since it has to 
walk thru every thread's stack in that running system. If you have 
cluster configured, it could make the node missing its heartbeat 
processing (so you need to increase the heartbeat interval before doing 
this).

> What sort of debugging can I do to figure out what's wrong here?
>
> (This is a dual-Xeon running:
>
>     Linux anthem 2.6.22-14-generic #1 SMP Tue Feb 12 07:42:25 UTC 2008 i686 GNU/Linux)
>   
Another approach is to make a debug kernel and run "crash" to poke the 
live kernel. Dave Anderson from Red Hat has an excellent tutorial in his 
people's page: http://people.redhat.com/anderson . It is also very helpful.

-- Wendy


