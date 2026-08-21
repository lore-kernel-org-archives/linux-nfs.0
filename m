Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 21C38415F36;
	Fri, 21 Aug 2026 07:56:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787299017; cv=none; b=juBKrFGGjE7qBhsfa+rZSVV9vBRcQ9y0GxWgeWBzi+iYxlCu8i3kg1OColmoxV22pdPxM3xxQ4Ha9O2BMY+W4vWTbzwdZwDGhIEsKguhkMa2TgFlpBXLZltBKbWOVI2N7IKqz4bYV3hKTUqDupaP1b/bQWTzImFzRkt5IaxWo20=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787299017; c=relaxed/simple;
	bh=Ktoz30SyulwVUFAipYMHhrBB8vsqFxIFo0/c4PKW/g8=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=f8gmwIZ32O2pqHLYX4wi4ln9onqDgJJCPPfDAdewE9wN+N0jmRGcFOvN/oo3OW9dWZPOXzJpU+TQWXEOOerM3cSk36MKI/JQuPZ8q+KBOEchwg92wZyA1aZ2PHjJIfRFND73pJEmpZK8shCAkMbqkfzZ/8oJl3scX+inltPJk6U=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=B7FKkvTN; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="B7FKkvTN"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 21AD01F000E9;
	Fri, 21 Aug 2026 07:56:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787299015;
	bh=tjjBBZ/k0RLbSDGZaWeN6t6IvNROJ7OMmNej421EHXw=;
	h=Date:Subject:To:Cc:References:From:In-Reply-To;
	b=B7FKkvTN+AVvwFWaae0GEz5bWAYGMjhYykTrLQH6sZHxNtmwJSC06TT6oijP5rGyj
	 05snL9vfZwtw3LreSzJcJqjZ+mG5lZDEdTI7rgZMcN83z1uikEHEHFp6A30/1kJ8xg
	 MQZMOcXRp+Za4puQ9RCN8egvQkgBEJkMzE4BZXTAxNeqfyifjPZwrFCMZN/uQ8E5Yt
	 IfHqTL4RoEmG+mjLKT4CyTVKh+p2vEprX8aMnavjB8RCBKRNBPSIVagli0TSSk1WTd
	 JJ7dScWvo11ij5GhsRdhzrY2RwyJIcUIt9NYe5bcObHvjJmePWnU1OQpzeGEubLNlk
	 G8Y435QyEiqcQ==
