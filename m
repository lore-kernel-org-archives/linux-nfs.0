Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.131
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795787974;
	b=3ZGt9so1a9I7KYazX++tuwhbTohtD9l0QmE9TfVUEvnOtHF5Wk3ikDTNRMCJpntTT5u8
	 qr2lHFmYtTjzNJm3HjEcn7Q7Pafw0UppHNfiOKRp4nSj83eY1EAiQIWhyx21LNPA/jF4Y
	 WS8+LrGApVr38u38ZAHQLKVDmnnxPCr+LM0AVhKhAGRqhxOwBZmh88KSKXWGfPTSvoqst
	 GxqxfJg1wL8FX3Lf7hR09tDrg1Ip3bv9+aEOyCF8eKbV2FuiKqRQzVhPzjOHSM/7wJ1yJ
	 FR5hbt1YNbMnEnCUAicJvisPKYPhj63MO/pER+lB6HXlyyqgcW4eFYfXfMoA59i3Aug==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795787974;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-Spam-Flag:X-Spam-Level:X-Spamd-Result:X-Spam-Score;
	bh=hSAGX0PlcKV7hxoSKihFcCP5vot5vWKykmT5/I1Rotw=;
	b=ZaVTkkkKwJBKXTFz93EX0GuYzZ9AGTc2RKolhad6C/sZpD2MfUjph3dQza1XYA+/aiKi
	 awZOEhth+7jhM5gTXE99vVYXIY530uMKRawyyAKsmqIIyMB9ui61+GEaOk3otp2js5ufR
	 9R0CvJQGgxajjVHgCwmvcd0N0BVWpbcj/ZqBZZh3INOkQoHEDZ3z/aj8OPHz39GD5cYKq
	 I6CdjSz25t/ihYOf7KzjkLFI5kLFcqXApAyjyEFVAZQsFS2R6P1ophplNLj3ekGkp0ntT
	 GvMG/WTb972bpMFVW/vf+e03fSeT2dLcX100zW83BmxhQM/ctfHCQzTS8MQEC1pOKVA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=suse.cz;
	spf=pass smtp.mailfrom=suse.cz;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=n8Sp1N6y;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=pODgPDhA;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=ptBQgtrQ;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=m5UC2tpx;
	arc=none smtp.remote-ip=195.135.223.131
Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ED422606A323;
	Fri, 27 Nov 2026 13:59:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org ED422606A323
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=n8Sp1N6y;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=pODgPDhA;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=ptBQgtrQ;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=m5UC2tpx
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id D311D1FBB0;
	Fri, 27 Nov 2026 13:59:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1795787972; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=hSAGX0PlcKV7hxoSKihFcCP5vot5vWKykmT5/I1Rotw=;
	b=n8Sp1N6y9Vm45Mgr7D/4hXr+E6kdClBXxiVKkx/q5AGVMNOvdcYnHgM8wgmleWTbydX/QG
	uuMm1BMVGIR3YVzyXvB4zzhU52UBrN334F0BC6VptBLw3q8doluBTW8UzBHcb/ROoal/RZ
	hB5Wy4ULuPz9NrLd64ks0FgbhAS6apQ=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1795787972;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=hSAGX0PlcKV7hxoSKihFcCP5vot5vWKykmT5/I1Rotw=;
	b=pODgPDhAIxp656pvlxUrpRSk4HSBAnk2OPd6F0EmkVWwkXolg1gbpxsCUHwBLlENz3fTy+
	vyjKYebOVwYrdiBA==
Authentication-Results: smtp-out2.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1795787971; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=hSAGX0PlcKV7hxoSKihFcCP5vot5vWKykmT5/I1Rotw=;
	b=ptBQgtrQ1GwX/wj0pA4/omtbuqgeHt/5dbnW0NE7ZSZb/rshDm92HW7IAbncmzCNomGHrq
	llRGEkndrmeio+ki1sR4C5SAO30en9k2MiDmH37kCNezcAXR3p3iE8ShjAucopDXxQKZ0z
	B+O3si4tKsoKxWqd++oRS8jajx2WrV8=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1795787971;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=hSAGX0PlcKV7hxoSKihFcCP5vot5vWKykmT5/I1Rotw=;
	b=m5UC2tpxZO9Yf2DSATt0pN8be86yEfoSuqxihq+0TXlJbrK4CsSDNWDf2F2CDIHK7o9gTL
	+NVHKwwbqHEZ7dCQ==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id A703013432;
	Fri, 27 Nov 2026 13:59:31 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id QDmCIMOMCWsgNQAAD6G6ig
	(envelope-from <jack@suse.cz>); Fri, 27 Nov 2026 13:59:31 +0000
