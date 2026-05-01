Received: from fout-b1-smtp.messagingengine.com (fout-b1-smtp.messagingengine.com [202.12.124.144])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AA06D24468C;
	Fri,  1 May 2026 01:40:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.144
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777599612; cv=none; b=oodiJ1e0omD4xSAFlX0sU+wff7BA+yaBnzE+6i6+kwEiiHBnjLWyGC12l0rlR+5xHoNQ2pa0hahuRFJFsl3XFgnsg5U9tAW4phT6o33+7dXb+XhvrpMu0qfBXkTIdA7lrCRfrmW+xga5/gcEcDsWZRC6E71OBUJwlx//ShdXR5I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777599612; c=relaxed/simple;
	bh=GGiMXbmGGlurHTFAl0auFeuoylpMDCwAv5c592jD7j0=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=DQLiKyES5NUBe9k4rmzlPRI3gQH7NfVlNxUrIqXhUv96ydPgAeCFfsY9DoOKOIfn4aXhhwFPZ6c1guE24f+U4p0NvVBZQ3W+xHUorpKWLzu2kKCDEDtrAPZysDsRnqz/XqZyG8teJJP+x5zathZx6gfzpRtPJd2rfTeCP5vYNoc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=pSOvlllf; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=gFbNhWrX; arc=none smtp.client-ip=202.12.124.144
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="pSOvlllf";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="gFbNhWrX"
Received: from phl-compute-05.internal (phl-compute-05.internal [10.202.2.45])
	by mailfout.stl.internal (Postfix) with ESMTP id 7D1D81D000FB;
	Thu, 30 Apr 2026 21:40:10 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-05.internal (MEProxy); Thu, 30 Apr 2026 21:40:11 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm2; t=
	1777599610; x=1777686010; bh=f9gKYzv9hMHa7zu4IUuMIDLKd/ShJ4tdEtH
	REKBnBfc=; b=pSOvlllfuEsAHbvR36LlU4PwowkSAgwhQoaR3IxSfmPyvjJNNSJ
	mFneXR2IdaqpJaiGw37MlwSd36nGPFgGLrHtHhSJJ5g9m2f54klOimmTJPqmnZJ4
	xJ16zKFmNERglxqiT3/HJooS6HuuzuWIayIMYi4UPeHsPT0NB0SLpHpqnFraxcBn
	LH7AX3LURKapVpnUNT6ot30ImEMlKeCjcYxsv+g5AlEI2sL5M73S6LoxwVvfpqyi
	Imx0MVFgwYi4aBES8ueppTq9W6MKRmfITzhROxQMrDhsS0Qy6NbYJtpRF9iXUY8R
	7WHefej9gOwYc8K24o7M4q6pjp7yJ98tZcQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; t=1777599610; x=
	1777686010; bh=f9gKYzv9hMHa7zu4IUuMIDLKd/ShJ4tdEtHREKBnBfc=; b=g
	FbNhWrXl/reqb0LVdiZOzVo//U+IzACd7HaGrCGPN8rc98gQKj4D/uepuk48c0NC
	fwL++Rh76hcbtZwSPUcukB9a7OXmiHUYireoZQAlr3qQzJFnlXSzodyP+SUVFi54
	VQZbSUxQPqoC6WLtl2h5QlaljC87Hhl5b/LSUFL8ykJHxzzlsXsQRN3/VNSuAsch
	8lHLiQjAkMS/fgusV7BOWWTaCO0xGuyazwib+xXi//wGrmumpl9Nj7ms/Qtj/ZNz
	r+uTYfoUZ/3s8a1xE2jh8Qr+IXEQHR7xnlGEGAJQtg7n9QwfKSGXylfnQ16IppQv
	N3YOKJAG3vR79g7KkbXGw==
