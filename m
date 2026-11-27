Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.131
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795786231;
	b=kZS5jO+kThTrROgVerJNiXKRuDktYgbavQ8oH1OEfD5od0OC0YIhpnCYYVcjCwVgn7zd
	 Z8aq0jJ89QZ72proLP7o/qcWY4rkjVeobRpnbaJWndGd3dsNCAzx501VVN4TKC99sM0cl
	 3b0OYF7UFp5KXF4Rl+4vejl/R+lQYoWkxDmD32vFtVgtv2wRsBwC+9zYtpBuVYJUynP1L
	 UR4a04BHdBYBHtjAjtcmIEE0iwP12OSh9j5afJQ2o+WFnQ5f7Y6P/TmqgAfWElmWRPLRL
	 f7nMwqSUWRn5R3ry+HKlvP1Yauh4K9b4pDc3MXJ36TIwP0ZTacCAqCxBlzgcpAQN57w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795786231;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To:
	 X-Spamd-Result:X-Spam-Score:X-Spam-Level:X-Spam-Flag;
	bh=H0Jql31Gwg5cy7/8LbYEz5eBl7mNTW69sIgrCB0NofA=;
	b=mJWdBKYtFDZrg1tSdBfW7xqqAX4nELv3erAghgHuN6VMm9SxSglFa+QDhtquLUf2r1Gl
	 aysth1muAvBDgjBFugiWW7IoGAyab4D00DNNSCgbFCGMeA4CXwnokWXx3yWr97jIq9LqI
	 ImxoCB13TREAnq78oUs1ZVXqmUZ5VYBw8sPGfcorYW9dIb/w3jrnFXNe055+GwiS39CFM
	 exB3/k2YpIo8HBBfnoLRAVUFe4rhTPOKIfHhK07GJsvfuKruwkk6almji1/MyQrtlNoFe
	 ZOGw6QLtsZGe0GvRi67EYWBuDrne4wypJ92xbF5hDvGj5RIDkEThDkyPHXs7c1PnKug==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=suse.de;
	spf=pass smtp.mailfrom=suse.de;
	dkim=pass header.d=suse.de header.i=@suse.de header.a=rsa-sha256 header.s=susede2_rsa header.b=U4NKcntY;
	dkim=pass header.d=suse.de header.i=@suse.de header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=RqNzIgqE;
	dkim=pass header.d=suse.de header.i=@suse.de header.a=rsa-sha256 header.s=susede2_rsa header.b=BaKocssb;
	dkim=neutral header.d=suse.de header.i=@suse.de header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=Xle0tI5a;
	arc=none smtp.remote-ip=195.135.223.131
Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5E17F606A31E;
	Fri, 27 Nov 2026 13:30:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 5E17F606A31E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.a=rsa-sha256 header.s=susede2_rsa header.b=U4NKcntY;
	dkim=pass header.d=suse.de header.i=@suse.de header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=RqNzIgqE;
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.a=rsa-sha256 header.s=susede2_rsa header.b=BaKocssb;
	dkim=neutral header.d=suse.de header.i=@suse.de header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=Xle0tI5a
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id 196091FF00;
	Fri, 27 Nov 2026 13:30:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1795786224; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=H0Jql31Gwg5cy7/8LbYEz5eBl7mNTW69sIgrCB0NofA=;
	b=U4NKcntY06TBTWk+IHhUJ5kuPFeYKqhQbotvPIvQDYGH9MOMGFHRDnJYoKotITYl6WNX8B
	ADY9SpBKRNCnkm3qO1VXyXeoKWuk9CpKUnFOFRfugKMdDHkLnrJyfGe0L2b+HYxAHdgWf2
	vEYSrDuzhHNz01IfDskcmsI3c1RRvtU=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1795786224;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=H0Jql31Gwg5cy7/8LbYEz5eBl7mNTW69sIgrCB0NofA=;
	b=RqNzIgqEdc7lsUieUicKkHJFxdXdCOpVphPrRXi+ocnzy6PbKtg5JV7ImUXgFYHVde3mm6
	KjZO977JawC+ILAA==
Authentication-Results: smtp-out2.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1795786223; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=H0Jql31Gwg5cy7/8LbYEz5eBl7mNTW69sIgrCB0NofA=;
	b=BaKocssbOonWoDcnn8ip9+Sy+3PuM4qiaBRWZl83bJBRRpPaLIpqCedCNxV4HMw6JKSuZw
	LywuQm1zwtNJGO2qPDJB1UznC0gIrvcYUdpld63uO73SRAVS4RW+BjrNC6rcvLaAAVf1I9
	TMYeJb/CFGdZIZ2yV/HWT33sMdVDw+c=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1795786223;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=H0Jql31Gwg5cy7/8LbYEz5eBl7mNTW69sIgrCB0NofA=;
	b=Xle0tI5aYu+cWxA+eRC57J7LdJQh7KEJpefFicnS5oKAlZPVJEBHmoewIapk1u1OVITcFD
	78iv9d9bvAR2mwBA==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 9931F13432;
	Fri, 27 Nov 2026 13:30:20 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id nO6AGeyFCWsfFwAAD6G6ig
	(envelope-from <pfalcato@suse.de>); Fri, 27 Nov 2026 13:30:20 +0000
