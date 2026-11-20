Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.131
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795175846;
	b=uv4XtgF78LcdSljell7Y6m+7SDBWsU0F2OPNu0HJykW5inPYb+k7QL3eLeg7PHjL2pb9
	 jq8UzooTQcHfi6kNRuTaacwt+kphds+Eh0NPRIwHHKIpB+bLrM+z8t2PPL3TuVcLdQPSX
	 /d+fSRoH2SaX1m1bWfrVaL5X/grTmy7XyBnuTcn14GA1jbnkjQoykt3xGAmh1R7WlWY6o
	 fF/Ss7MqKNeFg75rGAjYbERLrykinDvvn+74L+u4fT+s35gs4Cc8o+vliaIKGkQ5Wwag8
	 WD4pOSwUgDJ3oAw30LCLvRpkZl1MHyKft8+vVMCasHRwfoNvc0g/+Fl8UHgC83X+CfA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795175846;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-Spamd-Result:X-Spam-Score:X-Spam-Level:X-Spam-Flag;
	bh=2UfyX4HcTgglDLDCpVQRwII+hpQZMq7tsHEziWfbiTU=;
	b=Q/yfV7KBwstk7AIH+FOZp6bSj+NcBlScvJknHzxST2mMaNFWAwwedBjbAXF3CYZ0FYix
	 F09xN53IR5OEMKwJ/GTN/9RxLUY4nWGct+3OVmOUiCq7ZY8mRbHqAHhVFlfxws8QpebYQ
	 xPHU9Wr5fkNp5jCtHZDiR0nTnVOmqNacRe7Ays1sMHUS32D4WGg1s8RD2jQak46mBQAci
	 Db0jnLlM0l0Cx1LW9t+Qlwu4e47Y7kPUMeMHkH2ZEyDJEz1gV35gRuiPrWO1NDqVzxbmk
	 pYJatacp5lq77Be77alWuQ4dvFP+AeYGXB20WnmNgZOvENvH7jzUp7aAifgS7UFw8XA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=suse.cz;
	spf=pass smtp.mailfrom=suse.cz;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b="aPxq/8Jr";
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=neGXudo8;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b="aPxq/8Jr";
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=neGXudo8;
	arc=none smtp.remote-ip=195.135.223.131
Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C8FEE606A33F;
	Fri, 20 Nov 2026 11:57:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org C8FEE606A33F
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=aPxq/8Jr;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=neGXudo8;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=aPxq/8Jr;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=neGXudo8
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id 022D01F441;
	Fri, 20 Nov 2026 11:57:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1795175844; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=2UfyX4HcTgglDLDCpVQRwII+hpQZMq7tsHEziWfbiTU=;
	b=aPxq/8JrK7TX5/4zb61bR0lNbw+ULbGnJx7r8UWPT1s/w1td1wy6y5QQ5dMqQaqtKnotMG
	0wuJBaEw0oWI0WHGN3bT2LIwVZqB2BZnhUuEh4mwBvbNzHMQ7cztp0gRFRWAlG5MrbOsfI
	YBkUHP+j/PSV0xGH52dneXTl/+Xzcxk=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1795175844;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=2UfyX4HcTgglDLDCpVQRwII+hpQZMq7tsHEziWfbiTU=;
	b=neGXudo8yCIZnK/u9k9axSwtuJRv4LtRqBsee9U9/HSxjThsg40KfQ1q5ujZJJ+jxbCZVt
	GdWCbnIWyiGdHLBg==
Authentication-Results: smtp-out2.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1795175844; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=2UfyX4HcTgglDLDCpVQRwII+hpQZMq7tsHEziWfbiTU=;
	b=aPxq/8JrK7TX5/4zb61bR0lNbw+ULbGnJx7r8UWPT1s/w1td1wy6y5QQ5dMqQaqtKnotMG
	0wuJBaEw0oWI0WHGN3bT2LIwVZqB2BZnhUuEh4mwBvbNzHMQ7cztp0gRFRWAlG5MrbOsfI
	YBkUHP+j/PSV0xGH52dneXTl/+Xzcxk=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1795175844;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=2UfyX4HcTgglDLDCpVQRwII+hpQZMq7tsHEziWfbiTU=;
	b=neGXudo8yCIZnK/u9k9axSwtuJRv4LtRqBsee9U9/HSxjThsg40KfQ1q5ujZJJ+jxbCZVt
	GdWCbnIWyiGdHLBg==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id C57FC1348F;
	Fri, 20 Nov 2026 11:57:23 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id 4gHRJ6M1AGu0EAAAD6G6ig
	(envelope-from <jack@suse.cz>); Fri, 20 Nov 2026 11:57:23 +0000
