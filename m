Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:37106 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751758Ab1LZHLn convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Dec 2011 02:11:43 -0500
Received: by obcwo16 with SMTP id wo16so6322048obc.19
        for <linux-nfs@vger.kernel.org>; Sun, 25 Dec 2011 23:11:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4EF74056.2040306@panasas.com>
References: <1323266927-3686-1-git-send-email-bhalevy@tonian.com>
 <4EF422A8.5070907@cn.fujitsu.com> <20111223132546.GA10015@umich.edu>
 <4EF6B516.5070609@tonian.com> <4EF74056.2040306@panasas.com>
From: Benny Halevy <bhalevy@tonian.com>
Date: Mon, 26 Dec 2011 09:11:22 +0200
Message-ID: <CAEMWVhsOemzR4D0DExT-eCeECps_ED690ogJ5uoLiAdT3DY0VQ@mail.gmail.com>
Subject: Re: [PATCH] fix do_xor_speed 64-bit devision issue on 32-bits arch
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Jim Rees <rees@umich.edu>, fanchaoting <fanchaoting@cn.fujitsu.com>,
        linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

No problem.  I'll revert it then.

Thanks,

Benny

On Sun, Dec 25, 2011 at 5:25 PM, Boaz Harrosh <bharrosh@panasas.com> wrote:
> On 12/25/2011 07:31 AM, Benny Halevy wrote:
>> On 2011-12-23 15:25, Jim Rees wrote:
>>> fanchaoting wrote:
>>>
>>>   Benny Halevy 写道:
>>>   > I am trying to build a pnfs client on a 32 bit system  and the
>>>   > pnfs-latest  kernel fails to compile. I get the following error
>>>   >
>>>   >  >  Building modules, stage 2.
>>>   >  >  TEST    posttest
>>>   >  > MODPOST 2046 modules
>>>   >  >ERROR: "__udivdi3" [crypto/xor.ko] undefined!
>>>   >  >make[1]: *** [__modpost] Error 1
>>>   >  >make: *** [modules] Error 2
>>>   >  >make: *** Waiting for unfinished jobs....
>>>   >  >Succeed: decoded and checked 1244492 instructions
>>>   >
>>>   > Reported-by: Rita Sequeira <rita.prajval@gmail.com>
>>>   > Signed-off-by: Benny Halevy <bhalevy@tonian.com>
>>>   > ---
>>>   >
>>>   > untested patch yet...
>>>   >
>>>   >  crypto/xor.c |    3 ++-
>>>   >  1 files changed, 2 insertions(+), 1 deletions(-)
>>>   >
>>>   > diff --git a/crypto/xor.c b/crypto/xor.c
>>>   > index 65433f5..2151ded 100644
>>>   > --- a/crypto/xor.c
>>>   > +++ b/crypto/xor.c
>>>   > @@ -95,7 +95,8 @@
>>>   >
>>>   >          ns_end -= ns_begin;
>>>   >          if (ns_end > 0)
>>>   > -                speed = BENCH_SIZE / 1024 * count * NSEC_PER_SEC / ns_end;
>>>   > +                speed = BENCH_SIZE / 1024 * count *
>>>   > +                                (unsigned)(NSEC_PER_SEC / ns_end);
>>>   >          else
>>>   >                  speed = 17;
>>>   >          tmpl->speed = speed;
>>>
>>>   Hi,I also meet this problem ,but when  i use you patch ,i can't solve this
>>>   problem.
>>>
>>> Maybe something like this?
>>>
>>> speed = do_div(BENCH_SIZE, 1024) * count * do_div(NSEC_PER_SEC, ns_end);
>>>
>>> This might not be exactly right because it changes the operator precedence,
>>> but it should eliminate the calls to __udivdi3.
>>
>> Hmm, you mean execution order? (which you do not)
>> C (and fortunately gcc too :) treats multiplication and division with the
>> same priority and executes them from left to right...
>>
>> Boaz, please ack...
>>
>
> Hi
>
> Please trash this patch for now. I will carry it out of tree for my use.
> (Looks I'm the only one who's using UML and the XOR engine)
>
> By next Connectathon I'll have a better patch sent to the right
> people.
>
> Thanks for your efforts, and sorry for the grief it caused.
> Boaz
>
>> Benny
>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
