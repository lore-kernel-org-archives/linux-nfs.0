Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.131
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795605691;
	b=wBA6kFvn/7h9uoupU9U3k+N1YOEojhf+xmTQgnpjV34voOsLbxvOugyogG+t9JTMSfw2
	 eov40hffRZroRp43U7mC7UhCUA3tV2KTpwMJFOnxbNgbPt/b0O8ZlhBU8IWF75+WR7ytx
	 1K4wlI0rDCJyILlmq/1zLwg4wxnA/oAPDbCFnY74lR/+v3/6G3kVfAm2c/LoulWSXd2zE
	 YZGE1luC2uFYserBMbPLa0SPsYOojymBU3cVxV4nYqexmUpjZUkMC8y5MndC3IVHlo/pm
	 LI9+6C1gf+y13AqNTUDYbThdPAWvTpCi2KwD88nhvvcJGMlYpwXrkVN8+iv2YaWbNEA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795605691;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To:
	 X-Spam-Flag:X-Spam-Level:X-Spamd-Result:X-Spam-Score;
	bh=ob+Vq6L4US0Tc+CXMPvwy44ZwB7QIg9X6EZnYEIjp60=;
	b=tbCYrQzM66RfZ9w4cv7GDjsAvrOxmX692afjV0X5uKSCIKwlh/wnAaiCH77qPFnh4Btg
	 0KbX7+F9SMgwzfJAsw+HmToULaPyWYhe0MPOl7udGvRpX5UsoaGsayuyJ5dv/YcH6oq+e
	 OKI4xSnBu8Bh/W4JbtuuZ0q28+rGvaWQxyRY9FTLEoKJrvaj2xLdhRVhYMRS4R132NnZQ
	 JD9pIzl1FixljXKZWNJ74+qIIpyr8TGwRAV8v5EchhyWHxL8DViTEk0ZeZPPAC7GIYwEa
	 Iwx5smfNU5jPYjb7NOzdRCQE+RAXvbhvaeUlO7Ck218DKcCrX+LMydaIUc6wR5+1f5Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=suse.de;
	spf=pass smtp.mailfrom=suse.de;
	dkim=pass header.d=suse.de header.i=@suse.de header.a=rsa-sha256 header.s=susede2_rsa header.b=SVKXub+d;
	dkim=pass header.d=suse.de header.i=@suse.de header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=1owZleYK;
	dkim=pass header.d=suse.de header.i=@suse.de header.a=rsa-sha256 header.s=susede2_rsa header.b=HnqKLhDZ;
	dkim=neutral header.d=suse.de header.i=@suse.de header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=vhjMSqEX;
	arc=none smtp.remote-ip=195.135.223.131
Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E5088606A323;
	Wed, 25 Nov 2026 11:21:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E5088606A323
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.a=rsa-sha256 header.s=susede2_rsa header.b=SVKXub+d;
	dkim=pass header.d=suse.de header.i=@suse.de header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=1owZleYK;
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.a=rsa-sha256 header.s=susede2_rsa header.b=HnqKLhDZ;
	dkim=neutral header.d=suse.de header.i=@suse.de header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=vhjMSqEX
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id CEF561F7E4;
	Wed, 25 Nov 2026 11:21:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1795605689; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=ob+Vq6L4US0Tc+CXMPvwy44ZwB7QIg9X6EZnYEIjp60=;
	b=SVKXub+dVIHf6xbd0DStZYOnuIKDz33gDFQBigyuSfSuY4ciQOy0UXh5VkUjb7uEtQ/itg
	n6ZiKcOVdbM7TCVJgL1pDHCGhxhCZdrZHTz3ibpWTR2m+MaCrUPMsujLR7rY9u+YyNk4Ok
	tfHx2gMqiNwIa4Ke+30SV2Tw7GauaF0=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1795605689;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=ob+Vq6L4US0Tc+CXMPvwy44ZwB7QIg9X6EZnYEIjp60=;
	b=1owZleYKDD4SGDw3fU3e4wcFD2o42VU8SE/VaPiW6UjnUs9aay7PwWB5iisJC3ATwreN1n
	q0oDmF2NpaB83fCA==