Received: by quack.suse.cz (Postfix, from userid 1000)
	id 4C6B225F40; Fri, 20 Nov 2026 12:57:23 +0100 (CET)
Date: Fri, 20 Nov 2026 12:57:23 +0100
From: Jan Kara <jack@suse.cz>
To: Pedro Falcato <pfalcato@suse.de>
Cc: David Hildenbrand <david@kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Zi Yan <ziy@nvidia.com>, 
	"Matthew Wilcox (Oracle)" <willy@infradead.org>, Jan Kara <jack@suse.cz>, Lorenzo Stoakes <ljs@kernel.org>, 
	John Hubbard <jhubbard@nvidia.com>, Peter Xu <peterx@redhat.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, linux-ext4@vger.kernel.org, linux-nfs@vger.kernel.org, 
	"Liam R. Howlett" <liam@infradead.org>, Vlastimil Babka <vbabka@kernel.org>, 
	Mike Rapoport <rppt@kernel.org>, Suren Baghdasaryan <surenb@google.com>, 
	Michal Hocko <mhocko@suse.com>, Baolin Wang <baolin.wang@linux.alibaba.com>, 
	Nico Pache <nico.pache@linux.dev>, Ryan Roberts <ryan.roberts@arm.com>, Dev Jain <dev.jain@arm.com>, 
	Barry Song <baohua@kernel.org>, Lance Yang <lance.yang@linux.dev>, 
	Usama Arif <usama.arif@linux.dev>, Kiryl Shutsemau <kas@kernel.org>, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org, Kairui Song <kasong@tencent.com>, Qi Zheng <qi.zheng@linux.dev>, 
	Shakeel Butt <shakeel.butt@linux.dev>, Axel Rasmussen <axelrasmussen@google.com>, 
	Yuanchu Xie <yuanchu@google.com>, Wei Xu <weixugc@google.com>, Baoquan He <baoquan.he@linux.dev>, 
	Michal Hocko <mhocko@kernel.org>, linux-fsdevel@vger.kernel.org, stable@vger.kernel.org
Subject: Re: [PATCH RFC 0/5] mm: GUP dirty + ->release_folio() fixes
Message-ID: <yawwmyxucwkzmay55hkcngm2bvaqjdrrvssgasf54zy5nwpfxl@6ocrzft2w6gy>
References: <20261119-gup-dirty-what-v1-0-236d69f25c24@suse.de>
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
In-Reply-To: <20261119-gup-dirty-what-v1-0-236d69f25c24@suse.de>
X-Spamd-Result: default: False [-16.80 / 50.00];
	SUSE_INTERNAL_BYPASS(-9.00)[];
	REPLY(-4.00)[];
	BAYES_HAM(-3.00)[100.00%];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_RHS_NOT_FQDN(0.50)[];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	RCVD_COUNT_THREE(0.00)[3];
	ARC_NA(0.00)[];
	RCPT_COUNT_TWELVE(0.00)[37];
	MIME_TRACE(0.00)[0:+];
	RCVD_TLS_LAST(0.00)[];
	FROM_HAS_DN(0.00)[];
	TO_DN_SOME(0.00)[];
	FROM_EQ_ENVFROM(0.00)[];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	R_RATELIMIT(0.00)[to_ip_from(RLc5chj8mdhigtayhgqted7wkp)];
	MISSING_XM_UA(0.00)[];
	DBL_BLOCKED_OPENRESOLVER(0.00)[imap1.dmz-prg2.suse.org:helo,suse.com:email]
X-Spam-Score: -16.80
X-Spam-Level: 
X-Spam-Flag: NO

