Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f42.google.com ([209.85.214.42]:40157 "EHLO
        mail-it0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751243AbdLIVEE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 9 Dec 2017 16:04:04 -0500
MIME-Version: 1.0
In-Reply-To: <1512767781.25033.30.camel@gmail.com>
References: <CAEdQ38HcOgAT6wJWWKY3P0hzYwkBGSQkRSQ2a=eaGmD6c6rwXA@mail.gmail.com>
 <CAEdQ38G4VTXDGOarmmTac=hP92VJbQHRFxQTaSWQ3j4d63pogg@mail.gmail.com>
 <CAEdQ38HcPswBk3pUHzQerFZ=4KjPc5nVYTqNnGQNMk7QbPXuOQ@mail.gmail.com>
 <CANn89iJKGRLVNAE99JWiyXcOXveytkjbQAiZ9XPiJc6fyEdFVA@mail.gmail.com>
 <1512741164.25033.28.camel@gmail.com> <CAEdQ38HEduSTY38Noj4peaMN_G++5sLJfqzCMkd3M4pPNTpU_Q@mail.gmail.com>
 <1512767781.25033.30.camel@gmail.com>
From: Matt Turner <mattst88@gmail.com>
Date: Sat, 9 Dec 2017 13:03:42 -0800
Message-ID: <CAEdQ38H+jUF3OXpe13Vfm=QZE3iHa=B7PpXkpbek1PnY2E1u5w@mail.gmail.com>
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

On Fri, Dec 8, 2017 at 1:16 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2017-12-08 at 12:26 -0800, Matt Turner wrote:
>>
>> Thanks for the quick reply!
>>
>> I tried the patch on top of master, but unfortunately the corruption
>> still occurs.
>
> You might try replacing in sbdma_add_rcvbuffer()
>
> sb_new = netdev_alloc_skb(dev, size);
>
> by
>
> sb_new = alloc_skb(size, GFP_ATOMIC);
>
> Maybe the device does not like having a frame spanning 2 pages.

No such luck. I also gave changing the page size from 16K to 4K a shot
without success.
