Received: from fout-a3-smtp.messagingengine.com (fout-a3-smtp.messagingengine.com [103.168.172.146])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E6E464E236B;
	Tue, 29 Sep 2026 22:04:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.146
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790719456; cv=none; b=pRDd9DhvimM/08RCVlvU0W0tZ9a2ec7D5R+cNlITPfIERsiW8vurnja4p12oDE1uatt8OJv26k7A78eln6v6y0K9rHEu11NKQtpUowqVVMAEKLeJrlFxRW1WL78a/ktjgPkoqmV8xp+HljqdGzte9G77/5z0wF23r0DZGgpe3U8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790719456; c=relaxed/simple;
	bh=16XFWo6ATwn43R7NHscr4K38O3/KMT8HyU7k+zgKqC0=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=o5zaIaPBkpGBelhsO/JlY8k+IAD0bhlj3mthkTTEaeGPyAxg1p7MY7n9fNlGFRtC0nSThCAumrM9Ny5rvmEBW+p1OvDukQMJ9S48YjVZEzwIOO4AnVLAVwPauVQQ7FMhY1FQXiUBn0G/cDkrC8BLiwcc5dHomwf03gFNctrnBdU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=bB+M/pl1; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=K0L8THyR; arc=none smtp.client-ip=103.168.172.146
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="bB+M/pl1";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="K0L8THyR"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfout.phl.internal (Postfix) with ESMTP id 0FA8FEC03DE;
	Tue, 29 Sep 2026 18:04:14 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-04.internal (MEProxy); Tue, 29 Sep 2026 18:04:14 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1790719454; x=1790805854; bh=udynu9P+wS+IBpdZ3J1EX3YCm0KHojnwhA3
	Wk7LL3nE=; b=bB+M/pl1KuNOZ+73qarfUJ2X09pm8e3Ms2GMYyVGt3Bc72/jZ8M
	Cxl2qzipP0vap4eCKsrYB/tt9sthaKbKiEZQYuo9tpF+w9lgOcRPAkckV1p+bsLy
	t9kvAsw0D1scFsRuETSn5D9/BUp/zCN83JppzmMfWgBI8NgaCjnMOh0AGpyBGlmZ
	uNhMlWrBK+obvOrHe5neLt9cs1DXmQYQWpQhzVvX1wxqktoz8y4tXA94Ura0cvDE
	k6P0MWcrkEf/hjvcAZRINBF0jfyeEiX/bEAsY56t7YgznGzoeWAggz0SEoAkXgUh
	iiBOOddoHHIoXNVlFtM0A+o/0vE9wamOVZQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1790719454; x=
	1790805854; bh=udynu9P+wS+IBpdZ3J1EX3YCm0KHojnwhA3Wk7LL3nE=; b=K
	0L8THyR6X7Z6bHyIydTB9BEFIHTxqL8C/kKG3XuL6IdDLnOb/l0yeVLhe1Gwy/ZB
	8lTPcQDSVfW6eLo4cGfkuTigFfASqHi2UZcSBu6rqk9QHzpjk/xk7wnU1ZPZCsDz
	MKPdoYJVPdcEPPPlWGRXO4Yqm6go3gXlVoLzKdSv0/17tBz6XWLzo4KfX0asBWzn
	C3aBHVXkwaQL+/Ovdt7rZectrlTXR5B81DjT8R7EVxmNDUYNWFuYcPqtc9WIEFK2
	XG9D2PT2OdB/tyV4BlBTFgWDNk2+yXFR+fHicpkamao2fFkr52LoTrVRQgzbIdhK
	42av5CdGv0SQEZ7d2axwQ==
X-ME-Sender: <xms:3TW8alwTWVt9ob_RkgrwOmlN9QcfZm7XvrxhfdBpXb8yKt1YkPO6PA>
    <xme:3TW8alqaMFdp3n0ZRiNK5goh1lJFlb3hQ40FAd2CuZiRcEmOdrXLQFggfPxnuZeTB
    -53Dhu89jlejLQSa9Y5sBtYDMAucPGMBZO2cGb6apPoPsPeAt8>
