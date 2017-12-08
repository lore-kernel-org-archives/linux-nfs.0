Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:44188 "EHLO
        mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750951AbdLHU1H (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Dec 2017 15:27:07 -0500
MIME-Version: 1.0
In-Reply-To: <1512741164.25033.28.camel@gmail.com>
References: <CAEdQ38HcOgAT6wJWWKY3P0hzYwkBGSQkRSQ2a=eaGmD6c6rwXA@mail.gmail.com>
 <CAEdQ38G4VTXDGOarmmTac=hP92VJbQHRFxQTaSWQ3j4d63pogg@mail.gmail.com>
 <CAEdQ38HcPswBk3pUHzQerFZ=4KjPc5nVYTqNnGQNMk7QbPXuOQ@mail.gmail.com>
 <CANn89iJKGRLVNAE99JWiyXcOXveytkjbQAiZ9XPiJc6fyEdFVA@mail.gmail.com> <1512741164.25033.28.camel@gmail.com>
From: Matt Turner <mattst88@gmail.com>
Date: Fri, 8 Dec 2017 12:26:46 -0800
Message-ID: <CAEdQ38HEduSTY38Noj4peaMN_G++5sLJfqzCMkd3M4pPNTpU_Q@mail.gmail.com>
Subject: Re: NFS corruption, fixed by echo 1 > /proc/sys/vm/drop_caches --
 next debugging steps?
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>,
        linux-nfs@vger.kernel.org, Paolo Abeni <pabeni@redhat.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        "Peter Zijlstra (Intel)" <peterz@infradead.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Ingo Molnar <mingo@kernel.org>,
        Manuel Lauss <manuel.lauss@gmail.com>,
        LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 8, 2017 at 5:52 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2017-12-08 at 05:42 -0800, Eric Dumazet wrote:
>> On Thu, Dec 7, 2017 at 11:54 PM, Matt Turner <mattst88@gmail.com>
>> wrote:
>> > On Thu, Dec 7, 2017 at 11:00 PM, Matt Turner <mattst88@gmail.com>
>> > wrote:
>> > > On Sun, Mar 12, 2017 at 6:43 PM, Matt Turner <mattst88@gmail.com>
>> > > wrote:
>> > > > On a Broadcom BCM91250a MIPS system I can reliably trigger NFS
>> > > > corruption on the first file read.
>> > > >
>> > > > To demonstrate, I downloaded five identical copies of the gcc-
>> > > > 5.4.0
>> > > > source tarball. On the NFS server, they hash to the same value:
>> > > >
>> > > > server distfiles # md5sum gcc-5.4.0.tar.bz2*
>> > > > 4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2
>> > > > 4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2.1
>> > > > 4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2.2
>> > > > 4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2.3
>> > > > 4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2.4
>> > > >
>> > > > On the MIPS system (the NFS client):
>> > > >
>> > > > bcm91250a-le distfiles # md5sum gcc-5.4.0.tar.bz2.2
>> > > > 35346975989954df8a8db2b034da610d  gcc-5.4.0.tar.bz2.2
>> > > > bcm91250a-le distfiles # md5sum gcc-5.4.0.tar.bz2*
>> > > > 4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2
>> > > > 4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2.1
>> > > > 35346975989954df8a8db2b034da610d  gcc-5.4.0.tar.bz2.2
>> > > > 4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2.3
>> > > > 4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2.4
>> > > >
>> > > > The first file read will contain some corruption, and it is
>> > > > persistent until...
>> > > >
>> > > > bcm91250a-le distfiles # echo 1 > /proc/sys/vm/drop_caches
>> > > > bcm91250a-le distfiles # md5sum gcc-5.4.0.tar.bz2*
>> > > > 4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2
>> > > > 4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2.1
>> > > > 4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2.2
>> > > > 4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2.3
>> > > > 4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2.4
>> > > >
>> > > > the caches are dropped, at which point it reads back properly.
>> > > >
>> > > > Note that the corruption is different across reboots, both in
>> > > > the size
>> > > > of the corruption and the location. I saw 1900~ and 1400~ byte
>> > > > sequences corrupted on separate occasions, which don't
>> > > > correspond to
>> > > > the system's 16kB page size.
>> > > >
>> > > > I've tested kernels from v3.19 to 4.11-rc1+ (master branch from
>> > > > today). All exhibit this behavior with differing frequencies.
>> > > > Earlier
>> > > > kernels seem to reproduce the issue less often, while more
>> > > > recent
>> > > > kernels reliably exhibit the problem every boot.
>> > > >
>> > > > How can I further debug this?
>> > >
>> > > I think I was wrong about the statement about kernels v3.19 to
>> > > 4.11-rc1+. I found out I couldn't reproduce with 4.7-rc1 and then
>> > > bisected to 4cd13c21b207e80ddb1144c576500098f2d5f882 ("softirq:
>> > > Let
>> > > ksoftirqd do its job"). Still reproduces with current tip of
>> > > Linus'
>> > > tree.
>> > >
>> > > Any ideas? The board's ethernet is an uncommon device supported
>> > > by
>> > > CONFIG_SB1250_MAC. Something about the ethernet driver maybe?
>> >
>> > With the patch reverted on master (reverts cleanly), NFS corruption
>> > no
>> > longer happens.
>>
>> Hi Matt.
>>
>> Thanks for bisecting.
>>
>> Patch simply exposes an existing bug more often by changing the way
>> driver functions are scheduled.
>>
>> Which is probably a good thing.
>>
>> sbmac_intr() looks extremely suspicious to me.
>>
>> A NAPI driver hard interrupt should simply schedule NAPI.
>>
>> Apparently, if sbmac_intr() can not grab NAPIF_STATE_SCHED bit, it
>> directly calls sbdma_rx_process() from
>> hard interrupt context.
>>
>> Insane really.
>
> Please try this fix (not compiled on my x86 laptop, and I had no coffee
> yet, so it might have some trivial errors)

Thanks for the quick reply!

I tried the patch on top of master, but unfortunately the corruption
still occurs.
