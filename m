Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:51057 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757810AbaLIQq0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Dec 2014 11:46:26 -0500
Message-ID: <54871E87.7000300@RedHat.com>
Date: Tue, 09 Dec 2014 11:08:39 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: =?UTF-8?B?RGF2aWQgSMOkcmRlbWFu?= <david@hardeman.nu>,
        Timo Teras <timo.teras@iki.fi>
CC: linux-nfs@vger.kernel.org,
        =?UTF-8?B?VGltbyBUZXLDpHM=?= <timo.teras@gmail.com>
Subject: Re: [PATCH v2 0/5] rework access to /proc/net/rpc
References: <399e974867e03c052fedfa8e8fd688ca@hardeman.nu> <20141209104236.2204671c@vostro> <24f5038cdd74837afb8a53887eb4b803@hardeman.nu>
In-Reply-To: <24f5038cdd74837afb8a53887eb4b803@hardeman.nu>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/09/2014 09:01 AM, David Härdeman wrote:
> On 2014-12-09 09:42, Timo Teras wrote:
>> On Tue, 09 Dec 2014 09:16:59 +0100
>> David Härdeman <david@hardeman.nu> wrote:
>>
>>> it seems that the "rework access to /proc/net/rpc" patchset removed
>>> dynamic buffers in favour of static, fixed size, buffers. That seems
>>> like a step backwards to me?
>>
>> Depends a bit on your view. On read() side, readline() like
>> functionality is removed yes. Though, my understanding is so that this
>> is not needed with the kernel API. Maybe someone can correct me if I'm
>> wrong. The removal simplifies memory management, overall code size. As
>> probably has a positive impact on speed too (probably not too big, but
>> this communication is used all overall, so it might be useful).
> 
> And it makes the buffer size static, introducing an arbitrary limitation (although a rather large one...32KB allocated on the stack IIRC)
> 
>> On write() side the old code was completely wrong. It did several
>> assumptions on how FILE buffering works, most of them being incorrect
>> in general, but also glibc. It only worked because no large messages
>> have been sent to kernel.
> 
> I didn't really check the write() side, it was just the readline() that I was interested in actually...
> 
>>
>>> At least the readline() function could be implemented using
>>> read/write (instead of fread/fwrite) and a dynamic buffer...no?
>>
>> It's extra complexity. I'd rather not add it unless it's required. My
>> understanding about the communication mechanism with kernel is that
>> it's not required. Why have code that would never be used?
> 
> I agree that it depends on your view. I tend to be very sceptical of arbitrary 
> limitations unless they have a very good reason (like measurable and relevant 
> performance impact), I doubt that's the case here.
Your skeptical-ability of arbitrary limitations has become very clear in 
the last few hours... ;-) I guess I'm indifferent about it... From reading
your gssd patch set, it is a bit more artful not to use fixed size buffers
but again, I'm indifferent... That said... if patches appear removing these
fixed buffers they definitely would be considered... 

> 
> It's up to the maintainer though, I just wanted to point it out :)
My understanding these patches were needed to make nfs-utils compatible with the musl c-library.
That is the case, correct? 

steved.
