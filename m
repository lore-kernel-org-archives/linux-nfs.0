Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A8F173ADBA7;
	Fri, 21 Aug 2026 07:37:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787297898; cv=none; b=PcgTZImPPcN20aVDR+zubiKEzgbe/HPyTN136m/oxdENgaa96qyXQ74gHlAob2DYLbQqy/3e9Pyjct9JwLgjN+1+jhuBMcZRkI0TOi1JupjD0AQOlKxh+WKUwocRAyx2BWilUWJkaYI3wj1GGnubZB0hxLxRJPJYSRyivsVqtzY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787297898; c=relaxed/simple;
	bh=rKCnKYEcumWl3JyfMbSEhreXXJgGzptLv9nA+mGVflE=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=ElRpY1GYtJlaHlx7wipfMsdXrL+3EKShO4BoCY3UhUK881X6Y1I2rY83eh04EVEyYes7nawch5mZJywg43SxfRE/F5iwMLQsMU4q1eX4nenxleeVcwDA2TlMryY2hh7Dk3+G0jzhzS9sBvu4Ur75z+/2F8+ZN9/L246cvppvryU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=QQYZoZy5; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="QQYZoZy5"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 22BAA1F000E9;
	Fri, 21 Aug 2026 07:37:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787297876;
	bh=e3HgVd1cxxmEjUBaLU/HIwYldnlIEKneQD/S3mbdmAw=;
	h=Date:Subject:To:Cc:References:From:In-Reply-To;
	b=QQYZoZy5XMUKRQ3cf2goz46XPoxmh58JVe2AGU+uh+MsIS4aHUXgKrB28hB092zbx
	 I1Ca30A5zDO/BM6vXHOwQr9Ww+LL2RajKvWcmCnVxBdi5Gue+9kqdTMQfxbiSjaghv
	 FlXE3DPbsU4C4c4alIYfBNXD5GCpd5K3spxKD8BU/W7WlILO5UQIX/mzPRGw7GHy1i
	 HVEm3LZABnXfB2zRPj1WhiKoiTgjggZtcyGdvsaw9cJOtpDlfQFKCMMO8gqzkTIZWE
	 w1z4aX4nM829Ub+PIjqaHJkXXyX6P6qyBaXSExMMdUL1TIHWJHe7y1cy7p1NSvUYFi
	 ARYZ2gTtTrMPw==
Message-ID: <f1657724-e7a9-45f6-9aef-af69d3c64a7d@kernel.org>
Date: Fri, 21 Aug 2026 09:37:07 +0200
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH v19 00/40] DEPT(DEPendency Tracker)
To: Matthew Wilcox <willy@infradead.org>
Cc: Byungchul Park <byungchul@sk.com>, linux-kernel@vger.kernel.org,
 max.byungchul.park@gmail.com, kernel_team@skhynix.com,
 torvalds@linux-foundation.org, damien.lemoal@opensource.wdc.com,
 linux-ide@vger.kernel.org, adilger.kernel@dilger.ca,
 linux-ext4@vger.kernel.org, mingo@redhat.com, peterz@infradead.org,
 will@kernel.org, tglx@linutronix.de, rostedt@goodmis.org,
 joel@joelfernandes.org, sashal@kernel.org, daniel.vetter@ffwll.ch,
 duyuyang@gmail.com, johannes.berg@intel.com, tj@kernel.org, tytso@mit.edu,
 david@fromorbit.com, amir73il@gmail.com, gregkh@linuxfoundation.org,
 kernel-team@lge.com, linux-mm@kvack.org, akpm@linux-foundation.org,
 mhocko@kernel.org, minchan@kernel.org, hannes@cmpxchg.org,
 vdavydov.dev@gmail.com, sj@kernel.org, jglisse@redhat.com,
 dennis@kernel.org, cl@linux.com, penberg@kernel.org, rientjes@google.com,
 vbabka@suse.cz, ngupta@vflare.org, linux-block@vger.kernel.org,
 josef@toxicpanda.com, linux-fsdevel@vger.kernel.org, jack@suse.cz,
 jlayton@kernel.org, dan.j.williams@intel.com, hch@infradead.org,
 djwong@kernel.org, dri-devel@lists.freedesktop.org,
 rodrigosiqueiramelo@gmail.com, melissa.srw@gmail.com,
 hamohammed.sa@gmail.com, harry.yoo@oracle.com, chris.p.wilson@intel.com,
 gwan-gyeong.mun@intel.com, boqun.feng@gmail.com, longman@redhat.com,
 yunseong.kim@ericsson.com, ysk@kzalloc.com, yeoreum.yun@arm.com,
 netdev@vger.kernel.org, matthew.brost@intel.com, her0gyugyu@gmail.com,
 corbet@lwn.net, catalin.marinas@arm.com, bp@alien8.de, x86@kernel.org,
 hpa@zytor.com, luto@kernel.org, sumit.semwal@linaro.org,
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
 <aoc-jJ10op62jXFK@casper.infradead.org>