Message-ID: <825134a8-ceae-430c-b2fc-d1d0c7240f39@kernel.org>
Date: Fri, 21 Aug 2026 09:56:05 +0200
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH v19 00/40] DEPT(DEPendency Tracker)
To: Byungchul Park <byungchul@sk.com>
Cc: linux-kernel@vger.kernel.org, max.byungchul.park@gmail.com,
 kernel_team@skhynix.com, torvalds@linux-foundation.org,
 damien.lemoal@opensource.wdc.com, linux-ide@vger.kernel.org,
 adilger.kernel@dilger.ca, linux-ext4@vger.kernel.org, mingo@redhat.com,
 peterz@infradead.org, will@kernel.org, tglx@linutronix.de,
 rostedt@goodmis.org, joel@joelfernandes.org, sashal@kernel.org,
 daniel.vetter@ffwll.ch, duyuyang@gmail.com, johannes.berg@intel.com,
 tj@kernel.org, tytso@mit.edu, willy@infradead.org, david@fromorbit.com,
 amir73il@gmail.com, gregkh@linuxfoundation.org, kernel-team@lge.com,
 linux-mm@kvack.org, akpm@linux-foundation.org, mhocko@kernel.org,
 minchan@kernel.org, hannes@cmpxchg.org, vdavydov.dev@gmail.com,
 sj@kernel.org, jglisse@redhat.com, dennis@kernel.org, cl@linux.com,
 penberg@kernel.org, rientjes@google.com, vbabka@suse.cz, ngupta@vflare.org,
 linux-block@vger.kernel.org, josef@toxicpanda.com,
 linux-fsdevel@vger.kernel.org, jack@suse.cz, jlayton@kernel.org,
 dan.j.williams@intel.com, hch@infradead.org, djwong@kernel.org,
 dri-devel@lists.freedesktop.org, rodrigosiqueiramelo@gmail.com,
 melissa.srw@gmail.com, hamohammed.sa@gmail.com, harry.yoo@oracle.com,
 chris.p.wilson@intel.com, gwan-gyeong.mun@intel.com, boqun.feng@gmail.com,
 longman@redhat.com, yunseong.kim@ericsson.com, ysk@kzalloc.com,
 yeoreum.yun@arm.com, netdev@vger.kernel.org, matthew.brost@intel.com,
 her0gyugyu@gmail.com, corbet@lwn.net, catalin.marinas@arm.com, bp@alien8.de,
 x86@kernel.org, hpa@zytor.com, luto@kernel.org, sumit.semwal@linaro.org,
 gustavo@padovan.org, christian.koenig@amd.com, andi.shyti@kernel.org,
 arnd@arndb.de, lorenzo.stoakes@oracle.com, Liam.Howlett@oracle.com,
 rppt@kernel.org, surenb@google.com, mcgrof@kernel.org, petr.pavlu@suse.com,
 da.gomez@kernel.org, samitolvanen@google.com, paulmck@kernel.org,
 frederic@kernel.org, neeraj.upadhyay@kernel.org, joelagnelf@nvidia.com,
 josh@joshtriplett.org, urezki@gmail.com, mathieu.desnoyers@efficios.com,
 jiangshanlai@gmail.com, qiang.zhang@linux.dev, juri.lelli@redhat.com,
 vincent.guittot@linaro.org, dietmar.eggemann@arm.com, bsegall@google.com,
 mgorman@suse.de, vschneid@redhat.com, chuck.lever@oracle.com,
 neil@brown.name, okorniev@redhat.com, Dai.Ngo@oracle.com, tom@talpey.com,
 trondmy@kernel.org, anna@kernel.org, kees@kernel.org, bigeasy@linutronix.de,
 clrkwllms@kernel.org, mark.rutland@arm.com, ada.coupriediaz@arm.com,
 kristina.martsenko@arm.com, wangkefeng.wang@huawei.com, broonie@kernel.org,
 kevin.brodsky@arm.com, dwmw@amazon.co.uk, shakeel.butt@linux.dev,
 ast@kernel.org, ziy@nvidia.com, yuzhao@google.com,
 baolin.wang@linux.alibaba.com, usamaarif642@gmail.com,
 joel.granados@kernel.org, richard.weiyang@gmail.com,
 geert+renesas@glider.be, tim.c.chen@linux.intel.com, linux@treblig.org,
 alexander.shishkin@linux.intel.com, lillian@star-ark.net,
 chenhuacai@kernel.org, francesco@valla.it, guoweikang.kernel@gmail.com,
 link@vivo.com, jpoimboe@kernel.org, masahiroy@kernel.org,
 brauner@kernel.org, thomas.weissschuh@linutronix.de, oleg@redhat.com,
 mjguzik@gmail.com, andrii@kernel.org, wangfushuai@baidu.com,
 linux-doc@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-media@vger.kernel.org, linaro-mm-sig@lists.linaro.org,
 linux-i2c@vger.kernel.org, linux-arch@vger.kernel.org,
 linux-modules@vger.kernel.org, rcu@vger.kernel.org,
 linux-nfs@vger.kernel.org, linux-rt-devel@lists.linux.dev,
 2407018371@qq.com, dakr@kernel.org, miguel.ojeda.sandonis@gmail.com,
 neilb@ownmail.net, bagasdotme@gmail.com, wsa+renesas@sang-engineering.com,
 dave.hansen@intel.com, geert@linux-m68k.org, ojeda@kernel.org,
 alex.gaynor@gmail.com, gary@garyguo.net, bjorn3_gh@protonmail.com,
 lossin@kernel.org, a.hindborg@kernel.org, aliceryhl@google.com,
 tmgross@umich.edu, rust-for-linux@vger.kernel.org
References: <20260706061928.66713-1-byungchul@sk.com>
 <359ea967-9b97-4584-88e6-bddb4044de2e@kernel.org>
 <20260821042143.GA40890@system.software.com>
