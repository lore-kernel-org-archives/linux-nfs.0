Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793817596;
	b=BlQgriMZLGg/yfbCecgnT/WRHHdMyMysZ5/p+CO9fkZ2sHG8eo7X1pLiAU074Vtqdt62
	 4nf/2o/wRFQS1htOabDUwzs9WrPQU9Xb0j48hVgq6dRvESExkCyAHBbKFeO1mv460jVCd
	 XL7YmRZuIy5pY5DBF5FpSVv7tWBcJ0foc7xCB9W85WOqFZstnh+Qsc216l827yZCJIqPl
	 E6KVXO/EYb/OyoFVQGBmC9mIRhfESuokZKYmrTpbcIn6vEvZ7YUDQBIZIGVcBN6YROBbx
	 hH2o3cQsMLDk9yvP/KOMslRFXuJJlgkW5qYfmVR6IHh4r67ryrs/kMaRJ9AxxdxEGxQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793817596;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=cfX+RSDf63q8RdYOSefxL9B17eZvLgT/fF9r72R8ItM=;
	b=JpGYuH62Vv5k02PpA0XvVss9NtYioYWRtz69gVxHJQEeqpNvr77/I4KuTb9VkV3L5XUO
	 9jvVW9vuqOBaUjPjt64Phu7te06oPAul0ykvdEjKqj8PFHulCZsF5i1uhcE69M8W8fDIO
	 /Z5KurUGXmfaPmfbAWxkquRdmUiO76oMFEaeP7fHcQ7S0BxDNysZeSGr1YPCvQLNGpmB4
	 oa2WYUsLgb+AAYZzr8cbHqzwkcxmOz9z8boV7QT6aRxDHBvq/nIy+aFfKOBlUBrtPPP0U
	 vXvvhlxmvtSYD9GcdQbGEr6fGCSogYCS+V8Fu7+Wy8aLgECQEQNhdoqRH1Dyr4cT/JQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=GDU8EuhU;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B2318606A337;
	Wed,  4 Nov 2026 18:39:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=GDU8EuhU
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6D94A1F000C1;
	Wed,  4 Nov 2026 18:39:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793817595;
	bh=cfX+RSDf63q8RdYOSefxL9B17eZvLgT/fF9r72R8ItM=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=GDU8EuhUF/10B5PY7Ge41gK5xPnjrcLHs7feXWHlvH4fq+/JLsc6ePLzmMcenBTV8
	 F8DU2mNIqG7yMOIN0gPqiAwJM3jV9nVVVUEYkA/ePBSooGTee00ROqhKBnF1Bqim3H
	 1MIVC6ndCg4IYSs9ehay5xqAR6tGspnn8txoZnqUV3a/rwlemC2StvUcjU4rBzRdDh
	 smT5Fi28DptI2/GHQw2s7uG8id08IW1enmMV0ZcuUo2Xf6u9ciNae6b4/FwizkvKf5
	 0O5jZIOLbbQIYlYObNdALqLNo9VEtQX1aZ+lQxJHqEn6uUf5MjI2wjNp8uWWy07SZL
	 e+KRVPYe7/Ndw==
Date: Wed, 4 Nov 2026 19:39:40 +0100
From: Christian Brauner <brauner@kernel.org>
To: linux-fsdevel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, 
	Jann Horn <jannh@google.com>, Josef Bacik <josef@toxicpanda.com>, 
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
	Chuck Lever <chuck.lever@oracle.com>, Takashi Iwai <tiwai@suse.de>, linux-input@vger.kernel.org, 
	linux-raid@vger.kernel.org, linux-ext4@vger.kernel.org, linux-modules@vger.kernel.org, 
	linux-debuggers@vger.kernel.org
Subject: Re: [PATCH v2 0/7] proc: move procfs to what kernfs does
Message-ID: <20261104-angriff-abgewandelt-ohnehin-e5ba30d31576@brauner>
References: <20261104-trompete-gejagt-raddampfer-9fb5640a6102@brauner>
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
In-Reply-To: <20261104-trompete-gejagt-raddampfer-9fb5640a6102@brauner>

Please ignore this. Network dropped halfway through and the umbrella
went out under a broken message-id.

I'll resend it all correctly.

-- 
