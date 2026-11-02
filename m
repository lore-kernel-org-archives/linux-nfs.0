Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793653929;
	b=xWU5+2fJM1BsuIMJvqY6AaqB246Mc7uVo5hhBT8O3d0dhF/Lw2VfENTxWtVYniIIPfjn
	 Y20z8FeXiWvoFpfviWAA/ZVbx5kAF4OTLh3USHYHVbjj47dMtWzRTC2dYSQWwEuVyujq/
	 OYQTJnMgJuTQCF67MaEskpfZqo87kE5VyGTuqrAIU3AO0m9Q2R9yqZd1348s+myWrMba8
	 0DKzAZeCtmqdwTKCMDfV7egPOISpa8vltbdjsdmYX6JqbARtZQOc5soPduukiiYUAxKjs
	 a1Gc2Ti476fwpgh5XZOeFV4qNODUd/U1mtonhy06cc0nFziOVsYQQiCHVpp1x6aKttg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793653929;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=2GzKULsklpP+bGy2QkTiTCDYRGUHpWIftO7smBM1HBU=;
	b=As0S1b/liVBH11NA8aHYlbkt7vNAhuI6PxE3P5m0WVR7F2gw8ckCRFandObo2ELGXPcL
	 UlOhsCgr+JflD9i2VidcXTSIuq++nRaiU7D5vsAINpNYobEfQB7CuxAQh0yNFo8nXb9z6
	 1TMvJMq/pQwOU8b7lH9RABZJKBvCADNVtJ54kgKBrgQXuk5kPEEPc2kg7sXgCx9nqZRJ4
	 0BQuqsVyZ+7SiWvBXEn9Ij4AF9tj175AeSPrM8S4ojZ5ghTQwAtJf72cgjAW6EcvzJd2H
	 s9G/a3ppViBQ+eg6TpfNTOW677q/zK5wo6Y89n8X/9K5jxUjRWk3LxNAo3Gus8RiZjw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=IZvk7QS1;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 903D6606D837;
	Mon,  2 Nov 2026 21:12:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=IZvk7QS1
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 844801F00A1D;
	Mon,  2 Nov 2026 21:12:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793653929;
	bh=2GzKULsklpP+bGy2QkTiTCDYRGUHpWIftO7smBM1HBU=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=IZvk7QS1F7ydpX3Q+fnO0nYF1Y6yEAwEg13pq52La1tfnX4M+FCGRIJAiGUKTGA3C
	 KthXnHUbUGeohLtwAGTuen1HqqrgDfvjO1zvGKRnOykgQVP7btxYx3ZMjZAafNKwmc
	 Xv5ZGcU3U2lY3MaI/Ry9Ipq/RfA6TCa/8Gron3pvEpgXhyoFeOJntItGfK5ti8R296
	 LQOXqK1hgvqTKL8E1I7iv0BCyZQqSqxhDtY0lNkQ+rTrEkJxtHgkF4iuFzcVc/1ysO
	 TR73WqGw1IkONGfggFw+2WsmyZEgXSAdRGaiT+QPFYNWFp7+V2JS1/dTMhW5eMgdm7
	 v0jhQ4oNQdbEw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id BD91CF4006B;
	Mon,  2 Nov 2026 16:12:07 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Mon, 02 Nov 2026 16:12:07 -0500
X-ME-Sender: <xms:p_zoar5wEOL-zlzp67mMM3x-0bNAjLemfC24U704bCdiqApcAHrL5g>
    <xme:p_zoaruIAZVbhbJzkx6BZiPT6OnY7CcZh02-zEnuIJo4UcNxLgosp2J6h-TjliEVB
    ZqPJYchFTqtRNpd3xztymrlwtOCf3UCUYjdeN78ZHthOZxdfY00mLZG>
X-ME-Proxy-Cause: dmFkZTGxQYs5bpjtdWlj8Aj0/kqiZPUFTcG+D5sN6gK6OkOpehgbLdIraoHIQBNOWiC1QO
    mSiq7CL0AgyKU65TRh9vty9eizP0QQR2Z1J75kzFRAHQ8v9pgNzRqji+qoE5q3T4Jsup+X
    lzhToSRo/U4CDB0WiseMMwJQb5pcYnSUocPTYgbfxcxlJvkIz24hVYMUVudHFBxGqfAX9y
    NRDQxVeK5x1i3Ddsg7AnpUJtaaABZOgfFKMPhhjC21xlDH5T8xynEUHv8Edi58BP4r6DL0
    tXBEiINt8Tc23nn0L1i3BHrhk7xFRR/K75qYZJEABSfJdxx23pck1s5cvRrC4mNh0d07cq
    HGqupMbxlMLGMsZjotNq8oNhgdgag6r7eoO6ewOX1TyUeE9ji0ElKsavbILPyuWY3lDPj6
    kLgEwwgkqtpl6Law0FU+iVEL+uJ3v7diWIhR0jGD6twa2ajmdS50u8Oktw1hPNF+UDlUQg
    yRIKtfDMmxM/Iq3R6DZSCzcwPA38v1HlDy+8UHl2XtcweDNG2ziQfFDzT1wklzeKBNEIzn
    ncu1wt1SWxYrYOypHpFH//wS1fzQ136rl7/PeJ5P1hx6Kup+TY4sKx8NYC5+s3heyhXAT3
    qvO+b0k172/Cyt1JkoPLBDRysBXKaKKQpHWfUnjG6Zu8N7q1Sv1Cn7PvRxMg