On Thu 19-11-26 20:10:43, Pedro Falcato wrote:
> Sooo.... It turns out GUP dirty and ->release_folio() interact really
> weirdly. This was initially reported by some AI agent, and David let me
> know.
> 
> The basic issue is:
>  - ->dirty_folio() relies on buffers/IFS/etc being attached to the
>    folios. It _cannot_ attach them itself, as dirty_folio() cannot
>    block.
>  - certain MM paths (reclaim, khugepaged, folio split, etc) are very
>    trigger-happy when it comes to asking filesystems to release them. In
>    most cases, barring any dirty folios, buffers, it will just drop
>    them.
>  - there is no problem in usual IO submission, but issues start to pop
>    up with GUP, where the code flow (roughly) becomes:
>         [get_user_pages(), etc]
>            ->page_mkwrite() called here, or before
>              ->private correctly populated with whatever the filesystem
>                expects.
>              folio is marked as dirty, initially.
>        *write finishes*
>        folio_lock();
>        folio_mark_dirty();
>          ->dirty_folio()
>               dirty_folio expects ->private to be populated by
>               ->page_mkwrite(), ->write_begin().
>        folio_unlock();

As John writes in much more detail, if you're modifying folio contents (and
then dirtying a folio), you're supposed to grab folio pin which should
among other things prevent the reclaim of fs private metadata. At least
that was one of design ideas behind folio pins. Maybe something got broken
or there are paths we missed that modify folios but before coming up with a
different mechanism I'd like to understand why the current scheme doesn't
work...

> What happens if any filemap_release_folio() runs (and succeeds) between
> the initial dirtying (plus eventually writeback) and the write to the
> folio completes? Welp, it's unpredictable. ext4 for example will
> WARN_ONCE, and likely drop data (see ext4_dirty_folio()).
> 
> So, what can we do about it? It's complicated, hence why this is an RFC.
> For the possible solutions:
>  - ->dirty_folio() attaching this FS information itself is not really
>    possible in many cases. ->dirty_folio() can't block, nor is it even
>    guaranteed to hold the folio lock while being called.
>  - Can pincount help? Kind of. Things like folio_maybe_dma_pinned() are
>    rough, and don't deal with the usage of get_user_pages(FOLL_WRITE).
>    pincount itself isn't available in the common order-0 case, and not
>    available on order-1 as well on 32-bit, but who cares about that^W^W^W^W^W
>  - Could get_user_pages() ban FOLL_WRITE? Mayhaps. I would not be
>    opposed to that, but that's probably a larger change than ideal for stable,
>    and I'm not familiar enough with GUP requirements to decide to go that way.
>    This would require migrating all FOLL_WRITE users to
>    pin_user_pages().
>  - Can the whole system be reworked? Probably, but not for stable.
> 
> This patch series is really rough but kind-of works. Instead of using
> folio_maybe_dma_pinned(), which only interacts with pin_user_pages(), I
> introduce a new helper that helps places deal with the folio refcount
> directly. In that case, we can also deal with GUP. On the other end,
> moar problems:
>  - NFS private data itself takes refs on folios. Now private data (that
>    we could perhaps release if only we tried) is keeping us from
>    releasing that same data. What?
>  - ext4 data=journal has some funky usage of buffer_heads. Data journalled
>    filesystems will not, in any way, dirty BHs. Instead it will,
>    *only if it was DMA pinned*, set the checked flag. ext4 skips
>    dropping those buffers if the checked flag is set.

Yes, that code is funky and there's a big comment in front of
ext4_journalled_dirty_folio() trying to explain what's going on. We
attach folio buffers to the transaction on ->page_mkwrite. When the
transaction commits, we must writeprotect the folio again to be notified
about next write so that we can attached buffers to the next transaction.
But what will you do with pins and users modifying folios through them? You
can't just "writeprotect" against an existing pin. So we just note with
folio_set_checked() that this folio has newer data than what is in the
journal and then in a more relaxed context, we do the journaling dance and
record the updated data in the journal. But you don't have to worry about
this too much. Ted plans to rip out data=journal mode in the near future
and then this will go away.

>  - ext4 move_extents seems to have suspicious usage of
>    filemap_release_folio() as well.

Yeah, that whole code is hairy and I agree these calls are probably
problematic.  We should hold invalidate_locks over the whole operation and
should bail if any of the folios has a pin before calling into
filemap_release_folio().

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
