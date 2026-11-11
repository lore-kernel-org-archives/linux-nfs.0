Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=82.195.75.108
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794398064;
	b=eBaSdccKQpBHGgvYilgSk5nY1nsrRJApqPHXTfJqLhJbAXt6oWRDVwg2DIna5NpEJxFx
	 3PjRg2F53FP/ohb3jalNgRok/rLnQsc66QQA6Y3nchx7q2odXZ1sjSGdGvTlvvuzGIfoH
	 pAvhCYUPKpxYBXYkzJKJhcUXtZlqjT1cvy8TZJFspFZnnT84yEmOkVavMvvWca7aUKN3j
	 5SDwW/Zk9ZM6n2XxKNu2NgoujIBAwl5c7ZXpvP2rNVQaiwo4QfdsOnjqFk684yzx6qpii
	 93eE1ac5INl/0t0Qy8DbyVy9UUgiH4i/uZ5FBkWpsT+pPSPipJ20xZOGXq5Lm43r0Gw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794398064;
	h=DMARC-Filter:DKIM-Signature:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-Debian-User;
	bh=Ep5AJlsUvRo/Sl9Rg+NwP6D7Lq/wQPVEaLy1Gie9QQ4=;
	b=kSLfRzPZ+UKsasYkIbpqJ/vITapkU0elP5o0JXeuaDjOpN+g3TP59lLBg2hg5PXjNGJt
	 vwgPYlXZR1d9ZvixRGmUHeOkWt+tsdyV0qBn9ZAY5xzYVzXf7hmuGyTFX6S57GOTnpIzF
	 AcnCBHNlTmWJ5edE+ZyX1yJLTuL6ve8DMStbkxWbSK+bfFfRnr8+kFgNTssE4l4ykYMFS
	 M6LTGpqnK4ylkmAdd9kx7/CPXQ14EKwSdB/OAXpAMzpoK7U+2i6ZyeY1r7zS9k45HxshI
	 LG6WpR1UQ4lYITagxJN5ayExy30UWYFegZa4g5E4JZiBEI2ZpVK+KshwtMpXC/95joA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=debian.org;
	spf=pass smtp.mailfrom=debian.org;
	dkim=pass header.d=debian.org header.i=@debian.org header.a=rsa-sha256 header.s=smtpauto.stravinsky header.b=vV5nh+mu;
	arc=none smtp.remote-ip=82.195.75.108
Received: from stravinsky.debian.org (stravinsky.debian.org [82.195.75.108])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (prime256v1) server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E310B606A321;
	Wed, 11 Nov 2026 11:54:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E310B606A321
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=debian.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=debian.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=debian.org header.i=@debian.org header.a=rsa-sha256 header.s=smtpauto.stravinsky header.b=vV5nh+mu
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=debian.org;
	s=smtpauto.stravinsky; h=X-Debian-User:In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=Ep5AJlsUvRo/Sl9Rg+NwP6D7Lq/wQPVEaLy1Gie9QQ4=; b=vV5nh+muii9KUwMXfoK65C9FPK
	aNSl0OiG0j4I+LFXc7WeA74kYOFf834TBtI7qS+ZEF0cf7hSHSrnoI47iOSAXQPCAXQU9fne6O/8R
	G2wk/XluU5ugbAZ7f5jU4JBscAk6nd/VyyPFhAk65/tq7U9wZjt9SJD8a8A/m2R6Cxj7l7C76kg9H
	1KIPLAQYQ/Fv+JWvD04uouKwGYT/8gu4uHiCPUf9Bg4PxVdqeWdNvrfltP4AIW+MdO1/5WBfOmizl
	DellelcAiKmJM9KaaC82wP83/72jAdgWurCb/I4tMo/beG16KgajqNT/PO+VCT1shIIGmoQlyuzr0
	Arg3hVEA==;