From: "David Hildenbrand (Arm)" <david@kernel.org>
Content-Language: en-US
Autocrypt: addr=david@kernel.org; keydata=
 xsFNBFXLn5EBEAC+zYvAFJxCBY9Tr1xZgcESmxVNI/0ffzE/ZQOiHJl6mGkmA1R7/uUpiCjJ
 dBrn+lhhOYjjNefFQou6478faXE6o2AhmebqT4KiQoUQFV4R7y1KMEKoSyy8hQaK1umALTdL
 QZLQMzNE74ap+GDK0wnacPQFpcG1AE9RMq3aeErY5tujekBS32jfC/7AnH7I0v1v1TbbK3Gp
 XNeiN4QroO+5qaSr0ID2sz5jtBLRb15RMre27E1ImpaIv2Jw8NJgW0k/D1RyKCwaTsgRdwuK
 Kx/Y91XuSBdz0uOyU/S8kM1+ag0wvsGlpBVxRR/xw/E8M7TEwuCZQArqqTCmkG6HGcXFT0V9
 PXFNNgV5jXMQRwU0O/ztJIQqsE5LsUomE//bLwzj9IVsaQpKDqW6TAPjcdBDPLHvriq7kGjt
 WhVhdl0qEYB8lkBEU7V2Yb+SYhmhpDrti9Fq1EsmhiHSkxJcGREoMK/63r9WLZYI3+4W2rAc
 UucZa4OT27U5ZISjNg3Ev0rxU5UH2/pT4wJCfxwocmqaRr6UYmrtZmND89X0KigoFD/XSeVv
 jwBRNjPAubK9/k5NoRrYqztM9W6sJqrH8+UWZ1Idd/DdmogJh0gNC0+N42Za9yBRURfIdKSb
 B3JfpUqcWwE7vUaYrHG1nw54pLUoPG6sAA7Mehl3nd4pZUALHwARAQABzS5EYXZpZCBIaWxk
 ZW5icmFuZCAoQ3VycmVudCkgPGRhdmlkQGtlcm5lbC5vcmc+wsGQBBMBCAA6AhsDBQkmWAik
 AgsJBBUKCQgCFgICHgUCF4AWIQQb2cqtc1xMOkYN/MpN3hD3AP+DWgUCaYJt/AIZAQAKCRBN
 3hD3AP+DWriiD/9BLGEKG+N8L2AXhikJg6YmXom9ytRwPqDgpHpVg2xdhopoWdMRXjzOrIKD
 g4LSnFaKneQD0hZhoArEeamG5tyo32xoRsPwkbpIzL0OKSZ8G6mVbFGpjmyDLQCAxteXCLXz
 ZI0VbsuJKelYnKcXWOIndOrNRvE5eoOfTt2XfBnAapxMYY2IsV+qaUXlO63GgfIOg8RBaj7x
 3NxkI3rV0SHhI4GU9K6jCvGghxeS1QX6L/XI9mfAYaIwGy5B68kF26piAVYv/QZDEVIpo3t7
 /fjSpxKT8plJH6rhhR0epy8dWRHk3qT5tk2P85twasdloWtkMZ7FsCJRKWscm1BLpsDn6EQ4
 jeMHECiY9kGKKi8dQpv3FRyo2QApZ49NNDbwcR0ZndK0XFo15iH708H5Qja/8TuXCwnPWAcJ
 DQoNIDFyaxe26Rx3ZwUkRALa3iPcVjE0//TrQ4KnFf+lMBSrS33xDDBfevW9+Dk6IISmDH1R
 HFq2jpkN+FX/PE8eVhV68B2DsAPZ5rUwyCKUXPTJ/irrCCmAAb5Jpv11S7hUSpqtM/6oVESC
 3z/7CzrVtRODzLtNgV4r5EI+wAv/3PgJLlMwgJM90Fb3CB2IgbxhjvmB1WNdvXACVydx55V7
 LPPKodSTF29rlnQAf9HLgCphuuSrrPn5VQDaYZl4N/7zc2wcWM7BTQRVy5+RARAA59fefSDR
 9nMGCb9LbMX+TFAoIQo/wgP5XPyzLYakO+94GrgfZjfhdaxPXMsl2+o8jhp/hlIzG56taNdt
 VZtPp3ih1AgbR8rHgXw1xwOpuAd5lE1qNd54ndHuADO9a9A0vPimIes78Hi1/yy+ZEEvRkHk
 /kDa6F3AtTc1m4rbbOk2fiKzzsE9YXweFjQvl9p+AMw6qd/iC4lUk9g0+FQXNdRs+o4o6Qvy
 iOQJfGQ4UcBuOy1IrkJrd8qq5jet1fcM2j4QvsW8CLDWZS1L7kZ5gT5EycMKxUWb8LuRjxzZ
 3QY1aQH2kkzn6acigU3HLtgFyV1gBNV44ehjgvJpRY2cC8VhanTx0dZ9mj1YKIky5N+C0f21
 zvntBqcxV0+3p8MrxRRcgEtDZNav+xAoT3G0W4SahAaUTWXpsZoOecwtxi74CyneQNPTDjNg
 azHmvpdBVEfj7k3p4dmJp5i0U66Onmf6mMFpArvBRSMOKU9DlAzMi4IvhiNWjKVaIE2Se9BY
 FdKVAJaZq85P2y20ZBd08ILnKcj7XKZkLU5FkoA0udEBvQ0f9QLNyyy3DZMCQWcwRuj1m73D
 sq8DEFBdZ5eEkj1dCyx+t/ga6x2rHyc8Sl86oK1tvAkwBNsfKou3v+jP/l14a7DGBvrmlYjO
 59o3t6inu6H7pt7OL6u6BQj7DoMAEQEAAcLBfAQYAQgAJgIbDBYhBBvZyq1zXEw6Rg38yk3e
 EPcA/4NaBQJonNqrBQkmWAihAAoJEE3eEPcA/4NaKtMQALAJ8PzprBEXbXcEXwDKQu+P/vts
 IfUb1UNMfMV76BicGa5NCZnJNQASDP/+bFg6O3gx5NbhHHPeaWz/VxlOmYHokHodOvtL0WCC
 8A5PEP8tOk6029Z+J+xUcMrJClNVFpzVvOpb1lCbhjwAV465Hy+NUSbbUiRxdzNQtLtgZzOV
 Zw7jxUCs4UUZLQTCuBpFgb15bBxYZ/BL9MbzxPxvfUQIPbnzQMcqtpUs21CMK2PdfCh5c4gS
 sDci6D5/ZIBw94UQWmGpM/O1ilGXde2ZzzGYl64glmccD8e87OnEgKnH3FbnJnT4iJchtSvx
 yJNi1+t0+qDti4m88+/9IuPqCKb6Stl+s2dnLtJNrjXBGJtsQG/sRpqsJz5x1/2nPJSRMsx9
 5YfqbdrJSOFXDzZ8/r82HgQEtUvlSXNaXCa95ez0UkOG7+bDm2b3s0XahBQeLVCH0mw3RAQg
 r7xDAYKIrAwfHHmMTnBQDPJwVqxJjVNr7yBic4yfzVWGCGNE4DnOW0vcIeoyhy9vnIa3w1uZ
 3iyY2Nsd7JxfKu1PRhCGwXzRw5TlfEsoRI7V9A8isUCoqE2Dzh3FvYHVeX4Us+bRL/oqareJ
 CIFqgYMyvHj7Q06kTKmauOe4Nf0l0qEkIuIzfoLJ3qr5UyXc2hLtWyT9Ir+lYlX9efqh7mOY
 qIws/H2t
