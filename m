Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792710960;
	b=gtiKZ8Mxvn7kfcEX327nSAPIG5V/+IRS4ep3RnKYpuRmt32CC/+oH7Km8o7sg3bLv076
	 /AFPxU4Ut2HpAUg8QDiq0J4j3hil2Ko5I8laGH3hoV+R2ls9jjfxNPIGUaEMwBzfUyQAX
	 2kRKRwZmQyNA/f/kKQDP2URyeul9HjM9WND5JuS8LofHGUViSY/8/yj6H32JrHDXKk4wG
	 6muvIe2BZM1Vf4qwQ/t7V3UHv/UMPw8lLhaSURmjgst5f9paJZ6G40Vc7ZyIchQw6/8Z2
	 014g5H4HJ48heWgE8dxbokee+GpdPZCK+g5PqBCJWyemdU1n3ru9C/qgpw+SlZ6l7ZQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792710960;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=EBg17K/M2nYjg0CJ2VB8RcMiLnQd34uRF9TAFezMHP8=;
	b=4szkeBp9Pu09y7bb7+fB48jwc5OBcbFoLrKFcFgPYEQgadd4RFVyIp1A9j29O+Thql9h
	 ubjwj4yjOACccHEIP6Z8B2SRp/DmbX3bGLUnN8xKRUcFopK8mlAMOpR8JgqvcD66laWIO
	 /M+IcYu257x/zwiQTfsliQJmiSHwpXDzPng8WDz2rQuPfKV2Nj+8r/i40xSBbbPuEZ9oz
	 SAoNKHWCjkBpFxbqCGHQ6bmVCeMBSsik5O4Gl8W5hRpXf2cNqvOzbd7TEst5XuGrJ3RVo
	 i7wCDaQkeqx4+1um7ms8MH7dMBjM53D2B4NvxADb/ArHBf6E7xtX2Z2e8aX+a0NMsAw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gVhlZskd;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5FB0F606A31E;
	Thu, 22 Oct 2026 23:16:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gVhlZskd
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9EBB81F01825;
	Thu, 22 Oct 2026 23:15:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792710959;
	bh=EBg17K/M2nYjg0CJ2VB8RcMiLnQd34uRF9TAFezMHP8=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=gVhlZskdTjjRGcb1sPLj5Vhn+WjGwji3C+5JBi46aBSw++60J4o+IrdTWTd/k0crC
	 1GCz+CzKZGtls6nwJ9Q0xU3uiOWZpJx8nfJjKY81yvnzDXsRUFbEdo4kaG7XziAG1A
	 M/0x6gHH63L9JaLKj8X643ZcDLNaHJjmqDApvDrgI5RC+xDowbhcmlcBe7DoJj1xLB
	 wj43MwjCYJNt+jOiqPjWBlVzEfQIWKbmhEMCJxrSbqUINUi+PXYC3SYCRIpPkYc3HR
	 b7LIMG0vBU6zF6jhCEWOmiYv4dMx5winYRDr7X/ZMUW4p21zDlNCkBJM06h6GBd9dD
	 W6YIoYbC9Gheg==
Date: Thu, 22 Oct 2026 19:15:58 -0400
From: Mike Snitzer <snitzer@kernel.org>
To: Jeff Layton <jlayton@kernel.org>
Cc: Mike Snitzer <snitzer@hammerspace.com>, Chuck Lever <cel@kernel.org>,
	linux-nfs@vger.kernel.org, NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>,
	Matthew Wilcox <willy@infradead.org>,
	Jonathan Corbet <corbet@lwn.net>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v7 2/5] mm: add folio_mark_dropbehind() to mark a folio
 dropbehind and account it
Message-ID: <atqZLryFXwjiUboe@kernel.org>
References: <20261020220346.28020-1-snitzer@kernel.org>
 <20261020220346.28020-3-snitzer@kernel.org>
 <8b666ab283f58e5913b3e4c33c52742a1153e9bd.camel@kernel.org>
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
In-Reply-To: <8b666ab283f58e5913b3e4c33c52742a1153e9bd.camel@kernel.org>

On Wed, Oct 21, 2026 at 06:52:59AM -0400, Jeff Layton wrote:
> 
> Chuck's sashiko had a comment on this one:
> 
> [Severity: Medium]
> Could this overcount WB_DONTCACHE_DIRTY if folio_mark_dropbehind() races with
> filemap_dirty_folio() in mm/page-writeback.c? The dirtying path can set
> PG_dirty before folio_account_dirtied() checks PG_dropbehind, and it need not
> hold the folio lock. If folio_mark_dropbehind() sets PG_dropbehind after that
> dirty transition but before the accounting check, both paths increment the
> counter, while folio_account_cleaned() subtracts it only once. The later NFSD
> use of this helper retains the same interleaving. Could the flag update and
> dirty accounting be serialized so the counter is incremented only once?

Yes, it can double count.  Every path that takes a folio off
WB_DONTCACHE_DIRTY holds the folio lock, as folio_mark_dropbehind()'s
callers do, but folio_account_dirtied() adds under the i_pages lock
after filemap_dirty_folio() has set PG_dirty without it.  So
PG_dirty is the wrong test: it is set before the folio is counted.
Reaching it needs a dirtier that doesn't hold the folio lock, such as a
zap of a dirty pte in a shared file mapping or bio_set_pages_dirty()
after a direct read into one; the cost is a counter the DONTCACHE kick
reads too high, not data.

v8 will test what folio_account_dirtied() leaves behind instead: the
dirty tag, which __folio_mark_dirty() sets in the same i_pages section
that counts the folio.  With the folio locked nothing can clean it, so
the tag is set exactly when the folio has been counted, and taking the
i_pages lock around setting the flag and testing the tag orders it
against that section:

        xa_lock_irqsave(&mapping->i_pages, flags);
        folio_set_dropbehind(folio);
        if (xa_get_mark(&mapping->i_pages, folio->index, PAGECACHE_TAG_DIRTY))
                wb_stat_mod(inode_to_wb(mapping->host), WB_DONTCACHE_DIRTY,
                            folio_nr_pages(folio));
        xa_unlock_irqrestore(&mapping->i_pages, flags);

A dirtier past folio_test_set_dirty() but not yet in that section finds
the flag set and counts the folio itself.

The same interleaving undercounts in the clear path that 88d6f128d06d
("mm: track DONTCACHE dirty pages per bdi_writeback") added to
__filemap_get_folio_mpol(): it clears the flag and subtracts if
PG_dirty is set, which a dirtier that has set PG_dirty but not yet
counted the folio makes it do for a folio that was never added.  The
same change, clearing instead of setting, fixes that; I will send it
as its own fix for 88d6f128d06d, at the start of this series for v8.

Thanks,
Mike
