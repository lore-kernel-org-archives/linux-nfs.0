Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=78.133.224.34
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794200762;
	b=LrG+DEEu60gJ62vzns+suZGrmEKRK0YtqaHn5WXr5tf1yY7yw2FGKosUn4N+BWIWmOzs
	 8YH/Z6kAKOq4DRdwxOIEF0uum3MNQ6sCiYT0Fw65sBfM4bp/fX8HEACI+pycPrG3ANgmF
	 0e10FM85Y90n9GEZcqj87xUzIjkfQ/2fgrRTTZEIXUQNyHeEJpNXiahk1rg7KYhStQ9op
	 YLCUgBffpmj2YMNgfPSXl3fGEOwwhzwTt0uQ206cqbDieW5ZiklOrT9pcbyG39aXWuNZx
	 VvAsG/FBocSTQw9IdspRDLu10fZf/+qpupZfv4YzTLCI7UtjDMFiAtdlH9J7SNs3TFw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794200762;
	h=DMARC-Filter:Received:Received:Date:From:To:cc:Subject:In-Reply-To:
	 Message-ID:References:User-Agent:MIME-Version:Content-Type;
	bh=+UmCB5muc9jAh5/NVu2M6h8Lcfrpgge2sRUuegusfl0=;
	b=0OuLEIAgKXU7KAvFozkBBa3f1Mv708ZV/mV7AuEqlv+uNv4RQQ6oxLuRg70CaAlrcQda
	 kU+/oTwNmCk/zqSL6WGacdL2KhGdhRBP6iAjFnQhUyBufPVmyVo9NSydGNXPPqZidzbqi
	 rRT5RxlkRrYqJHI5/17JfeD3gW4i53LeqT0Re6P4C2VxMjHeIXqA+pU6csayT4bFkvyt4
	 s5t29sErJRBTR2rzX/A9fzsDpt6mOW6cR2LBeiVOQFpMyu9K53GhNNVYS7dh5dhlWNz11
	 w9LLnBMkuA51LXElSj1oFDY8oQxhCWOlue9fVSB2NQO3QDlefZUvazzMdeLxRtRqsDw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=orcam.me.uk;
	spf=none smtp.mailfrom=orcam.me.uk;
	arc=none smtp.remote-ip=78.133.224.34
Received: from angie.orcam.me.uk (angie.orcam.me.uk [78.133.224.34])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 187C9606A322;
	Mon,  9 Nov 2026 05:05:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 187C9606A322
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=orcam.me.uk
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=orcam.me.uk
Received: by angie.orcam.me.uk (Postfix, from userid 500)
	id B42DD92009C; Mon,  9 Nov 2026 06:05:57 +0100 (CET)
Received: from localhost (localhost [127.0.0.1])
	by angie.orcam.me.uk (Postfix) with ESMTP id B0D2992009B;
	Mon,  9 Nov 2026 05:05:57 +0000 (GMT)
Date: Mon, 9 Nov 2026 05:05:57 +0000 (GMT)
From: "Maciej W. Rozycki" <macro@orcam.me.uk>
To: David Laight <david.laight.linux@gmail.com>
cc: Christian Brauner <brauner@kernel.org>, 
    Geert Uytterhoeven <geert@linux-m68k.org>, linux-fsdevel@vger.kernel.org, 
    Linus Torvalds <torvalds@linux-foundation.org>, 
    Jann Horn <jannh@google.com>, Josef Bacik <josef@toxicpanda.com>, 
    Chris Mason <mason@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
    NeilBrown <neil@brown.name>, Eric Dumazet <edumazet@kernel.org>, 
    Thomas Gleixner <tglx@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, 
    Jonathan Corbet <corbet@lwn.net>, Christoph Hellwig <hch@lst.de>, 
    Greg Kroah-Hartman <gregkh@suse.de>, 
    Joel Granados <joel.granados@kernel.org>, Kees Cook <kees@kernel.org>, 
    Jan Kara <jack@suse.cz>, Jan Kara <jack@suse.com>, 
    linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, 
    linux-acpi@vger.kernel.org, linux-kselftest@vger.kernel.org, 
    linux-s390@vger.kernel.org, linux-scsi@vger.kernel.org, 
    linux-um@lists.infradead.org, linux-wireless@vger.kernel.org, 
    linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org, 
    ntfs3@lists.linux.dev, platform-driver-x86@vger.kernel.org, 
    coreteam@netfilter.org, kexec@lists.infradead.org, 
    linux-pci@vger.kernel.org, linux-sound@vger.kernel.org, 
    netfilter-devel@vger.kernel.org, dri-devel@lists.freedesktop.org, 
    ibm-acpi-devel@lists.sourceforge.net, jfs-discussion@lists.sourceforge.net, 
    linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, 
    linux-cifs@vger.kernel.org, linux-fbdev@vger.kernel.org, 
    linux-hwmon@vger.kernel.org, linux-mm@kvack.org, linux-sh@vger.kernel.org, 
    linux-usb@vger.kernel.org, samba-technical@lists.samba.org, 
    sparclinux@vger.kernel.org, linux-m68k@lists.linux-m68k.org, 
    linux-doc@vger.kernel.org, linux-serial@vger.kernel.org, 
    linux-atm-general@lists.sourceforge.net, Takashi Iwai <tiwai@suse.de>, 
    linux-input@vger.kernel.org, linux-raid@vger.kernel.org, 
    linux-ext4@vger.kernel.org, linux-modules@vger.kernel.org, 
    linux-debuggers@vger.kernel.org, Chuck Lever <cel@kernel.org>
Subject: Re: [PATCH RESEND v2 14/23] proc: let procfs copy in writes before
 pinning the entry
In-Reply-To: <20261108185953.28054fb3@pumpkin>
Message-ID: <alpine.DEB.2.21.2611090504170.17804@angie.orcam.me.uk>
References: <20261104-work-procfs-core-v2-14-76ace653a773@kernel.org> <CAMuHMdVfakapgBK6TBhO1iWX8qzvLDk8jzRS=t2MVa5G=MCUeg@mail.gmail.com> <20261107-akteur-gemieden-eckdaten-21304d085e35@brauner> <20261108185953.28054fb3@pumpkin>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII

On Sun, 8 Nov 2026, David Laight wrote:

> > > While at it, I think it would be good to use this conversion as an
> > > opportunity to replace "char *" by "void *", which will probably let
> > > you drop several casts from users.  
> > 
> > So I tried that too. The thing is it drops exactly one u8 * cast in
> > ntfs3's label write. 
> 
> Since char is now unsigned that one isn't even needed...

 Please excuse me missing the context, but what circumstances does your 
claim refer to?

  Maciej