In-Reply-To: <20260821042143.GA40890@system.software.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit


[...]

> Exactly.  That's why we use classification e.g. lock class - DEPT also
> makes use of the concept.
> 
> DEPT doesn't use a full map in each page but uses a minimum space for a
> timestamp in each to track when each starts to wait so as to use the
> recorded timestamp when the event occurs e.g. folio_unlock().

Thanks for that information!

> 
>> Given that lockdep is a debug feature, and we will at some point allocate struct
>> folio separately, I assume we could just squeeze a "struct lockdep_map" in there
>> in such debug configs and the world would not collapse.
> 
> That's a good news for lockdep.  (And even for DEPT :)

He :) Where do you currently store the additional per-page information?

> 
>> Doing that today (one "struct lockdep_map" in each "struct page") wouldn't work
>> as mm_zero_struct_page() would not expect such large "struct page". But
>> conceptually, for a debug kernel with a special CONFIG_LOCKDEP_PAGE_LOCK, maybe
>> that would already be ok and we could just do that (and optimize it as we
>> allocate folios separately).
> 
> Sounds great.
> 
>> Not that it's ideal, but for a debug feature to at least check PG_lock, probably
>> an easier way to achieve it than some completely new infrastructure.
> 
> I understand what you are going to tell.
> 
> However, it's worth noting that lockdep tracks dependencies basically
> based on **lock acqusition orders** in the system.  To make it track
> even rwlock and general synchronization mechanism as well, lockdep has
> no choice but to get more complicated.

Well, yes, sure :)

