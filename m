Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9549A463B97;
	Wed,  2 Sep 2026 11:10:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.130
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788347449; cv=none; b=MU6zbMH1+uboHAn/v0Zn3Hy34Blzhfc/QCu/BjycTTDl5IlDvL2oM9GB5s8XAVeYKBdmQJTVtRHK3KghHgX17kv0IXZJQSpm1aC6wIyd9C8ELn3DROTYrwvR+ggcIfkae9G0e7SeXmunkUWn5DRrPMS0rsvOHaimC+4vQyLy3Tg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788347449; c=relaxed/simple;
	bh=7fgBuZLiNimVvrD80umRECR/8moutXANtquWFazfRuI=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=VbunE86OpCPfEu+lVRbF4oDlSoYf+Fz5x+AvSUat9wPHwlUus0HaEEhlZdMYg2JGodPzImtFCOTLsydfoVnw3mThXCN8qISsK+15R8wzLqyYA1xtjE1xXI/5unXSaGW3Ecfsf2eYxYLUhSho1hOeUYTj/Pf0jagufgz+Cu9UJjw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz; spf=pass smtp.mailfrom=suse.cz; dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b=g+I5jb3a; dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b=5f+kPJ/G; dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b=i4awXZwZ; dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b=2t8d14Fr; arc=none smtp.client-ip=195.135.223.130
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b="g+I5jb3a";
	dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b="5f+kPJ/G";
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b="i4awXZwZ";
	dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b="2t8d14Fr"
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id 926EF21B42;
	Wed,  2 Sep 2026 11:10:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1788347432; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=BITWzZNmeMDjm8k0eeXsWYV9IVxG5MPwzg3kkMKHdxQ=;
	b=g+I5jb3asJP+DKcimiRb8lMZ++xAI7e2WzajCxek4Z+naQuPfb2i9zf4BHDq3y15JYnD1f
	XaKdLVhStJe1q+eQ5OeU0m5V/KeBEMECj268oDP1ucvfy+ou4G0z+JfdR4fS9q0MvrVTq/
	Z56Zzzej/Q7g2n0BWYU2WJuvjrN0YiM=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1788347432;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=BITWzZNmeMDjm8k0eeXsWYV9IVxG5MPwzg3kkMKHdxQ=;
	b=5f+kPJ/GQDsaj2GCpHy4ZaJNjwGFHwHsHw1le0uJQISQShyVz6yOKrkx6j+Ws1glwGHb48
	g53IwnZ75eVvcNBA==
Authentication-Results: smtp-out1.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1788347428; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=BITWzZNmeMDjm8k0eeXsWYV9IVxG5MPwzg3kkMKHdxQ=;
	b=i4awXZwZDEbDUKl5PuZMLuv4fAG+zxQkSnvzxiBitiZMMBsf0g1cE8MpV4/h5lo3tnJlXQ
	piujfbimJHaAft5lg/W49LZ8XMj4hnQCy9a+22z2Oxmq39X/GkBMaiTj2O48BKNbvPG+YP
	xcFwWCUicCIDIFUhQ+fmFn92PXHbDJw=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1788347428;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=BITWzZNmeMDjm8k0eeXsWYV9IVxG5MPwzg3kkMKHdxQ=;
	b=2t8d14Frtqy5p5X0Qwz58MNM/6zuEg4VBi6uFTJX3734DPJBg7Fs3T6g4+sYLLGvl2ILAo
	Os2B7K3OBp4bp9CA==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 6E93713515;
	Wed,  2 Sep 2026 11:10:28 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id 82D2GiQEmGqBSQAAD6G6ig
	(envelope-from <jack@suse.cz>); Wed, 02 Sep 2026 11:10:28 +0000
Received: by quack3.suse.cz (Postfix, from userid 1000)
	id E0738A13B5; Wed, 02 Sep 2026 13:10:27 +0200 (CEST)
