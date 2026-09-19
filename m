Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BA12D377ECC;
	Sat, 19 Sep 2026 15:59:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789833575; cv=none; b=Gbs8Xxwm6ARjOOFNCNXSBaO1YmhYgzY39VeGLWZMAh7FCgWPbLwKTY20BE2MS8F7IrzqEX+RQJFW8z9nBZnyWqfUWDlLGpdjZ9KR3bitZNjA6nWCKt0RrxZE31YZsQJUSGLLyNFe3g6vbJUztikinNhLHk1VmPDmijIjOYMDQDo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789833575; c=relaxed/simple;
	bh=KuZxTGYmYI+18lYLipMVDIRS5uCzvWfO7Vz+l7dBcNw=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=e/Xa7Y7SKNvunM269jVkiMt7zY3hbFCBMyiMNTbLm9TPEfwMOOs3eXdbhBLnjVCJ0hJdm+/81HLpPokFmzi4YZ2REAo4Jsg8V4dZYvKUmAd+mieGbxBg2qKw8ySeyzO+JJIynjeD0VNPjKLMYcoTpvzOF0DmrIimZyxZl3rI/c0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=aAjXuHgc; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="aAjXuHgc"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C6D861F00893;
	Sat, 19 Sep 2026 15:59:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789833573;
	bh=q9tGf2FHjvgt3EYsyTdi+IQiT0IDvvD38OcRKEVlpoA=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=aAjXuHgcm5sppM0erniPLOOn7gm43yQzo7P62FKAx3TDITEaFopNgCC4QWS0kZJft
	 qNo8iSImnQMJ7NCiguVzszrCo/IWI/9cHIuuVseKKH11l+B/6F83X0lhNJggEPkT6C
	 DtHYX73KokrpS+joSM77K9MoO7U+A/ACuRYdJ/tJ+zlFVM2Z8leJiXF0mdi6yUL6/B
	 nstLOXyEyVJt3STxb4nUCq9KDltD0Qt2mcSs3upP5//5CZvKV6FGxKLa2whrMDxWDK
	 ZuxBxbtKcHdJZJmV6QJO+rBfeXzK/vLUAE2u9q/R8arNL5rIRKvu1lveFmCb7w0EgV
	 4/9SRQFMg0aGw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id DC7BCF40066;
	Sat, 19 Sep 2026 11:59:31 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Sat, 19 Sep 2026 11:59:31 -0400
X-ME-Sender: <xms:Y7GuasnpgOpticBZFGdWhC0dSIhSK0A_KuTB45BC8whK4OVed-iQ5A>
    <xme:Y7Guamr0yFme39V5i8WWcGesJIlReCzc7ecA3weMg41SVR6TFCH-RT1jpIjkV5fP0
    W_TCG5KVyNIZd9-b7F0DmQ1k8fZyCGgmGd59hpamNyWFRmZQMdoL-mO>
X-ME-Proxy-Cause: dmFkZTEWaFWew1YtC5kOyRNe16JieifWt0qiUM04EPgn9QLCnIWp956Fs6XsXOuGDWbPys
    HJNwl8prIHsgOTDrtWY2xhwbpwyDrMtoWEh4rZfGAKCvqod1NVrtqs07w1bAZZUoy9mIcq
    +tR3/adKNO3hOkcgJm0prld2ULCet9BOiK1CIErqNrvNiYjmUJFpi5sXdqw+e0KQKchmhd
    mDKjBccjZy0VW6BBXmrrzl6vtDMrNz/krSAaMY5fzdrBjVyqP1WEvestmRq948TI++qWlO
    RfEZEV9X3re3MScR7+hwhZ/eTW7r3W2pyuC7ADQ3mtL1Ga4oz5FRnBHoDr56l7YUNeGLNZ
    BJ+qcwgtdvkuofgL+A+tiFAQwcWDuuIVhXU0G3mtvB6xktzdBTUgZ72crIggLeqWeQNN6S
    j5wcwcxipyNW+JH+tVzcOGz5Rxp4ygjc0uEBRZBeyLzdL0CECXqnzsywXQSV77SQWWsFJ2
    yQlcIQxsPBUw0RLgMyTr3eHx6JBOSsmOcmv65IrPeg8ePFGmGbGBYsa1LJMH4I+rb0pou9
    oyFXB+1vxyu2ILJ3hltVKAhJblh+RnUWJSn1bi9gCp+RLssrL4fCw1b9XINJDjd1Sf6yhl
    OBx/ln6mMHPfStvU4B0FH4KIoA3z1wuTbdgFsDSJzkCjHC/uqHX71GD5EQrQ