Received: from authenticated-user
	by stravinsky.debian.org with esmtpsa (TLS1.3:ECDHE_X25519__RSA_PSS_RSAE_SHA256__AES_256_GCM:256)
	(Exim 4.96)
	(envelope-from <leitao@debian.org>)
	id 1xR6u3-00DA6f-37;
	Wed, 11 Nov 2026 11:54:12 +0000
Date: Wed, 11 Nov 2026 03:54:00 -0800
From: Breno Leitao <leitao@debian.org>
To: Christian Brauner <brauner@kernel.org>
Cc: linux-fsdevel@vger.kernel.org, 
	Linus Torvalds <torvalds@linux-foundation.org>, Jann Horn <jannh@google.com>, Josef Bacik <josef@toxicpanda.com>, 
	Chris Mason <mason@kernel.org>, Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
	Eric Dumazet <edumazet@kernel.org>, Thomas Gleixner <tglx@kernel.org>, 
	Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Christoph Hellwig <hch@lst.de>, 
	Greg Kroah-Hartman <gregkh@suse.de>, Joel Granados <joel.granados@kernel.org>, 
	Kees Cook <kees@kernel.org>, Jan Kara <jack@suse.cz>, Jan Kara <jack@suse.com>, 
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, linux-acpi@vger.kernel.org, 
	linux-kselftest@vger.kernel.org, linux-s390@vger.kernel.org, linux-scsi@vger.kernel.org, 
	linux-um@lists.infradead.org, linux-wireless@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, 
	netdev@vger.kernel.org, ntfs3@lists.linux.dev, platform-driver-x86@vger.kernel.org, 
	coreteam@netfilter.org, kexec@lists.infradead.org, linux-pci@vger.kernel.org, 
	linux-sound@vger.kernel.org, netfilter-devel@vger.kernel.org, dri-devel@lists.freedesktop.org, 
	ibm-acpi-devel@lists.sourceforge.net, jfs-discussion@lists.sourceforge.net, 
	linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-cifs@vger.kernel.org, 
	linux-fbdev@vger.kernel.org, linux-hwmon@vger.kernel.org, linux-mm@kvack.org, 
	linux-sh@vger.kernel.org, linux-usb@vger.kernel.org, samba-technical@lists.samba.org, 
	sparclinux@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-doc@vger.kernel.org, 
	linux-serial@vger.kernel.org, linux-atm-general@lists.sourceforge.net, 
	Takashi Iwai <tiwai@suse.de>, linux-input@vger.kernel.org, linux-raid@vger.kernel.org, 
	linux-ext4@vger.kernel.org, linux-modules@vger.kernel.org, linux-debuggers@vger.kernel.org, 
	Chuck Lever <cel@kernel.org>, stable@vger.kernel.org
Subject: Re: [PATCH RFC 25/38] powerpc/crash_dump: check ioremap_cache() in
 copy_oldmem_page()
Message-ID: <avRXHYDKemkiDvoj@gmail.com>
References: <20261102-work-procfs-bugfixes-v1-0-59422ed3e465@kernel.org>
 <20261102-work-procfs-bugfixes-v1-25-59422ed3e465@kernel.org>
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
In-Reply-To: <20261102-work-procfs-bugfixes-v1-25-59422ed3e465@kernel.org>
X-Debian-User: leitao

On Mon, Nov 02, 2026 at 03:21:40PM +0100, Christian Brauner wrote:
> copy_oldmem_page() maps a page of the old kernel that isn't in the
> linear mapping with ioremap_cache() and copies from it without checking
> whether the mapping worked. If it didn't, the copy reads from an offset
> into the NULL page. That oopses unless the copy happens to be a user
> copy, whose exception table entries turn the fault into a short copy.
> 
> Return -ENOMEM like the other architectures do. read_from_oldmem()
> turns that into -EFAULT like any other short copy.
> 
> Reported-by: Chris Mason <mason@kernel.org>
> Fixes: 54c32021eb6f ("[PATCH] powerpc: Add arch-dependent copy_oldmem_page")
> Cc: stable@vger.kernel.org
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Reviewed-by: Breno Leitao <leitao@debian.org>
