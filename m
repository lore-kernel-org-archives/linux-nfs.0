Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.131
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795786641;
	b=YcWw9oNTZ2WG/WJFhmcLr7m00Jax4pEu5GBCv+OCiLtSsJO2e93uW/O1KFrg0Ze+xIah
	 DP9vBy8vvkJiZTf+6z/0yEYCa1O7iRGT1qmft8nEDRTs7dk4nQnT0Eigbhgzi05kpFRR/
	 bWYbrA7UjqbGkojp7BpqTQO9oQq8XkRHCUNns1ZlI0ug2/jsX/YEkTkKiSD6fqOjGB8ND
	 Kq50CiZrj+d4eiQd9SqmkyXNvyrOzAK7oFP+jXZ14EtN+t0IUMgDzjoJfLUUEV5KQwQta
	 IFjJPQePDUaZdCm0LX4tpb9TPW4LXMSkye6WXVydUg7zP3X5SJiH9+JY8Ikt+f5Wl4Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795786641;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To:
	 X-Spam-Flag:X-Spam-Level:X-Spamd-Result:X-Spam-Score;
	bh=Y08yZxh1ryLIY7mvmhCDj43e42/YR5o0fMDQtRHyXPs=;
	b=NEVexBahmX/sxxa0OT8FUJbNHRbxm2/NbumD7+v82WtLorxvJowh79DD2Ze0BMm4r+cQ
	 zbQ5FGibLvSXK7Bmu1JBTQHlsr28YUzvWSE7WKPWU3Cf5iSiN8v8570fhk55ZuZmM7xFk
	 7snX5rCpxU6QhvGQKFFkzctEkXHN+C9Ux4W1j18gsXiO/IEOVP9FqbOWlTDKJPPKjhp/B
	 WbmehLEl/rAF0UKEEC863eKh7R89RAhuo6C7dwosgoTMtN1c6Ql0J6A9zdPLIWfAPXT/E
	 SE01i6wNtNXlLZ4DF6pxnHzJ+yLXB5bSHkcEhf/lehHtR5ceWsL2fvYge13yH0PSYWA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=suse.de;
	spf=pass smtp.mailfrom=suse.de;
	dkim=pass header.d=suse.de header.i=@suse.de header.a=rsa-sha256 header.s=susede2_rsa header.b=vynBLAwI;
	dkim=pass header.d=suse.de header.i=@suse.de header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=1UkdL3aO;
	dkim=pass header.d=suse.de header.i=@suse.de header.a=rsa-sha256 header.s=susede2_rsa header.b=vynBLAwI;
	dkim=neutral header.d=suse.de header.i=@suse.de header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=1UkdL3aO;
	arc=none smtp.remote-ip=195.135.223.131
Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2BE37606A31C;
	Fri, 27 Nov 2026 13:37:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 2BE37606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.a=rsa-sha256 header.s=susede2_rsa header.b=vynBLAwI;
	dkim=pass header.d=suse.de header.i=@suse.de header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=1UkdL3aO;
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.a=rsa-sha256 header.s=susede2_rsa header.b=vynBLAwI;
	dkim=neutral header.d=suse.de header.i=@suse.de header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=1UkdL3aO
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id 30F031FE20;
	Fri, 27 Nov 2026 13:37:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1795786639; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=Y08yZxh1ryLIY7mvmhCDj43e42/YR5o0fMDQtRHyXPs=;
	b=vynBLAwIxfNSUoEpC0eTK1NpGV5HV4AvyVmLzwIJxcNZgLXLXVtcMQb0VXHj/6tMZxND7U
	tO5YbPp66IyElEUGkBD67YXwGx43SgUkD1u5sCPThJwyuU7zkmlX9HWNezXVUPCut+VPme
	GuXvrcQB9YNIUqxE/4d8tPh5VRCAy4k=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1795786639;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=Y08yZxh1ryLIY7mvmhCDj43e42/YR5o0fMDQtRHyXPs=;
	b=1UkdL3aOAmd6XgVNUirmpCHJqBdZNcsvfCN7pcZivSvN7oc/A9T4w2KXrG+uWGnJtib/dU
	kVtlEx8wnCtNA2Cw==
