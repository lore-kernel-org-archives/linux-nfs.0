Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793723196;
	b=de0t5tAyrnyXAbkQbiTZ2C+cbAYfDQs2cTyl/SqxKfDJG3XHdMeMj3022Ufe+mERdVAT
	 +ZzygmdJOITO18ZCTcF6Hze1dneVPtjYSJLLNNOZ4bq4JZQoTyhfB2H4OWGAlSDtbAp8X
	 lMw+lQb0HBhfuqekU6sPU6XOcgN62V2BzWtztyYNkR5lDMcxukdlo1ZJ+1pazOpZmQLfn
	 yWXqCMjxYFEfYAIrmYqyKPh7vya7mLyXWm99lwJ3Yunl0DlePoZ15H46ZKsOVXA5XjajR
	 amsBuX0CyCvpY0OOus2YL65Do0Uox5LMAGQG9R6+YMBItQrG2k2yVSvVPsokIp2mzZA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793723196;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=88x5nWCU4/5DUnm5J75+/44oJREtwTCj+m3lJcaJoNE=;
	b=tdawQlYfgDrb3alGEDfr439O5Cw+xIZMzgxuDQTvu1eq98R7olpfgWnXNElxe+6RNneW
	 +WtM6uldUVExM54iZpuquygLBgV4ss9v1DdlPrhBRgjlpJsdA9htasb5VqBuKI9xdRRZQ
	 mXNqPuVznzoA01sj3DERKYaelKX3fIa36NpOutkvXGqh8Mxsj0eSKWhsIaJedFVEQIxti
	 n7X9odVx6mncFTtIw7BeW8JUrJIaRC0dbILM11QFF47/8afyZkTDuml9E/fnFFfGtarJY
	 +ME6FErInGL9MCUfBY7Ykc5Ds6s17BJZSRUQzGoG5BB1MPpvwHhtpkwzrDzTAt0asVQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=HyDteQG2;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 259F4606A327;
	Tue,  3 Nov 2026 16:26:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=HyDteQG2
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 09A721F000C1;
	Tue,  3 Nov 2026 16:26:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793723195;
	bh=88x5nWCU4/5DUnm5J75+/44oJREtwTCj+m3lJcaJoNE=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=HyDteQG2VBDz2pwudxJvRFZ3NzuhMM1n/qoJyRpSIEa+4sIo8qfNjCKCMkx9fqPnu
	 PTXEB3HB8c+csEYJbUqrD18YNji+Wb3P0nPR4rCDriU41qd0d35Q951xfxtaew6zqD
	 xTRV7HQa/evoV4YEWVb3yEGxlVh8/pDAOnR650sPVOaA2QtXNMiUjYtFVGzVyuFmxJ
	 cuqSFcaDMPcPNDAwdq/HarCHKLW8nQ/TcudxBJnTO/IQN1HpQ6LTm2xHx92xHn7YRV
	 9GYQVIg2n29fkajQrtiWC1hueIuFYRrAfwMXbzDr3+UFxfeou5MMiBIFbN+ZYhp4th
	 RFlMkVbcaKQDw==
Date: Tue, 3 Nov 2026 17:26:21 +0100
From: Christian Brauner <brauner@kernel.org>
To: Chuck Lever <cel@kernel.org>
Cc: linux-fsdevel@vger.kernel.org, 
	Linus Torvalds <torvalds@linux-foundation.org>, Jann Horn <jannh@google.com>, Josef Bacik <josef@toxicpanda.com>, 
	Chris Mason <mason@kernel.org>, Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
	Eric Dumazet <edumazet@kernel.org>, Thomas Gleixner <tglx@kernel.org>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Christoph Hellwig <hch@lst.de>, 
	Greg Kroah-Hartman <gregkh@suse.de>, Joel Granados <joel.granados@kernel.org>, 
	Kees Cook <kees@kernel.org>, Jan Kara <jack@suse.cz>, Jan Kara <jack@suse.com>, 
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, linux-acpi@vger.kernel.org, 
	linux-kselftest@vger.kernel.org, linux-s390@vger.kernel.org, 
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, linux-um@lists.infradead.org, linux-wireless@vger.kernel.org, 
	Linuxppc Dev <linuxppc-dev@lists.ozlabs.org>, netdev@vger.kernel.org, ntfs3@lists.linux.dev, 
	platform-driver-x86@vger.kernel.org, coreteam@netfilter.org, kexec@lists.infradead.org, 
	linux-pci@vger.kernel.org, linux-sound@vger.kernel.org, netfilter-devel@vger.kernel.org, 
	dri-devel@lists.freedesktop.org, ibm-acpi-devel@lists.sourceforge.net, 
	jfs-discussion@lists.sourceforge.net, linux-alpha@vger.kernel.org, 
	linux-arm-kernel@lists.infradead.org, linux-cifs@vger.kernel.org, linux-fbdev@vger.kernel.org, 
	linux-hwmon@vger.kernel.org, linux-mm@kvack.org, linux-sh@vger.kernel.org, 
	linux-usb@vger.kernel.org, samba-technical@lists.samba.org, sparclinux@vger.kernel.org, 
	linux-m68k@lists.linux-m68k.org, linux-doc@vger.kernel.org, linux-serial@vger.kernel.org, 
	linux-atm-general@lists.sourceforge.net, Takashi Iwai <tiwai@suse.de>, linux-input@vger.kernel.org, 
	linux-raid@vger.kernel.org, linux-ext4@vger.kernel.org, linux-modules@vger.kernel.org, 
	linux-debuggers@vger.kernel.org, stable@vger.kernel.org
