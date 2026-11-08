Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.52
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794164398;
	b=FnQEhYe5ZkVyHzP3aEtubg0Av8SevJIbMxH3oxVj+rzvLg8PvDhKm8c2bYIbRGZWv2NO
	 OE4tDUMUD5/KVkMQNDHYss8DaGHOwVheedwRmlycbLHfhxq5T7T/FM6b84gUwsJerNQwk
	 8LyZLkTnoKofP9Qus766DRrtL8LoXIxVwdD8OGJIGmFZ5M77DyVt5XFmIB1+RO2OnLLyZ
	 iFKX4zu4RTuuh/tV5gctGeRNUnO2kuIl0kOso7nJcwIzvAQvSCGCs+q5t6T6aylR7o+g0
	 TrekyVsbr8oWucGlLipoMlsgYBd51+QhuY0iE/xmyzPM5lgM+obXPNzd6f30yNYJYnA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794164398;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Date:From:To:Cc:Subject:Message-ID:In-Reply-To:References:X-Mailer:
	 MIME-Version:Content-Type:Content-Transfer-Encoding;
	bh=JLhUwzup1lwefYy8NOOFjthYnrByVfTsqIe79kkV+Lk=;
	b=N1+VrlkWmRfo1kqX/W7X3it7W3ZxYNBTo5om461keTHqkmKA7yZqD1aNAvh9hCtdH8wf
	 i0o+9gqW43mY3PvcyvPil1lFkVitgqSCncR2uIQgsg56lE4XH8oRJ8jiZLzUYtyylxn4Y
	 5B9NkeR8FOou9rNSO/05e04CegsjFUjvaakok2n9Dp2VDhlt/k8a5naTAUH59NeyJ1kZM
	 TOoC/7s0CoBJS8zD1LRck7TD/q4Sg416sIvlqVtlgf7wWCybKSPFIO6jC4spHllG5w8VX
	 /XM7DQsmshyIyBg8DtUZqRojy8yDsE/p3lW6rGfIiXj6PaVRKdZcrlDjPykevBhJ07g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=XrEUEgHU;
	arc=none smtp.remote-ip=209.85.128.52
Received: from mail-wm1-f52.google.com (mail-wm1-f52.google.com [209.85.128.52])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3E7D7606A33E
	for <linux-nfs@vger.kernel.org>; Sun,  8 Nov 2026 18:59:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 3E7D7606A33E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=XrEUEgHU
Received: by mail-wm1-f52.google.com with SMTP id 5b1f17b1804b1-4a35ac4475dso1148485e9.2
        for <linux-nfs@vger.kernel.org>; Sun, 08 Nov 2026 10:59:58 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794164397; x=1794769197; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:mime-version:references
         :in-reply-to:message-id:subject:cc:to:from:date:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=JLhUwzup1lwefYy8NOOFjthYnrByVfTsqIe79kkV+Lk=;
        b=XrEUEgHUwv+lt2Z0T4RzlOQuYT1yMbnY/MJrtF5HY2pc8m0ujKE+1IGJbqc3A1SsPJ
         Pz+po0Wh7ECcrOl1hyNdZBme+OsO/r11IeCA1lW9KMbstFhlOkC0Hm7Ef+TTavGsfrDk
         7T2AE8nlcorDhYFpLo0KTCt4xOv09AacMRilfH2h4PS2mZ0iBReAF8XAcgtI3iT+qlRY
         EJQPYUIUlDRCCjadf1+24R8V0flZyhCZpLCroCVsidoQ510350k4POOaAcSXgGRrBTWF
         rbpUnz5O6K0TOR8uz/zwLHiObwDAqnCJFWP0+ssCNYCBYnXJwQ2yMfUqdKkv6ro/lp/q
         XMaA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794164397; x=1794769197;
        h=content-transfer-encoding:content-type:mime-version:references
         :in-reply-to:message-id:subject:cc:to:from:date:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=JLhUwzup1lwefYy8NOOFjthYnrByVfTsqIe79kkV+Lk=;
        b=MJ2O1V6KpaF1GLo5tjIiM4rKqanhtkQ5Z8mNX5wlI944TXKcqbBEO2aSpV1EtkAZu2
         Y+MK6eGkxgV9E2W+bJDPdnCfwmP/qyNWKWXmz5/B57Ppue+ScL27vSAVPifj/cRiyX8B
         X1CohNZRhvJfjk2ZMMKiQCgPzCfRKsbWDXsOhSAdmuNKKtw0FwuBOOMKnTbb8z2xqK9c
         YqQBYmzcbonz6kBfnKUvhl2Xq+M52XbYRQ3m0OwMOucI6TTGpyf4dJRuoXcr1J2w1UP9
         DKAT94ycR/xDAI///Vvqg1NqztHkwMPT8sB+qNWFLY1KoltrUr+OJ/ZhEY+gei0ndOZ+
         lFuA==
X-Forwarded-Encrypted: i=1; AL+hErF2duSqIy8LVR+JeqQmdlbj7xzrIOi7EX5yZeqrB6d7VB8QVglOEbhYHG/L00nzprWn5ERSDuoLKTU=@vger.kernel.org
X-Gm-Message-State: APuU4Z8ijdMF9VbiizOajHiObVIDq2F2YJ5FeDlzQZEdn38E89wV6wvS
	j4i0fKNFub976yLUp6qZ1TZ9tH6zToc5mn74lochKpkLbVQm1RBNT028
