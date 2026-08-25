Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1E8C33B6C18;
	Wed, 26 Aug 2026 07:50:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.130
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787730618; cv=none; b=Bfxc1hkgUiKKiyQ8UoUtBd/3knLWf93DOAeSJ0wpPRM5VU11qr1UB+6fGuYw+75Sdg1t6uXRPzPiXZ5YaJDKPYsq1vavmA8Af359ISIcgvLt+JX6eDq+go5+SmpqrXqL3/HlmmPmP34EvM3KlSeY5uaaBvLL7Q4H2AMrDCqwSMU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787730618; c=relaxed/simple;
	bh=a2btTeaHPqaWUx1hv3tFSSuWg92+seYqUJqRI+0fmNw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=HCCxaxDgcwGRwL9F8TKiogW35KZgtnoLfPhl81B/JE3UJDjV90ZPFsa4SeXaIU18Vx1+J3d/GEXFLvo/1d4y5VrPSyYA5wRYCLPQzCXkNWHTWT3QyRZsNRvLtgQyVZ3WlAH2UcRMr07tzOhUyFJ0sd6toeLQ53yD3MDGepBIOKo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz; spf=pass smtp.mailfrom=suse.cz; dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b=2Z1Tf/yp; dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b=658bYWki; dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b=1JuUKAco; dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b=vA5oIE6L; arc=none smtp.client-ip=195.135.223.130
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b="2Z1Tf/yp";
	dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b="658bYWki";
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b="1JuUKAco";
	dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b="vA5oIE6L"
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id E8ADB87217;
	Wed, 26 Aug 2026 07:50:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1787730610; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=V/kDgiqCJ24UzYKi/b0vTHiHEoPucZGyvIT9cCOxpb0=;
	b=2Z1Tf/ypjBvVk+yBoniYR6BcmnlXWvIf6tUvzYS1LY5lHf1JhccViu7h5BgvZjiNltUVr3
	kVZDko2QEGnhBIRhDzJcJpdy47Nq1ot2zMLC5+HKo0abzmfnSiXYCYb2wS4daIZJwz6ku+
	mXaAvocjnmEJfLIojQHOnYh4tlzafKs=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1787730610;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=V/kDgiqCJ24UzYKi/b0vTHiHEoPucZGyvIT9cCOxpb0=;
	b=658bYWki4AUwyhAOT31qDuMyPna1QbJfz6FjGWQiHbcaSyiSXtc7eETidr9tnt+NHkWzNX
	zMcpKPXEliEmCtDw==
Authentication-Results: smtp-out1.suse.de;
	dkim=pass header.d=suse.cz header.s=susede2_rsa header.b=1JuUKAco;
	dkim=pass header.d=suse.cz header.s=susede2_ed25519 header.b=vA5oIE6L
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1787730605; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=V/kDgiqCJ24UzYKi/b0vTHiHEoPucZGyvIT9cCOxpb0=;
	b=1JuUKAcodENvSgJev1mTdBqYGVNqOhIPDnDRUFHDNNfI+UKF5Hbx66lEdWsfh1WYPiRDz5
	NdPE4LAktNCQQPyuvR2Cmrbi0lThRccYF7sWAKSpyCYBW2xbtXUPAndVOZ3cFa9a9T+XQJ
	5SCdZ6uIdEikprCWzSb1uJ1VjbVSklY=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1787730605;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=V/kDgiqCJ24UzYKi/b0vTHiHEoPucZGyvIT9cCOxpb0=;
	b=vA5oIE6Lxvhb0G4M580CVZeOvk+ZaLTuwbG6zEdGNN79MxFpOzhk69zb4Q8Fq/lk5kzWsE
	NOc2dZCq8DTfn2CQ==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id D787713699;
	Wed, 26 Aug 2026 07:49:55 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id APOYNKOajmodDAAAD6G6ig
	(envelope-from <jack@suse.cz>); Wed, 26 Aug 2026 07:49:55 +0000
Received: by quack3.suse.cz (Postfix, from userid 1000)
	id 1DB57A13A3; Tue, 25 Aug 2026 17:50:17 +0200 (CEST)
Date: Tue, 25 Aug 2026 17:50:17 +0200
From: Jan Kara <jack@suse.cz>
To: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Cc: Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>, 
	Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.com>, 
	Miklos Szeredi <miklos@szeredi.hu>, Trond Myklebust <trondmy@kernel.org>, 
	Anna Schumaker <anna@kernel.org>, Mike Marshall <hubcap@omnibond.com>, 
	Martin Brandenburg <martin@omnibond.com>, Alexander Viro <viro@zeniv.linux.org.uk>, 
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, 
	linux-btrfs@vger.kernel.org, fuse-devel@lists.linux.dev, linux-nfs@vger.kernel.org, 
	devel@lists.orangefs.org, Pavel Begunkov <asml.silence@gmail.com>
