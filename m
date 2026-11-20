Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=213.95.11.211
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795189455;
	b=NoAXFcFDoM0X47DYGsdTf05b1SferWjBCbI4ktXsjQvyWRTVd/wJ6gx128m/k/DBgr/I
	 LmGzQh3Ej+gxddHZ5ghIlmVh487fLmFH7S6peKMmoqCq5qkBMR1tF8nVeD1sLiVxtMVBF
	 bLCG9hS/rwp+Q+dU7/W65M0LSBEs6KGgX7KQ/05Eql0Sgw8tFScUwWa0LEGuf7r4QqkEp
	 CdAffTwX/eCKWlUChfktdxzqz7vGZsN66StsLpBBz1cNX9yqA1pIgWD+evm3XKVbZxker
	 JncB8uxzPdK8Mne/tD17w9AnHqwwTUfvFHoqSm8HGjl4oREjWuVXws79/7Wr+rKimeg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795189455;
	h=DMARC-Filter:Received:Date:From:To:Cc:Subject:Message-ID:References:
	 MIME-Version:Content-Type:Content-Disposition:In-Reply-To:User-Agent;
	bh=MpAFJKoRLBHWua5zVfwBOUWeo6j4cvTXzjQs1AqjA18=;
	b=QBQU3ZgAS0wmjuFY+vBYZQCSv/ELGhrP6J4lrzLcFskSQ4/d586e1AMwRKplM+XVpEWI
	 P3xM6dbFoViMcZKQMqZF30v8pKcq7hgAE5FFDvLvt33oZirNiNL7AGQN/vYmVwTPmiqEX
	 koaJBJm6VkI3gP/luKBC9GPfTnMSQuPolkNqk7dMS8Blx++8wivND8QxhbSpNI0+lZeYq
	 thf7bsx0P71tIQ9PKeOHqPY9+sUdPJwLOqS33Um1mXGv1xOtu6PTYZ6Nrdsp89rkc6Uiq
	 xR73LxEnFmQQY7jmURRWryNGBgrugAwiO5Oqr5SgPhaiaaehFGg5jsuc3hVeBAseQnA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=lst.de;
	spf=pass smtp.mailfrom=lst.de;
	arc=none smtp.remote-ip=213.95.11.211
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8C82E606A325;
	Fri, 20 Nov 2026 15:44:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 8C82E606A325
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id A190E68AFE; Fri, 20 Nov 2026 16:44:09 +0100 (CET)
Date: Fri, 20 Nov 2026 16:44:09 +0100
From: Christoph Hellwig <hch@lst.de>
To: Jan Kara <jack@suse.cz>
Cc: Christian Brauner <brauner@kernel.org>, Christoph Hellwig <hch@lst.de>,
	Shakeel Butt <shakeel.butt@linux.dev>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Jens Axboe <axboe@kernel.dk>, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, io-uring@vger.kernel.org,
	linux-block@vger.kernel.org, linux-nvme@lists.infradead.org,
	linux-scsi@vger.kernel.org, target-devel@vger.kernel.org,
	linux-unionfs@vger.kernel.org, bpf@vger.kernel.org,
	linux-nfs@vger.kernel.org, stable@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>, Will Deacon <will@kernel.org>,
	Boqun Feng <boqun@kernel.org>, Waiman Long <longman@redhat.com>
Subject: Re: [PATCH 07/12] zloop: take freeze protection when recording
 write pointers
Message-ID: <20261120154409.GD28611@lst.de>
References: <20261114-work-fs-frozen_writes-v1-0-f5ae61c898b1@kernel.org> <20261114-work-fs-frozen_writes-v1-7-f5ae61c898b1@kernel.org> <20261116064820.GB2964@lst.de> <20261116-biegen-flaute-flanke-cebddae97444@brauner> <t73376p7ip4bvetjbqijzugvglhi2rdxsqt62l3uuqtmt3tqgk@2rlkkdy33hwk>
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
In-Reply-To: <t73376p7ip4bvetjbqijzugvglhi2rdxsqt62l3uuqtmt3tqgk@2rlkkdy33hwk>
User-Agent: Mutt/1.5.17 (2007-11-01)

On Mon, Nov 16, 2026 at 12:57:09PM +0100, Jan Kara wrote:
> On Mon 16-11-26 10:41:49, Christian Brauner wrote:
> > Fwiw, the check can't go into __vfs_setxattr(), __vfs_setxattr_noperm()
> > or __vfs_removexattr(). cap_inode_killpriv(), IMA and EVM call those
> > from ->write_iter() via file_remove_privs() and kiocb_start_write()
> > hides the freeze protection from lockdep for aio and io_uring. I have
> > not bothered to figure out why. Maybe you already know? In any case,
> > until that's fixed we can't place it there which means this doesn't
> > catch IMA/EVM at which point this patch becomes pointless.
> 
> It's because of AIO and io_uring - if you don't hide the protection from
> lockdep, it will complain about it when returning to userspace while IO is
> still in flight (and thus protection is held). Sadly lockdep does not
> support releasing resources by anybody else than the process which acquired
> it so we fool it in this way...

Can we try to escalate this to the lockdep folks instead of piling hacks
deeper and deeper?
> 
> 								Honza
> -- 
> Jan Kara <jack@suse.com>
> SUSE Labs, CR
---end quoted text---
