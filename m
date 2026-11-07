Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794069814;
	b=X8nlDF0sXANpnSLfuYz/k39R8H7gKb44F1WYLef+2FDZ1qkebDKTj8wUw6QRtbf+tDSH
	 cZbL4wyceg9fDcMCOGhutmdkoCbar2I8/jdV8cqXaxZI6tCCIQAdzyCh2E7i9sdCUgy0R
	 cHOzJpEWSDGmPfhW0YIVT4zdd9hRQnp7fx4FsTggj692gvb7vF5MzvMnDK8dJ2xuTH3Uv
	 F+3EzPw01CssFYHFdr9HZMG1MZDIrGU/XmLQfM1vuub6MhFCU0i46OuG+wI8Zlck8i3iO
	 Vc1h7ymCPibi+sNc/ndUFXdbvHd4J666O/Z/1ulk7Th1CV9VhhR2F6qA5s87BNwbsHg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794069814;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=vJlfnNqej/LkG6MaOOq3+jKdNMX9ZNsvcUBYJfUwMpw=;
	b=cwBUHQ3tWJICORqVVwDzxCaGx2d5eeErnvq03OxGKh3BQ/uUb0ZjBK8LjAY3oIUSzFtS
	 7b8GllKh4SSjqYUjkOcdcxdJNSscnP+bKRybu2SecM8YrhWm2NWfyYk8ih37qvDJzMhGp
	 tco7caG3+NE71auliAI9ZYO/nan+fvFEztvTgMTf8YJeyzoP9CzHOnD3j8y6tHxy0ulcE
	 1tlFB7Q+R35Hi67esCtRlVAGhJE9zdBSMuSG7SJ/XW/WrbMMp7hk1AeNBtd3zIanG+P6c
	 4X/n2SKh+7gBgAEmDox/KCfjGjVYSXNooD86kj+Eonz01JJA4OgyMYEfoFDug+3m2iQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Ec9OinBL;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6888E606D807;
	Sat,  7 Nov 2026 16:43:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Ec9OinBL
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D87E21F008A3;
	Sat,  7 Nov 2026 16:43:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794069813;
	bh=vJlfnNqej/LkG6MaOOq3+jKdNMX9ZNsvcUBYJfUwMpw=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=Ec9OinBLTdERos6h50EC0xUMTn77I2eH+sW83Lh5kwSY9BvV2OOVa/KNof0GP2Q58
	 RS4VV3vBrJ/LJog1T9lg0D2JE4OoyqUja1mYU0rh9TBbXyPIEhQRpsuojcmq8ZMIA4
	 CCDIxEY1vZFYI7ppfT5M0lTExZ07bRV7cMY147urYKAEBYKJp+dYFF+px+uccoSGQJ
	 uVAe3HJmFJqNBLzSUpkpxl6XM/ygvvEBAxQusxKpDQigosD1nBGLgkLmP/DR4y72y1
	 LgnZYxUr+IR4Egl8rgUGA8KwMUI2eGvYxK8dwEAUy7fQvT097QujPauhtAAp8a8K3u
	 wRcc9px1LLfNQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 1E9E1F40067;
	Sat,  7 Nov 2026 11:43:31 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Sat, 07 Nov 2026 11:43:31 -0500
X-ME-Sender: <xms:MlXvakDJz2aoRG_Q0Tr3dYW0eo4APQUabQqIttoZFPRFZ-x9snzIqw>
    <xme:MlXvahUE11fMZOXF9JjGlaXmovQ63rXPe9CVrxbGMz01XC2UXZ8Ub-s6v11mUcT7K
    6EUgoab8dJTWAHO_c14xHkS1kUKnJq9SFX4dojoicG37nrqW8Y-SchLZQ>
X-ME-Proxy-Cause: dmFkZTF47JQfJLdRdMge2GMs+GugpouQhIspgU7BDymJQjozGtWeayorP8T8qJjOJtez5n
    Mu6YVQMuTAuQf8dNPbyiJidY6z5iDchqOk/rPreMnFBsaZEyFLA1xNLvX2+sRgAAEV6CpA
    18n7d+taVvJebv5vU6jJPdclNeeGqwUnruqBfjOVpjA4xXpT5GCaWy76JSn+teNqAA0ny2
    vVmyqvtCRPIMNOkOlHDxwf2R+IqqtIN68NFJGnHnqmIyGIjD3zNX0zKaDGqEk7Ze2onYqy
    9RdgDPRA3PikGN1W/7nDb8NiYp8Q9/+7zqfHAJcBEVt9DgwuHrHPFfmetOJuJSFKJUDZpN
    mbRzObrxaiH+VuPVfFTvBWVxOAq7xc3fchnSigBQCyM4PA4HDuL1vAF5IoeXrMQk2aUW21
    59Pn6Ph8ElZIblHku0CFRDKCKdVU/6BJGsrAIobO6f/CRmXPwJZ+FZIWnzEq4zHbFnFSj5
    2GavxWreHaI/dkosMa1/Hz50DzNovuOurQwGdhu5YM7nZSIaOcaigZUM86iQpTNPvFE5q8
    X0RucoetdeEG7ZlTg0zjUFsHpRlOfhY/tCKI3ix9kioMo32DZjUgaL6ky8l30WUfX53owO
    FaUB1P+IyjUQnKRpIIcJTsmMD1HsAXSFOSlEcd18MZD9Rox3fmXGxCSSzMdg
X-ME-Proxy: <xmx:M1Xvarm_GuLHtdhc-beslZ2ZxZoqr1pVXnXixSSL7TSDZnhBDdRW2w>
    <xmx:M1XvakuXdXodbZzwSGhXpuZDbgbK4xmWfFZIJTq2PW_KgUkMPLhQ2w>
    <xmx:M1XvakHt6uhcrYM_XDobstbNvikecMWxKGRyUkZcuWV3Fx0M6IIITQ>
    <xmx:M1XvakswcIzGwK3QU4AniovTIpZY-XUd3Ibq2iA0mAnVEdW_mDFClQ>
    <xmx:M1XvaqI_u5j39OfSlUWtLpJlRc3Dik8eKjcfeQJUyBgtS0utAvmxR5za>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id DFD31782738; Sat,  7 Nov 2026 11:43:30 -0500 (EST)
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
X-ThreadId: AE4uiykVHNXw
Date: Sat, 07 Nov 2026 11:43:10 -0500
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
Message-Id: <39d3364c-d4d1-4919-86c0-695f75946c95@app.fastmail.com>
In-Reply-To: <20261104-work-procfs-net-v2-7-221e2437fed1@kernel.org>
References: <20261104-work-procfs-net-v2-0-221e2437fed1@kernel.org>
 <20261104-work-procfs-net-v2-7-221e2437fed1@kernel.org>
Subject: Re: [PATCH RESEND v2 07/13] SUNRPC: let procfs copy in writes
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Wed, Nov 4, 2026, at 2:59 PM, Christian Brauner wrote:
> Implement ->proc_write_buf() for the procfs channel, flush and
> use-gss-proxy files so procfs copies in what is written before it pins
> the entry. The channel file parses the downcall from that copy and the
> flush files share the parsing with rpc_pipefs in do_write_flush(). The
> rpc_pipefs files keep copying in themselves.
>
> CACHE_DOWNCALL_MAX and CACHE_FLUSH_MAX name the limits both sides
> enforce, procfs through ->proc_write_size. The procfs files are removed
> when the network namespace goes away and that no longer waits for a
> writer that faults on its buffer.
>
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Acked-by: Chuck Lever <cel@kernel.org>


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
