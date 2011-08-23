Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:33036 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752070Ab1HWOcI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Aug 2011 10:32:08 -0400
Received: by vxi9 with SMTP id 9so134944vxi.19
        for <linux-nfs@vger.kernel.org>; Tue, 23 Aug 2011 07:32:08 -0700 (PDT)
In-Reply-To: <4E52E538.7040807@panasas.com>
References: <1313197213-1651-1-git-send-email-bergwolf@gmail.com>
 <4E4AD655.9090305@panasas.com> <CA+a=Yy6xNFu62nZavt1KnrZWTZGjgR3H=bgF-uERsf=xp7TARg@mail.gmail.com>
 <4E52E538.7040807@panasas.com>
From: Peng Tao <bergwolf@gmail.com>
Date: Tue, 23 Aug 2011 22:31:48 +0800
Message-ID: <CA+a=Yy6xqzxDkE9siSWWJOhdtYWecU7UQHSO9RR_HL6q3ub4YQ@mail.gmail.com>
Subject: Re: [PATCH v2 0/3] recoalesce when ld read/write fails
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: benny@tonian.com, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi, Boaz,

On Tue, Aug 23, 2011 at 7:24 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:
> On 08/17/2011 06:42 AM, Peng Tao wrote:
> <snip>
>>> They look *really* good these patches. But as you said, do they actually work?
>>>
>>> Did you test any of this? I mean do you have a facility to inject random
>>> IO errors and test this out?
>> I have tested the patchset by forcing all bio to fail so IO will be
>> re-send to MDS. Also I tested read/write by forcing all IO that
>> touches pages beyond 16K to fail. Both tests passed.
>>
>
> So that sounds good. Why don't you like these patches?
Well, I do like them :)

>
>>>
> <snip>
>> I tried to test "git clone linux" on a 384M memory VM but it hangs as
>> server is rejecting layoutget with NFS4ERR_LAYOUTTRYLATER.
>> /proc/self/mountstats shows that client has sent more than 14K
>> layoutgets but never returns any layout. I checked related code and it
>> seems client should send layoutreturn for closed files. Will git keep
>> all files open? Or is there any case that client won't return the
>> layout even after file close?
>>
>
> Yes! our client will never ever return any layouts. The forgetful
> model for you. It will only ever "layout_return" on evict_inode which
> is way after close, when the Kernel decides to cleanup the inode
> cache. Which only happens after a while.
>
> If Your layout driver sets the RETURN_ON_CLOSE bit on the layout
> then the pNFSD server code will simulate a layout_return on a file
> close. This is what I use in EXOFS and it works very well. (I should
> know because I wrote this patch for the pnfsd server)
>
> It looks like your blocks-based pNFSD filesystem needs layouts
> returned. Set the res->lg_return_on_close = true; flag in your
> .layout_get member and you should see layout_return on close.
>
> Look in Benny's pNFS tree at fs/exofs/export.c file how I do
> it there.
Thanks for the explanation. Setting return_on_close may lose the
chance to reuse layout segments for reopen cases. I will look into it
more closely.

>
>> This seems to be another issue though.
>>
>
> Yes this is a different Issue.
>
> It looks from what you tested that the second approach works
> well. I'll also test this out later on. Lets not rule these
> out yet.
Thanks again for helping to test them.

Cheers,
Tao
>
>> Thanks,
>> Tao
>
> Sorry for the late response I just came back from Vacation,
> It'll me some time to catch up
>
> Thanks
> Boaz
>