Date: Wed, 2 Sep 2026 13:10:27 +0200
From: Jan Kara <jack@suse.cz>
To: Shivank Garg <shivankg@amd.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, 
	David Hildenbrand <david@kernel.org>, Zi Yan <ziy@nvidia.com>, Matthew Brost <matthew.brost@intel.com>, 
	Joshua Hahn <joshua.hahnjy@gmail.com>, Rakie Kim <rakie.kim@sk.com>, Byungchul Park <byungchul@sk.com>, 
	Gregory Price <gourry@gourry.net>, Ying Huang <ying.huang@linux.alibaba.com>, 
	Alistair Popple <apopple@nvidia.com>, Vlastimil Babka <vbabka@kernel.org>, 
	Suren Baghdasaryan <surenb@google.com>, Michal Hocko <mhocko@suse.com>, 
	Brendan Jackman <brendan.jackman@linux.dev>, Johannes Weiner <hannes@cmpxchg.org>, SJ Park <sj@kernel.org>, 
	Jason Gunthorpe <jgg@ziepe.ca>, John Hubbard <jhubbard@nvidia.com>, Peter Xu <peterx@redhat.com>, 
	Miaohe Lin <linmiaohe@huawei.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>, 
	Oscar Salvador <osalvador@suse.de>, Kairui Song <kasong@tencent.com>, Qi Zheng <qi.zheng@linux.dev>, 
	Shakeel Butt <shakeel.butt@linux.dev>, Barry Song <baohua@kernel.org>, 
	Axel Rasmussen <axelrasmussen@google.com>, Yuanchu Xie <yuanchu@google.com>, Wei Xu <weixugc@google.com>, 
	Lorenzo Stoakes <ljs@kernel.org>, "Matthew Wilcox (Oracle)" <willy@infradead.org>, 
	Jan Kara <jack@suse.cz>, Jonathan Corbet <corbet@lwn.net>, 
	Shuah Khan <skhan@linuxfoundation.org>, Randy Dunlap <rdunlap@infradead.org>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Christian Brauner <brauner@kernel.org>, 
	Benjamin LaHaise <bcrl@kvack.org>, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.com>, 
	Muchun Song <muchun.song@linux.dev>, Dave Kleikamp <shaggy@kernel.org>, 
	Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
	Mike Rapoport <rppt@kernel.org>, Sean Christopherson <seanjc@google.com>, 
	Paolo Bonzini <pbonzini@redhat.com>, Bharata B Rao <bharata@amd.com>, 
	David Rientjes <rientjes@google.com>, Yiannis Nikolakopoulos <yiannis@zptcorp.com>, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org, damon@lists.linux.dev, linux-cxl@vger.kernel.org, 
	linux-fsdevel@vger.kernel.org, linux-doc@vger.kernel.org, linux-aio@kvack.org, 
	linux-btrfs@vger.kernel.org, jfs-discussion@lists.sourceforge.net, linux-nfs@vger.kernel.org, 
	kvm@vger.kernel.org
Subject: Re: [PATCH RFC 11/11] mm/migrate: pass migrate_control to
 migrate_folio()
Message-ID: <gz3vibrercrujs6oykvlsyrgwaslpzjgmegnouthmkjaswznzg@haaqpwmacdwc>
References: <20260902-migrate-refactor-shivank-v1-0-9dcca87669c4@amd.com>
 <20260902-migrate-refactor-shivank-v1-11-9dcca87669c4@amd.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260902-migrate-refactor-shivank-v1-11-9dcca87669c4@amd.com>
X-Spam-Level: 
X-Spam-Score: -2.30
X-Spam-Flag: NO
X-Spamd-Result: default: False [-2.30 / 50.00];
	BAYES_HAM(-3.00)[100.00%];
	SUSPICIOUS_RECIPS(1.50)[];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_RHS_NOT_FQDN(0.50)[];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	FREEMAIL_CC(0.00)[linux-foundation.org,kernel.org,nvidia.com,intel.com,gmail.com,sk.com,gourry.net,linux.alibaba.com,google.com,suse.com,linux.dev,cmpxchg.org,ziepe.ca,redhat.com,huawei.com,suse.de,tencent.com,infradead.org,suse.cz,lwn.net,linuxfoundation.org,zeniv.linux.org.uk,kvack.org,fb.com,amd.com,zptcorp.com,vger.kernel.org,lists.linux.dev,lists.sourceforge.net];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	MISSING_XM_UA(0.00)[];
	MIME_TRACE(0.00)[0:+];
	ARC_NA(0.00)[];
	TO_DN_SOME(0.00)[];
	TAGGED_RCPT(0.00)[];
	RCVD_COUNT_THREE(0.00)[3];
	RCPT_COUNT_GT_50(0.00)[62];
	FROM_HAS_DN(0.00)[];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	FROM_EQ_ENVFROM(0.00)[];
	RCVD_TLS_LAST(0.00)[];
	TO_MATCH_ENVRCPT_SOME(0.00)[];
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.cz:email,imap1.dmz-prg2.suse.org:helo,suse.com:email,amd.com:email]