X-ME-Proxy: <xmx:p_zoaoHJ7xvsGvW3yFXcg2GyCfq0QOXNhFMLApvXbwcVoRvOTLpFJg>
    <xmx:p_zoaqD_fWcNQS-k0yAhxYt-R3IJf7E5eyB3ofH-w9Jcw-Ciu6FGTA>
    <xmx:p_zoaiEsVZ8oScPDYN1YcYKCJawqQx0MVy6PLKPjVBYTbZu4plkUXw>
    <xmx:p_zoamlot3YNd3N_kPvGE0BeCL_hccbMjKBcqkXjEFdndcPA6R8aDg>
    <xmx:p_zoajqn1Cb4ZRHuQPt4ntIWweEfW3VpSRM9FhhgkVteT1l-hSkXouXh>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 96E7B78273E; Mon,  2 Nov 2026 16:12:07 -0500 (EST)
X-Mailer: MessagingEngine.com Webmail Interface
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-ThreadId: A5s7LfNSi9ds
Date: Mon, 02 Nov 2026 16:11:47 -0500
From: "Chuck Lever" <cel@kernel.org>
To: "Christian Brauner" <brauner@kernel.org>, linux-fsdevel@vger.kernel.org
Cc: "Linus Torvalds" <torvalds@linux-foundation.org>,
 "Jann Horn" <jannh@google.com>, "Josef Bacik" <josef@toxicpanda.com>,
 "Chris Mason" <mason@kernel.org>, "Jeff Layton" <jlayton@kernel.org>,
 NeilBrown <neil@brown.name>, "Eric Dumazet" <edumazet@kernel.org>,
 "Thomas Gleixner" <tglx@kernel.org>,
 "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Jonathan Corbet" <corbet@lwn.net>, "Christoph Hellwig" <hch@lst.de>,
 "Greg Kroah-Hartman" <gregkh@suse.de>,
 "Joel Granados" <joel.granados@kernel.org>, "Kees Cook" <kees@kernel.org>,
 "Jan Kara" <jack@suse.cz>, "Jan Kara" <jack@suse.com>,
 linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
 linux-acpi@vger.kernel.org, linux-kselftest@vger.kernel.org,
 linux-s390@vger.kernel.org,
 "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
 linux-um@lists.infradead.org, linux-wireless@vger.kernel.org,
 "Linuxppc Dev" <linuxppc-dev@lists.ozlabs.org>, netdev@vger.kernel.org,
 ntfs3@lists.linux.dev, platform-driver-x86@vger.kernel.org,
 coreteam@netfilter.org, kexec@lists.infradead.org, linux-pci@vger.kernel.org,
 linux-sound@vger.kernel.org, netfilter-devel@vger.kernel.org,
 dri-devel@lists.freedesktop.org, ibm-acpi-devel@lists.sourceforge.net,
 jfs-discussion@lists.sourceforge.net, linux-alpha@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, linux-cifs@vger.kernel.org,
 linux-fbdev@vger.kernel.org, linux-hwmon@vger.kernel.org, linux-mm@kvack.org,
 linux-sh@vger.kernel.org, linux-usb@vger.kernel.org,
 samba-technical@lists.samba.org, sparclinux@vger.kernel.org,
 linux-m68k@lists.linux-m68k.org, linux-doc@vger.kernel.org,
 linux-serial@vger.kernel.org, linux-atm-general@lists.sourceforge.net,
 "Takashi Iwai" <tiwai@suse.de>, linux-input@vger.kernel.org,
 linux-raid@vger.kernel.org, linux-ext4@vger.kernel.org,
 linux-modules@vger.kernel.org, linux-debuggers@vger.kernel.org
Message-Id: <7a864852-252c-4a62-b4f7-33072e33b7dc@app.fastmail.com>
In-Reply-To: <20261102-work-procfs-net-v1-9-982104a4f592@kernel.org>
References: <20261102-work-procfs-net-v1-0-982104a4f592@kernel.org>
 <20261102-work-procfs-net-v1-9-982104a4f592@kernel.org>
Subject: Re: [PATCH RFC 09/11] SUNRPC: drop the ioctl of the procfs channel files
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Mon, Nov 2, 2026, at 10:07 AM, Christian Brauner wrote:
> do_vfs_ioctl() answers FIONREAD for regular files with i_size - f_pos
> before it gets to the file's ->unlocked_ioctl(). The channel files are
> regular files, so cache_ioctl_procfs() has never seen FIONREAD and only
> ever failed other commands with -EINVAL. Drop it. Other commands fail
> with -ENOTTY now.
>
> The rpc_pipefs channel files are regular files as well.
>
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Acked-by: Chuck Lever <cel@kernel.org>


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