From: "David Hildenbrand (Arm)" <david@kernel.org>
Content-Language: en-US
Autocrypt: addr=david@kernel.org; keydata=
 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
 qIws/H2t
In-Reply-To: <aoc-jJ10op62jXFK@casper.infradead.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

On 8/20/26 19:51, Matthew Wilcox wrote:
> On Thu, Aug 20, 2026 at 07:16:05PM +0200, David Hildenbrand (Arm) wrote:
>>> Consider this real deadlock pattern that lockdep cannot detect:
>>>
>>>    context X              context Y              context Z
>>>
>>>                           mutex_lock A
>>>    folio_lock B
>>>                           folio_lock B <- DEADLOCK
>>>                                                  mutex_lock A <- DEADLOCK
>>>                                                  folio_unlock B
>>>                           folio_unlock B
>>>                           mutex_unlock A
>>>                                                  mutex_unlock A
>>
>> But that really just boils down to folio lock being implemented as a PG_lock +
>> some advanced wait mechanism. And we must do that because of lack of bits in
>> struct page.
>>
>> Willy mentioned in a previous version [1]: "I don't think it makes sense to
>> track lock state in the page (nor folio).  Partly because there's just so many
>> of them, but also because the locking rules don't really apply to individual
>> folios so much as they do to the mappings (or anon_vmas) that contain folios."
>>
>> Given that lockdep is a debug feature, and we will at some point allocate struct
>> folio separately, I assume we could just squeeze a "struct lockdep_map" in there
>> in such debug configs and the world would not collapse.
>>
>> Doing that today (one "struct lockdep_map" in each "struct page") wouldn't work
>> as mm_zero_struct_page() would not expect such large "struct page". But
>> conceptually, for a debug kernel with a special CONFIG_LOCKDEP_PAGE_LOCK, maybe
>> that would already be ok and we could just do that (and optimize it as we
>> allocate folios separately).
>>
>> Not that it's ideal, but for a debug feature to at least check PG_lock, probably
>> an easier way to achieve it than some completely new infrastructure.
>>
>> Now, Willy said "locking rules don't really apply to individual folios", I
>> wonder if that could just help to also let lockdep check PG_lock with less
>> metadata? (didn't fully wrap my head around the implications)
>>
>> [1]
>> https://lore.kernel.org/all/aR3WHf9QZ_dizNun@casper.infradead.org/?utm_source=chatgpt.com
> 
> There are a few things going on that make PG_lock special.  Let me try
> to explain again, only better this time.
> 

Thanks for that information :)

> 1. The current lifetime of a struct page is the lifetime of the system.
> But the semantics of its PG_lock bit change each time it is freed and
> allocated.

Well, yeah, but that will effectively change once we dynamically allocate struct
folio.

Until then, don't we have the following two events:

(a) Allocator handing out a page
(b) Page getting returned to page allocator

And while in the allocator, the PG_locked is essentially unused/unusable (and so
would be lockdep data)?

I'd argue there is a well defined lifetime for PG_locked and any additional
lockdep metadata. At least theoretically ;)

> 
> 2. The position of PG_lock in the locking hierarchy only depend on
> what the folio is currently being used for.  That is, all folios in
> a given xfs inode behave exactly the same from a locking perspective.
> There's no need to build up state about how each PG_lock is used;
> they can all share.  Arguably all xfs file inodes are the same as
> each other (directory inodes might be different from file inodes),
> so we might want to go further than telling DEPT that "this folio
> belongs to this inode" and go to "this folio belongs to this xfs file
> inode".

"There is no need", I am not entirely sure when it comes to anonymous folios.

Even if there is actually no need, given that we are talking about debugging
mechanisms, I am not sure if optimizing for less memory consumption is our
highest priority. Debug kernels already consume plenty of memory on other things
(page_ext, for example), so consuming some more to support the folio lock with
lockdep does not sound too crazy for me.

(maybe lockdep data could even life in page_ext)

I understand that Dept applies to more things than just PG_locked, though.

> 
> 3. PG_lock can be taken in task context then released in interrupt
> context.  For full points, we need to mark the exact point at which
> we submit the folio for read.  Otherwise we can get into the situation
> alluded to by f2c817bed58d and better discussed at
> https://lore.kernel.org/linux-mm/20200127150024.GN1183@dhcp22.suse.cz/
> where we have the folio locked but haven't yet submitted it for I/O
> so it doesn't matter how long we wait, it will never come unlocked.

Yeah, it seems hard to squeeze different locking contexts into existing lockdep.
I cannot tell whether lockdep could be adjusted to allow for that, or how much
work it would involve.

So yeah, Dept might be a more natural fit for this scenario.

-- 
Cheers,

David
