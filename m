Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793783736;
	b=heY8DZfjs596eoeBD5Z2sDOUU9B1ozsiyIw9Ub5j5NN18cL3ACo/mUb+8fdUQxz5eknT
	 AGHLKCBcM82NzD0fuSMaukcw6smbGvzmBLwxSSuq5fKTgnyFK3wIgZtHAwOfjsyOLGNUl
	 EiCrjnO3XhFFGMySJ3xCOCLWogk3C1BrrMYba4ksBCT8888DurqYn6Vt6hFNjwvkESbOU
	 /ilzQS+Bmzpgc8XaQVtUdl3qH0LHiLromofkdHAcDZgzYez5ObWIz+6D+m3kF3Mt6fzkT
	 kzuU+alJ51HWmnUBCnfr72czmjbMxJZizh+ZFsMPXlAwFP7C4rrf0/Ct+Mu9O4f6a7Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793783736;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=tun3DxnivT6n8ykyvHDle1jgjloMyn9wMMyaVwUBJtE=;
	b=xmcr7yec+WPhYpeNieSszKshZJXr/3jZlrcW8PLnr+8Zh4T2kyeXJvf1i/aGPlwa+qVS
	 R6xPzgd1Ro2Z+SaMXtkyN6ZxEdLAAtVN6DqR2QjzGXvdlwahqdhv6qUOiaQl1kLdUMPPo
	 svBQYusftCZ8mNsJ9Le9tpJsm1Jf6NSf+sX3zXiHp5gTlqJVORtB3x1oNI6PIm6r1kdGV
	 PolVhj4xUkvFWlKwY7Lk1oM+acc8YBO0v7qi0n7xFCNGfHNKesXbXw7JqXVKcphP3VWel
	 PHCWI5ukpuhM5nNOHoVBztxqRAXPCZbK895HWGrw28um8DVKOXnYgI8YqQOODf7vdeA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=QF98rpjB;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C1070606A31B;
	Wed,  4 Nov 2026 09:15:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=QF98rpjB
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 786C51F000C1;
	Wed,  4 Nov 2026 09:15:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793783735;
	bh=tun3DxnivT6n8ykyvHDle1jgjloMyn9wMMyaVwUBJtE=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=QF98rpjBzH7nX1jmz4Zo8ykeu0WPbxz0HGt6XxCXrOQ4V4PB3P/wbn5sluIzZ3bgP
	 woOpkCVq06Ek6V7bKkHEP2phdvrGGARxXAl1OBE0IhgkRUa/IQ935AFbXxh1YUY5bJ
	 utfjbIjp7LtybAhtZNGHqFcIoDw2mhpfxaUaUe5IHuBCvHt5tgYAPu/YfrtEAf4jWd
	 v5zbJS1rE1Hby/io2vM2SNwmccLVR3w7pjdFYCtf7rR4Wu4skeBeZ5GH0Q1ajKmHHR
	 yetiYqpJqieJOdcKUSYdWCjNW5p22mqd+bHsoVYbOTO4y8Ft2ybe6f5kRc5h/hiSzc
	 /PiiXfUYZ7Gcw==
Date: Wed, 4 Nov 2026 10:15:18 +0100
From: Christian Brauner <brauner@kernel.org>
To: Florian Westphal <fw@strlen.de>
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
Subject: Re: [PATCH RFC 03/38] netfilter: xt_recent: don't remove the proc
 entries under a spinlock
Message-ID: <20261104-entgangen-nettigkeiten-intuitiv-f39521735261@brauner>
References: <20261102-work-procfs-bugfixes-v1-0-59422ed3e465@kernel.org>
 <20261102-work-procfs-bugfixes-v1-3-59422ed3e465@kernel.org>
 <auig_zhd3L0HEis3@strlen.de>
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
In-Reply-To: <auig_zhd3L0HEis3@strlen.de>

On Mon, Nov 02, 2026 at 03:41:03PM +0100, Florian Westphal wrote:
> Yes, but note that this change is already part of a pending nf -> net
> merge request.

Dropped.
