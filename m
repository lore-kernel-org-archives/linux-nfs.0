Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f175.google.com ([209.85.192.175]:41718 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756055AbaCEDzn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Mar 2014 22:55:43 -0500
MIME-Version: 1.0
In-Reply-To: <20140305014310.GC3334@linux.vnet.ibm.com>
References: <CAGVrzcbsSV7h3qA3KuCTwKNFEeww_kSNcfUkfw3PPjeXQXBo6g@mail.gmail.com>
 <1393980534.26794.147.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAGVrzcaekM51hme_tquaT6e22fV1_cocpn1kDUsYfFce=F+o4g@mail.gmail.com>
 <CAGVrzcbRycBy0w64R9pV=JG6M3aJeARbOnh-xRrumYzzVDgWGQ@mail.gmail.com> <20140305014310.GC3334@linux.vnet.ibm.com>
From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 4 Mar 2014 19:55:03 -0800
Message-ID: <CAGVrzcae0XPXpue_+n-O+EBzK92JqXHNftTPGt+5SRzroTSF3Q@mail.gmail.com>
Subject: Re: RCU stalls when running out of memory on 3.14-rc4 w/ NFS and
 kernel threads priorities changed
To: Paul McKenney <paulmck@linux.vnet.ibm.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        linux-mm <linux-mm@kvack.org>, linux-nfs <linux-nfs@vger.kernel.org>,
        "trond.myklebust" <trond.myklebust@primarydata.com>,
        netdev <netdev@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2014-03-04 17:43 GMT-08:00 Paul E. McKenney <paulmck@linux.vnet.ibm.com>:
> On Tue, Mar 04, 2014 at 05:16:27PM -0800, Florian Fainelli wrote:
>> 2014-03-04 17:03 GMT-08:00 Florian Fainelli <f.fainelli@gmail.com>:
>> > 2014-03-04 16:48 GMT-08:00 Eric Dumazet <eric.dumazet@gmail.com>:
>> >> On Tue, 2014-03-04 at 15:55 -0800, Florian Fainelli wrote:
>> >>> Hi all,
>> >>>
>> >>> I am seeing the following RCU stalls messages appearing on an ARMv7
>> >>> 4xCPUs system running 3.14-rc4:
>> >>>
>> >>> [   42.974327] INFO: rcu_sched detected stalls on CPUs/tasks:
>> >>> [   42.979839]  (detected by 0, t=2102 jiffies, g=4294967082,
>> >>> c=4294967081, q=516)
>> >>> [   42.987169] INFO: Stall ended before state dump start
>> >>>
>> >>> this is happening under the following conditions:
>> >>>
>> >>> - the attached bumper.c binary alters various kernel thread priorities
>> >>> based on the contents of bumpup.cfg and
>> >>> - malloc_crazy is running from a NFS share
>> >>> - malloc_crazy.c is running in a loop allocating chunks of memory but
>> >>> never freeing it
>> >>>
>> >>> when the priorities are altered, instead of getting the OOM killer to
>> >>> be invoked, the RCU stalls are happening. Taking NFS out of the
>> >>> equation does not allow me to reproduce the problem even with the
>> >>> priorities altered.
>> >>>
>> >>> This "problem" seems to have been there for quite a while now since I
>> >>> was able to get 3.8.13 to trigger that bug as well, with a slightly
>> >>> more detailed RCU debugging trace which points the finger at kswapd0.
>> >>>
>> >>> You should be able to get that reproduced under QEMU with the
>> >>> Versatile Express platform emulating a Cortex A15 CPU and the attached
>> >>> files.
>> >>>
>> >>> Any help or suggestions would be greatly appreciated. Thanks!
>> >>
>> >> Do you have a more complete trace, including stack traces ?
>> >
>> > Attatched is what I get out of SysRq-t, which is the only thing I have
>> > (note that the kernel is built with CONFIG_RCU_CPU_STALL_INFO=y):
>>
>> QEMU for Versatile Express w/ 2 CPUs yields something slightly
>> different than the real HW platform this is happening with, but it
>> does produce the RCU stall anyway:
>>
>> [  125.762946] BUG: soft lockup - CPU#1 stuck for 53s! [malloc_crazy:91]
>
> This soft-lockup condition can result in RCU CPU stall warnings.  Fix
> the problem causing the soft lockup, and I bet that your RCU CPU stall
> warnings go away.

I definitively agree, which is why I was asking for help, as I think
the kernel thread priority change is what is causing the soft lockup
to appear, but nothing obvious jumps to mind when looking at the
trace.

Thanks!
-- 
Florian
