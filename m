Received: from flow-a3-smtp.messagingengine.com (flow-a3-smtp.messagingengine.com [103.168.172.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 135B136BCFD;
	Mon, 23 Feb 2026 22:04:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.138
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771884282; cv=none; b=PFNxKgmcarWkf0zqVFJqnDCQd8DBpzccSsvgDOJjTLbb5Q/7o6osOX2M1xkCfNlBk62bAiSPE/JctfX/xduSssh+lke5fHo0cT0Ls60bocVs4qceZf4fxddZtyjp5UQtnxtoQi3Z7Gqiomi/g7A8cYGFl/p/zik9t9tyXp0YgOw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771884282; c=relaxed/simple;
	bh=b8ebazC08m5tcyqPoSGgh7JjSJ9g1Sz97a83jABjm2g=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=cXpEl0TDc4IMleNFkGw89iZW3YT3VX5E1v3uqxZ1UAjUYOjs+GSqqd4vUZ92nNHHohY0CYXRoo5LLQ213guMYYF+ncKUizu3binolqjNPazIniF5kcvyma+3YeiMdkiLZTZ7N6yWINlu+Ry6W1ugk8+YMlvGrJrsT0b505LMS3s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=Ws9UlC4r; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=gSfvEOQL; arc=none smtp.client-ip=103.168.172.138
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="Ws9UlC4r";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="gSfvEOQL"
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailflow.phl.internal (Postfix) with ESMTP id 321D11380B23;
	Mon, 23 Feb 2026 17:04:40 -0500 (EST)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-02.internal (MEProxy); Mon, 23 Feb 2026 17:04:40 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm3; t=
	1771884280; x=1771891480; bh=irJDLVX2qQd7f5zlPhvRXNbNOW59zFnQ/W/
	IgkKi5wQ=; b=Ws9UlC4rdriRa58ciza8b/c8892GSffjK4vkvwK954POlcz2OLd
	VocxQMBMIDIuYSfHzGqq1u5KvY1ucluTa8LIMX0UGJUqfwEePKk83cHtYriVfunu
	hDcEejJZw0ihKjkBsQifj50+BH2BTncg1WYH53Sa4hXmmgw+tvUfbL62iD5CIbLM
	e+bGRRQxJxafgNPvlM52xGDBrGl3uBBnwTRlbpJdBEycTqioZhsoEJobcQeWg/8b
	9+KNyq6UcQ/ckMD6PHGquMFUrOuo5l7JnPCdf4YKbzQ6Z1YWnnN0+AyDt/FQgf37
	V3RHM7FhB4x1u7gi8ODZn1J8lxdpWQ2Dwbg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; t=1771884280; x=
	1771891480; bh=irJDLVX2qQd7f5zlPhvRXNbNOW59zFnQ/W/IgkKi5wQ=; b=g
	SfvEOQLw03OJS55vANdkI8ZK0mDTjV4rbPiMQP5hk6tPdiUTcgzHORJVzlnh5yhW
	MhpnHbAVh3lvmU1AOT+1Q4s4jALw3pvSXLsufb4tq8KacyUcoBx2R5WCgFxr4J+f
	LIs8YnOBRBhlbxePazNlKj4WmdTLL89NDXcQFYuYEA2O7XioXR6xuqEkAMnk8hXM
	+LEVTJAUGamZd6PHdG2P1yxTMEdJLbtMzbHLDNj0wOmIZ0WwBcw8jGxhAbpjVpgX
	9Tp5bK3mSBrg4VKtftuNK4jj9oz8BdO7KI6/Yp/0Y+w2KEttE+RiTcBS9oEr1xXs
	P/rN2/vGT8nSvuCIgPRIw==
X-ME-Sender: <xms:9s6caajI56O9imISxyOkzDSC_MpwrChoCCPHEQJo0aQxIfr3tWOa6w>
    <xme:9s6caXKOeQt2WKMFpfvQ0M6rtsLaOeE6RUgFu7T32IgxFtnf8nXYHcFqhYmtOvHR1
    O2GGx91cKWKeMEZxzbbl1myQDCyLQiY8X13fNZTGLITpedG8w>
X-ME-Received: <xmr:9s6cad5eHm4bz9KWixR0h9Yx4lOHceVBloWp1EP5PO2FzM3jijsihFMEheV0EkxjYQqbo-mPF6h1P8WQ8NOY6VIdP8n1_0ww6BJoDU_OgeVC>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeefgedrtddtgddvfeekfeelucetufdoteggodetrf
    dotffvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfurfetoffkrfgpnffqhgenuceu
    rghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujf
    gurheptgfgggfhvfevufgjfhffkfhrsehtqhertddttdejnecuhfhrohhmpefpvghilheu
    rhhofihnuceonhgvihhlsgesohifnhhmrghilhdrnhgvtheqnecuggftrfgrthhtvghrnh
    epleejtdefgeeukeeiteduveehudevfeffvedutefgteduhfegvdfgtdeigeeuudejnecu
    vehluhhsthgvrhfuihiivgeptdenucfrrghrrghmpehmrghilhhfrhhomhepnhgvihhlsg
    esohifnhhmrghilhdrnhgvthdpnhgspghrtghpthhtohepvdefpdhmohguvgepshhmthhp
    ohhuthdprhgtphhtthhopehvihhrohesiigvnhhivhdrlhhinhhugidrohhrghdruhhkpd
    hrtghpthhtohepshgvlhhinhhugiesvhhgvghrrdhkvghrnhgvlhdrohhrghdprhgtphht
    thhopehlihhnuhigqdhunhhiohhnfhhssehvghgvrhdrkhgvrhhnvghlrdhorhhgpdhrtg
    hpthhtoheplhhinhhugidqshgvtghurhhithihqdhmohguuhhlvgesvhhgvghrrdhkvghr
    nhgvlhdrohhrghdprhgtphhtthhopehlihhnuhigqdhnfhhssehvghgvrhdrkhgvrhhnvg
    hlrdhorhhgpdhrtghpthhtoheplhhinhhugidqkhgvrhhnvghlsehvghgvrhdrkhgvrhhn
    vghlrdhorhhgpdhrtghpthhtoheplhhinhhugidqfhhsuggvvhgvlhesvhhgvghrrdhkvg
    hrnhgvlhdrohhrghdprhgtphhtthhopehmihhklhhoshesshiivghrvgguihdrhhhupdhr
    tghpthhtohepjhgrtghksehsuhhsvgdrtgii
X-ME-Proxy: <xmx:9s6caclzLrgKfeDhlox16fw51GXG-3HrDff5GauOyjg85bKiL4YmNg>
    <xmx:9s6caX6TGDCjSAAqAFbyiuqfkVrSrwQwMHwy5d8W07K53q3z5lNFXw>
    <xmx:9s6caV_2kCQ1Lik20KddbFxgbSwKSj3rN2G2aUmuymGiRuDLfloUBA>
    <xmx:9s6caXidElUn8Kg0ersqdtpRNxuaxlxy_QnaPAYc7wp0BUi5SC4-8Q>
    <xmx:-M6caRagjaoVbqBcqtcqEGXNSfbjV9m04SvT9GVJMVNOcNe_crWGDOHL>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 23 Feb 2026 17:04:32 -0500 (EST)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Chris Mason" <clm@meta.com>
Cc: "Christian Brauner" <brauner@kernel.org>,
 "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "David Howells" <dhowells@redhat.com>, "Jan Kara" <jack@suse.cz>,
 "Chuck Lever" <chuck.lever@oracle.com>, "Jeff Layton" <jlayton@kernel.org>,
 "Miklos Szeredi" <miklos@szeredi.hu>, "Amir Goldstein" <amir73il@gmail.com>,
 "John Johansen" <john.johansen@canonical.com>,
 "Paul Moore" <paul@paul-moore.com>, "James Morris" <jmorris@namei.org>,
 "Serge E. Hallyn" <serge@hallyn.com>,
 "Stephen Smalley" <stephen.smalley.work@gmail.com>,
 "Darrick J. Wong" <djwong@kernel.org>, linux-kernel@vger.kernel.org,
 netfs@lists.linux.dev, linux-fsdevel@vger.kernel.org,
 linux-nfs@vger.kernel.org, linux-unionfs@vger.kernel.org,
 apparmor@lists.ubuntu.com, linux-security-module@vger.kernel.org,
 selinux@vger.kernel.org
Subject: Re: [PATCH v2 01/15] VFS: note error returns is documentation for
 various lookup functions
In-reply-to: <20260223135517.1229434-1-clm@meta.com>
References: <20260223011210.3853517-1-neilb@ownmail.net>,
 <20260223011210.3853517-2-neilb@ownmail.net>,
 <20260223135517.1229434-1-clm@meta.com>
Date: Tue, 24 Feb 2026 09:04:27 +1100
Message-id: <177188426768.8396.6205782771317375008@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Tue, 24 Feb 2026, Chris Mason wrote:
> NeilBrown <neilb@ownmail.net> wrote:
> > From: NeilBrown <neil@brown.name>
> >=20
> > Darrick recently noted that try_lookup_noperm() is documented as
> > "Look up a dentry by name in the dcache, returning NULL if it does not
> > currently exist." but it can in fact return an error.
> >=20
> > So update the documentation for that and related function.
> >
>=20
> Hi everyone,
>=20
> I don't normally forward the typos, but since this is a documentation-y pat=
ch:

I'm certainly happy to receive them.  Thanks for these and the others

I also found ....
>=20
> commit 0254b9b974f23889898562aa94f6428bf30eb6b5
> Author: NeilBrown <neil@brown.name>
>=20
> VFS: note error returns is documentation for various lookup functions
>                        ^^^^^ in?
>=20
> Darrick recently noted that try_lookup_noperm() is documented as
> "Look up a dentry by name in the dcache, returning NULL if it does not
> currently exist." but it can in fact return an error. So update the
> documentation for that and related function.
                                     ^^functions=20

Thanks,
NeilBrown
