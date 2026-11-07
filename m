Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794069871;
	b=N/VLVaqebUcx2tp7URcYI6picnpu8DPZV+zwRDtq/JhnCDVRAvlIF6h/SMZKGunR1jwq
	 zvgSp42Z6ptiS/ZeAZr+lQ/KxrUonRJrma2+rBC5090mQLtEKEKD8F1FzNAmY12WD6fFU
	 x0bU+07f93aTVj+nyuCERbaH4AyXsNlEjx4gfl3uyAqU/N2Q316WM40bqIbauDUpWjvlh
	 vXgevYnXsOvf5ynr99O8tkqAl1A2IGrwHxq3NLY4T7P4FojR3SFgsjBqWI0xq/ATnMTwF
	 ytBsj9/QPrwYzooD1sWW2uvimtEOEzT+NZCiQgcqmp9OrHTbkMrmmUeTg3c4Yksj3bA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794069871;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=G0TBUyhmKh6st027cPZY/A7ojV3HiUgM2XJr1Qt7yqs=;
	b=4J5SLPLROXYwNPlEaUEweIQDvXLWLkK9YDax6zNJf8MYSPYU3UavaZCdNW7s23O2FRRN
	 snpqutDXfeFUeMIIxK28zDxvKGQHNppKXRsXa3pkLbT1fUi+vgLZ3m1Gim71kvVgeOGyx
	 UIM++sKvirYXezHkDKI/vUUnCGT1KFTR/GusqnpqFvJ7PiRX+q0r/y/0a8Pih1K0NJ34C
	 cPGBiZZV0beV7BKnWagtOHTLOX4LZrgfACPJU4ewDam7qbR4KgSQsXoB9BGUw1WI1gID+
	 Cv5zrdoSPFHhVdhhB+5BsoYjz1mN94C8sqgDzKHdWHmtFd1o2auvSxKUdj+yxj0M1Ig==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="Q3lPZ/DM";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AB219606D803;
	Sat,  7 Nov 2026 16:44:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Q3lPZ/DM
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E2C7C1F008A3;
	Sat,  7 Nov 2026 16:44:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794069870;
	bh=G0TBUyhmKh6st027cPZY/A7ojV3HiUgM2XJr1Qt7yqs=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=Q3lPZ/DM6uQ6KxKqeMit86Uw4h24/Oj4MoAMD+U42UyqHSJq4m8RqVF8SFBtqbgkl
	 uLKz7uSZCEmnbuYs91ZPRuPISbz6KSUXhqlGhYcdFXvRs+fV4tNtz+fMJYc6LC8oMR
	 oFDFo+Teg8oUBRgmiYpBQfMzAA1XArB/oe6USeIIpMwY/xLRQ+GXugleq6FMCjsnvR
	 oL0GzjIOrGJ7szvoPIr8z2eQLBvFfcxaFY5OSG8DuQTl7sLA5iAPsPb9X1GVQmFWRl
	 v9+b0K+DLHBtV/h4SwZCCLNGLR2bk/lGk8/rlnYsXPGkRtp7eujxFA2FlH7COmPBxC
	 cINjf9/GH3c6w==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 3FA84F40067;
	Sat,  7 Nov 2026 11:44:28 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Sat, 07 Nov 2026 11:44:28 -0500
X-ME-Sender: <xms:bFXvandvnO8fT9Ny0BCMkPPq4EFCNpni2vpykfELem4aQ_ooyMfLPQ>
    <xme:bFXvaoAzA2Ev766iXQhLHmbFgZ3OtIBo7SEoGueehftkt2V279uG4gPc-dHGVACl4
    3eUuL64evjIj3at6Odni9S14c19BTcr-N9PUxIQTqRuyqO5bQpFvwjH>