Authentication-Results: smtp-out2.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1795786639; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=Y08yZxh1ryLIY7mvmhCDj43e42/YR5o0fMDQtRHyXPs=;
	b=vynBLAwIxfNSUoEpC0eTK1NpGV5HV4AvyVmLzwIJxcNZgLXLXVtcMQb0VXHj/6tMZxND7U
	tO5YbPp66IyElEUGkBD67YXwGx43SgUkD1u5sCPThJwyuU7zkmlX9HWNezXVUPCut+VPme
	GuXvrcQB9YNIUqxE/4d8tPh5VRCAy4k=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1795786639;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=Y08yZxh1ryLIY7mvmhCDj43e42/YR5o0fMDQtRHyXPs=;
	b=1UkdL3aOAmd6XgVNUirmpCHJqBdZNcsvfCN7pcZivSvN7oc/A9T4w2KXrG+uWGnJtib/dU
	kVtlEx8wnCtNA2Cw==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id ED1CE13432;
	Fri, 27 Nov 2026 13:37:16 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id 4IeHLoyHCWu4HgAAD6G6ig
	(envelope-from <pfalcato@suse.de>); Fri, 27 Nov 2026 13:37:16 +0000
Date: Fri, 27 Nov 2026 13:37:15 +0000
From: Pedro Falcato <pfalcato@suse.de>
To: Jan Kara <jack@suse.cz>
Cc: David Hildenbrand <david@kernel.org>, 
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
Message-ID: <awmGDyR4WUJrwqn1@pedro-suse.tail5790ac.ts.net>
References: <20261119-gup-dirty-what-v1-0-236d69f25c24@suse.de>
 <20261119-gup-dirty-what-v1-4-236d69f25c24@suse.de>
 <wm57zjtvdpexvbfygmdggw2ytsazelyds4rt3mtx6oy6u72mke@rhviuzp26rt6>
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
In-Reply-To: <wm57zjtvdpexvbfygmdggw2ytsazelyds4rt3mtx6oy6u72mke@rhviuzp26rt6>
X-Spam-Flag: NO
X-Spam-Level: 
X-Spamd-Result: default: False [-13.30 / 50.00];
	SUSE_INTERNAL_BYPASS(-9.00)[];
	BAYES_HAM(-3.00)[100.00%];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	MISSING_XM_UA(0.00)[];
	TO_DN_SOME(0.00)[];
	RCPT_COUNT_TWELVE(0.00)[36];
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
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.de:email,imap1.dmz-prg2.suse.org:helo,suse.cz:email]
X-Spam-Score: -13.30

On Wed, Nov 25, 2026 at 09:45:01AM +0100, Jan Kara wrote:
> On Thu 19-11-26 20:10:47, Pedro Falcato wrote:
> > Namely, don't call ->release_folio() for mapped or referenced folios.
> > Since this is the active list, there's no actual point in doing
> > unmapping. In fact, that would be counterproductive for active folios.
> > 
> > So, gate on !mapped && may_release_folio.
> > 
> > Reported-by: David Hildenbrand <david@kernel.org>
> > Cc: stable@vger.kernel.org
> > Fixes: d824ec2a1546 ("mm: do not reclaim private data from pinned page")
> > Signed-off-by: Pedro Falcato <pfalcato@suse.de>
> 
> This is OK with me but so feel free to add:
> 
> Reviewed-by: Jan Kara <jack@suse.cz>

Thanks!

> 
> Just given buffer_heads_over_limit is a HIGHMEM thing and given how much we
> care (not) about HIGHMEM, maybe just completely ripping out the whole
> buffer_heads_over_limit logic is a better "solution"? I mean it's a crude
> heuristic anyway and for struct buffer_head to occupy significant portion
> of ZONE_NORMAL, you'd have to have several GB of pagecache with buffers
> which means the machine has to have quite some highmem which makes the
> setup even more dubious...

Is it _just_ a HIGHMEM thing? I had the impression it had some effect as
a general buffer_head shrinker. Either way, I do think we can remove it,
but I chose not to do it for stable; also, I don't have technical arguments
as to why it's useless, I just assume it is.

Other filesystems (iomap, XFS, btrfs) don't participate in this scheme and
they turn out just fine. So, unless you find something I'm missing, I will
probably send a (separate) patch removing this whole mechanism for next.

-- 
Pedro
