Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.182
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793973969;
	b=5fUbc1eyKnQrGsnmXbnj9wSlqmLmu9uvGHoHNLYGRVHL18k6KETg5O/jOViyMINBIngU
	 rknPxfubgMqf23OsYxOawG5CZkVRhgw7gLjpcoErByr1P5StLSs9CWTX2T/LZFREk7hP5
	 vd3FfNOEKZNNs2JhpY/uHw+o0Weq3SE2MiWuIXVIrBxzMp7VL6omwQVrQ17Dcetb9O839
	 ICC6eIfIR+Z9+Tc9TeQy/WOKM13sq+lkOBRJ8mfRjPjv9VORqE4iXiM03oBXCrxE3TXG7
	 2Nz/9Dt/GFWfvKv/LLeDbPof5OTmvsEgwVhZ4k/I2HMDWUuVnXwf7ysxs6xQQ+mH6yw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793973969;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To;
	bh=eqhBVbUtw3dy734MGt0XscJMrayl/heBjdE55TwHpBE=;
	b=yVmJfd4zlsMY/A99ThIMS6u2sz5cRrVEpJWJ+KsAOz1Har8+XSBLRaLIz1K42kcaGXA5
	 dBe07M+k5QH5X+ncTvbcc3rumy/IT/wTQha0T01PvXENEqBCUsCYoWkjBeunbh+2O93yq
	 sYCOqI27+RL/mbeHc08R83/Y8rOWiZrbVTENMx5H0WgRPWlGjFZPtXtl/1jCU73dUCEkD
	 7W4u/zMZJ5Kn3PNLJzleZmryjdK8tYp9gMej1VI8Ig8bvcmpV7vj9tw8E/rRASaR8qlTP
	 5v0CpH5QE8q5dGWdGxYAVFd21/jMtOra0mCIlV9l6Cyx8XCjT/cBya97G7bdXAGf4Ng==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=cmpxchg.org;
	spf=pass smtp.mailfrom=cmpxchg.org;
	dkim=pass header.d=cmpxchg.org header.i=@cmpxchg.org header.a=rsa-sha256 header.s=google header.b=rEFjIsRc;
	arc=none smtp.remote-ip=209.85.128.182
Received: from mail-yw1-f182.google.com (mail-yw1-f182.google.com [209.85.128.182])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E439E606A330
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 14:06:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E439E606A330
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=cmpxchg.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=cmpxchg.org header.i=@cmpxchg.org header.a=rsa-sha256 header.s=google header.b=rEFjIsRc
Received: by mail-yw1-f182.google.com with SMTP id 00721157ae682-8b309147589so5647087b3.1
        for <linux-nfs@vger.kernel.org>; Fri, 06 Nov 2026 06:06:07 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg.org; s=google; t=1793973967; x=1794578767; darn=vger.kernel.org;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=eqhBVbUtw3dy734MGt0XscJMrayl/heBjdE55TwHpBE=;
        b=rEFjIsRctA59Iu2/BHBn1Bio1Z530ac+g4EEE4umpjlRFctJ/W1yi+oJAJdR8sIKtC
         0ANk4+IEeh+gWZdP8+5Abj0Wi+7JUGtI3eOPnJ0wMnngrGVtvT7+mdXKDwBc4VjMOreA
         HRXNX16MAj9gPw3V6sQG29RsCMeifuq7vktm82eZ1OL9M0wUFDM8b1mHYrWOWDjP7hoA
         FgchrqECOX93FzgDhG9Sn07L+FCR1PCSxN8pDG5a+ABli7EEuG5ifSugYUsuO9WbK3uX
         2labLzJdsWWlMl8/Ibz30wICnbSFS6Rx+DAJRAtH3OrhgDaH9x+c/HNq/PuJNNkUGIVa
         0UdQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793973967; x=1794578767;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=eqhBVbUtw3dy734MGt0XscJMrayl/heBjdE55TwHpBE=;
        b=zR3yzqgxmeZLvx/lx/qoC5OlulZoKGUjAK6x6EuMVEPcrHktvG0E2ClFxORFjRImFd
         QEhOKMC59ZQblnmuq8Sw8CRKdmEVKGOH8R6ovNbylg4Y0F8aRmNTapV8A3sZXJ5DI4v/
         RNfnARVjfT/XHcHLdsAAYiB9Ose0HUseRV8RwkmwzW5Iqz1D+iKMXFxMVZUlymsIO1f5
         IDyVkKZlPTXxFHW+cew0lLuYp2eXep7bNvG4r0o6jIpCMtdkA8SduP2kVJuyKy4OHRnZ
         5XfnUQZM0AqAlJ5kCcxp5pObbQCOGxdaTFqzZVPF5yqJWEV8tPheTb/iUimWIVZiPPWj
         V5WQ==