Received: by quack.suse.cz (Postfix, from userid 1000)
	id 2B5DF5103B; Fri, 27 Nov 2026 14:59:31 +0100 (CET)
Date: Fri, 27 Nov 2026 14:59:31 +0100
From: Jan Kara <jack@suse.cz>
To: Pedro Falcato <pfalcato@suse.de>
Cc: Jan Kara <jack@suse.cz>, David Hildenbrand <david@kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Zi Yan <ziy@nvidia.com>, 
	"Matthew Wilcox (Oracle)" <willy@infradead.org>, Lorenzo Stoakes <ljs@kernel.org>, 
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
Subject: Re: [PATCH RFC 4/5] mm/vmscan: be more careful when releasing FS
 metadata if buffer_heads_over_limit
Message-ID: <mlu22apiuzcim6icjolifdr6wgsk5u6dpo4kwn4ppkcdgfudn7@t6sp7ck7qafd>
References: <20261119-gup-dirty-what-v1-0-236d69f25c24@suse.de>
 <20261119-gup-dirty-what-v1-4-236d69f25c24@suse.de>
 <wm57zjtvdpexvbfygmdggw2ytsazelyds4rt3mtx6oy6u72mke@rhviuzp26rt6>
 <awmGDyR4WUJrwqn1@pedro-suse.tail5790ac.ts.net>
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
In-Reply-To: <awmGDyR4WUJrwqn1@pedro-suse.tail5790ac.ts.net>
X-Spam-Flag: NO
X-Spam-Level: 
X-Spamd-Result: default: False [-16.80 / 50.00];
	SUSE_INTERNAL_BYPASS(-9.00)[];
	REPLY(-4.00)[];
	BAYES_HAM(-3.00)[100.00%];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_RHS_NOT_FQDN(0.50)[];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	ARC_NA(0.00)[];
	MISSING_XM_UA(0.00)[];
	FROM_HAS_DN(0.00)[];
	MIME_TRACE(0.00)[0:+];
	TO_DN_SOME(0.00)[];
	RCPT_COUNT_TWELVE(0.00)[37];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	RCVD_COUNT_THREE(0.00)[3];
	R_RATELIMIT(0.00)[to_ip_from(RLc5chj8mdhigtayhgqted7wkp)];
	FROM_EQ_ENVFROM(0.00)[];
	URIBL_BLOCKED(0.00)[imap1.dmz-prg2.suse.org:helo,suse.com:email];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	RCVD_TLS_LAST(0.00)[];
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.com:email,imap1.dmz-prg2.suse.org:helo]
X-Spam-Score: -16.80

On Fri 27-11-26 13:37:15, Pedro Falcato wrote:
> On Wed, Nov 25, 2026 at 09:45:01AM +0100, Jan Kara wrote:
> > Just given buffer_heads_over_limit is a HIGHMEM thing and given how much we
> > care (not) about HIGHMEM, maybe just completely ripping out the whole
> > buffer_heads_over_limit logic is a better "solution"? I mean it's a crude
> > heuristic anyway and for struct buffer_head to occupy significant portion
> > of ZONE_NORMAL, you'd have to have several GB of pagecache with buffers
> > which means the machine has to have quite some highmem which makes the
> > setup even more dubious...
> 
> Is it _just_ a HIGHMEM thing? I had the impression it had some effect as
> a general buffer_head shrinker. Either way, I do think we can remove it,
> but I chose not to do it for stable; also, I don't have technical arguments
> as to why it's useless, I just assume it is.

I don't believe it can ever activate without HIGHMEM - each bh points to
actual data in the folio it is attached to which, usless you have 512-byte
blocks, is more than 10x larger than struct buffer_head. So buffer heads
can never occupy more than 10% of total memory unless you are really trying
to screw up your system... And AFAIK this mechanism was introduced as
a HIGHMEM thing many years ago.

> Other filesystems (iomap, XFS, btrfs) don't participate in this scheme and
> they turn out just fine. So, unless you find something I'm missing, I will
> probably send a (separate) patch removing this whole mechanism for next.

Yes, that would be great.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
