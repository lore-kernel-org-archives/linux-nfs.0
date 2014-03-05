Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f175.google.com ([209.85.192.175]:59822 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753907AbaCEAtD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Mar 2014 19:49:03 -0500
Message-ID: <1393980534.26794.147.camel@edumazet-glaptop2.roam.corp.google.com>
Subject: Re: RCU stalls when running out of memory on 3.14-rc4 w/ NFS and
 kernel threads priorities changed
From: Eric Dumazet <eric.dumazet@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        linux-mm <linux-mm@kvack.org>, paulmck@linux.vnet.ibm.com,
        linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        netdev <netdev@vger.kernel.org>
Date: Tue, 04 Mar 2014 16:48:54 -0800
In-Reply-To: <CAGVrzcbsSV7h3qA3KuCTwKNFEeww_kSNcfUkfw3PPjeXQXBo6g@mail.gmail.com>
References: <CAGVrzcbsSV7h3qA3KuCTwKNFEeww_kSNcfUkfw3PPjeXQXBo6g@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2014-03-04 at 15:55 -0800, Florian Fainelli wrote:
> Hi all,
> 
> I am seeing the following RCU stalls messages appearing on an ARMv7
> 4xCPUs system running 3.14-rc4:
> 
> [   42.974327] INFO: rcu_sched detected stalls on CPUs/tasks:
> [   42.979839]  (detected by 0, t=2102 jiffies, g=4294967082,
> c=4294967081, q=516)
> [   42.987169] INFO: Stall ended before state dump start
> 
> this is happening under the following conditions:
> 
> - the attached bumper.c binary alters various kernel thread priorities
> based on the contents of bumpup.cfg and
> - malloc_crazy is running from a NFS share
> - malloc_crazy.c is running in a loop allocating chunks of memory but
> never freeing it
> 
> when the priorities are altered, instead of getting the OOM killer to
> be invoked, the RCU stalls are happening. Taking NFS out of the
> equation does not allow me to reproduce the problem even with the
> priorities altered.
> 
> This "problem" seems to have been there for quite a while now since I
> was able to get 3.8.13 to trigger that bug as well, with a slightly
> more detailed RCU debugging trace which points the finger at kswapd0.
> 
> You should be able to get that reproduced under QEMU with the
> Versatile Express platform emulating a Cortex A15 CPU and the attached
> files.
> 
> Any help or suggestions would be greatly appreciated. Thanks!

Do you have a more complete trace, including stack traces ?




