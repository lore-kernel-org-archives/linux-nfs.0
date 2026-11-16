Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=78.133.224.34
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794812947;
	b=ePYLK8Y++vV92rE1O+zSZCs4lo87Otb4FfAJWiDs70cEphLaB2Y96yBMFN3hxfG6Wu7S
	 ID1wO3/s7IRKmfszS6ass9rVS/NkT+0IEKNclHH6Na5A1XglLvVX89hw6EX3OTizXWw11
	 XaY2Vq2klq+DvtRoTGG5+ExU/nDQ1RsbCFoZ8eimZrSHXVAtAp/S1UOfts+Fre8by4a0k
	 75Ao4/kAVxy2XfqfbsSPh5jyAdGfMPBkfJKDBLVoPGrY+SF+4T5MKQQKPRboRM10D4ihZ
	 XGbgoYXU6qr45whCoELyMp4Xzt4TGUiDdtmlGclm984F6gQjikei6KsKoZ/5SsaMAvg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794812947;
	h=DMARC-Filter:Received:Received:Date:From:To:cc:Subject:In-Reply-To:
	 Message-ID:References:User-Agent:MIME-Version:Content-Type;
	bh=1mHmG9IJHtIMld4ZeRanDjKIMZUQxx8f0ptnWkrCv+U=;
	b=0i8RahmNidBKHbWBeQckX6v4j9iCyuvVL/fZe/BEsPc/Xoe2nv+21TKq8Z9boKNYHrYK
	 TotB7T80Z1D6oFXyUkcSsAhoCh3IC2ARjY/i+UN6pi3dNYn0B76azB/X9E/tIfcdqgcSB
	 9AKBwpQFVyOBZwo6poe7axdA/vqIytMUUML/LMiEAVafmfqLwAHbYtegV4ihhnpc2LQN1
	 1aZBowjXeK5BftnnOth8JJo70ZfTNBNImfEeyD/SSoOHs0mtHF983Xw9qw+XNmuv9T2VO
	 QrXYqlONvEBxO/uVPvcWVve8MQ3C5gxmDeM/Gca8NoKmNnPn6fkxMNR6i7ZoQw4/UxQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=orcam.me.uk;
	spf=none smtp.mailfrom=orcam.me.uk;
	arc=none smtp.remote-ip=78.133.224.34
Received: from angie.orcam.me.uk (angie.orcam.me.uk [78.133.224.34])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 364A6606A332;
	Mon, 16 Nov 2026 07:09:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 364A6606A332
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=orcam.me.uk
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=orcam.me.uk
Received: by angie.orcam.me.uk (Postfix, from userid 500)
	id 39D8A92009C; Mon, 16 Nov 2026 08:09:04 +0100 (CET)
Received: from localhost (localhost [127.0.0.1])
	by angie.orcam.me.uk (Postfix) with ESMTP id 376CC92009B;
	Mon, 16 Nov 2026 07:09:04 +0000 (GMT)
Date: Mon, 16 Nov 2026 07:09:04 +0000 (GMT)
From: "Maciej W. Rozycki" <macro@orcam.me.uk>
To: Linus Torvalds <torvalds@linux-foundation.org>
cc: David Laight <david.laight.linux@gmail.com>, 
    Christian Brauner <brauner@kernel.org>, 
    Geert Uytterhoeven <geert@linux-m68k.org>, linux-fsdevel@vger.kernel.org, 
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
In-Reply-To: <CAHk-=whsA3tKcUCBJDj_vmJ11rVGT9rivgnKjGRgMO21CPmCxg@mail.gmail.com>
Message-ID: <alpine.DEB.2.21.2611160657470.17804@angie.orcam.me.uk>
References: <20261104-work-procfs-core-v2-14-76ace653a773@kernel.org> <CAMuHMdVfakapgBK6TBhO1iWX8qzvLDk8jzRS=t2MVa5G=MCUeg@mail.gmail.com> <20261107-akteur-gemieden-eckdaten-21304d085e35@brauner> <20261108185953.28054fb3@pumpkin>
 <alpine.DEB.2.21.2611090504170.17804@angie.orcam.me.uk> <20261109214558.0d9d5228@pumpkin> <CAHk-=whsA3tKcUCBJDj_vmJ11rVGT9rivgnKjGRgMO21CPmCxg@mail.gmail.com>
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

On Mon, 9 Nov 2026, Linus Torvalds wrote:

> > Just that the cast would have to be:
> >         u8 *foo = (u8 *)bar;
> > where 'bar' is 'char *', and I don't think you need a cast there when
> > char is unsigned.
> 
> .. and just to clarify: 'char' is always unsigned in the kernel on all
> architectures since commit 3bc753c06dd0 ("kbuild: treat char as always
> unsigned") back four years ago...

 Thanks, yes, that's the piece of the context I was missing.  I've since
actually come across this commit while investigating which Linux ports 
have plain `char' signed in the psABI (MIPS for sure).

  Maciej