X-ME-Received: <xmr:3TW8ageiEKDKDTtF5RVJfKNC9BRSSKrm_TjyyHwwRDbAztCVjubfbdT-j_j_Y9XsNjB7U3HIAsIZ4ML58H44Z3t6LsY_KKY>
X-ME-Proxy-Cause: dmFkZTEhYeZ7AcnZkOHqvU57j7tfcy7G15Xx0OlemqmM5leZZUU3yVbuMGFNb1nJkB2m4E
    eqGUZy/NzG+yPnx3+NKWvgMozSKTe3MvRESWT+GI2OBG8PASaJdaE1dPzULEQLY2R8Bfhe
    XI7yt4hMoN0sjjhb4K2o6rB5XK5y64y9g34CUols03YSDdg7dUG8fvvkKQdGiIeF/qdwGF
    tsk5zbextjtg+xXr+wyhsHxdCGAqnYmXWFPDoDRiLrAGOAjHfQUEOTtyoY/RMc+vzsUBEK
    n/AvC2KHqJvp3zfUgac/REmEOcQMpRF++SV82tluAV9OhKm7GXUnHmHC5cDAgIV9bFI4Qm
    HGqfL9IsTDCZ1lUX+RXj1bhlbLHsW2lart6MPyDKkjKYG0NQ8KCRCX77H/S3WL+6Fq23z5
    FdK2EEmnvuMhG2wA3yvy+JjtGGxlF8DBbch944ckWqoOPm0S5BNl9BNKYmP8ePXMcEoZx9
    rKj8Ye1ZesmUFiq0Ckqm4UBfYKYVMYf7q178mjbgz6HHOKVTPOjmyApx7Oco/U4Ky2g/8u
    xEt1Vn2jVDmJvyfdM6X9vnigwSrNG0Xs+HlrH2NlxNGp3UuNRFZrg6EbFcfHQgLE4V+SU+
    km3bB3zG48wAo9fKiWBaqm/8NCKSqn/gYONYLByalJo6iqD3sn77dlp6v2iw
X-ME-Proxy: <xmx:3TW8ajj47CbipcBriqjEYjAxShVBXRRn1Fo_oQW2cOvaFyOmztcV0Q>
    <xmx:3TW8amIEt3jt0LpSR_eQWrkT7dug5QJEzRUc30kBQwX-k2GcBaa7Ew>
    <xmx:3TW8aoqR8ITAbSvccosTJu0DWEcPCv-dvz9vq1vVTS4r6SfeBGqoyw>
    <xmx:3TW8ajqRjdq3SxmJglzyAZ--fXLZOakBBE4NaLIimuQPX0a4_UXmNg>
    <xmx:3jW8ammR1vuHEasDxA3FES5K2HSaD3I4M3XDZol0tDSOjwA_p8yw4zAn>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 29 Sep 2026 18:04:07 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Jori Koolstra" <jkoolstra@xs4all.nl>
Cc: "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Christian Brauner" <brauner@kernel.org>, "Chuck Lever" <cel@kernel.org>,
 "Jeff Layton" <jlayton@kernel.org>, "Mateusz Guzik" <mjguzik@gmail.com>,
 "Dorjoy Chowdhury" <dorjoychy111@gmail.com>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 "Andreas Gruenbacher" <agruenba@redhat.com>, gfs2@lists.linux.dev,
 "Ilya Dryomov" <idryomov@gmail.com>, "Alex Markuze" <amarkuze@redhat.com>,
 "Viacheslav Dubeyko" <slava@dubeyko.com>, ceph-devel@vger.kernel.org,
 "Paulo Alcantara" <pc@manguebit.org>, "Namjae Jeon" <linkinjeon@kernel.org>,
 linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-nfs@vger.kernel.org
Subject:
 Re: [PATCH v2 06/14] vfs: add some allowed open flags to vfs_lookup_open()
In-reply-to: <113651329.602012.1790695136052@kpc.webmail.kpnmail.nl>
References: <20260919022441.3305170-1-neilb@ownmail.net>
  <20260919022441.3305170-7-neilb@ownmail.net>
  <113651329.602012.1790695136052@kpc.webmail.kpnmail.nl>