X-ME-Sender: <xms:eQT0aW4IIlU-w-yTDqGc-lef6TYm7AY03q3CGll9a57tw1PH4vUA4g>
    <xme:eQT0acM0-qkhEL0E106TIJlnUQ0AHT-G_GzIgenqkEWvPWVzD6j4gIh6f-2j5elxx
    rO0GBGKWlt9xdZGPEFHL43hi8NDM8Tk-6vjPjR4-78bLjDUbQ>
X-ME-Received: <xmr:eQT0aXFLqaJFomfGct3TAdBlNfXerjVzF7WiNbphIXzTknzBMJfmnHvHAB3jlGQzfT9wGdx966CRQyeDQGDetEtP9Je6cZI>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeefhedrtddtgdekkeeltdcutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpuffrtefokffrpgfnqfghnecuuegr
    ihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenucfjug
    hrpegtgfgghffvvefujghffffkrhesthhqredttddtjeenucfhrhhomheppfgvihhluehr
    ohifnhcuoehnvghilhgssehofihnmhgrihhlrdhnvghtqeenucggtffrrghtthgvrhhnpe
    dvueetleekjeekveetteevtdekgeeludeifedtfeetgfdttdeljefglefgveffieenucff
    ohhmrghinhepkhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgeptdenucfrrg
    hrrghmpehmrghilhhfrhhomhepnhgvihhlsgesohifnhhmrghilhdrnhgvthdpnhgspghr
    tghpthhtohepudeipdhmohguvgepshhmthhpohhuthdprhgtphhtthhopehvihhrohesii
    gvnhhivhdrlhhinhhugidrohhrghdruhhkpdhrtghpthhtoheplhhinhhugidquhhnihho
    nhhfshesvhhgvghrrdhkvghrnhgvlhdrohhrghdprhgtphhtthhopehlihhnuhigqdhnfh
    hssehvghgvrhdrkhgvrhhnvghlrdhorhhgpdhrtghpthhtoheplhhinhhugidqkhgvrhhn
    vghlsehvghgvrhdrkhgvrhhnvghlrdhorhhgpdhrtghpthhtoheplhhinhhugidqfhhsug
    gvvhgvlhesvhhgvghrrdhkvghrnhgvlhdrohhrghdprhgtphhtthhopehlihhnuhigqdgv
    fhhisehvghgvrhdrkhgvrhhnvghlrdhorhhgpdhrtghpthhtohepmhhikhhlohhssehsii
    gvrhgvughirdhhuhdprhgtphhtthhopehjrggtkhesshhushgvrdgtiidprhgtphhtthho
    pehjkhesohiilhgrsghsrdhorhhg
X-ME-Proxy: <xmx:eQT0aQRkTS9ssw5i_KvA71UfqVoVVfsCmDcmD6zqBYXKKKk3wSuhYw>
    <xmx:eQT0afTJYBotcKCn8TL2D6WyO8j1clDO-vk1ZcixfTpbKT1u4bLGzQ>
    <xmx:eQT0abcNPRh7Eb_VGnNEguZ7Alzn1QbeWng_9Xxqe_fBexBX2Is9EQ>
    <xmx:eQT0abfzxI_c5DqP2taZLXiF1yQeB47uxZMN2D_LNDudHm-PX42LzQ>
    <xmx:egT0adI8zCjViHFI5LbHLSEr1JOXAk1lzpiADYOY5pHmjYke0t1YoYGe>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Thu,
 30 Apr 2026 21:40:05 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Al Viro" <viro@zeniv.linux.org.uk>
Cc: "Linus Torvalds" <torvalds@linux-foundation.org>,
 "Christian Brauner" <brauner@kernel.org>, "Jan Kara" <jack@suse.cz>,
 "Jeff Layton" <jlayton@kernel.org>, "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, "Miklos Szeredi" <miklos@szeredi.hu>,
 "Amir Goldstein" <amir73il@gmail.com>, "Jeremy Kerr" <jk@ozlabs.org>,
 "Ard Biesheuvel" <ardb@kernel.org>, linux-efi@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
 linux-unionfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v3 04/19] VFS: use wait_var_event for waiting in
 d_alloc_parallel()