> 
> Focusing on only the dependency checking, the most parts of lockdep are
> for the tricky things, so the reusable parts are not that big.
> 
>> Now, Willy said "locking rules don't really apply to individual folios", I
>> wonder if that could just help to also let lockdep check PG_lock with less
>> metadata? (didn't fully wrap my head around the implications)
> 
> That's what DEPT did and what brought external wgen introduced in DEPT.
> I was considering the exactly same thing :)
> 
> Again, lockdep that tracks lock acquisition orders can't do that.
> 
>> [1]
>> https://lore.kernel.org/all/aR3WHf9QZ_dizNun@casper.infradead.org/?utm_source=chatgpt.com
>>
>>
>> It's your guiding example, that's why I mention it. You do mention other wait
>> cases here, I don't know anything about them, but for folios it's really just
>> "we used a single bit so far" AFAIKs.
> 
> It doesn't matter whether it's implemented using bit or not.  folio lock
> is quite special since it's allowed to be released other than the
> acquisition context that makes lockdep impossible to track them.

Does that really make lockdep *impossible* to track them? IOW, there is no way
to extend lockdep to support lock release in different context?

I guess there is a way, but the question is at which price (I seriously have no
idea, maybe this was already discussed and people have a pointer for me).

> 
>> [...]
>>
>>>
>>> Q. Why not build DEPT into lockdep?
>>>
>>> A. Lockdep is stable, battle-tested code. I chose separation because
>>>    while DEPT borrows BFS and hashing ideas, the wait/event model
>>>    requires rebuilding from scratch. Lockdep was designed for lock
>>>    acquisition order — retrofitting it would risk its stability.
>>
>> Why can't this just be some configurable extension to lockdep
>> (CONFIG_LOCKDEP_XYZ) until the feature is stable and can unconditionally be
>> enabled along with it?
> 
> Answered?

Not quite. I don't understand why this must be a completely separate machinery,
even if, conceptually, it would do more than traditional lockdep.

Is it either DEPT or LOCKDEP in current configurations? Can both run at the same
time?

> 
>> I don't quite buy the "would risk its stability" argument. A lot of stuff we do
>> "risks stability", every day :)
> 
> That's awsome anyway :)
> 
>> Is there another good reason (incompatible with X, dangerous with Y, cinfusing
>> Z) why this really must be a separate thing?
> 
> Roughly:
> 
>    1. Similar or less effort is needed for the new one - retrofitting
>       lockdep is not easy and big changes are required since the
>       reusable parts are not that big.
> 
>    2. Even though you didn't agree, retrofitting it would risk its
>       stability.

Well, I don't buy the stability argument, really :)

Retrofitting effort for lockdep is an interesting point, though. Lockdep
maintainers would have to make the call here regarding direction and feasibility.

[...]

>> But I am not a locking maintainer. I think there was plenty of discussion in the
>> past, so I might just be raising points that were already discussed in the past,
>> but I really just read some random pieces of earlier discussions. (ideally
>> previous discussions would be summarized here)
>>
>> Long story short: we are now in v19 and I think there was pushback in the past.
>> Did the opinion of locking maintainers change, or is there a way forward to
>> integrate this in a way that would make locking maintainers accept this?
> 
> One of locking maintainers who I met in an LPC told me that he agrees
> with the direction of DEPT and supports DEPT, not officially tho.

Hm.

> 
> What he and other people are concerning w.r.t DEPT the most is, false
> positives, which is the most important issue for now.

Thanks for highlighting that. What's the main reason for false positives? Is it
something conceptual that is mostly impossible to solve, or rather just
implementation work to cover all edge cases?

> 
> At the same time, I think the most important thing is to make DEPT
> useful in practice especially with folio locks involved.  Actually, I'm
> planning to share DEPT's true reports periodically to LKML and work with
> people who believe DEPT can make things better.
> 
> Any advices will be welcome.  Thanks for your opinions.

I think we must come to some conclusion on how to proceed with DEPT. I see the
following options:

(1) Don't merge it and carry it OOT. Shame if it delivers real value.

(2) Merge it (after proper review and acks from relevant maintainers ;) ),
    keeping it entirely separate from lockdep.

(3) Integrate it with lockdep on a high level, giving us a single locking
    dependency checker, but mostly letting dept have a separate implementation.
    Look into possible merging afterwards.

(4) Retrofit and extend lockdep to really have one mechanism.

As the saying goes, it's hard to teach old dogs new tricks, but in the end
taking care of two dogs is likely harder than only a single dog? :)

I tend to favor (4) (or 3 with possible future work to achieve 4), but I am not
a locking maintainer, so really they have to voice what to do.

I do see value in DEPT (even if the folio lock might be handled differently).

-- 
Cheers,

David
