Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=213.95.11.211
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793702798;
	b=3veoQrr4jQ0kXYe5q4ImtTnDqJHpeUErR9O2iqt5K/bZi6zX5ohZuEpc9Z6lrJrgp8g0
	 Nrr8pODiIhRplCwh3NvSy4WVueBNO+rPyUJI3kJ2mnDVsUC/f/lbGVFNrCdMQPLqqzwcU
	 f4I8kMUlGrNmqTB4ynD+hyq8SCParsoLQz9ntsqeUj9OcCBIK9gnl+nWS1t9Av5qVC/PR
	 p9j6G1Vlq2yd4aasO+u01r9Bg5F5quYXXC7tRFDat7PZyf1PRiaK4vCm7oBbNdPRjdm6T
	 wmfovQkGjADTMq42t7Uq16WdjjpoOEQeBZJIwaZgcIxPU6CAoBsVS3OD7vOuO2Meywg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793702798;
	h=DMARC-Filter:Received:Date:From:To:Cc:Subject:Message-ID:References:
	 MIME-Version:Content-Type:Content-Disposition:In-Reply-To:User-Agent;
	bh=LdIXNf/kbOEd603rTDv8mLco3g5Owvy0jg0HM9Q6Xrs=;
	b=xRNnuR8UPeIy9spGNy/deSp29I3YMmFOc0SLIXWBeiSDI+h4IJRtkeRWq1cWXslTHGfC
	 tyZ+BsRj1XM6+kgz7P0652CX/wvNN9Tu+oNNblk/SQ7Kkl7Ce3w1b7X3tOQIR9pHArYX0
	 LVP+DOX2GNa8vYcdkg7tjq4yddrpYu/sGRasplUqwwzo07ALmTRWZyRLWgi3guaKk3LiV
	 Bo2W7umf5b20v2Vpa42J639n1qRYDy7v6YwFDWwA1okr+IHF+LKof0FU+ZUgqOqeAbuIU
	 Rw1MjMZDwDpjJ/q0y0RFh91b36NJga4LvJXkr50Zxb3v1CrhTWmsMczMmGqihBxw2PA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=lst.de;
	spf=pass smtp.mailfrom=lst.de;
	arc=none smtp.remote-ip=213.95.11.211
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 45F206072C8E;
	Tue,  3 Nov 2026 10:46:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 45F206072C8E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id AA59A68B05; Tue,  3 Nov 2026 11:46:29 +0100 (CET)
Date: Tue, 3 Nov 2026 11:46:29 +0100
From: Christoph Hellwig <hch@lst.de>
To: Mike Snitzer <snitzer@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org, Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>,
	Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH v9 1/6] mm: take a folio off WB_DONTCACHE_DIRTY only if
 it was counted there
Message-ID: <20261103104629.GA7296@lst.de>
References: <20261024221152.6965-1-snitzer@kernel.org> <20261024221152.6965-2-snitzer@kernel.org>
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
In-Reply-To: <20261024221152.6965-2-snitzer@kernel.org>
User-Agent: Mutt/1.5.17 (2007-11-01)

Please write a concise commit log.  This is a long meandering thought
of eletronic dreams making no sense.

> +/*
> + * Clear the uncached flag of a folio a cached lookup found, and take the
> + * folio off WB_DONTCACHE_DIRTY if it is counted there.
> + *
> + * folio_account_dirtied() counts a dropbehind folio under the i_pages lock,
> + * in the section that sets its dirty tag, after PG_dirty has been set
> + * without the folio lock.  Every path that uncounts a dirty folio holds the
> + * folio lock.  So with the folio locked and the i_pages lock held, the folio
> + * is counted when both PG_dirty and the dirty tag are set.  PG_dirty alone
> + * is not enough: a dirtier past folio_test_set_dirty() but not yet counting
> + * finds the flag clear and does not count the folio.  The tag alone is not
> + * enough either: __folio_cancel_dirty() uncounts a folio and clears
> + * PG_dirty, but leaves the tag until writeback or truncation clears it.  A
> + * folio another task has locked keeps the flag, as it would have had this
> + * lookup not run.
> + */

And this comment isn't much better.

> -	if (!(fgp_flags & FGP_DONTCACHE) && folio_test_clear_dropbehind(folio)) {
> -		if (folio_test_dirty(folio) &&
> -		    mapping_can_writeback(mapping)) {
> -			struct inode *inode = mapping->host;
> -			struct bdi_writeback *wb;
> -			struct wb_lock_cookie cookie = {};
> -			long nr = folio_nr_pages(folio);
> -
> -			wb = unlocked_inode_to_wb_begin(inode, &cookie);
> -			wb_stat_mod(wb, WB_DONTCACHE_DIRTY, -nr);
> -			unlocked_inode_to_wb_end(inode, &cookie);
> -		}
> -	}
> +	if (!(fgp_flags & FGP_DONTCACHE) && folio_test_dropbehind(folio))
> +		filemap_clear_dropbehind(mapping, folio, fgp_flags & FGP_LOCK);

Please don't mix code moves and non-trivial behavior changes.

Add a prep patch moving the code, and only then modify it.