Date: Wed, 30 Sep 2026 08:04:02 +1000
Message-id: <179071944284.37859.11007945820334867989@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Wed, 30 Sep 2026, Jori Koolstra wrote:
> > Op 19-09-2026 04:06 CEST schreef NeilBrown <neilb@ownmail.net>:
> >=20
> > =20
> > From: NeilBrown <neil@brown.name>
> >=20
> > vfs_lookup_open() must allow:
> >   O_LARGEFILE so that large files can be opened.
> >   O_NONBLOCK so that break_lease() can be asked to return -EWOULDBLOCK.
> >=20
> > Also O_NOFOLLOW as we don't/can't handle symlinks.  In fact we
> > should enforce O_NOFOLLOW for the same reason we enforce __O_REGULAR.
>=20
> I don't know all the NFS background, but: you can handle intermediate symli=
nks
> but not trailing ones? Why is that?

NFS performs a lookup one component at a time.  Each component might be
a symlink and the client decides what to do it if is.
When opening a file where the client hasn't previously performed a
lookup of the basename, it can use the NFS OPEN request which combines
lookup and open (and create), much like how ->atomic_open does.
So the OPEN NFS request only needs to care about trailing symlinks as
those are the only ones that it has any chance of seeing.

>=20
> >=20
> > Signed-off-by: NeilBrown <neil@brown.name>
> > ---
> >  fs/namei.c | 5 +++--
> >  1 file changed, 3 insertions(+), 2 deletions(-)
> >=20
> > diff --git a/fs/namei.c b/fs/namei.c
> > index 0f69abb3743b..a08f37aca3e1 100644
> > --- a/fs/namei.c
> > +++ b/fs/namei.c
> > @@ -4632,11 +4632,12 @@ struct file *vfs_lookup_open(struct path *parent,=
 struct qstr *last,
> >  	int error =3D 0;
> > =20
> >  	WARN_ONCE(mode & ~S_IALLUGO, "mode must only have permission bits");
> > -	WARN_ONCE(open_flag & ~(O_ACCMODE|O_CREAT|O_EXCL|O_TRUNC|__O_REGULAR),
> > +	WARN_ONCE(open_flag & ~(O_ACCMODE|O_CREAT|O_EXCL|O_TRUNC|__O_REGULAR|
> > +				O_NONBLOCK|O_LARGEFILE|O_NOFOLLOW),
> >  		  "open_flag has unsupported flags");
> > =20
> >  	mode |=3D S_IFREG;
> > -	open_flag |=3D __O_REGULAR;
> > +	open_flag |=3D __O_REGULAR | O_NOFOLLOW;
>=20
> What does __O_REGULAR | O_NOFOLLOW do? Does __O_REGULAR only block opening
> if the final resolved thing is not a regular file, or does is also block
> trailing symlinks? Afaict, the former.

__O_REGULAR is not documented it detail, but I understand that it
prevents the filesystem from opening anything that isn't a regular file.
As symlinks can never be opened anyway (O_PATH is not really an "open"),
__O_REGULAR should have no effect if a symlink is found.  But O_NOFOLLOW
might have an effect.  (If the symlink is followed and ultimately points
to a non-regular file, then __O_REGULAR will have an effect).

For ->atomic_open, if a symlink is found, then the dentry should be
instantiated to that symlink and it should be provided via
finish_no_open().
If, however, O_NOFOLLOW is set, then if a symlink is found then it is
perfectly acceptable to return -ELOOP instead.

This makes a difference for the NFS client.  If it sends an OPEN request
to the server and gets the error NFS4ERR_SYMLINK, then it will normally
send a LOOKUP to the server to get the details of the symlink.  However
if O_NOFOLLOW is set it can avoid the LOOKUP and simply return -ELOOP.


NeilBrown

>=20
> > =20
> >  	error =3D lookup_noperm_common(last, parent->dentry);
> >  	if (error)
> > --=20
> > 2.50.0.107.gf914562f5916.dirty
>=20