X-Forwarded-Encrypted: i=1; AL+hErEi7m670eBkL9X9BfnxdXfCCHnzf6kyF+k9yXQUNXLYqSkNYc1hKePHr3H5QU6YR1yxDKSCnqL+Vj8=@vger.kernel.org
X-Gm-Message-State: APuU4Z9ISrkHw+fk8qyRboAkpQcYmR/fVmLQS7Jf9+Qv4aAik1/hBX0o
	7h/LzXue1QaFzL98zUIZ0P1EMOVQVWe1fDbIROLZ2wj0VKQa7oP4fA+0kgG2yPc8EHU=
X-Gm-Gg: AYBFou08//jOxpxQL2xmuIzL89zN3SV7We3oQKxKKAkzFiE9TkJ3gEgGXcew95qzBxa
	eYVW0IsOX/TU3oVgTXfIknaLlcVayS5l6ekBhNR9fORLZJXFUSVWysWhIGiE20PiRp6ejCE5QYS
	TH1YbwIhNSAJHk3UnL+/rhlRvgeqPIVZUy0QvCQB69bH24JTt7hNQMHTrRX0mViQCVt0/VR5p/m
	0XX1QV+0mKIB3eG4gA/KL7zmKrzRvlW4G3XgyXkRFAU0jMuYgKwtFjcIgFsANrl5U6S3t34aD24
	rYJ20zIDdLq74CNgbW2LDh/z1IrTwea/MRdq6nJu46LEbJGA90NsZ5pgXSonnIIZerDPoQk8Zz4
	BcpNmkpoRW+H2x2e1umzfaU/B3CgPnrClQqfm1aEq4xcVgxm1BHJp6M17MR5JrJPUC9whgN9kG5
	/uZ4bnrGRDYkW1y0LfYzw0hb5+Z70NqGhuyfNq3C9hUKXLv83TuPKlQkXU9u+CTxlpzNj3kGLG0
	BDMOrsbdGruZg+l8TqjpRl9PEygeh5YE2C+CGxVqerBbN3eeukB7uqAmdmLQe4SB2f8MRMo930Z
	30wxa/tvngBdh6dK1PDA7NH4IkCd
X-Received: by 2002:a05:690c:560f:10b0:8b3:10df:54a3 with SMTP id 00721157ae682-8b341b1ebe2mr10611897b3.65.1793973966605;
        Fri, 06 Nov 2026 06:06:06 -0800 (PST)
