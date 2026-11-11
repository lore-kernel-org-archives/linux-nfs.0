Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=82.195.75.108
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794398342;
	b=0tyZQwbuiy42oxCDaVhOZzFjT7aC/WSLR2SlOoaWuvS62YqCniej84tplEepbvPSlRKd
	 1xsqOjVh/35KuwmC09naKQbkkulbMst9tNuXnSZqlhH8e2ZLjd0FtGfVJBO0VVujzvbYl
	 x3DQlnuZLnxxehKy9CtxCnyy7vQUPAldID4mJ6meVgsr+rXYxHQC4c66bLZ30JEi01Wbu
	 5/LlzZn2MF5v2N5KKTkqXAstrlKSeiBeLuWOK03ZdK5c3Z3U1GDW5dy9ijMKXkwUoVG/i
	 Xfozy+6rWG6NkG5PO2yVwfbP1MDtQ3a9r2WuqMUg15T+DS9Tmmw2FIgDbvKHuQALPmA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794398342;
	h=DMARC-Filter:DKIM-Signature:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-Debian-User;
	bh=6+DIIko/jddTALojzUdCwqYFD7qAVSieeB13vaTbTZ4=;
	b=3ZRUCpDbmpEIqJg6asZuWCc8fZxzo6lXaaSCZ0QAxP95vLI7LAQKcX9iohx0TsIgU1va
	 QTCQH6UO/prTdzSOxtGty+PEHCFS9gxfcgdDwUDTIDO+KF2UrMC+hIfrKbno6sAIIHCHX
	 Pnt/VW+p7jrXC6xEZ+yX7nTykz7R5OhdVuFCPQBEvrcsnB5UL4etyyEpvKyffZ/B5JHfC
	 rPeAdPgYjX4Ox0IBDUvQ0dmGh9A/d4tlouZAkjgs3eoZcLbblxEvT4fsiU26tlsbBU3yd
	 4YMi9mRgAwMd7CawaTdNiNWpC2QZimU59ww6viAdoJL39aN3SflSSlyy2qCaOHa2AcQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=debian.org;
	spf=pass smtp.mailfrom=debian.org;
	dkim=pass header.d=debian.org header.i=@debian.org header.a=rsa-sha256 header.s=smtpauto.stravinsky header.b=R5XxGFbM;
	arc=none smtp.remote-ip=82.195.75.108
Received: from stravinsky.debian.org (stravinsky.debian.org [82.195.75.108])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (prime256v1) server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 579BC606A324;
	Wed, 11 Nov 2026 11:59:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 579BC606A324
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=debian.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=debian.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=debian.org header.i=@debian.org header.a=rsa-sha256 header.s=smtpauto.stravinsky header.b=R5XxGFbM
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=debian.org;
	s=smtpauto.stravinsky; h=X-Debian-User:In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=6+DIIko/jddTALojzUdCwqYFD7qAVSieeB13vaTbTZ4=; b=R5XxGFbM6TZRqhT0SXxuzcMt1x
	LUNRh7V8lAnKwChToktKXZ/BvtFiWDBfAUJ9dLKtb2UHW2064KOlAZ6KUeSJJgWg/hPASfykHm9lb
	dvvgSD9ejQiiI+LIrAd6gbPGs/9xZWqr0yWBdHoCClUgJD2Bg1YMupaoC/QOZRmfVPSCT6MpDMhbS
	246KM0GzqcBbc4E2580QxhluNnyoa2vW19Sk2kqFlCkeQ6ViS/yest6rZWy5lPKlR+T/Ay7hDfWGq
	IJLMSEFD0EmRJ6D4dVOiq+0BkJb7lfNarlib+MyMxjNYvepLWzR3xSOakoCQkMgy3TimUB70/p52t
	iE2dAMXA==;
Received: from authenticated-user
	by stravinsky.debian.org with esmtpsa (TLS1.3:ECDHE_X25519__RSA_PSS_RSAE_SHA256__AES_256_GCM:256)
	(Exim 4.96)
	(envelope-from <leitao@debian.org>)
	id 1xR6yh-00DAF9-2o;
	Wed, 11 Nov 2026 11:59:00 +0000
Date: Wed, 11 Nov 2026 03:58:49 -0800
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
Subject: Re: [PATCH RESEND v2 39/51] powerpc/crash_dump: recover from a
 machine check in copy_oldmem_page()
Message-ID: <avRXzzCSzT9Qj2FC@gmail.com>
References: <20261104-work-procfs-bugfixes-v2-0-021c84d852e0@kernel.org>
 <20261104-work-procfs-bugfixes-v2-39-021c84d852e0@kernel.org>
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
In-Reply-To: <20261104-work-procfs-bugfixes-v2-39-021c84d852e0@kernel.org>
X-Debian-User: leitao

On Wed, Nov 04, 2026 at 08:25:32PM +0100, Christian Brauner wrote:
> A capture kernel reads the memory of the crashed kernel, and that memory
> may well have uncorrectable errors. On powerpc a machine check in the
> kernel is only recovered from if the instruction that took it has an
> exception table entry (cf. mce_common_process_ue()). copy_oldmem_page()
> copies with copy_to_iter(). For a read() of /proc/vmcore that is a user
> copy, all of whose loads have exception table entries, so the machine
> check turns into a short copy and read_from_oldmem() returns -EFAULT.
> 
> But since commit 4a22fd20379c ("vmcore: convert __read_vmcore to use an
> iov_iter") /proc/vmcore can be spliced too, and splice(), sendfile()
> and copy_file_range() copy into kernel pages with memcpy(), which has
> no exception table entries. A machine check there panics the capture
> kernel. The same goes for the reads of the ELF headers and notes that
> vmcore does itself, and those have been memcpy() for as long as
> copy_oldmem_page() has had its kernel buffer branch, since commit
> 54c32021eb6f ("[PATCH] powerpc: Add arch-dependent copy_oldmem_page").
> 
> Copy with _copy_mc_to_iter() instead. PPC64 selects ARCH_HAS_COPY_MC
> and there it uses copy_mc_generic() for kernel and user destinations
> alike, which has the exception table entries. Everywhere else it is
> _copy_to_iter().
> 
> Reported-by: Chris Mason <mason@kernel.org>
> Fixes: 54c32021eb6f ("[PATCH] powerpc: Add arch-dependent copy_oldmem_page")
> Fixes: 4a22fd20379c ("vmcore: convert __read_vmcore to use an iov_iter")
> Cc: stable@vger.kernel.org
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Reviewed-by: Breno Leitao <leitao@debian.org>

The change is the right direction, and x86_64 has the same gap.

arch/x86/kernel/crash_dump_64.c:__copy_oldmem_page() copies with
copy_to_iter(), the same as the powerpc code this patch changes. x86_64
selects ARCH_HAS_COPY_MC, and _copy_mc_to_iter() is already available,
with the _copy_to_iter() fallback in include/linux/uio.h for arches
without it. The plain and encrypted paths share __copy_oldmem_page(), so
one conversion there covers both.

PS: I found this because I am looking at x856 production fleet  kdump
success rate , where first kernel died of an MCE very often produce no
usable vmcore at all, and makedumpfile never finishes due to this type
of problem.
