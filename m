Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.131
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795596751;
	b=NH3DS218UUQrgyKCMXEk5El5s5Xdtm1oVYPtcgYH72k1FByL0HAc7AuXiJi2Uy+M9Xq6
	 OOlKhhSH/QyrSa8WfXfusloCvuL0AHn8ed/JSzzMSHQsk2Z7YiJVN2YxGHHZqf3CPSN5K
	 nPPeSOF7XSYCFRm0p77UpjmM2KylQGoyc1QVVCjpD5BoAPYPjg4mY0bij+vtrQnmO4mPI
	 69cpoC6cljVwHr6VIPcpQLYQG++96qC/ZAbOQlGcJk63VQOKLDh9f0NdJ+CSHEJw1dR5A
	 faTAXZzkp5xdt9t1J46zMjL6HNTu/8ZTjtr4k5lK6+7+pT7StOl/cWlbT/SGu1dcgZw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795596751;
	h=DMARC-Filter:Received:Received:Received:Received:Date:From:To:Cc:
	 Subject:Message-ID:References:MIME-Version:Content-Type:
	 Content-Disposition:In-Reply-To:X-Rspamd-Pre-Result:X-Rspamd-Server:
	 X-Spamd-Result:X-Spam-Flag:X-Spam-Score:X-Spam-Level:
	 X-Rspamd-Queue-Id:X-Rspamd-Pre-Result:X-Rspamd-Action;
	bh=p9vbL0ysv91ckHuds7ouuXNkYWInSQU+tytOp4PqZGg=;
	b=wrHSNT/NDji8jUc2xswpvtMnC699RckMj5Q83LS+XmTcW82oVVmRKJRJx6SML6RdwwsB
	 P9YMIH2N1vdzNrVLBiLZvtLunomhsO0eqLQ9eqXEG9ET5cnHzn1alc9IDnmukTo2JL/1O
	 LpYQYnPfrQyPNUNeo4ex2kr9T5egPj0mtrOH0ZQ2d6Ll8DFV12SFp6bPT0+62vbaAjA5O
	 uCz9SIGkJjw/MyEnIT3Fm5cVO63t6iqGhj9h6t9RRzBu4K3F4N5+noJPtVuOqJDLs/7t/
	 shh7UWbWfH7J3OOAmVYZcQs1gHIoLE8pPTD7E0/TXAS3pj+7dp+ehsY1nYUJ4BuPhWw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=suse.cz;
	spf=pass smtp.mailfrom=suse.cz;
	arc=none smtp.remote-ip=195.135.223.131
Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A8CCA606A323;
	Wed, 25 Nov 2026 08:52:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org A8CCA606A323
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id D09491F456;
	Wed, 25 Nov 2026 08:52:28 +0000 (UTC)
Authentication-Results: smtp-out2.suse.de;
	none
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id A6C51134CA;
	Wed, 25 Nov 2026 08:52:28 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id 88BVIMyhBmubAwAAD6G6ig
	(envelope-from <jack@suse.cz>); Wed, 25 Nov 2026 08:52:28 +0000
Received: by quack.suse.cz (Postfix, from userid 1000)
	id 36C7D27BC4; Wed, 25 Nov 2026 09:52:24 +0100 (CET)
Date: Wed, 25 Nov 2026 09:52:24 +0100
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
Subject: Re: [PATCH RFC 5/5] mm/filemap: refuse releasing maybe_dma_pinned
 folios
Message-ID: <ioqon6b2fg3ycdxztdfgxc6x2dkc4f6ysep6bpornycbkrj7ax@5rlqupekoyl2>
References: <20261119-gup-dirty-what-v1-0-236d69f25c24@suse.de>
 <20261119-gup-dirty-what-v1-5-236d69f25c24@suse.de>
 <fsmnfotflgrddrlak24cve7vkcjkellsgb3xbei5ysxvmqnul6@byvxblm4dtqm>
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
In-Reply-To: <fsmnfotflgrddrlak24cve7vkcjkellsgb3xbei5ysxvmqnul6@byvxblm4dtqm>
X-Rspamd-Pre-Result: action=no action;
	module=replies;
	Message is reply to one we originated
X-Rspamd-Server: rspamd1.dmz-prg2.suse.org
X-Spamd-Result: default: False [-4.00 / 50.00];
	REPLY(-4.00)[]
X-Spam-Flag: NO
X-Spam-Score: -4.00
X-Spam-Level: 
X-Rspamd-Queue-Id: D09491F456
X-Rspamd-Pre-Result: action=no action;
	module=replies;
	Message is reply to one we originated
X-Rspamd-Action: no action

On Wed 25-11-26 09:47:39, Jan Kara wrote:
> On Thu 19-11-26 20:10:48, Pedro Falcato wrote:
> > Some callers, like folio_unmap_invalidate(), call filemap_release_folio()
> > without any care for folio refcounts. This is on purpose. As
> > folio_unmap_invalidate() states, invalidate_inode_pages2() needs stronger
> > guarantees, and "can't afford to leave folios behind because
> > shrink_folio_list() has a temp ref on them". Ok.
> > 
> > Use folio_maybe_dma_pinned() universally, in filemap_release_folio(). This
> > has a much lower false positive rate, and should be ok enough for most
> > serious cases.
> > 
> > While here, properly assert that no folio passed to release_folio is
> > mapped.
> > 
> > Cc: stable@vger.kernel.org
> > Fixes: d824ec2a1546 ("mm: do not reclaim private data from pinned page")
> > Signed-off-by: Pedro Falcato <pfalcato@suse.de>
> 
> Looks good to me. Feel free to add:
> 
> Reviewed-by: Jan Kara <jack@suse.cz>
> 
> and we'll see whether there's some path which actually required private
> data on pinned page to be freed in some cornercase :)

Oh, now I can see Sashiko already found some :).

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