Received: from localhost ([2605:8600:200:14e3:365a:60ff:fe62:ff29])
        by smtp.gmail.com with ESMTPSA id 00721157ae682-8b33f856f99sm19108527b3.34.2026.11.06.06.06.04
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 06 Nov 2026 06:06:04 -0800 (PST)
Date: Fri, 6 Nov 2026 09:06:00 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
To: Dave Chinner <dgc@kernel.org>
Cc: Kaitao Cheng <kaitao.cheng@linux.dev>, gregkh@linuxfoundation.org,
	arve@android.com, tkjos@android.com, brauner@kernel.org,
	cmllamas@google.com, aliceryhl@google.com, nat@pixelcluster.dev,
	arunpravin.paneerselvam@amd.com, maarten.lankhorst@linux.intel.com,
	mripard@kernel.org, tzimmermann@suse.de, airlied@gmail.com,
	simona@ffwll.ch, viro@zeniv.linux.org.uk, agruenba@redhat.com,
	trondmy@kernel.org, anna@kernel.org, cel@kernel.org,
	jlayton@kernel.org, cem@kernel.org, akpm@linux-foundation.org,
	david@fromorbit.com, david@kernel.org, hughd@google.com,
	yosry@kernel.org, nphamcs@gmail.com, matthew.auld@intel.com,
	matthew.brost@intel.com, thomas.hellstrom@linux.intel.com,
	jack@suse.cz, neil@brown.name, okorniev@redhat.com,
	Dai.Ngo@oracle.com, tom@talpey.com, qi.zheng@linux.dev,
	roman.gushchin@linux.dev, muchun.song@linux.dev, ziy@nvidia.com,
	baolin.wang@linux.alibaba.com, liam@infradead.org,
	nico.pache@linux.dev, ryan.roberts@arm.com, dev.jain@arm.com,
	baohua@kernel.org, lance.yang@linux.dev, usama.arif@linux.dev,
	kas@kernel.org, mhocko@kernel.org, shakeel.butt@linux.dev,
	ljs@kernel.org, kasong@tencent.com, axelrasmussen@google.com,
	yuanchu@google.com, weixugc@google.com, baoquan.he@linux.dev,
	chengming.zhou@linux.dev, linux-kernel@vger.kernel.org,
	dri-devel@lists.freedesktop.org, linux-fsdevel@vger.kernel.org,
	gfs2@lists.linux.dev, linux-nfs@vger.kernel.org,
	linux-xfs@vger.kernel.org, linux-mm@kvack.org,
	Kaitao Cheng <chengkaitao@kylinos.cn>
Subject: Re: [PATCH] mm/list_lru: Account node removals in isolation helpers
Message-ID: <au3eyCrHiuhbJx3u@cmpxchg.org>
References: <20261103045053.59548-1-kaitao.cheng@linux.dev>
 <aupITfr9pBKPrU20@dread>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <aupITfr9pBKPrU20@dread>

On Wed, Nov 04, 2026 at 07:47:09AM +1100, Dave Chinner wrote:
> On Tue, Nov 03, 2026 at 12:50:53PM +0800, Kaitao Cheng wrote:
> > From: Kaitao Cheng <chengkaitao@kylinos.cn>
> > 
> > Successful writeback calls zswap_entry_free(), which removes the entry
> > from the LRU and decrements both the sublist and node item counts.
> > shrink_memcg_cb() then returns LRU_REMOVED_RETRY, causing the LRU walker
> > to decrement the node count again.
> > 
> > The affected call path before this change is:
> > 
> >   __list_lru_walk_one()
> >     shrink_memcg_cb()
> >       zswap_writeback_entry()
> >         zswap_entry_free()
> >           zswap_lru_del()
> >             list_lru_del()
> >               __list_lru_del()
> >                 atomic_long_dec()  /* first node count decrement */
> >       return LRU_REMOVED_RETRY
> >     atomic_long_dec()              /* second node count decrement */
> 
> That's a bug in the zswap code. You shouldn't be calling
> list_lru_del() from __list_lru_walk_one() context.

Grr, Kaitao you dropped the wrong thing that I thought had merit in my
proposal...

Dave, would you mind taking a look at my patch at
https://lore.kernel.org/all/auJkvb-Lq0M5Enkz@cmpxchg.org/?

Ignore zswap for a second. I know it has problems. Most of it stems
from the fact that we rely on the swap locking and do none of our own
locking/lifetime on the zswap entry. As a result we work around it in
odd ways. Sorry, you didn't ask :-) That's worth revisiting, although
it's likely more invasive work.

The observation that led to the patch above was a much simpler one:
since we now have the caller-locked __list_lru_del() anyway, the only
difference between that and the list_lru_isolate* is the
accounting. The patch is about one thing: removing the isolate helpers
entirely. There is then simply one tool for caller-locked list
unlinking, __list_lru_del(). It removes an avoidable distinction,
shrinks the API surface, makes it harder to screw up.

The zswap weirdness made me look at list_lru. Consider it a stress
test from idiotic code :-) But I would propose the list_lru
simplification for its own sake, regardless of what we do with zswap.
