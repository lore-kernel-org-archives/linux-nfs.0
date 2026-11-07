Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=91.218.175.53
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794059857;
	b=s/qELN/B20kj4MCPWWjjCRIjXp0lsMBxD6qiuM73PPsTlaEaIiebl9uZh60/AYr0LU8t
	 66ILYq6wy4xgcH54UtuLuUND21F86IfDTlOqbD+vfgBtf5MkqhBxUH/aC6zWkGohzpw10
	 Np++33KGJgMd4/kDr0R9eQ2Nhi2xvCVMZ4pyY+si7zA+RtknUg6fQ7ncgNr+ApcOqBM6k
	 JXZdaqH6h6+a3wv5WAOIRY6vBuEUZU+Fvjsdc3114Sx7OgXMsvw8NnZMhFXDesvF/HJjW
	 ULf4FWk00u/sXFpIBlv47j3DiZGuW0a1JHdkBI3b5p4Vma7UCla90BjDMWpdFDdyjFg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794059857;
	h=DMARC-Filter:X-Envelope-To:DKIM-Signature:X-Envelope-To:Received:
	 X-Mizu-Trace-ID:X-Migadu-Flow:Message-ID:Date:MIME-Version:User-Agent:
	 Subject:To:Cc:References:From:In-Reply-To:Content-Type:
	 Content-Transfer-Encoding;
	bh=bof9tUcTOZBXMkDJCDfY6C3YrCB7UvJznTngHIBFOlg=;
	b=rCp/3+UC2dhAWPCugHZglqlXCYZ6l7l3Cf2c81QFkyUiXwElaMyAqz7G01O8TjLUURPG
	 VZkWEMI1yfdWiFE0VtkMqg41IIX5wT8uLJ781rty22xlOIiqqZ/veuIxCNn2/D06Ur9WN
	 VMVa9BqeWnXdEvxPXmRjG7zdcjVd+XuRTyHCnNNMFuhZPHaD5Xlw/uJWjISvDqA6bR7aR
	 NaY/Nr1/GiWMmh42lI1oT7jV8RafpwEyuk5fbJb0E/2/DKS+hK6dYELaLuIxQtCcOp9zA
	 054pPBH9PLvHg0S8PTw4Cu/+ruQ2AvI8Rmr+lafN+LnHHbbfvXGrLdBChOPgbuxjlcw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=linux.dev;
	spf=pass smtp.mailfrom=linux.dev;
	dkim=pass header.d=linux.dev header.i=@linux.dev header.a=rsa-sha256 header.s=key1 header.b=lJxfz6F4;
	arc=none smtp.remote-ip=91.218.175.53
Received: from mta0.migadu.com (out-53.mta0.migadu.com [91.218.175.53])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 32E17606A336
	for <linux-nfs@vger.kernel.org>; Sat,  7 Nov 2026 13:57:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 32E17606A336
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.dev
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=linux.dev header.i=@linux.dev header.a=rsa-sha256 header.s=key1 header.b=lJxfz6F4
X-Envelope-To: linux-nfs@vger.kernel.org
DKIM-Signature: a=rsa-sha256; bh=a4WQjTS9cLmNAnAJkm3u/yMKK8cVrEp4RpmNfDVq90s=;
 c=simple/simple; d=linux.dev;
 h=from:to:subject:date:message-id:mime-version:content-type; s=key1;
 t=1794059853; v=1; x=1794664653;
 b=lJxfz6F4qBNSR5tFla7gLu8C60Ut8j6sNhgl36PjYrBesekcQ460PWTFUBZKJBTXlOb167Cz
 EYAxD+DU/YXTiDp0v0C46KCq/hhwcfZgC5Q+E2SOBt3QwWyB+hXy5CTC+iuQKMFnn9NMW+C4It5
 ILQjSrkCXaBdr5OGpjI70qJg=
X-Envelope-To: linux-nfs@vger.kernel.org
Received: by mta12.migadu.com with ESMTPS id bb1f088a7420c55f;
	Sat, 07 Nov 2026 13:57:32 +0000
