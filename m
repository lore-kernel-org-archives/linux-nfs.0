Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:33350 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751016AbcFIVKh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jun 2016 17:10:37 -0400
MIME-Version: 1.0
In-Reply-To: <89EF59F9-52D2-4F37-A7A8-52BD0FF7E98E@primarydata.com>
References: <1465448705-25055-1-git-send-email-deepa.kernel@gmail.com>
 <1465448705-25055-19-git-send-email-deepa.kernel@gmail.com> <89EF59F9-52D2-4F37-A7A8-52BD0FF7E98E@primarydata.com>
From: Deepa Dinamani <deepa.kernel@gmail.com>
Date: Thu, 9 Jun 2016 14:10:35 -0700
Message-ID: <CABeXuvoLr7amTYBs5AbMv15Vqx2CQib9F8Qr4GzX9RoZZ9ZnpQ@mail.gmail.com>
Subject: Re: [PATCH 18/21] fs: nfs: Make nfs boot time y2038 safe
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        "y2038@lists.linaro.org" <y2038@lists.linaro.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>>boot_time is represented as a struct timespec.
>>struct timespec and CURRENT_TIME are not y2038 safe.
>>Overall, the plan is to use timespec64 for all internal
>>kernel representation of timestamps.
>>CURRENT_TIME will also be removed.
>>Use struct timespec64 to represent boot_time.
>>And, ktime_get_real_ts64() for the boot_time value.
>>
>>boot_time is used to construct the nfs client boot verifier.
>>This will now wrap in 2106 instead of 2038 on 32-bit systems.
>>The server only relies on the value being persistent until
>>reboot so the wrapping should be fine.
>
> We really do not give a damn about wraparound here, since the boot time is
> only ever compared for an exact match, and the odds of two reboots occurring
> exactly 2^32 * 10^9 nanoseconds apart are cosmically small...
> If struct timespec is going away, can we just convert this into a ktime_t?

timespec64 is the same as timespec already on 64 bit machines.
But, yes, we can use ktime_t here.

Did you mean the internal storage value or the wire boo_time used for verifier?
In case you don't want to change the wire value, then we will have a division
operation, every time the verifier needs to be sent.

-Deepa

-Deepa
