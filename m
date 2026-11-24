Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.130
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795527471;
	b=q7KpEermPxtsFkT3e1pF8v0lVfdOsop8KJOJnd9OMxrMZBCjY1w1C4SB1pKMpIU3sOHu
	 f9A4udwISpiQXtJLYCQA6cFJrRBOhBDpl/DpsjbLWbyre5FgVPdxPzpkHqT/Rs3ib2bzO
	 7gsJSYe7GB92s/JtJ/SY+Fdwbe5DbYx9bGv5xfzA8r8LMmZJ98UsfJ8FhNBuhATLyk+Lc
	 HNGQQV68VPoLNvTmejhF3JFDgoGPalY8//5uaV32yUFWSYF1R+tFdRRVmEH5cbuW4iF4f
	 9sws12FjouofJ2977d9++LXxXYoBGoJnJHX/ssYdaVKpElxge86MfHlPLAILHCsz1sw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795527471;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To:
	 X-Spamd-Result:X-Rspamd-Server:X-Rspamd-Action:X-Spam-Flag:
	 X-Spam-Score:X-Spam-Level:X-Rspamd-Queue-Id;
	bh=qoBXvSkKFB/hg52/Z3aOD/B3EVltr1cS716I45qk3To=;
	b=uaaf9L+PubH3Ee1VeD3z9EOfWr3K+BoJfFV4kzBO2uhl4IBS6nlfGP9t1+jg0eybdVOd
	 3pdUZsBv7U9U1skfy5Dn/YsZE7FtV7EnC7XFqquFa5f3PcY3klHvQLdJ6fWvlYvEenfWG
	 HqnNKARoRaR96FotuE7M7Gg/mKpndWaBRwTCZX7+UhBN7ProGCczCwjY5qGf24fLxYwhf
	 5W2rZLuQcnXAavcFOYZWi5EwdBZm0BfqUejGF4B1NioQy2I6uooVJbbMivqvLR/14fJqw
	 zwmkc9odpWLrJI6RrWtevkyZSUvifCNRb2Y3tQe4KeM/JAAkbN+CnR2vRnN9SYGseCA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=suse.de;
	spf=pass smtp.mailfrom=suse.de;
	dkim=pass header.d=suse.de header.i=@suse.de header.a=rsa-sha256 header.s=susede2_rsa header.b="lco/hl8N";
	dkim=pass header.d=suse.de header.i=@suse.de header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=alZaJIH1;
	dkim=pass header.d=suse.de header.i=@suse.de header.a=rsa-sha256 header.s=susede2_rsa header.b=GrSTaFhB;
	dkim=neutral header.d=suse.de header.i=@suse.de header.a=ed25519-sha256 header.s=susede2_ed25519 header.b="ctYW/Eio";
	arc=none smtp.remote-ip=195.135.223.130
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 442F2606A321;
	Tue, 24 Nov 2026 13:37:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 442F2606A321
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.a=rsa-sha256 header.s=susede2_rsa header.b=lco/hl8N;
	dkim=pass header.d=suse.de header.i=@suse.de header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=alZaJIH1;
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.a=rsa-sha256 header.s=susede2_rsa header.b=GrSTaFhB;
	dkim=neutral header.d=suse.de header.i=@suse.de header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=ctYW/Eio
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id 406AD22045;
	Tue, 24 Nov 2026 13:37:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1795527469; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=qoBXvSkKFB/hg52/Z3aOD/B3EVltr1cS716I45qk3To=;
	b=lco/hl8NuT52rOMTnhNPzkjxpgpMKgl5c3r+lYMfoziPUpXwuaQx+YQB23RIMuyWSJoVfU
	TUOGfqMXf4Y4pJvrqFDCf/IsBODVwW5Uu53J8OeC9k4Z+RFDuT7q/cVpWQPmHdwv9erbgi
	zajCwIL9kCHg3J+pIg8O76WcPmWTXjs=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1795527469;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=qoBXvSkKFB/hg52/Z3aOD/B3EVltr1cS716I45qk3To=;
	b=alZaJIH1IM9U6rlVlGHsk+Nm/4PIyn5M2HQasw4PKpXD7H47cw09mbtw4MdzByNUE8L6qc
	scbWYIb+TmQeX8Cg==
