Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795600255;
	b=D/dFLcK3IjY6rGfJAd0DJRTL2KEOS4IuwB82GK688VaXhKlbMdLndJKNP68jmpJBmY6/
	 TfSPhS121MNAkDTZKt2wBX2SKnaRIi2eLw3gaebgDMgQatFw8TdIqEstwra8reFXEBcDr
	 B26rDEng5hnsrcA/H1ToTmuwy6f8SCOZYkSK+K3kTF9VVeMQGjOissMX1kQprtudm3UQG
	 ieUiUm9tffA9q3WQGMuIhF/VeFfJjANt7wgHcHgXXtv/F8HhpDE7siAfOCamahjpL6myo
	 J4O5TuMXJGeBRvm0SFzm2nKAptbDvR+5a4Ih9dNv0CkyStIHEbF2QNnIGCvcyS4Xdlg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795600255;
	h=Received:DKIM-Signature:Message-ID:Date:MIME-Version:User-Agent:
	 Subject:To:Cc:References:From:Content-Language:Autocrypt:In-Reply-To:
	 Content-Type:Content-Transfer-Encoding;
	bh=tGnj930oYxvF/0cd6nEVQpcZo3ih9Np+B2tQs915UOA=;
	b=Bha+NYr9Y8HFzD7EHmz29lyGJOQXB2ZDN5OxQMxzU5aGpluKInTKgUML/3ZLtIX0N5rq
	 W7YraHliMlmBBf33PB2h5KaS9bAYQERMjrJF3Y20BTGDiW33SUsLjA73IelQdFGpVa4l9
	 mgirVushsZ76EpYQd63PoYEh0T4yfUEmYvIcFsSfI7wU/uXRCE02zCcVb1LL3YLhVYbCx
	 /xPpgIlbUEm3gpe72KzwqUpA/3eKqo2cOYeMoB8je9qdRTKJ4rPXQTVWlrv3/nsbRC7oe
	 rr2u1UKP29LP8je7foA8Z7+desdvsYd8FAgOvyDvhby/70ZcKZpzVARccSoSWY0lheQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=B9tou37Y;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 37A15606A31E;
	Wed, 25 Nov 2026 09:50:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=B9tou37Y
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 894941F000CF;
	Wed, 25 Nov 2026 09:50:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795600254;
	bh=tGnj930oYxvF/0cd6nEVQpcZo3ih9Np+B2tQs915UOA=;
	h=Date:Subject:To:Cc:References:From:In-Reply-To;
	b=B9tou37YVeV/G6AsGUDZ7SNc5OQVrGY/e9fE6e/1iMXgYZYdZ/PG/h0Aade1ilmLy
	 qwQkMhJ4Oq6rdmJz2jIkmIQxqr6WN16CSV4Avy5fsNI4fbj/B0B0L9XIArwzx30wtb
	 6EQOMXOy3aw0dq3Hg1UrmNPaLRtwrVonlnPgHUW6B7Mdyk/9Hrmps1xVD9L33zzMzY
	 XA6n9Sn0k8dqCLzbGRZEEcXtPzcWZVBW7wshk2ZT94W0+N9f9LOib2f5MX/2pu06pc
	 e7VKroqFAm6xbpg5hSelGOkkhoY3rPNpqNHQoIZih+ZomJOIp7NMgS0AuAngoGBqwc
	 jXV0PFZA3A6tg==
Message-ID: <55114986-0ba1-4a80-8498-bf674d64e01b@kernel.org>
Date: Wed, 25 Nov 2026 10:50:42 +0100
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH RFC 0/5] mm: GUP dirty + ->release_folio() fixes
To: Pedro Falcato <pfalcato@suse.de>, John Hubbard <jhubbard@nvidia.com>,
 Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Zi Yan <ziy@nvidia.com>,
 "Matthew Wilcox (Oracle)" <willy@infradead.org>,
 Lorenzo Stoakes <ljs@kernel.org>, Peter Xu <peterx@redhat.com>,
 Johannes Weiner <hannes@cmpxchg.org>, linux-ext4@vger.kernel.org,
 linux-nfs@vger.kernel.org, "Liam R. Howlett" <liam@infradead.org>,
 Vlastimil Babka <vbabka@kernel.org>, Mike Rapoport <rppt@kernel.org>,
 Suren Baghdasaryan <surenb@google.com>, Michal Hocko <mhocko@suse.com>,
 Baolin Wang <baolin.wang@linux.alibaba.com>,
 Nico Pache <nico.pache@linux.dev>, Ryan Roberts <ryan.roberts@arm.com>,
 Dev Jain <dev.jain@arm.com>, Barry Song <baohua@kernel.org>,
 Lance Yang <lance.yang@linux.dev>, Usama Arif <usama.arif@linux.dev>,
 Kiryl Shutsemau <kas@kernel.org>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, Kairui Song <kasong@tencent.com>,
 Qi Zheng <qi.zheng@linux.dev>, Shakeel Butt <shakeel.butt@linux.dev>,
 Axel Rasmussen <axelrasmussen@google.com>, Yuanchu Xie <yuanchu@google.com>,
 Wei Xu <weixugc@google.com>, Baoquan He <baoquan.he@linux.dev>,
 Michal Hocko <mhocko@kernel.org>, linux-fsdevel@vger.kernel.org,
 stable@vger.kernel.org
References: <20261119-gup-dirty-what-v1-0-236d69f25c24@suse.de>
 <4f096d70-6f94-4148-8f47-242b8551e5f9@nvidia.com>
 <awWNyDZT2SVu2Zp9@pedro-suse.tail5790ac.ts.net>
