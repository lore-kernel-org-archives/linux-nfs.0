Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794044930;
	b=FxN8x0CdoVmuXem/PbyuZoavU79Lrb/y11DkGIRuhpDeJYYbN7ZNLB7eLcnRSl9w9bSe
	 rYWYwbsuPSUJu1yNcsBJRf7TfIElA7NWyzg3rhe6M4UvIGFwzypQCZBimsXWhuv2uiMUO
	 yB13Deb9RKSvdZgwpL0A2CgCFVGKmGw5TBxalc+OtpMI8DlwYuIdDt8T+7GWCg7GFwsXG
	 2cOMmw6L7kyXLbwiRiG6by8jyMWLJolvKwMJcdk+AMI84zGJSXlDtNuaY2FqbXjcgxWny
	 505wsLusQcyNy03C3qZ0kfdlO+lqZHE7WP1mI5jxNRR0MIitwhk2bkzMmjsn6WbB0xQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794044930;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=rorNI1UIic/55wFWIBl0e+Ri75FN+PnMt9WvbEXwkRc=;
	b=U7/psnXgEAnYQfxcSYHkkcUaBfLtp62nIG71yjEKq9ciYEBylQLa1LRNjfxuI8QXWsQc
	 I6sGz2e6w6flKpwB3Gi59o/W9xwSWMotfMs8WhV/A4PkVzmRf0kzY6kGLWlBV69TJS6VK
	 y8RCWYnIQoFkNGesjqgVrUUl9jcFQE9zwooeG9FHN/3/rX2h7/IDeGXJS1IPkU83u/yfm
	 x/kyM1KupAhNeUhYagHFQ/QuCeoP0LMtpamDdbaNo70nyBMM0xyMQyigE+SjBOXQcCqAj
	 /9c66oNu7IYlPouJfRw7syEROdKPuzSCD38Uj3D8yBaUJmO/YKo4Bs7G9XBhIToBd2w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=iW02CE60;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 20473606D801;
	Sat,  7 Nov 2026 09:48:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=iW02CE60
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 328FB1F0089F;
	Sat,  7 Nov 2026 09:48:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794044929;
	bh=rorNI1UIic/55wFWIBl0e+Ri75FN+PnMt9WvbEXwkRc=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=iW02CE60RHF02fEuqPqKcJf6i4V3KTjWDHzo9DZbo95gORtH0ZrmCJDxrNOCnD4Id
	 9WnOBlB++VD4fZIWQsCzrQhJIry0nbljvHblYH3quGITH2PJSiPvwUzFopDT7DZDt2
	 EHHmNwDws2w9I0dTG1wwVA0PVma1a6Hmr9kUmUnaP/d8oN+oH0kQjwhxNPRQPPwlA4
	 xw0Rt/uXRWnSdUas9IyJY6YU5S7A3WpR700rHxBipZTWxfOwImozcBkuV3AdARVDwJ
	 t+x6t7k7LiUG553yMU1QgCJYHr0hUKV7+ybnwND/Tl+BQydELSVgjRpI3YK5OOLnj3
	 agc3DJMfrldDA==
Date: Sat, 7 Nov 2026 10:48:35 +0100
From: Christian Brauner <brauner@kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
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
	Chuck Lever <cel@kernel.org>
Subject: Re: [PATCH RESEND v2 14/23] proc: let procfs copy in writes before
 pinning the entry
Message-ID: <20261107-akteur-gemieden-eckdaten-21304d085e35@brauner>
References: <20261104-work-procfs-core-v2-14-76ace653a773@kernel.org>
 <CAMuHMdVfakapgBK6TBhO1iWX8qzvLDk8jzRS=t2MVa5G=MCUeg@mail.gmail.com>
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
In-Reply-To: <CAMuHMdVfakapgBK6TBhO1iWX8qzvLDk8jzRS=t2MVa5G=MCUeg@mail.gmail.com>

On Thu, Nov 05, 2026 at 11:07:32AM +0100, Geert Uytterhoeven wrote:
> > +       ssize_t (*proc_write_buf)(struct file *, char *, size_t, loff_t *);
> 
> "const char *"?

I prototyped this to have a detailed reply. It's not worth it.

* The buffer is the entry's private copy.
  procfs creates the copy for this specific call and frees it
  afterwards.

  A bunch of handlers modify the buffer in place and it's documented as
  allowed:

  - afs_proc_cells_write()
  - afs_proc_sysname_write
  - a chunk of the sunrpc cache channel ->cache_parse() implementations
  - thinkpad_acpi's ->write() methods
  - SCSI devinfo file
  - dyndbg
  - cio_ignore
  - the pseries ofdt parsers
  - two more hand the buffer to a char * interface:
    - the SCSI host ->write_info()
    - simple_strtoul() in proc_scsi_write()
  - four strip a trailing newline in place

All ways to make that work suck.

(1) Copy in the handler. That means eight kmemdup_nul()s and a
    kvmemdup() for every nfs downcall.
    IOW the copy this series just removed comes back as a copy of a
    copy which is not acceptable.

(2) Make the parsers work on spans which also sucks and doesn't solve
    all of them.

(3) Leave the buffer writable. Costs nothing, nobody else can see it.

So (3) I think char * stays.

> While at it, I think it would be good to use this conversion as an
> opportunity to replace "char *" by "void *", which will probably let
> you drop several casts from users.

So I tried that too. The thing is it drops exactly one u8 * cast in
ntfs3's label write. And to get this done we need to introduce a whole
range of local char *foo = arg assignments. So I decided against this.
It just doesn't add value.

Thanks for taking a look!
