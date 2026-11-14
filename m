Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794652724;
	b=oqawjCYXViBhZDOu54mO4rFz5m3zErSirnUbuzXnMAw5PATI/TruwwQCkwdYiSLiYDWT
	 87+gx8lEZbzpBfhA+I9R/lP3Tj64Irpw9UlSdc+p4na9S7JCuJzxOJ4l/gtzUEqjOMI7V
	 DJHN6iX/ivzO7lbnKY46RBEEl0JZ42vbCVul1KDbsbqHvMtBf7fP7k5za24lFJMnv2acy
	 tc9PFjKvxjpUacndXixORGVwbf0veUq8K7TT9dHn+NvEw19syoMtzELWJVlFAnS85jZU2
	 MsBpOdAkcOgkFCqLIUggxnTJAqvI4a+i6uFgZcE3+rlJwGd7/bwvyVtmWY/ExSPHbTw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794652724;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=f0g6P6hsNAkBmmk1dhVL/yqmLVxvhNEJRF73P8Hffz8=;
	b=XTRFf3I9lNTiXczV41KEJg/FNuIVqDVo2dmDdYyszYgVrx7yTyVRPsPuZfvPA4veCQgQ
	 jKr/qKLNzZFhQ2jewlC/ZCTk4+8Poh+6hOz3XN5IEfOlepYONBBN/dZ283nK3OXJNhLZ3
	 LUjdHWsRXLFyh6UM22W5GyemHIlJGs7c/oztRdwvhrP9kxWVJWRUZdqykh/yKnLFBm5zI
	 jW/KA9kONTlAz0bqr1L/Ybfmzs2qCgDwTbIVbBI+YVwP1Dtp3zII5gIcV0LHpaX/uQIQh
	 TF5BkI2HzftmVZuRIitvcviJKbYL8yp7+DQl14DOpUMxZZ2GcSxk2dCywnFttGpRBDw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Ozu7z0Kj;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AFCDB606A323;
	Sat, 14 Nov 2026 10:38:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Ozu7z0Kj
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3CE541F000C4;
	Sat, 14 Nov 2026 10:38:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794652724;
	bh=f0g6P6hsNAkBmmk1dhVL/yqmLVxvhNEJRF73P8Hffz8=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=Ozu7z0Kj1tHIOD24bkiz6twDQ59H2LG047bnoA597yeAQD+7loV9AVNQq6/EfNxmA
	 RAV43n2Xp3rFswhwCvrdVPjCv2twIaBECTwXwjSyPBKOEecSJccYi16iPUffdcy+kX
	 2KsSYHa0TM5q3kVm9Et0sKjXOYpfJER4fjfggVZYik+Tlk8iLg4VYcTfwPq6hSWTb+
	 FqNtagBKrLecsr9nZyvU/RGWRSqwrFdabGVO12uSaA2rrQgzv6ROpsZEsD9jdN00pG
	 9AVp7r2bVcIF0aGX9qNUD3D/9g7VuGmG+jesekdRYeqNRWWlH0zjJp4ZwQJyQCg3y0
	 VLaLdAkJXNuOg==
Date: Sat, 14 Nov 2026 11:38:35 +0100
From: Christian Brauner <brauner@kernel.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-fsdevel@vger.kernel.org, Jann Horn <jannh@google.com>, 
	Chris Mason <mason@kernel.org>, Josef Bacik <josef@toxicpanda.com>, linux-block@vger.kernel.org, 
	linux-kernel@vger.kernel.org, linux-nvme@lists.infradead.org, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>, linux-scsi@vger.kernel.org, 
	target-devel@vger.kernel.org, driver-core@lists.linux.dev, linux-mm@kvack.org, 
	bpf@vger.kernel.org, linux-security-module@vger.kernel.org, selinux@vger.kernel.org, 
	apparmor@lists.ubuntu.com, linux-nfs@vger.kernel.org, netdev@vger.kernel.org, 
	fuse-devel@lists.linux.dev, linux-efi@vger.kernel.org, xen-devel@lists.xenproject.org, 
	ocfs2-devel@lists.linux.dev, linux-s390@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, 
	linux-usb@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>, 
	linux-erofs@lists.ozlabs.org, linux-kselftest@vger.kernel.org, stable@vger.kernel.org
Subject: Re: [PATCH RFC 01/41] loop: refuse backing files that aren't open
 for reading
Message-ID: <20261114-erfrieren-vorher-taktieren-ef10b08e210f@brauner>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
 <20261110-work-loop-pseudo-v1-1-4c998976c6c7@kernel.org>
 <20261111145555.GA9996@lst.de>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20261111145555.GA9996@lst.de>

On Wed, Nov 11, 2026 at 03:55:55PM +0100, Christoph Hellwig wrote:
> But i wonder if we want a thin wrapper around ->read_iter/_write_iter
> to do this check so that it matches the normal read/write path?

Yes, I had thought about that as well. We could use
vfs_iocb_iter_{read,write}() for that but it's not thin at all and
brings in the LSM into these codepaths where they shouldn't meddle.

So maybe as a follow-up series with a new
vfs_iocb_iter_{read,write}_raw() or whatever. Feel free to make a
suggestion.