Subject: Re: [PATCH 0/7] Remove aops->launder_folio
Message-ID: <cpxzyq5vdzuwters6mn3irrxvpvvkr6g7cjqbrsckivrupbua3@pzjpyvzqnke4>
References: <20260820193343.3852967-1-willy@infradead.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260820193343.3852967-1-willy@infradead.org>
X-Spamd-Result: default: False [-2.51 / 50.00];
	BAYES_HAM(-3.00)[100.00%];
	SUSPICIOUS_RECIPS(1.50)[];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_RHS_NOT_FQDN(0.50)[];
	R_DKIM_ALLOW(-0.20)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	MX_GOOD(-0.01)[];
	RCVD_COUNT_THREE(0.00)[3];
	RCPT_COUNT_TWELVE(0.00)[19];
	ARC_NA(0.00)[];
	MIME_TRACE(0.00)[0:+];
	SPAMHAUS_XBL(0.00)[2a07:de40:b281:104:10:150:64:97:from];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	RCVD_TLS_LAST(0.00)[];
	FREEMAIL_ENVRCPT(0.00)[gmail.com];
	TO_DN_SOME(0.00)[];
	DNSWL_BLOCKED(0.00)[2a07:de40:b281:104:10:150:64:97:from,2a07:de40:b281:106:10:150:64:167:received];
	FROM_EQ_ENVFROM(0.00)[];
	FROM_HAS_DN(0.00)[];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	TAGGED_RCPT(0.00)[];
	MISSING_XM_UA(0.00)[];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	FREEMAIL_CC(0.00)[kernel.org,suse.cz,fb.com,suse.com,szeredi.hu,omnibond.com,zeniv.linux.org.uk,vger.kernel.org,kvack.org,lists.linux.dev,lists.orangefs.org,gmail.com];
	DKIM_TRACE(0.00)[suse.cz:+];
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.cz:dkim,imap1.dmz-prg2.suse.org:rdns,imap1.dmz-prg2.suse.org:helo,suse.com:email]
X-Spam-Flag: NO
X-Spam-Score: -2.51
X-Spam-Level: 
X-Rspamd-Queue-Id: E8ADB87217
X-Rspamd-Server: rspamd2.dmz-prg2.suse.org
X-Rspamd-Action: no action

On Thu 20-08-26 20:33:33, Matthew Wilcox (Oracle) wrote:
> There's really no reason to implement ->launder_folio.  Most filesystems
> don't.  The only problem is that some filesystems rely on dirty folios
> being written back this way, so we need to make sure that folios are
> written back before invalidating them.  filemap_invalidate_pages()
> works well for that, once we remove the 'nowait' parameter.

I like the idea (and was myself wondering from time to time whether
launder_folio is actually needed) but what was putting me off was that when
using folio_launder() you can clean a folio while keeping folio locked and
so you can guarantee later eviction without someone messing with the folio
between writeout & ->release_folio. Maybe nobody actually needs this, which
would be great, but it would be great to hear more from the folks using
launder_folio about their reasons...

								Honza

> 
> Matthew Wilcox (Oracle) (7):
>   filemap: Export filemap_invalidate_pages() to modules
>   fuse: Use filemap_invalidate_pages()
>   btrfs: Use filemap_invalidate_pages()
>   nfs: Use filemap_invalidate_pages()
>   orangefs: Use filemap_invalidate_pages()
>   orangefs: Remove launder_folio implementation
>   Remove folio_launder()
> 
>  Documentation/filesystems/locking.rst |  8 -----
>  Documentation/filesystems/vfs.rst     |  6 ----
>  block/ioctl.c                         | 14 +++++---
>  fs/btrfs/direct-io.c                  |  2 +-
>  fs/btrfs/disk-io.c                    | 11 ++++---
>  fs/btrfs/free-space-cache.c           |  4 +--
>  fs/btrfs/inode.c                      | 12 ++-----
>  fs/btrfs/volumes.c                    |  4 +--
>  fs/fuse/dax.c                         | 15 ++-------
>  fs/fuse/dir.c                         | 12 ++++---
>  fs/fuse/file.c                        | 46 ++++-----------------------
>  fs/fuse/inode.c                       | 17 +++-------
>  fs/nfs/dir.c                          |  7 ++--
>  fs/nfs/direct.c                       |  5 ++-
>  fs/nfs/file.c                         | 24 --------------
>  fs/nfs/inode.c                        |  5 +--
>  fs/nfs/nfs42proc.c                    |  3 +-
>  fs/nfs/nfstrace.h                     |  1 -
>  fs/orangefs/file.c                    |  4 +--
>  fs/orangefs/inode.c                   |  1 -
>  include/linux/fs.h                    |  1 -
>  include/linux/pagemap.h               |  2 +-
>  mm/filemap.c                          | 42 ++++++++++++++++--------
>  mm/truncate.c                         | 15 ++-------
>  24 files changed, 87 insertions(+), 174 deletions(-)
> 
> -- 
> 2.47.3
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