Subject: Re: [PATCH RFC 27/38] sunrpc: make queue_wait a global wait queue
 again
Message-ID: <20261103-lufttemperatur-absondern-zweifach-31d272ad55ab@brauner>
References: <20261102-work-procfs-bugfixes-v1-0-59422ed3e465@kernel.org>
 <20261102-work-procfs-bugfixes-v1-27-59422ed3e465@kernel.org>
 <16f91f93-16b4-49b1-b7fa-cec69759c349@app.fastmail.com>
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
In-Reply-To: <16f91f93-16b4-49b1-b7fa-cec69759c349@app.fastmail.com>

On Mon, Nov 02, 2026 at 10:12:12AM -0500, Chuck Lever wrote:
> 
> 
> On Mon, Nov 2, 2026, at 9:21 AM, Christian Brauner wrote:
> > Since commit 552d0e17ea04 ("sunrpc: convert queue_wait from global to
> > per-cache-detail waitqueue") poll() and epoll queue their waiters for a
> > channel file on the queue_wait head in struct cache_detail. But the
> > cache_detail can be freed while its channel file is still open and
> > waited on.
> >
> > The procfs channel files of a network namespace are removed when the
> > namespace goes away. Removing a procfs file waits for the callers that
> > are in one of its methods right now and then calls ->release on every
> > file that is still open (cf. close_pdeo()). The waiters that poll() and
> > epoll left on the head stay queued until their file is really closed.
> > So:
> >
> >   sunrpc_exit_net()
> >   -> ip_map_cache_destroy()
> >      -> cache_unregister_net()
> >         -> remove_cache_proc_entries()
> >            -> proc_remove()      // ->release, the waiters stay queued
> >      -> cache_destroy_net()      // kfree(cd)
> >
> > and when poll() returns remove_wait_queue() writes to the freed
> > cache_detail:
> >
> >   BUG: KASAN: slab-use-after-free in _raw_spin_lock_irqsave+0x4b/0xa0
> >   Read of size 1 at addr ff110001131bb570 by task sunrpc-poll-uaf/242
> >   Call Trace:
> >    remove_wait_queue+0x22/0x1c0
> >    poll_freewait+0xc2/0x230
> >    do_sys_poll+0x9ba/0xd50
> >    __x64_sys_poll+0x165/0x470
> >   Freed by task 12:
> >    kfree+0x267/0x620
> >    sunrpc_exit_net+0x34/0x80
> >    ops_undo_list+0x271/0x8d0
> >    cleanup_net+0x3f3/0x860
> >
> > Closing an epoll instance that watches the file gets there through
> > ep_unregister_pollwait() instead.
> >
> > The channel files of a network namespace belong to the root of its
> > user namespace and cache_open() doesn't check for a capability. So an
> > unprivileged user can open the channel file of a namespace of its own
> > from the outside, poll it and let the namespace die.
> >
> > Go back to a single static wait queue that never goes away. A wakeup
> > for one cache wakes the waiters of all caches again but cache_poll()
> > reports per cache_detail so that's just a spurious wakeup. procfs
> > should really own the wait queue of its files like kernfs does but
> > that's nothing for stable.
> >
> > Reported-by: Chris Mason <mason@kernel.org>
> > Fixes: 552d0e17ea04 ("sunrpc: convert queue_wait from global to 
> > per-cache-detail waitqueue")
> > Cc: stable@vger.kernel.org
> > Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
> 
> Acked-by: Chuck Lever <cel@kernel.org>

Fwiw, I have a patch series on top of this that makes procfs own the
waitqueue and then this whole UAF issues goes away structurally and you
get to elide that global thing here.