On Wed 02-09-26 10:52:25, Shivank Garg wrote:
> The migration core now carries policy in struct migrate_control, but
> migrate_folio() and the address_space migrate_folio callback still receive
> only the migration mode. This prevents additional policy, such as
> copy-cache hints, from reaching folio-specific migration code.
> 
> Pass the control as const through migrate_folio(), the common migration
> helpers, and the address_space callback. Update all implementations and
> documentation accordingly. Existing callbacks continue to make their
> decisions from ctl->mode only, none changes behavior yet.
> 
> No functional change intended.
> 
> Signed-off-by: Shivank Garg <shivankg@amd.com>

The changes to FS interface look good to me. Feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  Documentation/filesystems/locking.rst |  2 +-
>  Documentation/filesystems/vfs.rst     |  7 +++--
>  fs/aio.c                              |  2 +-
>  fs/btrfs/disk-io.c                    |  5 ++--
>  fs/btrfs/inode.c                      |  6 ++---
>  fs/hugetlbfs/inode.c                  |  4 +--
>  fs/jfs/jfs_metapage.c                 | 14 +++++-----
>  fs/nfs/internal.h                     |  2 +-
>  fs/nfs/write.c                        |  8 +++---
>  include/linux/buffer_head.h           |  6 +++--
>  include/linux/fs.h                    |  6 ++---
>  include/linux/migrate.h               |  2 +-
>  include/linux/pagemap.h               |  2 +-
>  mm/migrate.c                          | 50 +++++++++++++++++++----------------
>  mm/secretmem.c                        |  3 ++-
>  virt/kvm/guest_memfd.c                |  2 +-
>  16 files changed, 66 insertions(+), 55 deletions(-)
> 
> diff --git a/Documentation/filesystems/locking.rst b/Documentation/filesystems/locking.rst
> index 844d65eb47a5..b406df403b4a 100644
> --- a/Documentation/filesystems/locking.rst
> +++ b/Documentation/filesystems/locking.rst
> @@ -260,7 +260,7 @@ prototypes::
>  	void (*free_folio)(struct folio *);
>  	int (*direct_IO)(struct kiocb *, struct iov_iter *iter);
>  	int (*migrate_folio)(struct address_space *, struct folio *dst,
> -			struct folio *src, enum migrate_mode);
> +			struct folio *src, const struct migrate_control *ctl);
>  	int (*launder_folio)(struct folio *);
>  	bool (*is_partially_uptodate)(struct folio *, size_t from, size_t count);
>  	int (*error_remove_folio)(struct address_space *, struct folio *);
> diff --git a/Documentation/filesystems/vfs.rst b/Documentation/filesystems/vfs.rst
> index d3a93eec3945..8e1404723db1 100644
> --- a/Documentation/filesystems/vfs.rst
> +++ b/Documentation/filesystems/vfs.rst
> @@ -767,7 +767,8 @@ cache in your filesystem.  The following members are defined:
>  		void (*free_folio)(struct folio *);
>  		ssize_t (*direct_IO)(struct kiocb *, struct iov_iter *iter);
>  		int (*migrate_folio)(struct mapping *, struct folio *dst,
> -				struct folio *src, enum migrate_mode);
> +				struct folio *src,
> +				const struct migrate_control *ctl);
>  		int (*launder_folio) (struct folio *);
>  
>  		bool (*is_partially_uptodate) (struct folio *, size_t from,
> @@ -939,7 +940,9 @@ cache in your filesystem.  The following members are defined:
>  	wants to relocate a folio (maybe from a memory device that is
>  	signalling imminent failure) it will pass a new folio and an old
>  	folio to this function.  migrate_folio should transfer any private
> -	data across and update any references that it has to the folio.
> +	data across and update any references that it has to the folio.  The
> +	control describes the blocking mode and the reason for migration.  If
> +	the mode is ``MIGRATE_ASYNC``, the callback must not block.
>  
>  ``launder_folio``
>  	Called before freeing a folio - it writes back the dirty folio.
> diff --git a/fs/aio.c b/fs/aio.c
> index d78acc69f487..58ee9d0845dd 100644
> --- a/fs/aio.c
> +++ b/fs/aio.c
> @@ -458,7 +458,7 @@ static const struct file_operations aio_ring_fops = {
>  
>  #if IS_ENABLED(CONFIG_MIGRATION)
>  static int aio_migrate_folio(struct address_space *mapping, struct folio *dst,
> -			struct folio *src, enum migrate_mode mode)
> +			     struct folio *src, const struct migrate_control *ctl)
>  {
>  	struct kioctx *ctx;
>  	struct aio_inode_info *ai = AIO_I(mapping->host);
> diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
> index 819727460bcf..509651577a1c 100644
> --- a/fs/btrfs/disk-io.c
> +++ b/fs/btrfs/disk-io.c
> @@ -460,7 +460,8 @@ int btrfs_validate_extent_buffer(struct extent_buffer *eb,
>  
>  #ifdef CONFIG_MIGRATION
>  static int btree_migrate_folio(struct address_space *mapping,
> -		struct folio *dst, struct folio *src, enum migrate_mode mode)
> +		struct folio *dst, struct folio *src,
> +		const struct migrate_control *ctl)
>  {
>  	/*
>  	 * we can't safely write a btree page from here,
> @@ -475,7 +476,7 @@ static int btree_migrate_folio(struct address_space *mapping,
>  	if (folio_get_private(src) &&
>  	    !filemap_release_folio(src, GFP_KERNEL))
>  		return -EAGAIN;
> -	return migrate_folio(mapping, dst, src, mode);
> +	return migrate_folio(mapping, dst, src, ctl);
>  }
>  #else
>  #define btree_migrate_folio NULL
> diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
> index 3c10a0ef0002..9f1e567fa5ed 100644
> --- a/fs/btrfs/inode.c
> +++ b/fs/btrfs/inode.c
> @@ -7653,10 +7653,10 @@ static bool btrfs_release_folio(struct folio *folio, gfp_t gfp_flags)
>  
>  #ifdef CONFIG_MIGRATION
>  static int btrfs_migrate_folio(struct address_space *mapping,
> -			     struct folio *dst, struct folio *src,
> -			     enum migrate_mode mode)
> +			       struct folio *dst, struct folio *src,
> +			       const struct migrate_control *ctl)
>  {
> -	int ret = filemap_migrate_folio(mapping, dst, src, mode);
> +	int ret = filemap_migrate_folio(mapping, dst, src, ctl);
>  
>  	if (ret)
>  		return ret;
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index 7611a8470ea2..367148251689 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -1022,8 +1022,8 @@ static int hugetlbfs_symlink(struct mnt_idmap *idmap,
>  
>  #ifdef CONFIG_MIGRATION
>  static int hugetlbfs_migrate_folio(struct address_space *mapping,
> -				struct folio *dst, struct folio *src,
> -				enum migrate_mode mode)
> +				   struct folio *dst, struct folio *src,
> +				   const struct migrate_control *ctl)
>  {
>  	int rc;
>  
> diff --git a/fs/jfs/jfs_metapage.c b/fs/jfs/jfs_metapage.c
> index 41fe12e641ce..7958edacb497 100644
> --- a/fs/jfs/jfs_metapage.c
> +++ b/fs/jfs/jfs_metapage.c
> @@ -155,7 +155,7 @@ static inline void dec_io(struct folio *folio, blk_status_t status,
>  #ifdef CONFIG_MIGRATION
>  static int __metapage_migrate_folio(struct address_space *mapping,
>  				    struct folio *dst, struct folio *src,
> -				    enum migrate_mode mode)
> +				    const struct migrate_control *ctl)
>  {
>  	struct meta_anchor *src_anchor = src->private;
>  	struct metapage *mps[MPS_PER_PAGE] = {0};
> @@ -168,7 +168,7 @@ static int __metapage_migrate_folio(struct address_space *mapping,
>  			return -EAGAIN;
>  	}
>  
> -	rc = filemap_migrate_folio(mapping, dst, src, mode);
> +	rc = filemap_migrate_folio(mapping, dst, src, ctl);
>  	if (rc)
>  		return rc;
>  
> @@ -231,7 +231,7 @@ static inline void remove_metapage(struct folio *folio, struct metapage *mp)
>  #ifdef CONFIG_MIGRATION
>  static int __metapage_migrate_folio(struct address_space *mapping,
>  				    struct folio *dst, struct folio *src,
> -				    enum migrate_mode mode)
> +				    const struct migrate_control *ctl)
>  {
>  	struct metapage *mp;
>  	int page_offset;
> @@ -241,7 +241,7 @@ static int __metapage_migrate_folio(struct address_space *mapping,
>  	if (metapage_locked(mp))
>  		return -EAGAIN;
>  
> -	rc = filemap_migrate_folio(mapping, dst, src, mode);
> +	rc = filemap_migrate_folio(mapping, dst, src, ctl);
>  	if (rc)
>  		return rc;
>  
> @@ -645,18 +645,18 @@ static bool metapage_release_folio(struct folio *folio, gfp_t gfp_mask)
>   */
>  static int metapage_migrate_folio(struct address_space *mapping,
>  				  struct folio *dst, struct folio *src,
> -				  enum migrate_mode mode)
> +				  const struct migrate_control *ctl)
>  {
>  	int expected_count;
>  
>  	if (!src->private)
> -		return filemap_migrate_folio(mapping, dst, src, mode);
> +		return filemap_migrate_folio(mapping, dst, src, ctl);
>  
>  	/* Check whether page does not have extra refs before we do more work */
>  	expected_count = folio_expected_ref_count(src) + 1;
>  	if (folio_ref_count(src) != expected_count)
>  		return -EAGAIN;
> -	return __metapage_migrate_folio(mapping, dst, src, mode);
> +	return __metapage_migrate_folio(mapping, dst, src, ctl);
>  }
>  #else
>  #define metapage_migrate_folio NULL
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index abc81f5ae578..e1f366cff2c0 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -673,7 +673,7 @@ void nfs_clear_pnfs_ds_commit_verifiers(struct pnfs_ds_commit_info *cinfo)
>  
>  #ifdef CONFIG_MIGRATION
>  int nfs_migrate_folio(struct address_space *, struct folio *dst,
> -		struct folio *src, enum migrate_mode);
> +		struct folio *src, const struct migrate_control *);
>  #else
>  #define nfs_migrate_folio NULL
>  #endif
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 623e7ef1f73d..159135900399 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -2112,7 +2112,7 @@ int nfs_wb_folio(struct inode *inode, struct folio *folio)
>  
>  #ifdef CONFIG_MIGRATION
>  int nfs_migrate_folio(struct address_space *mapping, struct folio *dst,
> -		struct folio *src, enum migrate_mode mode)
> +		struct folio *src, const struct migrate_control *ctl)
>  {
>  	/*
>  	 * If the private flag is set, the folio is currently associated with
> @@ -2123,19 +2123,19 @@ int nfs_migrate_folio(struct address_space *mapping, struct folio *dst,
>  	 *        the folio lock.
>  	 */
>  	if (folio_test_private(src)) {
> -		if (mode == MIGRATE_SYNC)
> +		if (ctl->mode == MIGRATE_SYNC)
>  			nfs_wb_folio(src->mapping->host, src);
>  		if (folio_test_private(src))
>  			return -EBUSY;
>  	}
>  
>  	if (folio_test_private_2(src)) { /* [DEPRECATED] */
> -		if (mode == MIGRATE_ASYNC)
> +		if (ctl->mode == MIGRATE_ASYNC)
>  			return -EBUSY;
>  		folio_wait_private_2(src);
>  	}
>  
> -	return migrate_folio(mapping, dst, src, mode);
> +	return migrate_folio(mapping, dst, src, ctl);
>  }
>  #endif
>  
> diff --git a/include/linux/buffer_head.h b/include/linux/buffer_head.h
> index fd2c7115c054..e4476596c9b6 100644
> --- a/include/linux/buffer_head.h
> +++ b/include/linux/buffer_head.h
> @@ -277,9 +277,11 @@ int block_truncate_page(struct address_space *, loff_t, get_block_t *);
>  
>  #ifdef CONFIG_MIGRATION
>  extern int buffer_migrate_folio(struct address_space *,
> -		struct folio *dst, struct folio *src, enum migrate_mode);
> +		struct folio *dst, struct folio *src,
> +		const struct migrate_control *);
>  extern int buffer_migrate_folio_norefs(struct address_space *,
> -		struct folio *dst, struct folio *src, enum migrate_mode);
> +		struct folio *dst, struct folio *src,
> +		const struct migrate_control *);
>  #else
>  #define buffer_migrate_folio NULL
>  #define buffer_migrate_folio_norefs NULL
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index f9d1e05e8ae6..93ba6054c478 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -423,11 +423,11 @@ struct address_space_operations {
>  	void (*free_folio)(struct folio *folio);
>  	ssize_t (*direct_IO)(struct kiocb *, struct iov_iter *iter);
>  	/*
> -	 * migrate the contents of a folio to the specified target. If
> -	 * migrate_mode is MIGRATE_ASYNC, it must not block.
> +	 * Migrate the contents of a folio to the specified target.  The
> +	 * callback must not block when ctl->mode is MIGRATE_ASYNC.
>  	 */
>  	int (*migrate_folio)(struct address_space *, struct folio *dst,
> -			struct folio *src, enum migrate_mode);
> +			struct folio *src, const struct migrate_control *ctl);
>  	int (*launder_folio)(struct folio *);
>  	bool (*is_partially_uptodate) (struct folio *, size_t from,
>  			size_t count);
> diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> index cec5713944e3..123111e7abd3 100644
> --- a/include/linux/migrate.h
> +++ b/include/linux/migrate.h
> @@ -55,7 +55,7 @@ extern const char *migrate_reason_names[MR_TYPES];
>  
>  void putback_movable_pages(struct list_head *l);
>  int migrate_folio(struct address_space *mapping, struct folio *dst,
> -		struct folio *src, enum migrate_mode mode);
> +		struct folio *src, const struct migrate_control *ctl);
>  int migrate_pages(struct list_head *l, new_folio_t new, free_folio_t free,
>  		unsigned long private, const struct migrate_control *ctl,
>  		unsigned int *ret_succeeded);
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index 0adfa6605653..455d57307f88 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -1327,7 +1327,7 @@ bool noop_dirty_folio(struct address_space *mapping, struct folio *folio);
>  
>  #ifdef CONFIG_MIGRATION
>  int filemap_migrate_folio(struct address_space *mapping, struct folio *dst,
> -		struct folio *src, enum migrate_mode mode);
> +		struct folio *src, const struct migrate_control *ctl);
>  #else
>  #define filemap_migrate_folio NULL
>  #endif
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 549f8b57092c..731836664a86 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -869,7 +869,7 @@ EXPORT_SYMBOL(folio_migrate_flags);
>  
>  static int __migrate_folio(struct address_space *mapping, struct folio *dst,
>  			   struct folio *src, void *src_private,
> -			   enum migrate_mode mode)
> +			   const struct migrate_control *ctl)
>  {
>  	int rc, expected_count = folio_expected_ref_count(src) + 1;
>  
> @@ -897,7 +897,7 @@ static int __migrate_folio(struct address_space *mapping, struct folio *dst,
>   * @mapping: The address_space containing the folio.
>   * @dst: The folio to migrate the data to.
>   * @src: The folio containing the current data.
> - * @mode: How to migrate the folio.
> + * @ctl: Migration policy for this folio.
>   *
>   * Common logic to directly migrate a single LRU folio suitable for
>   * folios that do not have private data.
> @@ -905,10 +905,10 @@ static int __migrate_folio(struct address_space *mapping, struct folio *dst,
>   * Folios are locked upon entry and exit.
>   */
>  int migrate_folio(struct address_space *mapping, struct folio *dst,
> -		  struct folio *src, enum migrate_mode mode)
> +		  struct folio *src, const struct migrate_control *ctl)
>  {
>  	BUG_ON(folio_test_writeback(src));	/* Writeback must be complete */
> -	return __migrate_folio(mapping, dst, src, NULL, mode);
> +	return __migrate_folio(mapping, dst, src, NULL, ctl);
>  }
>  EXPORT_SYMBOL(migrate_folio);
>  
> @@ -947,8 +947,8 @@ static bool buffer_migrate_lock_buffers(struct buffer_head *head,
>  }
>  
>  static int __buffer_migrate_folio(struct address_space *mapping,
> -		struct folio *dst, struct folio *src, enum migrate_mode mode,
> -		bool check_refs)
> +		struct folio *dst, struct folio *src,
> +		const struct migrate_control *ctl, bool check_refs)
>  {
>  	struct buffer_head *bh, *head;
>  	int rc;
> @@ -956,14 +956,14 @@ static int __buffer_migrate_folio(struct address_space *mapping,
>  
>  	head = folio_buffers(src);
>  	if (!head)
> -		return migrate_folio(mapping, dst, src, mode);
> +		return migrate_folio(mapping, dst, src, ctl);
>  
>  	/* Check whether page does not have extra refs before we do more work */
>  	expected_count = folio_expected_ref_count(src) + 1;
>  	if (folio_ref_count(src) != expected_count)
>  		return -EAGAIN;
>  
> -	if (!buffer_migrate_lock_buffers(head, mode))
> +	if (!buffer_migrate_lock_buffers(head, ctl->mode))
>  		return -EAGAIN;
>  
>  	if (check_refs) {
> @@ -995,7 +995,7 @@ static int __buffer_migrate_folio(struct address_space *mapping,
>  		}
>  	}
>  
> -	rc = filemap_migrate_folio(mapping, dst, src, mode);
> +	rc = filemap_migrate_folio(mapping, dst, src, ctl);
>  	if (rc)
>  		goto unlock_buffers;
>  
> @@ -1022,7 +1022,7 @@ static int __buffer_migrate_folio(struct address_space *mapping,
>   * @mapping: The address space containing @src.
>   * @dst: The folio to migrate to.
>   * @src: The folio to migrate from.
> - * @mode: How to migrate the folio.
> + * @ctl: Migration policy for this folio.
>   *
>   * This function can only be used if the underlying filesystem guarantees
>   * that no other references to @src exist. For example attached buffer
> @@ -1033,9 +1033,10 @@ static int __buffer_migrate_folio(struct address_space *mapping,
>   * Return: 0 on success or a negative errno on failure.
>   */
>  int buffer_migrate_folio(struct address_space *mapping,
> -		struct folio *dst, struct folio *src, enum migrate_mode mode)
> +		struct folio *dst, struct folio *src,
> +		const struct migrate_control *ctl)
>  {
> -	return __buffer_migrate_folio(mapping, dst, src, mode, false);
> +	return __buffer_migrate_folio(mapping, dst, src, ctl, false);
>  }
>  EXPORT_SYMBOL(buffer_migrate_folio);
>  
> @@ -1044,7 +1045,7 @@ EXPORT_SYMBOL(buffer_migrate_folio);
>   * @mapping: The address space containing @src.
>   * @dst: The folio to migrate to.
>   * @src: The folio to migrate from.
> - * @mode: How to migrate the folio.
> + * @ctl: Migration policy for this folio.
>   *
>   * Like buffer_migrate_folio() except that this variant is more careful
>   * and checks that there are also no buffer head references. This function
> @@ -1054,17 +1055,19 @@ EXPORT_SYMBOL(buffer_migrate_folio);
>   * Return: 0 on success or a negative errno on failure.
>   */
>  int buffer_migrate_folio_norefs(struct address_space *mapping,
> -		struct folio *dst, struct folio *src, enum migrate_mode mode)
> +		struct folio *dst, struct folio *src,
> +		const struct migrate_control *ctl)
>  {
> -	return __buffer_migrate_folio(mapping, dst, src, mode, true);
> +	return __buffer_migrate_folio(mapping, dst, src, ctl, true);
>  }
>  EXPORT_SYMBOL_GPL(buffer_migrate_folio_norefs);
>  #endif /* CONFIG_BUFFER_HEAD */
>  
>  int filemap_migrate_folio(struct address_space *mapping,
> -		struct folio *dst, struct folio *src, enum migrate_mode mode)
> +		struct folio *dst, struct folio *src,
> +		const struct migrate_control *ctl)
>  {
> -	return __migrate_folio(mapping, dst, src, folio_get_private(src), mode);
> +	return __migrate_folio(mapping, dst, src, folio_get_private(src), ctl);
>  }
>  EXPORT_SYMBOL_GPL(filemap_migrate_folio);
>  
> @@ -1072,7 +1075,8 @@ EXPORT_SYMBOL_GPL(filemap_migrate_folio);
>   * Default handling if a filesystem does not provide a migration function.
>   */
>  static int fallback_migrate_folio(struct address_space *mapping,
> -		struct folio *dst, struct folio *src, enum migrate_mode mode)
> +		struct folio *dst, struct folio *src,
> +		const struct migrate_control *ctl)
>  {
>  	WARN_ONCE(mapping->a_ops->writepages,
>  			"%ps does not implement migrate_folio\n",
> @@ -1085,9 +1089,9 @@ static int fallback_migrate_folio(struct address_space *mapping,
>  	 * can't migrate automatically.
>  	 */
>  	if (!filemap_release_folio(src, GFP_KERNEL))
> -		return mode == MIGRATE_SYNC ? -EAGAIN : -EBUSY;
> +		return ctl->mode == MIGRATE_SYNC ? -EAGAIN : -EBUSY;
>  
> -	return migrate_folio(mapping, dst, src, mode);
> +	return migrate_folio(mapping, dst, src, ctl);
>  }
>  
>  /*
> @@ -1112,7 +1116,7 @@ static int move_to_new_folio(struct folio *dst, struct folio *src,
>  	VM_BUG_ON_FOLIO(!folio_test_locked(dst), dst);
>  
>  	if (!mapping)
> -		rc = migrate_folio(mapping, dst, src, ctl->mode);
> +		rc = migrate_folio(mapping, dst, src, ctl);
>  	else if (mapping_inaccessible(mapping))
>  		rc = -EOPNOTSUPP;
>  	else if (mapping->a_ops->migrate_folio)
> @@ -1123,9 +1127,9 @@ static int move_to_new_folio(struct folio *dst, struct folio *src,
>  		 * migrate_folio callback. This is the most common path
>  		 * for page migration.
>  		 */
> -		rc = mapping->a_ops->migrate_folio(mapping, dst, src, ctl->mode);
> +		rc = mapping->a_ops->migrate_folio(mapping, dst, src, ctl);
>  	else
> -		rc = fallback_migrate_folio(mapping, dst, src, ctl->mode);
> +		rc = fallback_migrate_folio(mapping, dst, src, ctl);
>  
>  	if (!rc) {
>  		/*
> diff --git a/mm/secretmem.c b/mm/secretmem.c
> index d29865075b6e..5c81833981d2 100644
> --- a/mm/secretmem.c
> +++ b/mm/secretmem.c
> @@ -144,7 +144,8 @@ static const struct file_operations secretmem_fops = {
>  };
>  
>  static int secretmem_migrate_folio(struct address_space *mapping,
> -		struct folio *dst, struct folio *src, enum migrate_mode mode)
> +		struct folio *dst, struct folio *src,
> +		const struct migrate_control *ctl)
>  {
>  	return -EBUSY;
>  }
> diff --git a/virt/kvm/guest_memfd.c b/virt/kvm/guest_memfd.c
> index 625e62e1a031..0a9af8c4768d 100644
> --- a/virt/kvm/guest_memfd.c
> +++ b/virt/kvm/guest_memfd.c
> @@ -457,7 +457,7 @@ static struct file_operations kvm_gmem_fops = {
>  
>  static int kvm_gmem_migrate_folio(struct address_space *mapping,
>  				  struct folio *dst, struct folio *src,
> -				  enum migrate_mode mode)
> +				  const struct migrate_control *ctl)
>  {
>  	WARN_ON_ONCE(1);
>  	return -EINVAL;
> 
> -- 
> 2.43.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
