Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:56229 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752328Ab1LYPZl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 25 Dec 2011 10:25:41 -0500
Message-ID: <4EF74056.2040306@panasas.com>
Date: Sun, 25 Dec 2011 17:25:10 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Benny Halevy <bhalevy@tonian.com>
CC: Jim Rees <rees@umich.edu>, fanchaoting <fanchaoting@cn.fujitsu.com>,
        Benny Halevy <benny@tonian.com>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] fix do_xor_speed 64-bit devision issue on 32-bits arch
References: <1323266927-3686-1-git-send-email-bhalevy@tonian.com> <4EF422A8.5070907@cn.fujitsu.com> <20111223132546.GA10015@umich.edu> <4EF6B516.5070609@tonian.com>
In-Reply-To: <4EF6B516.5070609@tonian.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/25/2011 07:31 AM, Benny Halevy wrote:
> On 2011-12-23 15:25, Jim Rees wrote:
>> fanchaoting wrote:
>>
>>   Benny Halevy 写道:
>>   > I am trying to build a pnfs client on a 32 bit system  and the
>>   > pnfs-latest  kernel fails to compile. I get the following error
>>   > 
>>   >  >  Building modules, stage 2.
>>   >  >  TEST    posttest
>>   >  > MODPOST 2046 modules
>>   >  >ERROR: "__udivdi3" [crypto/xor.ko] undefined!
>>   >  >make[1]: *** [__modpost] Error 1
>>   >  >make: *** [modules] Error 2
>>   >  >make: *** Waiting for unfinished jobs....
>>   >  >Succeed: decoded and checked 1244492 instructions
>>   > 
>>   > Reported-by: Rita Sequeira <rita.prajval@gmail.com>
>>   > Signed-off-by: Benny Halevy <bhalevy@tonian.com>
>>   > ---
>>   > 
>>   > untested patch yet...
>>   > 
>>   >  crypto/xor.c |    3 ++-
>>   >  1 files changed, 2 insertions(+), 1 deletions(-)
>>   > 
>>   > diff --git a/crypto/xor.c b/crypto/xor.c
>>   > index 65433f5..2151ded 100644
>>   > --- a/crypto/xor.c
>>   > +++ b/crypto/xor.c
>>   > @@ -95,7 +95,8 @@
>>   >  
>>   >  	ns_end -= ns_begin;
>>   >  	if (ns_end > 0)
>>   > -		speed = BENCH_SIZE / 1024 * count * NSEC_PER_SEC / ns_end;
>>   > +		speed = BENCH_SIZE / 1024 * count *
>>   > +				(unsigned)(NSEC_PER_SEC / ns_end);
>>   >  	else
>>   >  		speed = 17;
>>   >  	tmpl->speed = speed;
>>   
>>   Hi,I also meet this problem ,but when  i use you patch ,i can't solve this
>>   problem.
>>
>> Maybe something like this?
>>
>> speed = do_div(BENCH_SIZE, 1024) * count * do_div(NSEC_PER_SEC, ns_end);
>>
>> This might not be exactly right because it changes the operator precedence,
>> but it should eliminate the calls to __udivdi3.
> 
> Hmm, you mean execution order? (which you do not)
> C (and fortunately gcc too :) treats multiplication and division with the
> same priority and executes them from left to right...
> 
> Boaz, please ack...
> 

Hi

Please trash this patch for now. I will carry it out of tree for my use.
(Looks I'm the only one who's using UML and the XOR engine)

By next Connectathon I'll have a better patch sent to the right
people.

Thanks for your efforts, and sorry for the grief it caused.
Boaz

> Benny
> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

