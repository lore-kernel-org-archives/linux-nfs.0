Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=91.216.245.30
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793630474;
	b=ikjCLBrhwjBVUT7U5Xikw1gopAJondWQMvIOqfw3TmJ7Ng+BdAwUipIejsbBXmZhVysH
	 g2rTbSUh/aVFpREvjT0OsM+v/hoqrCqQeyqFqVI3B4iqbJvHENlCu8xbylDt65Z+sbmHr
	 1pdJvmBEudMFjMHPzd23GvB5kgCjSNry+hi2VSOSF6S37Q5hcC5vki9pr+f6BYEygqvp3
	 +aTTMxasxESjxsMw39DgOV6xsb2ay+c9FoKLj3Va3XcTJ0fE1UBB+xHZ+eUt3KvcalIdK
	 7ewmOX7/ybCf3R0x34d3ABMbg5sn7vlNgK4EJMpsmhHiFc+Ua4+jA0UPrw2PYiEvpqg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793630474;
	h=DMARC-Filter:Received:Date:From:To:Cc:Subject:Message-ID:References:
	 MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=OMjVTvjZtZrTjrcI72ExCzD1i9afB7DwzHLxEXPZD7Y=;
	b=QAagfSfraZYCEWKYZoj7u18gvF+xVL0V9/XxN5HTb6ZU3XKXclP9VH4SNNrwOqMzBKa+
	 DRYSv7dtCh6H6VlEvbbdaGzExo53YYKKGvGBi/zx94DsuUj9C7KIqVHah8OUn1Kb+FDC8
	 U9igneJDol81Z8fYH2au+BwZy/bwcCnQgp5ne4ccYY87pUYBX38WP7I8sJys5IrYlZC/S
	 lswLfFcvpIpFqiH/8qxntTabuu3jR1DnZhtSX8DWwyDHjVxlPRUxOa3T90LLIyppyNiHX
	 FFdiUa3ErmSZG7ukOKwm5rYbfLFwwiww4XEYOJFqdxNhttcnqNNj1K0k4Yn7WuKj/Bw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=strlen.de;
	spf=pass smtp.mailfrom=strlen.de;
	arc=none smtp.remote-ip=91.216.245.30
Received: from Chamillionaire.breakpoint.cc (Chamillionaire.breakpoint.cc [91.216.245.30])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DFE80607BDEE;
	Mon,  2 Nov 2026 14:41:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org DFE80607BDEE
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=strlen.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=strlen.de
Received: by Chamillionaire.breakpoint.cc (Postfix, from userid 1003)
	id B65DD60342; Mon, 02 Nov 2026 15:41:04 +0100 (CET)
Date: Mon, 2 Nov 2026 15:41:03 +0100
From: Florian Westphal <fw@strlen.de>
To: Christian Brauner <brauner@kernel.org>
Cc: linux-fsdevel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jann Horn <jannh@google.com>, Josef Bacik <josef@toxicpanda.com>,
	Chris Mason <mason@kernel.org>, Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>, Eric Dumazet <edumazet@kernel.org>,
	Thomas Gleixner <tglx@kernel.org>,
	Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>,
	Christoph Hellwig <hch@lst.de>, Greg Kroah-Hartman <gregkh@suse.de>,
	Joel Granados <joel.granados@kernel.org>,
	Kees Cook <kees@kernel.org>, Jan Kara <jack@suse.cz>,
	Jan Kara <jack@suse.com>, linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org, linux-acpi@vger.kernel.org,
	linux-kselftest@vger.kernel.org, linux-s390@vger.kernel.org,
	linux-scsi@vger.kernel.org, linux-um@lists.infradead.org,
	linux-wireless@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, ntfs3@lists.linux.dev,
	platform-driver-x86@vger.kernel.org, coreteam@netfilter.org,
	kexec@lists.infradead.org, linux-pci@vger.kernel.org,
	linux-sound@vger.kernel.org, netfilter-devel@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	ibm-acpi-devel@lists.sourceforge.net,
	jfs-discussion@lists.sourceforge.net, linux-alpha@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-cifs@vger.kernel.org,
	linux-fbdev@vger.kernel.org, linux-hwmon@vger.kernel.org,
	linux-mm@kvack.org, linux-sh@vger.kernel.org,
	linux-usb@vger.kernel.org, samba-technical@lists.samba.org,
	sparclinux@vger.kernel.org, linux-m68k@lists.linux-m68k.org,
	linux-doc@vger.kernel.org, linux-serial@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net,
	Takashi Iwai <tiwai@suse.de>, linux-input@vger.kernel.org,
	linux-raid@vger.kernel.org, linux-ext4@vger.kernel.org,
	linux-modules@vger.kernel.org, linux-debuggers@vger.kernel.org,
	Chuck Lever <cel@kernel.org>, stable@vger.kernel.org
Subject: Re: [PATCH RFC 03/38] netfilter: xt_recent: don't remove the proc
 entries under a spinlock
Message-ID: <auig_zhd3L0HEis3@strlen.de>
References: <20261102-work-procfs-bugfixes-v1-0-59422ed3e465@kernel.org>
 <20261102-work-procfs-bugfixes-v1-3-59422ed3e465@kernel.org>
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
In-Reply-To: <20261102-work-procfs-bugfixes-v1-3-59422ed3e465@kernel.org>

Christian Brauner <brauner@kernel.org> wrote:
> recent_proc_net_exit() removes the proc entries of all tables with
> recent_lock held. remove_proc_entry() waits until nobody calls into the
> entry anymore, and reading one of them takes recent_lock in
> recent_seq_start() while procfs has the entry pinned. So when a reader
> gets there while the network namespace goes away, the exit path sleeps
> with a spinlock held and bh disabled, waiting for a reader that spins
> on that very lock:

Yes, but note that this change is already part of a pending nf -> net
merge request.