In-reply-to: <20260501011132.GA3518998@ZenIV>
References: <20260427040517.828226-1-neilb@ownmail.net>
  <20260427040517.828226-5-neilb@ownmail.net>
  <20260428033738.GV3518998@ZenIV>
  <177737511992.1474915.1952404144121931523@noble.neil.brown.name>
  <20260428142225.GX3518998@ZenIV>
  <177741881482.1474915.12527082398060370192@noble.neil.brown.name>
  <20260429052626.GY3518998@ZenIV>  <20260429170731.GZ3518998@ZenIV>
  <177759308866.1474915.9708613530229799376@noble.neil.brown.name>
  <20260501011132.GA3518998@ZenIV>
Date: Fri, 01 May 2026 11:39:59 +1000
Message-id: <177759959922.1474915.14496442965390503813@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Fri, 01 May 2026, Al Viro wrote:
> On Fri, May 01, 2026 at 09:51:28AM +1000, NeilBrown wrote:
>=20
> > I saw this comment the first time I read this email, but I didn't
> > process it properly.  That code is wrong.
>=20
> One in mainline isn't - d_wait comes from target, as it ought to.
>=20
> > It only makes sense to=20
> > __d_wake_in_lookup_waiters() a dentry that we know was in-lookup, and in
> > d_move, that is target.
> > This can only happen (I think) in nfs where nfs_lookup() skips the lookup
> > for LOOKUP_RENAME_TARGET and leaves the dentry in-lookup.  Other threads
> > looking up that name will then block.
> > After the rename completes that in-lookup dentry will now be unhashed
> > but we need to wake it up so other threads can continue (and repeat the
> > lookup).=20
> >=20
> > So we need
> >=20
> > 		__d_wake_in_lookup_waiters(target);
> >=20
> > in d_move.  target, not dentry.
>=20
> Yep.
>=20
> > Thanks for flagging this,
> >=20
> > Also my testing has hit a problem with some sort of deadlock in the nfs
> > server (so accessing and XFS filesystem).  They are tring to unlink a
> > file and are waiting in d_alloc_parallel() under reconnect_path.
> > This is running generic/467.
> >=20
> > So better hold off this patchset until I have that understood.
>=20
> Let's deal with d_alloc_parallel() first; it doesn't have to be tied
> into the rest of patchset.  Does the variant I've posted + s/dentry/target/=
 in that
> call of __d_wake_in_lookup_waiters() trigger any problems in your testing?

I'll let you know.  Still building at present.

>=20
> If it doesn't, let's get that part out of the way - it makes sense on its o=
wn
> and getting it into -next (I'm sitting on a bunch of fs/dcache.c patches, a=
nd
> it would fit there nicely) would be a good idea.

OK

>=20
> FWIW, your "noblock" variant is a misnomer - it *is* a trylock analogue of
> d_alloc_parallel(), all right, but it might very well block; on allocations,
> if nothing else, and there's a chance of having that dput(dentry) in "would=
block"
> case coming right after the sucker ceased to be in-lookup and dropping the =
sole
> remaining reference.  Which may block on real IO, final dput() being what i=
t is...

I'm happy to rename it to d_alloc_trylock()

>=20
> And I really dislike the "drop and regain a caller-held lock" games - we'd =
been
> there many times and it had ended up with race galore again and again; see
> https://lore.kernel.org/all/20250623213747.GJ1880847@ZenIV/ for one recent
> example...
>=20

I dislike them too.  I doubt I can find solutions that either of us
like, but they should be relatively short-lived.  Once we push the
locking down in the the inode_operations the filesystem will be in a
position to hold the lock only when it actually needs it (if at all).

I'm confident that dropping the lock is safe.  If there was some way to
tell the VFS that the lock has already been dropped, then we wouldn't
need to reclaim it, but I cannot see a clean way to do that.

I'm certainly open to suggestions.

Thanks,
NeilBrown