Date: Fri, 27 Nov 2026 13:30:18 +0000
From: Pedro Falcato <pfalcato@suse.de>
To: "David Hildenbrand (Arm)" <david@kernel.org>, 
	Tal Zussman <tz2294@columbia.edu>
Cc: Christoph Hellwig <hch@infradead.org>, 
	Miklos Szeredi <miklos@szeredi.hu>, fuse-devel@lists.linux.dev, John Hubbard <jhubbard@nvidia.com>, 
	Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, 
	Zi Yan <ziy@nvidia.com>, "Matthew Wilcox (Oracle)" <willy@infradead.org>, 
	Lorenzo Stoakes <ljs@kernel.org>, Peter Xu <peterx@redhat.com>, 
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
Message-ID: <awmE8VSlF2VTHLGu@pedro-suse.tail5790ac.ts.net>
References: <20261119-gup-dirty-what-v1-0-236d69f25c24@suse.de>
 <4f096d70-6f94-4148-8f47-242b8551e5f9@nvidia.com>
 <awWNyDZT2SVu2Zp9@pedro-suse.tail5790ac.ts.net>
 <55114986-0ba1-4a80-8498-bf674d64e01b@kernel.org>
 <away88BuU8ibcTA5@infradead.org>
 <d088452f-1118-4a06-bc16-1942e523e0fc@kernel.org>
 <20261126022418.3620783-1-tz2294@columbia.edu>
 <50045fa1-0b46-402f-baf0-a08d05282410@kernel.org>
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
In-Reply-To: <50045fa1-0b46-402f-baf0-a08d05282410@kernel.org>
X-Spamd-Result: default: False [-13.30 / 50.00];
	SUSE_INTERNAL_BYPASS(-9.00)[];
	BAYES_HAM(-3.00)[100.00%];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	MISSING_XM_UA(0.00)[];
	TO_DN_SOME(0.00)[];
	RCPT_COUNT_TWELVE(0.00)[40];
	MIME_TRACE(0.00)[0:+];
	ARC_NA(0.00)[];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	RCVD_TLS_ALL(0.00)[];
	DKIM_SIGNED(0.00)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
	FROM_HAS_DN(0.00)[];
	R_RATELIMIT(0.00)[to_ip_from(RL8d8xedm6iu8o66torxsk6bwd)];
	FROM_EQ_ENVFROM(0.00)[];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	RCVD_COUNT_TWO(0.00)[2];
	DBL_BLOCKED_OPENRESOLVER(0.00)[imap1.dmz-prg2.suse.org:helo]
X-Spam-Score: -13.30
X-Spam-Level: 
X-Spam-Flag: NO

On Thu, Nov 26, 2026 at 07:43:37AM +0100, David Hildenbrand (Arm) wrote:
> On 11/26/26 03:24, Tal Zussman wrote:
> > +CC Miklos
> > 
> > On 11/25/26 5:19 AM, David Hildenbrand (Arm) wrote:
> >> On 11/25/26 11:05, Christoph Hellwig wrote:
> >>>
> >>> We need to, if not for this series then for all the other outstanding
> >>> issues with GUP writes.
> >>
> >> Cool, and I agree (that's why I placed it at 1).
> >>
> >> But who is "we"? Because I recall that "we" wanted to do that a while ago.
> >>
> >> (I won't be "we" ;) Pedro, can you take a look? I'm afraid the fuse thing might
> >> be the harder nut to crack)
> > 
> > Coincidentally, I sent out a patch to convert fuse_copy_fill() to use
> > iov_iter_extract_pages() a few days ago in order to remove its usage of
> > set_page_dirty_lock() and address a different race. I think it should
> > address the fuse side of this issue as well.
> > 
> > https://lore.kernel.org/all/20261120-fuse-copy-fill-pin-v1-1-72a0d888f140@columbia.edu/

Awesome!

> 
> Oh, nice! I was assuming the usual "we use put_page() on some random hidden path
> or core code" would make that harder.

Right.

> I recall that's the reason why vmsplice
> still uses FOLL_GET years after we discussed that it should be using
> FOLL_PIN|FOLL_LONGTERM.

You almost gave me a heart attack, before I remembered these vmspliced pages
aren't writable :) That's a battle for another day!

-- 
Pedro
