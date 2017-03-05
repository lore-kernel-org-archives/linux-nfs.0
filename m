Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail1.trendhosting.net ([195.8.117.5]:49504 "EHLO
        mail1.trendhosting.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751652AbdCEUCW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 5 Mar 2017 15:02:22 -0500
Subject: Re: Bug#852395: unblock: gssproxy/0.5.1-2
To: Niels Thykier <niels@thykier.net>, linux-nfs@vger.kernel.org,
        852395@bugs.debian.org, Robbie Harwood <rharwood@club.cc.cmu.edu>
References: <148524180980.26332.422684345851896222.reportbug@kirtar>
 <8ed20c71-d7e2-72e1-a8ce-c913f8e0fffd@thykier.net>
 <17e5fbd0-9bb1-d7fa-6056-8adbda8a1f4d@pocock.pro>
 <e157cdda-35b6-8643-7d9f-da79faec56f7@thykier.net>
 <e157cdda-35b6-8643-7d9f-da79faec56f7@thykier.net>
 <5df78805-b791-0a5e-3dcb-99792d78c3bd@thykier.net>
Cc: Debian kernel team <debian-kernel@lists.debian.org>
From: Daniel Pocock <daniel@pocock.pro>
Message-ID: <f4e3252f-0115-954d-5749-c330c6905b75@pocock.pro>
Date: Sun, 5 Mar 2017 20:09:13 +0100
MIME-Version: 1.0
In-Reply-To: <5df78805-b791-0a5e-3dcb-99792d78c3bd@thykier.net>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/03/17 19:42, Niels Thykier wrote:
> On Sat, 04 Feb 2017 09:58:00 +0000 Niels Thykier <niels@thykier.net> wrote:
>> Daniel Pocock:
>>> [...]
>>>
>>> Upstream is not really supporting rpc.svcgssd any more, they actually
>>> disabled it in the build so people can still have it as a transitional
>>> measure in stretch.
>>>
>>> People shouldn't be using it in any new installations.  Offering them
>>> gssproxy is a very sensible thing to do.
>>>
>>> Regards,
>>>
>>> Daniel
>>>
>> Debian kernel team <debian-kernel@lists.debian.org>
>> Ok, follow up questions:
>>
>>  * Do you have an upstream reference to the state of rpc.svcgssd?


http://git.linux-nfs.org/?p=steved/nfs-utils.git;a=commit;h=24b5d60d7f0a514310df810e3eb27b72f665febf

"svcgssd: Disable support for the rpcsec_gss server by default

At this point the gssproxy is better option than the
svcgssd so the support is off by default.

Use --enable-svcgss to re-enable the support"

but it looks like it may not be completely abandoned, there have been
other commits that mention gssd recently.


>>
>>  * Can we provide both rpc.svcgssd and gssproxy in Debian (with the
>>    admin choosing) or is it an "xor"?
>>

I think there are two questions:

a) can they both exist in different packages that conflict with each
other?  I'm guessing that will probably be yes.

b) can they both be installed simultaneously?  Possibly not (can anybody
on the linux-nfs list answer?)


>>  * If this package is unblocked, are there any changes needed in
>>    nfs-common needed to support gssproxy?  (source upload, binNMU or
>>    "just works with no further changes")
>>

I don't have time to investigate that right now, if anybody else has
time to look more closely that would be great.

Regards,

Daniel