X-ME-Proxy-Cause: dmFkZTFFrV0pX7VIZHKjzx4tcEIBivmHNdZcL0Pkl1lJMTa+tHru5crcMzNJ3Ws5mFJzd2
    XoT9/tbpTRQi5ChHG+aO2WivfTQ8W/O4HZ8iiDaUhj+m1NpPL+KAn6GP/9UxfYRXNa7cOc
    joX0s1lnfj++o3vhXCB/o3bz0dxm7d2O02yAjwOawfYiOaHUVz/507CGSU2dlZJBdpa+Lz
    mT8nq07x/0R9yoox5e3apvL89qLOUo53VSUiLJOZQeHJ+y5wU8qmJSABIKtsK2dgt8sOGA
    T0DJ96+tszK/FKEJttYLQ0VT04nQzocHzMxQ4SOw7VSUIeN3vxtysUHCL040YGaqf23dGj
    ivvheSUM0dUu5CxVO2D3v9xKFwvw7gFiwnI6UZYJP+uiexSaebviQXnQh8wljTipWYfAFU
    IDtD+lRbDheFBrn7MsE10utxcQB7tzgbJi/CxporQ/0eC9ISB6TmNPCUWQW6EWtOUS1W/V
    EfIMfzoVkcdnKDH3f2go0raKAX0SZ+/rZLtKb8QoFwHn2sRk1lRwwIBewPwH60y5mUz1IA
    WNrlo2pYNCHcEWWJdaW35YV6jWZAX+iToSdrBmlEz3no1vvx1gGr28JIlz5xbU3YSZffVC
    XOYDs0bBCET+39NKG1Rl3ZxSLfa2WPKKz5qq4UxbERsnsGjG5/I8hnQr8ljA
X-ME-Proxy: <xmx:bFXvaiBZo0cONei-bs8Nn0XJuMfXZQKqSffOVJ8zNsNVaUiIUh4gog>
    <xmx:bFXvaj54dGXonsoLgi1ZS_BqxfhmI6DHm1oV66RilkelMocJVZZgbg>
    <xmx:bFXvahk0NuZcDB1AhZh9ACjM7Ufrv3Lvp0-YaZL6LBc10s6td6_Deg>
    <xmx:bFXvaqY5dGBTySVeOdGC2PKrnCR7w_fFScEZ0z0S-oALV8B19pi_ZA>
    <xmx:bFXvagqosWNpEErQ6k8RVnvtVK1EAxpNL3pHPEOnn-RYopUKyguaOx3_>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 12146782738; Sat,  7 Nov 2026 11:44:28 -0500 (EST)
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
X-ThreadId: A37rHgw9iumg
Date: Sat, 07 Nov 2026 11:44:07 -0500
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
Message-Id: <a04dde49-8373-4687-a905-10c3a3b89492@app.fastmail.com>
In-Reply-To: <20261104-work-procfs-net-v2-8-221e2437fed1@kernel.org>
References: <20261104-work-procfs-net-v2-0-221e2437fed1@kernel.org>
 <20261104-work-procfs-net-v2-8-221e2437fed1@kernel.org>
Subject: Re: [PATCH RESEND v2 08/13] SUNRPC: let procfs copy out reads
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Wed, Nov 4, 2026, at 2:59 PM, Christian Brauner wrote:
> Implement ->proc_read_buf() for the procfs channel, flush,
> use-gss-proxy and gss_krb5_enctypes files so procfs copies what is read
> to userspace after it unpinned the entry.
>
> cache_read() takes an iov_iter now. The rpc_pipefs channel file passes
> one for the user buffer and behaves like before. The procfs one passes
> one for procfs' buffer, and a read still hands out at most one request.
> A reader of the procfs channel file whose copy out fails, a readv()
> with a bad later segment included, loses what was handed out, since the
> request moves on before procfs copies it out. If that was only part of
> a request the next read returns the rest of it. Both flush files share
> flush_time_text().
>
> The procfs files are removed when the network namespace goes away and
> that no longer waits for a reader that faults on its buffer.
>
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Acked-by: Chuck Lever <cel@kernel.org>


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