Authentication-Results: smtp-out2.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1795605688; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=ob+Vq6L4US0Tc+CXMPvwy44ZwB7QIg9X6EZnYEIjp60=;
	b=HnqKLhDZivs/f2jjuH6c7tNSEGKa80ZFlBDZfWgC/9RFIFPl3/+vISlD6n+roytFSSwujc
	1FI0XEfN7aqxrnGO8hiKnqIhYTUo3zu+wGURSb/dUyVdtnHOedpykl7FFW222+ppScAr66
	MZ5wEDXser8U3QKglz6hW55tfTjqYQU=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1795605688;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=ob+Vq6L4US0Tc+CXMPvwy44ZwB7QIg9X6EZnYEIjp60=;
	b=vhjMSqEX5XU9Ms1yJL6Mh5evELI4VLISLDyWtfuLY4vo5dac2rQ2fLoDc/4TvC9vDrX2ye
	+TN2YXflhJF+e4CQ==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id C00F6134E8;
	Wed, 25 Nov 2026 11:21:25 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id lQdhG7XEBmtNHwAAD6G6ig
	(envelope-from <pfalcato@suse.de>); Wed, 25 Nov 2026 11:21:25 +0000
Date: Wed, 25 Nov 2026 11:21:23 +0000
From: Pedro Falcato <pfalcato@suse.de>
To: "David Hildenbrand (Arm)" <david@kernel.org>
Cc: Christoph Hellwig <hch@infradead.org>, 
	John Hubbard <jhubbard@nvidia.com>, Jan Kara <jack@suse.cz>, 
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
Message-ID: <awbEPaUkbQA3TviB@pedro-suse.tail5790ac.ts.net>
References: <20261119-gup-dirty-what-v1-0-236d69f25c24@suse.de>
 <4f096d70-6f94-4148-8f47-242b8551e5f9@nvidia.com>
 <awWNyDZT2SVu2Zp9@pedro-suse.tail5790ac.ts.net>
 <55114986-0ba1-4a80-8498-bf674d64e01b@kernel.org>
 <away88BuU8ibcTA5@infradead.org>
 <d088452f-1118-4a06-bc16-1942e523e0fc@kernel.org>
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
In-Reply-To: <d088452f-1118-4a06-bc16-1942e523e0fc@kernel.org>
X-Spam-Flag: NO
X-Spam-Level: 
X-Spamd-Result: default: False [-13.30 / 50.00];
	SUSE_INTERNAL_BYPASS(-9.00)[];
	BAYES_HAM(-3.00)[100.00%];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	URIBL_BLOCKED(0.00)[imap1.dmz-prg2.suse.org:helo,wikipedia.org:url];
	DKIM_SIGNED(0.00)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
	ARC_NA(0.00)[];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	RCPT_COUNT_TWELVE(0.00)[37];
	MIME_TRACE(0.00)[0:+];
	FROM_HAS_DN(0.00)[];
	R_RATELIMIT(0.00)[to_ip_from(RL8d8xedm6iu8o66torxsk6bwd)];
	TO_DN_SOME(0.00)[];
	FROM_EQ_ENVFROM(0.00)[];
	RCVD_TLS_ALL(0.00)[];
	RCVD_COUNT_TWO(0.00)[2];
	MISSING_XM_UA(0.00)[];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	DBL_BLOCKED_OPENRESOLVER(0.00)[imap1.dmz-prg2.suse.org:helo]
X-Spam-Score: -13.30

On Wed, Nov 25, 2026 at 11:19:18AM +0100, David Hildenbrand (Arm) wrote:
> On 11/25/26 11:05, Christoph Hellwig wrote:
> > On Wed, Nov 25, 2026 at 10:50:42AM +0100, David Hildenbrand (Arm) wrote:
> >> When I looked into this issue, there were some problematic things.
> >>
> >> We have some odd drivers that use FOLL_GET|FOLL_WRITE, but I am not too
> >> concerned about them.
> >>
> >> But are ways where unprivileged users can mess with  FOLL_GET|FOLL_WRITE
> >> references to trigger this.
> >>
> >> I think the two that stand out are:
> >>
> >> 1) /proc/self/mem access using mem_rw() -> access_remote_vm()
> >>
> >> User can write to a writable-mapped page-cache PTE. Then we can race with
> >> removal of folio metadta, to then set the folio dirty afterwards.
> >>
> >> I remember a good reason to not convert these paths in the past (we are not
> >> performing DMA).
> > 
> > I don't think that is a good reason.  For file system backed VMAs we
> > really need the pin to be able to do someting sane, DMA or not.
> > 
> >> 1) We fix all such cases now where unprivileged users can trigger this,
> >>    converting to FOLL_PIN.
> > 
> > We need to, if not for this series then for all the other outstanding
> > issues with GUP writes.
> 
> Cool, and I agree (that's why I placed it at 1).
> 
> But who is "we"? Because I recall that "we" wanted to do that a while ago.
> 
> (I won't be "we" ;) Pedro, can you take a look? I'm afraid the fuse thing might
> be the harder nut to crack)

"we"[1] will take a look.

-- 
Pedro

[1] https://en.wikipedia.org/wiki/Royal_we
