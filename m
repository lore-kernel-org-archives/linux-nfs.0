Received: from outgoing.mit.edu (outgoing-auth-1.mit.edu [18.9.28.11])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 14F8F43E4BD
	for <linux-nfs@vger.kernel.org>; Thu,  4 Jun 2026 14:08:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=18.9.28.11
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780582117; cv=none; b=qDuseRcdcFGU/b8A6WehsGFtH/nDxtekqtfecvj83yKeUXzGvCAMG/E3IUsj76jCmZPUBM0aEGHaMrKhDocXjto1QdyHEcDQJF9P2GSTlglNGpzpF0NwBPyKHRc2F25j1Uy6foyYLNC6yIM4OPTz613xw/DPXk1aFRcTH4Xdgac=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780582117; c=relaxed/simple;
	bh=mvIP8ngdXo4jA96Ea8p105NJqwzP24HZicHRCFQ/FdQ=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=tZT+VqILscRXELZnW49LHRnTNRzljy47w9HSBotJKG0j/2hYaeEhKNYMqI45dbmEcrX+0KXmoXCYXEiiUvyV1edmJLmNyIbV/FKrY300nbo+axWXnMoAilKt4zUTFXW6t9ew4xrqZuPZiH9sX9Z8yuigiW0zHFvy+V5fVales6I=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=mit.edu; spf=pass smtp.mailfrom=mit.edu; dkim=pass (2048-bit key) header.d=mit.edu header.i=@mit.edu header.b=mb/IBx2t; arc=none smtp.client-ip=18.9.28.11
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=mit.edu
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=mit.edu
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=mit.edu header.i=@mit.edu header.b="mb/IBx2t"
Received: from macsyma.thunk.org (pool-173-48-113-247.bstnma.fios.verizon.net [173.48.113.247])
	(authenticated bits=0)
        (User authenticated as tytso@ATHENA.MIT.EDU)
	by outgoing.mit.edu (8.14.7/8.12.4) with ESMTP id 654E6rvL025698
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 4 Jun 2026 10:06:54 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=mit.edu; s=outgoing;
	t=1780582020; bh=5s99V2F+cdxC+MwrT27Mau0Uu2siNBpgurBs08PszHI=;
	h=Date:From:Subject:Message-ID:MIME-Version:Content-Type;
	b=mb/IBx2t4Epn1180cTZPKExA+5u946+tIwlV31jpfDtN0UiOTyD0Hl31IYSdo6HEC
	 kuQbQnyc5edecobCL5JrbpcyK5pHbtgHcD/Jc8TQWSO1qBkfNL95JoWIgDAs8IGKBt
	 uBG9CP9x40IWHSEnEPklfmc8Uei3gfqs9m/dTJEFJODXZ6nVP3b/R8vroBVkUEW1Gq
	 tr4zxnTzkZEmmCDYotcI+GORmTAykiAacHUlAIw/6Z/bI4lAyVeYWvg7XuwidEXkQe
	 60NEfoN/RFaTuY9hSDI9GhFLE2N+msS6oWqaHWyRFqJPqBnGuLGlZsZ0vrl0RBcYOl
	 I/KRqdjz9TCRQ==
Received: by macsyma.thunk.org (Postfix, from userid 15806)
	id ED63E37A6B9; Thu,  4 Jun 2026 10:05:52 -0400 (EDT)
Date: Thu, 4 Jun 2026 10:05:52 -0400
From: "Theodore Tso" <tytso@mit.edu>
To: Mike Rapoport <rppt@kernel.org>
Cc: Jan Kara <jack@suse.com>, Mark Fasheh <mark@fasheh.com>,
        Joel Becker <jlbec@evilplan.org>,
        Joseph Qi <joseph.qi@linux.alibaba.com>,
        Ryusuke Konishi <konishi.ryusuke@gmail.com>,
        Viacheslav Dubeyko <slava@dubeyko.com>,
        Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>, Jeff Layton <jlayton@kernel.org>,
        NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>,
        Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>,
        Dave Kleikamp <shaggy@kernel.org>, Miklos Szeredi <miklos@szeredi.hu>,
        Andreas Hindborg <a.hindborg@kernel.org>,
        Breno Leitao <leitao@debian.org>, Kees Cook <kees@kernel.org>,
        "Tigran A. Aivazian" <aivazian.tigran@gmail.com>,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        ocfs2-devel@lists.linux.dev, linux-nilfs@vger.kernel.org,
        linux-nfs@vger.kernel.org, jfs-discussion@lists.sourceforge.net,
        linux-ext4@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 10/17] jbd2: replace __get_free_pages() with kmalloc()
Message-ID: <ximvn6jwgtam665a4droqkp73o55kwvd5uukyidwjesmysobth@oe7rigpsjfkz>
References: <20260523-b4-fs-v1-0-275e36a83f0e@kernel.org>
 <20260523-b4-fs-v1-10-275e36a83f0e@kernel.org>
 <yfzx3jgzwesernofl7mzixa2mhjfii5v3o7yapghtmozixrpfu@6bsh7iixyiov>
 <aiEX4UTxEnBTjVKo@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <aiEX4UTxEnBTjVKo@kernel.org>

On Thu, Jun 04, 2026 at 09:14:57AM +0300, Mike Rapoport wrote:
> There's no memory overhead when order == 1.
> As for the CPU overhead, the difference for the fast path allocations is
> not measurable and for the slow path it is anyway determined by the amount
> of reclaim involved rather than by what allocator is used.

Thanks for confirming!

> Larger allocations (> PAGE_SIZE * 2) go straight to the page allocator.

Another question: Today, we can either use kmalloc() (or
__get_free_pages, previously) or vmalloc().  Is there a way a file
system can say, "give me physically contiguous pages if possible, but
if it's too hard --- with some TBD to specify what 'too hard' means or
can be specified --- fall back to a vmalloc-style approach, with the
page table / TLB overhead that this might imply"?

I suppose we could do it with kmalloc() with some flags which to
prevent forced reclaim / compaction, and if that fails, then fall back
to vmalloc().  Is there a better way?

Thanks,

					- Ted