Authentication-Results: smtp-out1.suse.de;
	dkim=pass header.d=suse.de header.s=susede2_rsa header.b=GrSTaFhB;
	dkim=pass header.d=suse.de header.s=susede2_ed25519 header.b="ctYW/Eio"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1795527468; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=qoBXvSkKFB/hg52/Z3aOD/B3EVltr1cS716I45qk3To=;
	b=GrSTaFhBy00Ek0GciUVJgmyZIVu/eK/cYxonxQUwIRdDtq6VMbDnZh37Ab97BSn1RmQI2+
	FZnIXV5iW8EatUHjUF+mDKTWJgrZ/lHOdKnZoHJhSgHxDtXUcfRl9beaLWkphKKt2baAjS
	e6tcTJQNO2u7VK1SyExVAA2Bl/Hnwco=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1795527468;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=qoBXvSkKFB/hg52/Z3aOD/B3EVltr1cS716I45qk3To=;
	b=ctYW/Eioa17vHbXnyPyrRNPD6yw6zFKUA5N6TmPXc7/uSEQumQBUZg5I8OHCCD+uGU7Odw
	RqDRkTlHGnYqB0Dg==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id D1B6B13505;
	Tue, 24 Nov 2026 13:37:45 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id 8+SPJimTBWuuewAAD6G6ig
	(envelope-from <pfalcato@suse.de>); Tue, 24 Nov 2026 13:37:45 +0000
Date: Tue, 24 Nov 2026 13:37:43 +0000
From: Pedro Falcato <pfalcato@suse.de>
To: John Hubbard <jhubbard@nvidia.com>, 
	Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>
Cc: David Hildenbrand <david@kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Zi Yan <ziy@nvidia.com>, 
	"Matthew Wilcox (Oracle)" <willy@infradead.org>, Lorenzo Stoakes <ljs@kernel.org>, Peter Xu <peterx@redhat.com>, 
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
Message-ID: <awWNyDZT2SVu2Zp9@pedro-suse.tail5790ac.ts.net>
References: <20261119-gup-dirty-what-v1-0-236d69f25c24@suse.de>
 <4f096d70-6f94-4148-8f47-242b8551e5f9@nvidia.com>
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
In-Reply-To: <4f096d70-6f94-4148-8f47-242b8551e5f9@nvidia.com>
X-Spamd-Result: default: False [-13.51 / 50.00];
	SUSE_INTERNAL_BYPASS(-9.00)[];
	BAYES_HAM(-3.00)[100.00%];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	R_DKIM_ALLOW(-0.20)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	MX_GOOD(-0.01)[];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	ARC_NA(0.00)[];
	RCPT_COUNT_TWELVE(0.00)[37];
	RBL_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:104:10:150:64:97:from];
	TO_DN_SOME(0.00)[];
	MIME_TRACE(0.00)[0:+];
	MISSING_XM_UA(0.00)[];
	RCVD_TLS_ALL(0.00)[];
	R_RATELIMIT(0.00)[to_ip_from(RL89xh3ijk4gdpeanxbepagf1s)];
	RCVD_COUNT_TWO(0.00)[2];
	FROM_EQ_ENVFROM(0.00)[];
	FROM_HAS_DN(0.00)[];
	RECEIVED_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:106:10:150:64:167:received];
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.de:dkim,imap1.dmz-prg2.suse.org:rdns,imap1.dmz-prg2.suse.org:helo];
	URIBL_BLOCKED(0.00)[suse.de:dkim,imap1.dmz-prg2.suse.org:rdns,imap1.dmz-prg2.suse.org:helo];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	DKIM_SIGNED(0.00)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
	DKIM_TRACE(0.00)[suse.de:+]
X-Rspamd-Server: rspamd1.dmz-prg2.suse.org
X-Rspamd-Action: no action
X-Spam-Flag: NO
X-Spam-Score: -13.51
X-Spam-Level: 
X-Rspamd-Queue-Id: 406AD22045

Hi John, Christoph, Jan,

Thank you for your replies. Since you largely share the same point, I'll
combine this into a single reply.

On Thu, Nov 19, 2026 at 04:55:30PM -0800, John Hubbard wrote:
> On 11/19/26 12:10 PM, Pedro Falcato wrote:
> > Sooo.... It turns out GUP dirty and ->release_folio() interact really
> > weirdly. This was initially reported by some AI agent, and David let me
> > know.
> > 
> > The basic issue is:
> 
> The basic issue is covered in a series of LWN articles that span 5 or
> 6 years:
> 
>     https://lwn.net/Kernel/Index/#Memory_management-get_user_pages
> 
> Probably good to read and absorb that. There's a lot.
>