X-ME-Proxy: <xmx:Y7GuanMcKK9PM7C_QjjmZuOliOWTaROYlxLorpEHs6-r-V8OZkbNGg>
    <xmx:Y7Guap4lnpUVY_Sg9uL2ZlF1C_TlJ-jf2WqiU0cnpbg5Mz4x2ekFqA>
    <xmx:Y7GuatcBcJG8Pn4Ur1BHVnfkhmD6DJc21xICsMatAU3C_kxoB8iHUQ>
    <xmx:Y7GuaiJQb8f2S3m7U8HfJxGBfSQH5jf5zCxGgtJF3F2wcUmOco0L_Q>
    <xmx:Y7Guarn8qvknBOJXUQJHyzOzb_QIlzX0c_gvsiB-tUg_zDpHXWkhJGCb>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id AEA58780070; Sat, 19 Sep 2026 11:59:31 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AwBBIkqz6-kg
Date: Sat, 19 Sep 2026 11:59:03 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Randy Dunlap" <rdunlap@infradead.org>
Cc: "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, "David S. Miller" <davem@davemloft.net>,
 "Eric Dumazet" <edumazet@google.com>, "Jakub Kicinski" <kuba@kernel.org>,
 "Paolo Abeni" <pabeni@redhat.com>, "Simon Horman" <horms@kernel.org>,
 "Jonathan Corbet" <corbet@lwn.net>, "Shuah Khan" <skhan@linuxfoundation.org>,
 "Christian Brauner" <brauner@kernel.org>,
 "David Howells" <dhowells@redhat.com>, "Sagi Grimberg" <sagi@grimberg.me>,
 linux-nfs@vger.kernel.org, keyrings@vger.kernel.org,
 kernel-tls-handshake@lists.linux.dev, netdev@vger.kernel.org,
 linux-doc@vger.kernel.org
Message-Id: <ebc7d73e-92be-4997-937c-7b9fd086154f@slotpi15m67>
In-Reply-To: <8d635404-f85f-48fa-817a-88d3c1ecd344@infradead.org>
References: <20260918-nfs-mtls-identity-v1-0-197e568d78a7@kernel.org>
 <20260918-nfs-mtls-identity-v1-5-197e568d78a7@kernel.org>
 <8d635404-f85f-48fa-817a-88d3c1ecd344@infradead.org>
Subject: Re: [PATCH RFC 5/5] NFS: add a key type that reveals the namespace .nfs
 keyring serial
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On 9/18/26 2:00 PM, Randy Dunlap wrote:
> This might be a locale thing, but using serial as a noun here seems
> awkward to me.  Is this like "serial number" with the "number" omitted?
>
> Serial as a noun usually means a publication in a series (TV, comics, etc.).
>
> Or is this some special security-related usage of the word serial?

It's "serial number" with the "number" omitted, borrowed from the
keyring code. The struct member is key->serial, the type is
key_serial_t, and the accessor is key_serial(). The bare form has
crept into prose in a few places (Documentation/bpf/signing.rst,
Documentation/ABI/stable/sysfs-nvme), but the canonical documents,
Documentation/security/keys/core.rst and the keyrings(7) man page,
consistently say "serial number", and keyctl(1) says "key ID".

I agree that it's a little disorienting. I'll update the patch
description and keyring.rst to use "serial number".

The cert_serial= and privkey_serial= mount option names have to
stay as they are, since those are an already established part of
the kernel/user space API.

Thanks for your review!

-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