From: "David Hildenbrand (Arm)" <david@kernel.org>
Content-Language: en-US
Autocrypt: addr=david@kernel.org; keydata=
 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
 qIws/H2t
In-Reply-To: <awWNyDZT2SVu2Zp9@pedro-suse.tail5790ac.ts.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

On 11/24/26 14:37, Pedro Falcato wrote:
> Hi John, Christoph, Jan,
> 
> Thank you for your replies. Since you largely share the same point, I'll
> combine this into a single reply.
> 
> On Thu, Nov 19, 2026 at 04:55:30PM -0800, John Hubbard wrote:
>> On 11/19/26 12:10 PM, Pedro Falcato wrote:
>>> Sooo.... It turns out GUP dirty and ->release_folio() interact really
>>> weirdly. This was initially reported by some AI agent, and David let me
>>> know.
>>>
>>> The basic issue is:
>>
>> The basic issue is covered in a series of LWN articles that span 5 or
>> 6 years:
>>
>>     https://lwn.net/Kernel/Index/#Memory_management-get_user_pages
>>
>> Probably good to read and absorb that. There's a lot.
>>
> 
> Thanks. I was aware of some of this, but it's good to take a fresh look again :)
>  
>> The problem remains not fully solved. pin_user_pages() is a building
>> block, but we need to fully coordinate with filesystems in order to
>> finish. It's good that you are looking at this.
>>
>>>  - ->dirty_folio() relies on buffers/IFS/etc being attached to the
>>>    folios. It _cannot_ attach them itself, as dirty_folio() cannot
>>>    block.
>>>  - certain MM paths (reclaim, khugepaged, folio split, etc) are very
>>>    trigger-happy when it comes to asking filesystems to release them. In
>>>    most cases, barring any dirty folios, buffers, it will just drop
>>>    them.
>>>  - there is no problem in usual IO submission, but issues start to pop
>>>    up with GUP, where the code flow (roughly) becomes:
>>>         [get_user_pages(), etc]
>>>            ->page_mkwrite() called here, or before
>>>              ->private correctly populated with whatever the filesystem
>>>                expects.
>>>              folio is marked as dirty, initially.
>>>        *write finishes*
>>>        folio_lock();
>>>        folio_mark_dirty();
>>>          ->dirty_folio()
>>>               dirty_folio expects ->private to be populated by
>>>               ->page_mkwrite(), ->write_begin().
>>>        folio_unlock();
>>>
>>> What happens if any filemap_release_folio() runs (and succeeds) between
>>> the initial dirtying (plus eventually writeback) and the write to the
>>> folio completes? Welp, it's unpredictable. ext4 for example will
>>> WARN_ONCE, and likely drop data (see ext4_dirty_folio()).
>>>
>>> So, what can we do about it? It's complicated, hence why this is an RFC.
>>> For the possible solutions:
>>>  - ->dirty_folio() attaching this FS information itself is not really
>>>    possible in many cases. ->dirty_folio() can't block, nor is it even
>>>    guaranteed to hold the folio lock while being called.
>>>  - Can pincount help? Kind of. Things like folio_maybe_dma_pinned() are
>>>    rough, and don't deal with the usage of get_user_pages(FOLL_WRITE).
>>>    pincount itself isn't available in the common order-0 case, and not
>>>    available on order-1 as well on 32-bit, but who cares about that^W^W^W^W^W
>>>  - Could get_user_pages() ban FOLL_WRITE? Mayhaps. I would not be
>>>    opposed to that, but that's probably a larger change than ideal for stable,
>>>    and I'm not familiar enough with GUP requirements to decide to go that way.
>>>    This would require migrating all FOLL_WRITE users to
>>>    pin_user_pages().
>>>  - Can the whole system be reworked? Probably, but not for stable.
>>>
>>> This patch series is really rough but kind-of works. Instead of using
>>> folio_maybe_dma_pinned(), which only interacts with pin_user_pages(), I
>>
>> pin_user_pages() was specifically introduced for this exact class of
>> problem. get_user_pages() is now meant for other, much more limited cases.
>> I've attempted to document that, here:
>>
>>     https://docs.kernel.org/core-api/pin_user_pages.html
> 
> Ok, so I guess you want me to drop the hacks to make GUP FOLL_WRITE not
> screw itself over? To be clear, the rest is still broken, even with pin_user_pages().
> It just means we get nicer looking fixes, and I can drop patch 3.

I think focusing on pinned pages as the first approach+long-term solution is ok.

BUT

When I looked into this issue, there were some problematic things.

We have some odd drivers that use FOLL_GET|FOLL_WRITE, but I am not too
concerned about them.

But are ways where unprivileged users can mess with  FOLL_GET|FOLL_WRITE
references to trigger this.

I think the two that stand out are:

1) /proc/self/mem access using mem_rw() -> access_remote_vm()

User can write to a writable-mapped page-cache PTE. Then we can race with
removal of folio metadta, to then set the folio dirty afterwards.

I remember a good reason to not convert these paths in the past (we are not
performing DMA).


2) /dev/fuse using fuse_copy_fill() -> iov_iter_get_pages2()

Same problem, just through fuse.


So either

1) We fix all such cases now where unprivileged users can trigger this,
   converting to FOLL_PIN.

2) We handle it for now in reclaim code by checking for unexpected folio
   references instead of GUP pins. The spirit of this series.

3) We accept that unprivileged users can trigger unexpected behavior
   (WARN_ON_ONCE()) etc. I don't think that's an option.

4) We turn all these checks for unexpected behavior into soft warnings.

I think only ext4 is problematic, but I didn't check.

-- 
Cheers,

David