Thanks. I was aware of some of this, but it's good to take a fresh look again :)
 
> The problem remains not fully solved. pin_user_pages() is a building
> block, but we need to fully coordinate with filesystems in order to
> finish. It's good that you are looking at this.
> 
> >  - ->dirty_folio() relies on buffers/IFS/etc being attached to the
> >    folios. It _cannot_ attach them itself, as dirty_folio() cannot
> >    block.
> >  - certain MM paths (reclaim, khugepaged, folio split, etc) are very
> >    trigger-happy when it comes to asking filesystems to release them. In
> >    most cases, barring any dirty folios, buffers, it will just drop
> >    them.
> >  - there is no problem in usual IO submission, but issues start to pop
> >    up with GUP, where the code flow (roughly) becomes:
> >         [get_user_pages(), etc]
> >            ->page_mkwrite() called here, or before
> >              ->private correctly populated with whatever the filesystem
> >                expects.
> >              folio is marked as dirty, initially.
> >        *write finishes*
> >        folio_lock();
> >        folio_mark_dirty();
> >          ->dirty_folio()
> >               dirty_folio expects ->private to be populated by
> >               ->page_mkwrite(), ->write_begin().
> >        folio_unlock();
> > 
> > What happens if any filemap_release_folio() runs (and succeeds) between
> > the initial dirtying (plus eventually writeback) and the write to the
> > folio completes? Welp, it's unpredictable. ext4 for example will
> > WARN_ONCE, and likely drop data (see ext4_dirty_folio()).
> > 
> > So, what can we do about it? It's complicated, hence why this is an RFC.
> > For the possible solutions:
> >  - ->dirty_folio() attaching this FS information itself is not really
> >    possible in many cases. ->dirty_folio() can't block, nor is it even
> >    guaranteed to hold the folio lock while being called.
> >  - Can pincount help? Kind of. Things like folio_maybe_dma_pinned() are
> >    rough, and don't deal with the usage of get_user_pages(FOLL_WRITE).
> >    pincount itself isn't available in the common order-0 case, and not
> >    available on order-1 as well on 32-bit, but who cares about that^W^W^W^W^W
> >  - Could get_user_pages() ban FOLL_WRITE? Mayhaps. I would not be
> >    opposed to that, but that's probably a larger change than ideal for stable,
> >    and I'm not familiar enough with GUP requirements to decide to go that way.
> >    This would require migrating all FOLL_WRITE users to
> >    pin_user_pages().
> >  - Can the whole system be reworked? Probably, but not for stable.
> > 
> > This patch series is really rough but kind-of works. Instead of using
> > folio_maybe_dma_pinned(), which only interacts with pin_user_pages(), I
> 
> pin_user_pages() was specifically introduced for this exact class of
> problem. get_user_pages() is now meant for other, much more limited cases.
> I've attempted to document that, here:
> 
>     https://docs.kernel.org/core-api/pin_user_pages.html

Ok, so I guess you want me to drop the hacks to make GUP FOLL_WRITE not
screw itself over? To be clear, the rest is still broken, even with pin_user_pages().
It just means we get nicer looking fixes, and I can drop patch 3.

It's unclear (to me) whether we care about any straggling get_user_pages
FOLL_WRITE users. A quick look around doesn't find me many; most seem to have
been converted to pin_user_pages() (though, admittedly, I don't know how many
of these are converted in stable; do we care?). Perhaps piling on a patch
to simply disallow get_user_pages(FOLL_WRITE) is ok? Giving Lorenzo's idea
a go again :)

FWIW I asked my least-favourite chatbot about get_user_pages(FOLL_WRITE) users,
and it found me a couple of cases. But little enough that it sounded fixable.
But, again, I don't know if this reflects stable, or whether we really care
that much.

> > ---
> > base-commit: 9663aa0da7070d958e333477ce0720512e9fa016
> > change-id: 20261116-gup-dirty-what-b73da748f5d1
> 
> A git alias to wrap "git format-patch" with a sed(1) invocation is a great way
> to avoid accidentally "leaking" gerrit change-id's into a posting, fwiw.

I appreciate the advice, but this is gunk that b4 adds to every patchset ;) 

-- 
Pedro
