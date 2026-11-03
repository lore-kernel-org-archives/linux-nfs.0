Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793730323;
	b=fMg914BT/asBU3ZC0n7PkKeUDiazOG9RCJRHpmUqaNUjw2inp7y4UNB2MKBKtXymZw8p
	 IcIvlcWbNEaFPkoqgXslGd6yC2cFvka/vLCuXqgWjCEXa+vpzX7j9uN+5XR44fNpJQbsr
	 DojFj3YCZb5m2p699GGBZ3VLe3p0F5OV5i/XFndiCuAbCFWMIVpAeHZBiYKoALXhlwC+w
	 +SATxBPtYJCLh0RpQRrMr/ycZnyskwyF9Pn4V+9iORXzPSxOqudvT/0GqyYZKetuvY4bx
	 VUNqyPdmsqGbdobuqyqgQfDhfuvYjYTtujyp2C2PUkn8EXLxqsUl0TKUfBxdiDVBG4Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793730323;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=Ar8emD3X5W7roqEpkOTWnlmegs5JH/dC0liFSCJECJQ=;
	b=TFLKImSn2PpildHIcezRUj3wdijIsNbq6mGVhcrxfbh9KGv59I5p3oyuOIW00jh5KFYe
	 TLnQtD+9mKFSX53omJ4qYXSd5dCYJx1QejvOj4Qq3wREhZZPiXe80OoZVwFzFeKiMk1qw
	 o1kT+JUoAN6fk2LFi9X6hzOtk8ISp1PowxAPLA2pa8Pq6CSrnvWbIl1i4ZONoWokhZHev
	 FkkKvQ0pgr8bEK23fhuH6U7+YHV94a9WYt8F3qfXwFKfal3QgZ7adhLk9d+H8rMIvxOjk
	 MD0tVZ+4bbYei+Ydr6wu++glt+qcqdYH/nWpYgWAxnQd/nJ5jGibneF6eidR0d6AdAA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=KGMD3+7C;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7F9BD606A31B;
	Tue,  3 Nov 2026 18:25:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=KGMD3+7C
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2A5FC1F00919;
	Tue,  3 Nov 2026 18:25:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793730323;
	bh=Ar8emD3X5W7roqEpkOTWnlmegs5JH/dC0liFSCJECJQ=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=KGMD3+7CdxX59NPHv2j6CKQynclGhHXBE4b2NPPVYth0TxFavAsf2Z1gt/FnM2TOT
	 0pN12WzFLknff4bqCy3kR9qm0laDLWVfFUFkjPyRfmILALQ7U/tZVJY6ChShw/XQYU
	 VzjXphTrdMpcoNDmFBsSQzxnB2CWabqw8wbdf+QERbN6R9ETj08HOgAbyZgsVXZyTS
	 M9U0agdaYGvkEnd0lsjjfG3Zp40yL52eJEpfOYRn2wyhrc+q8qrh/kdRxmbJebGS5x
	 uRkNwSvnoicqQzMz8W94RiItUZUbhD6IX5Lwwj369Z9Zav4KitEKENQ5stTovVj9tM
	 kXiNU6JZfFQJQ==
Date: Tue, 3 Nov 2026 13:25:22 -0500
From: Mike Snitzer <snitzer@kernel.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org, Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	Jens Axboe <axboe@kernel.dk>, Jonathan Corbet <corbet@lwn.net>,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: Re: [PATCH v9 6/6] NFSD: drop a shared boundary page only once both
 WRITEs have written it
Message-ID: <auonEkQ2Td15c58L@kernel.org>
References: <20261024221152.6965-1-snitzer@kernel.org>
 <20261024221152.6965-7-snitzer@kernel.org>
 <20261103105134.GC7296@lst.de>
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
In-Reply-To: <20261103105134.GC7296@lst.de>

On Tue, Nov 03, 2026 at 11:51:34AM +0100, Christoph Hellwig wrote:
> FYI, this doesn't apply to mainline.  Together with the complete
> garbage commit logs this doesn't really leave much to review
> unfortunately.

From the cover-letter:

"This series applies on cel/nfsd-testing at 6d13b7f74eec ("NFSD: Map
every NFS_ACLv2 reply status into aclstat2")" -- that SHA1 is stale
since Chuck rebased on Sunday but: baseline is cel/nfsd-testing