X-Gm-Gg: AYBFou3FQs+g/jm6tEk5JQq3h+WiujAYnakjwNcSbsaCR7FQo4YZX63/msWT102ShHj
	ihnVKLaRBGSRDB5AyeNmNqg+clyposoRkB2Dwdu4JyFvk3Be/bVIZNYemv9ioDO+tYmbMUs2X2x
	iOn+YK9PFAotF8R/6eiEG91ICvG3wku1wSxAZCPl8OuDSFwPlYx4P3eePQbTqfIq2rAmIyHNcJR
	SPLSrE59wF3O4aMBcfTj8Wiigrsijf07AZaLcJdlfJ1rcEeWtzKgagl6odn4Z+wv4XYlYwGqVtU
	6l4pGtGdn5d8UTXm5bTi8Ow6tG6Okz5cPyidSsfWbsSnlpFbXSD/STuQS3HwEaFFjgxwe5qLGlg
	CwSw2canECxE/ChllZOhDRgS6MBH7N3htWUWVO29NkeKcTAHtLU+1CUKaQlQGZ8Zp4+nMEEqYYi
	2B+nEwxJ8VPVby5n2NOoNEDyRhmAOpvP9Lkm5jVruODiEip+wjLJ1gn/SqVVHO9ki121oluaNtv
	MHIcdsgLYOnfotq/w72QzrX9JK4A6lp5hvlxNpx0tzUCAiRT8UTWXNwGwV3rC8ZdDXpgIOu6tR9
	1i/SAWn7IQ1YTZyfkIr58gA0kHCV1/CtS0x8L60bHNVd6pj9nDt8foh8ba801o9l
X-Received: by 2002:a05:600c:468f:b0:4a1:7e77:c382 with SMTP id 5b1f17b1804b1-4b960d9b170mr35982125e9.5.1794164396406;
        Sun, 08 Nov 2026 10:59:56 -0800 (PST)
Received: from pumpkin (82-69-66-36.dsl.in-addr.zen.co.uk. [82.69.66.36])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4b7efb1f3acsm185228445e9.14.2026.11.08.10.59.55
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 08 Nov 2026 10:59:56 -0800 (PST)
Date: Sun, 8 Nov 2026 18:59:53 +0000
From: David Laight <david.laight.linux@gmail.com>
To: Christian Brauner <brauner@kernel.org>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
 linux-fsdevel@vger.kernel.org, Linus Torvalds
 <torvalds@linux-foundation.org>, Jann Horn <jannh@google.com>, Josef Bacik
 <josef@toxicpanda.com>, Chris Mason <mason@kernel.org>, Jeff Layton
 <jlayton@kernel.org>, NeilBrown <neil@brown.name>, Eric Dumazet
 <edumazet@kernel.org>, Thomas Gleixner <tglx@kernel.org>, Al Viro
 <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Christoph
 Hellwig <hch@lst.de>, Greg Kroah-Hartman <gregkh@suse.de>, Joel Granados
 <joel.granados@kernel.org>, Kees Cook <kees@kernel.org>, Jan Kara
 <jack@suse.cz>, Jan Kara <jack@suse.com>, linux-kernel@vger.kernel.org,
 linux-nfs@vger.kernel.org, linux-acpi@vger.kernel.org,
 linux-kselftest@vger.kernel.org, linux-s390@vger.kernel.org,
 linux-scsi@vger.kernel.org, linux-um@lists.infradead.org,
 linux-wireless@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 netdev@vger.kernel.org, ntfs3@lists.linux.dev,
 platform-driver-x86@vger.kernel.org, coreteam@netfilter.org,
 kexec@lists.infradead.org, linux-pci@vger.kernel.org,
 linux-sound@vger.kernel.org, netfilter-devel@vger.kernel.org,
 dri-devel@lists.freedesktop.org, ibm-acpi-devel@lists.sourceforge.net,
 jfs-discussion@lists.sourceforge.net, linux-alpha@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, linux-cifs@vger.kernel.org,
 linux-fbdev@vger.kernel.org, linux-hwmon@vger.kernel.org,
 linux-mm@kvack.org, linux-sh@vger.kernel.org, linux-usb@vger.kernel.org,
 samba-technical@lists.samba.org, sparclinux@vger.kernel.org,
 linux-m68k@lists.linux-m68k.org, linux-doc@vger.kernel.org,
 linux-serial@vger.kernel.org, linux-atm-general@lists.sourceforge.net,
 Takashi Iwai <tiwai@suse.de>, linux-input@vger.kernel.org,
 linux-raid@vger.kernel.org, linux-ext4@vger.kernel.org,
 linux-modules@vger.kernel.org, linux-debuggers@vger.kernel.org, Chuck Lever
 <cel@kernel.org>
Subject: Re: [PATCH RESEND v2 14/23] proc: let procfs copy in writes before
 pinning the entry
Message-ID: <20261108185953.28054fb3@pumpkin>
In-Reply-To: <20261107-akteur-gemieden-eckdaten-21304d085e35@brauner>
References: <20261104-work-procfs-core-v2-14-76ace653a773@kernel.org>
	<CAMuHMdVfakapgBK6TBhO1iWX8qzvLDk8jzRS=t2MVa5G=MCUeg@mail.gmail.com>
	<20261107-akteur-gemieden-eckdaten-21304d085e35@brauner>
X-Mailer: Claws Mail 4.1.1 (GTK 3.24.38; arm-unknown-linux-gnueabihf)
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
Content-Transfer-Encoding: 7bit

On Sat, 7 Nov 2026 10:48:35 +0100
Christian Brauner <brauner@kernel.org> wrote:

> > While at it, I think it would be good to use this conversion as an
> > opportunity to replace "char *" by "void *", which will probably let
> > you drop several casts from users.  
> 
> So I tried that too. The thing is it drops exactly one u8 * cast in
> ntfs3's label write. 

Since char is now unsigned that one isn't even needed...

David