X-Mizu-Trace-ID: bb1f088a7420c55f
X-Migadu-Flow: FLOW_OUT
Message-ID: <fd7ed305-6192-46e8-a5bb-cc1ed8f12f74@linux.dev>
Date: Sat, 7 Nov 2026 21:57:02 +0800
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
Subject: Re: [PATCH] mm/list_lru: Account node removals in isolation helpers
To: Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <dgc@kernel.org>
Cc: gregkh@linuxfoundation.org, arve@android.com, tkjos@android.com,
 brauner@kernel.org, cmllamas@google.com, aliceryhl@google.com,
 nat@pixelcluster.dev, arunpravin.paneerselvam@amd.com,
 maarten.lankhorst@linux.intel.com, mripard@kernel.org, tzimmermann@suse.de,
 airlied@gmail.com, simona@ffwll.ch, viro@zeniv.linux.org.uk,
 agruenba@redhat.com, trondmy@kernel.org, anna@kernel.org, cel@kernel.org,
 jlayton@kernel.org, cem@kernel.org, akpm@linux-foundation.org,
 david@fromorbit.com, david@kernel.org, hughd@google.com, yosry@kernel.org,
 nphamcs@gmail.com, matthew.auld@intel.com, matthew.brost@intel.com,
 thomas.hellstrom@linux.intel.com, jack@suse.cz, neil@brown.name,
 okorniev@redhat.com, Dai.Ngo@oracle.com, tom@talpey.com, qi.zheng@linux.dev,
 roman.gushchin@linux.dev, muchun.song@linux.dev, ziy@nvidia.com,
 baolin.wang@linux.alibaba.com, liam@infradead.org, nico.pache@linux.dev,
 ryan.roberts@arm.com, dev.jain@arm.com, baohua@kernel.org,
 lance.yang@linux.dev, usama.arif@linux.dev, kas@kernel.org,
 mhocko@kernel.org, shakeel.butt@linux.dev, ljs@kernel.org,
 kasong@tencent.com, axelrasmussen@google.com, yuanchu@google.com,
 weixugc@google.com, baoquan.he@linux.dev, chengming.zhou@linux.dev,
 linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org,
 linux-fsdevel@vger.kernel.org, gfs2@lists.linux.dev,
 linux-nfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org,
 Kaitao Cheng <chengkaitao@kylinos.cn>
References: <20261103045053.59548-1-kaitao.cheng@linux.dev>
 <aupITfr9pBKPrU20@dread> <au3eyCrHiuhbJx3u@cmpxchg.org>
From: Kaitao Cheng <kaitao.cheng@linux.dev>
In-Reply-To: <au3eyCrHiuhbJx3u@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

在 2026/11/6 22:06, Johannes Weiner 写道:
> On Wed, Nov 04, 2026 at 07:47:09AM +1100, Dave Chinner wrote:
>> On Tue, Nov 03, 2026 at 12:50:53PM +0800, Kaitao Cheng wrote:
>>> From: Kaitao Cheng <chengkaitao@kylinos.cn>
>>>
>>> Successful writeback calls zswap_entry_free(), which removes the entry
>>> from the LRU and decrements both the sublist and node item counts.
>>> shrink_memcg_cb() then returns LRU_REMOVED_RETRY, causing the LRU walker
>>> to decrement the node count again.
>>>
>>> The affected call path before this change is:
>>>
>>>   __list_lru_walk_one()
>>>     shrink_memcg_cb()
>>>       zswap_writeback_entry()
>>>         zswap_entry_free()
>>>           zswap_lru_del()
>>>             list_lru_del()
>>>               __list_lru_del()
>>>                 atomic_long_dec()  /* first node count decrement */
>>>       return LRU_REMOVED_RETRY
>>>     atomic_long_dec()              /* second node count decrement */
>>
>> That's a bug in the zswap code. You shouldn't be calling
>> list_lru_del() from __list_lru_walk_one() context.
> 
> Grr, Kaitao you dropped the wrong thing that I thought had merit in my
> proposal...
> 
> Dave, would you mind taking a look at my patch at
> https://lore.kernel.org/all/auJkvb-Lq0M5Enkz@cmpxchg.org/?
> 
> Ignore zswap for a second. I know it has problems. Most of it stems
> from the fact that we rely on the swap locking and do none of our own
> locking/lifetime on the zswap entry. As a result we work around it in
> odd ways. Sorry, you didn't ask :-) That's worth revisiting, although
> it's likely more invasive work.
> 
> The observation that led to the patch above was a much simpler one:
> since we now have the caller-locked __list_lru_del() anyway, the only
> difference between that and the list_lru_isolate* is the
> accounting. The patch is about one thing: removing the isolate helpers
> entirely. There is then simply one tool for caller-locked list
> unlinking, __list_lru_del(). It removes an avoidable distinction,
> shrinks the API surface, makes it harder to screw up.

I don't think replacing EXPORT_SYMBOL_GPL(list_lru_isolate) with
EXPORT_SYMBOL_GPL(__list_lru_del) makes much difference by itself.
The only reason I kept list_lru_isolate() in the current version
is to avoid passing an additional parameter (nid) to the isolate
callbacks.

I don't have a strong preference for the current approach. If we
can reach a consensus, I'd be happy to send v3 with the proposed
changes.

> The zswap weirdness made me look at list_lru. Consider it a stress
> test from idiotic code :-) But I would propose the list_lru
> simplification for its own sake, regardless of what we do with zswap.

-- 
Thanks
Kaitao Cheng

