Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6A1E93D6664;
	Thu,  4 Jun 2026 06:15:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780553711; cv=none; b=YwpXpRyac0zMKTITkcSG77j+ivcxA+XdcmJM6vh80QbElxM1ys/n/OL38V0JQNIphAyAYpIoCVFDrTm3kxyrRhb2/jMFghlVIHWqTOEv4dsxbF8I0TCBLVsRPzxkafNHF6dkq5XaiEo3dsVJ9UVC8Vz1w3icQmXrzvNislspcyM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780553711; c=relaxed/simple;
	bh=atVSAfHhDYBovprcHMCjWAChHvgsN9Zly/q2GkqZTdM=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=HsSXpO8srZ6x0paQBdomoVZac5qJ6y8fWyb9dHJTenYOQFkVehtDnMX04uyoKLwHGpT2uJJrwW3hzPQrhqDUbDALnitmkVsRlkUQ9BaRzSk8foi4mvbjn3oorBLKxDi0zuYB0BArUChRHx43RBAzMJPbdQ4NG6cB3SlU9PwucbQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=YZdzENTk; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="YZdzENTk"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EE6611F00893;
	Thu,  4 Jun 2026 06:15:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1780553709;
	bh=maKYg38a30VxIX8QCcSBujTuAdCuRyvh3rWBPMbaTa8=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=YZdzENTkOazs5XSTumSTfKjNe97Bx1gIjbWPEe0rEOYizlJ+PG3Skn0hS26Ux74Jl
	 AXCvUF5ahoFRq9So4PlOjS3IWyCIq5NTGNUoudm5MMRDdJhNBKN1LdgBDErw0LtVFd
	 jzKhcofKN8uPI1V71amXjFQlau+IKLTXzAiqIsn/g+sTxSoMC/LouWT+HEHb+idjuI
	 8F/5ZnoIZWEz4pT/Oim/JLh5w98h2ycR5nXmcdy58o4NERbYl1r+Hpa7rpblTquRvP
	 owmPxKztmOlhAuoaO/iNyxsWnpCrb8pm0xA6MdS2Qr/cnlFMvHA1Yq1Qntrgg1OIwG
	 JJVS4xnu2W56g==
Date: Thu, 4 Jun 2026 09:14:57 +0300
From: Mike Rapoport <rppt@kernel.org>
To: Theodore Tso <tytso@mit.edu>
Cc: Jan Kara <jack@suse.com>, Mark Fasheh <mark@fasheh.com>,
	Joel Becker <jlbec@evilplan.org>,
	Joseph Qi <joseph.qi@linux.alibaba.com>,
	Ryusuke Konishi <konishi.ryusuke@gmail.com>,
	Viacheslav Dubeyko <slava@dubeyko.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>,
	Dave Kleikamp <shaggy@kernel.org>,
	Miklos Szeredi <miklos@szeredi.hu>,
	Andreas Hindborg <a.hindborg@kernel.org>,
	Breno Leitao <leitao@debian.org>, Kees Cook <kees@kernel.org>,
	"Tigran A. Aivazian" <aivazian.tigran@gmail.com>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	ocfs2-devel@lists.linux.dev, linux-nilfs@vger.kernel.org,
	linux-nfs@vger.kernel.org, jfs-discussion@lists.sourceforge.net,
	linux-ext4@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 10/17] jbd2: replace __get_free_pages() with kmalloc()
Message-ID: <aiEX4UTxEnBTjVKo@kernel.org>
References: <20260523-b4-fs-v1-0-275e36a83f0e@kernel.org>
 <20260523-b4-fs-v1-10-275e36a83f0e@kernel.org>
 <yfzx3jgzwesernofl7mzixa2mhjfii5v3o7yapghtmozixrpfu@6bsh7iixyiov>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <yfzx3jgzwesernofl7mzixa2mhjfii5v3o7yapghtmozixrpfu@6bsh7iixyiov>

Hi Ted,

On Wed, Jun 03, 2026 at 09:50:15AM -0400, Theodore Tso wrote:
> On Sat, May 23, 2026 at 08:54:22PM +0300, Mike Rapoport (Microsoft) wrote:
> > jbd2_alloc() falls back from kmem_cache_alloc() to __get_free_pages() for
> > allocations larger than PAGE_SIZE.
> > But kmalloc() can handle such cases with essentially the same fallback.
> > 
> > Replace use of __get_free_pages() with kmalloc() and simplify
> > jbd2_free() as both kmem_cache_alloc() and kmalloc() allocations can be
> > freed with kfree().
> > 
> > Signed-off-by: Mike Rapoport (Microsoft) <rppt@kernel.org>
> 
> So historically __get_free_pages() was more efficient than kmalloc
> since previously the kmalloc overhead meant that a single 4k
> allocation would take two pages instead of one.  I'm guessing that has
> since changed?

Today there's no memory overhead for kmalloc(PAGE_SIZE). Cache refill takes
more pages of course, but they will be handed over to the next
kmalloc(PAGE_SIZE).
 
> Can you explain to someone who hasn't been tracking the changes in
> kmalloc over time:
> 
>   * How does the efficiency of kmalloc compare to __get_free_page when
>     order == 1?  What is the overhead in terms of memory overhead?
>     I'm a bit less concerned about CPU overhead, but it would be good
>     to know that?

There's no memory overhead when order == 1.
As for the CPU overhead, the difference for the fast path allocations is
not measurable and for the slow path it is anyway determined by the amount
of reclaim involved rather than by what allocator is used.
 
>   * What does kmalloc() do when a size > PAGE_SIZE is passed?  Will it
>     return contiguous memory, or return an error or worse, BUG?  And
>     same question as above; what is the overhead of kmalloc() when
>     size is 2*PAGE_SIZE?  8*PAGE_SIZE?

For size >= PAGE_SIZE kmalloc() always returns contiguous page aligned
memory.

Larger allocations (> PAGE_SIZE * 2) go straight to the page allocator. 

> Thanks,
> 
> 						- Ted

-- 
Sincerely yours,
Mike.
