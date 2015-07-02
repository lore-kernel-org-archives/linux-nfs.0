Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:34490 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751382AbbGBITF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Jul 2015 04:19:05 -0400
MIME-Version: 1.0
In-Reply-To: <20150702075932.GI17109@ZenIV.linux.org.uk>
References: <20150701062752.GC17109@ZenIV.linux.org.uk>
	<55939BE3.6040902@samsung.com>
	<20150701082753.GD17109@ZenIV.linux.org.uk>
	<5593A7A0.6050400@samsung.com>
	<20150701085507.GE17109@ZenIV.linux.org.uk>
	<5593CE37.4070307@samsung.com>
	<20150701184408.GF17109@ZenIV.linux.org.uk>
	<20150702032042.GA32613@ZenIV.linux.org.uk>
	<20150702041046.GG17109@ZenIV.linux.org.uk>
	<CAPAsAGzZVy3-D4J1ZGsUZU4RRQ36NtprZg_Uvfi5=46=1_rpWA@mail.gmail.com>
	<20150702075932.GI17109@ZenIV.linux.org.uk>
Date: Thu, 2 Jul 2015 11:19:03 +0300
Message-ID: <CAPAsAGzJW1C-4rd9myZOsiA9dLp2d420PTePaguK=y2RWjrz2A@mail.gmail.com>
Subject: Re: running out of tags in 9P (was Re: [git pull] vfs part 2)
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
To: Al Viro <viro@zeniv.linux.org.uk>,
        Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
        Eric Van Hensbergen <ericvh@gmail.com>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/02/2015 10:59 AM, Al Viro wrote:
> On Thu, Jul 02, 2015 at 10:50:05AM +0300, Andrey Ryabinin wrote:
>
>>>> and see if it triggers.  I'm not sure if failing with ENOMEM is the
>>>> right response (another variant is to sleep there until the pile
>>>> gets cleaned or until we get killed), and WARN_ON_ONCE() is definitely
>>>> not for the real work, but it will do for confirming that this is what
>>>> we are hitting.
>>>
>>
>> Apparently, I'm seeing something else. That WARN_ON_ONCE didn't trigger.
>
> Summary for those who'd missed the beginning of the thread: what we are
> seeing is p9_client_write() issing TWRITE and getting RWRITE in reply
> (tags match, packets look plausible) with count in RWRITE way more than
> that in TWRITE.
>
> IOW, we are telling the server to write e.g. 93 bytes and are getting told
> that yes, the write had been successful - all 4096 bytes of it.
>
> qemu virtio-9p for server; from my reading of qemu side of things, it can't
> be sending reply with count greater than that in request.

Besides qemu, I've also tried kvmtool with the same result. IOW I'm seeing
this under kvmtool as well. It just takes a bit longer to reproduce
this in kvmtool.

> The bug I suspected to be the cause of that is in tag allocation in
> net/9p/client.c - we could end up wrapping around 2^16 with enough pending
> requests and that would have triggered that kind of mess.  However, Andrey
> doesn't see that test (tag wraparound in p9_client_prepare_req()) trigger.
> BTW, was that on the run where debugging printk in p9_client_write() *did*
> trigger?

Yes, WARN_ON_ONCE() in p9_client_prepare_req() didn't trigger,
but debug printk in p9_client_write() *did* trigger.
