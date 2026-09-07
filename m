Received: from fhigh-a4-smtp.messagingengine.com (fhigh-a4-smtp.messagingengine.com [103.168.172.155])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0D443369208
	for <linux-nfs@vger.kernel.org>; Mon,  7 Sep 2026 21:46:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.155
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788817604; cv=none; b=SdptYWhIXTKZ/xOxRFuIVMy5VSRdPYneUXPUE4cQo8mcbXc0fO8X2GaPu5PWH31cddxCg/d5rrv/M0g5+JJ76Wt+m8oyglclj8u6SXeQacIVAGL4unJvwpRIIhbF8VfmsO2kl8G/zG7dFJyX+sxH39N9uEXzUCjzEarfp4t6+j0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788817604; c=relaxed/simple;
	bh=Q9Jj4ZrOpEt/xJY2IgLz/M3WXVJVvp4MsOvmRjytYJw=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=ckUdaFuymyRgY9PAX2f/DW5ylsFfz8CPblwM/lRvmHq3lBjq+KYSR9OIof2UOZkZljVFytnWbZcuudYE8aXH+6QBvObUTioMyuZ8QVLcX+T/pWpQ4vZh7FdNJNNHDraCMR3XIYJ6ABIWAMhM2Dh2+iVSF6T4O4bP2DPjt19R/6g=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=nSsNCV0/; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=NeHNWoWs; arc=none smtp.client-ip=103.168.172.155
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="nSsNCV0/";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="NeHNWoWs"
Received: from phl-compute-05.internal (phl-compute-05.internal [10.202.2.45])
	by mailfhigh.phl.internal (Postfix) with ESMTP id 171A61400154;
	Mon,  7 Sep 2026 17:46:41 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-05.internal (MEProxy); Mon, 07 Sep 2026 17:46:41 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1788817601; x=1788904001; bh=HSB7i4NvIOdv9Kn4Z9GYhunWiAWvehQhcZy
	4hZGOfFw=; b=nSsNCV0/PalOmIS+z0TeOABaihIjGPlxk66ZNaT7lC9rjjYO+aC
	JmCxR766UilbVXaR4pxJtBB94Wh+oWnkWGnBHiAKmnwTqK4c/RO1r8wBG+furC4e
	hrugtYVlfjLZFG+2Il5uYetxxucnDGn+WG6vPoOtyi1MSqT7bjNQi9VylRnVgfCM
	dCggFaYYifLRwUQ6HypIWk74oV6WWzzl3WSIdrVfy+ul/MAO/0GXrbytDRWl8b5M
	LsO62MKNu6qgrM+wcw/yrxvnGgvLrcfde3u+Uggq+ESSCsnozHwZdTHdmZjjc6bb
	hGFXF/m+ydNQLEYfrwBihFrMBbntC46OJqw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1788817601; x=
	1788904001; bh=HSB7i4NvIOdv9Kn4Z9GYhunWiAWvehQhcZy4hZGOfFw=; b=N
	eHNWoWsoBmhr+bgQlUxui4ELN4dYpyMYw8tCY9KNALapla5RxN/OS1Ho2X0HCp4z
	kWPPxnof2AddcUhztwYHBjQg0ARntT/nCFII/oTfbTal38cXUmzxZbhFGgScDpJW
	z4f2+ir12mhJ/6c5Ioh1WbA9sNiY/0kAjBK8I+/bHJyjyWpZG5llHmc5R1zJG6M/
	E2SgNnML4GMmntUo2kfDolTPE9jT+f9F6rgRIq3s6NgIk2WtzXKyHD4di45ptw9t
	Mr4NxKoLZiSLt8/10sSbhd4urWwq+sO8++rEtumTmgNBTWh8G4ItJF8W+UoQgL1B
	xjUJDRrI5lg4+QkrYrfNA==
X-ME-Sender: <xms:wDCfatipFzDhuNLinq1wBQEC63Zg66fyj15s0HdcSc44dVkZqNwsmw>
    <xme:wDCfaluiPJdJXTPnO3GWRi901_XFcQAr8aiZEb6cd65Rx5lXezuDqNGXXOP8aZ-7n
    FFJFZ_MBttG3liLoAGNjGcnYua19I-ADSTEkbv7DqC0R51LUw>
X-ME-Received: <xmr:wDCfam49Vr3lYSkOX6L5Wpzokqxmwa1D2awLNqlgUVOL1dnHjReW-AgCA0PmzDl_GQ>
X-ME-Proxy-Cause: dmFkZTGVwsnBGZktWqh4FkmKVCURkq9dfd6mk0JU1JxflmZyK7dSRxQ+i6O+zO78w9grwL
    5ZlLYKTxJWdXjTzqr6Xf3tZYxQDwfaOmLiQdQyaMAVVM5cZtxwt3Qh2RBqdoTX76ZP2tY5
    1Y8EBgM9cJiNTbh+QSEPOLDt0HESlrxuF8WpXTdQNRzl9re+jIhlSvLSyMIlAe1CrYXm/9
    vLxP//VLdc9c9+Z6c7Tj6rs6GNZuDnRrrAXs6EM3Pamzlo+IVOPnGmP0UzzJjWGTDQH5dO
    E6HQmEJPtZYLZNqOusYlSETn0gTqNidFaqThpPDrR7y3DkbfAozstlUDl0aKwVKSc8B9XK
    FQJ1LRx9YY/hsjywi+EaAk6pP4/dMHpZBwwQ4eDDJJw4l9B5EgkSPuJu0OtuCe+0u1MiXg
    Oq/guAMtswHryL6j77swXqzJtAjDucZnCandtO0xSpEJr5pkKxg6KcNK6KIBhmsNqZaH5V
    0or/NHuMwCTPifGczsp7kEaLMSkXAvjhwmJup6kbgg9sU6ypF9p04ak1wRQTlRL4/Ymg1t
    9zexJ5eP+BDG3wbcHQusRNvBT0CRGromq6TqXsoNpT2m30MrVTLoqT7rj/R/53CHrK17Cv
    eNoi8cY9ZSwD+atV4oU5B/Uiv1sCMve7rkH3Ue3Pwkq5Z96uNd40qwJzslVQ
X-ME-Proxy: <xmx:wDCfapNrPgJWuicGz3bsmP-dMEO4iruf-8sYPgqd14tS4E1topXxww>
    <xmx:wDCfasuuMxWDxv8rEAX6TsGthZdtE7y6A2laTClf8Iisb6iMCUlp_w>
    <xmx:wDCfakbtXzJtjri8aUlQmdHV8eTGfUknHW7NtCmqflfpHuqDxc0WZA>
    <xmx:wDCfamxhlSAOnG-szUhiScTZkjK2mOfir3cVaoLoHMtH7ixvKr51ww>
    <xmx:wTCfavA4LVl2psh5W6NvLOuVS5ibZ_UPaFbu58aPBeBTMxsLCXpuNWzX>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 7 Sep 2026 17:46:37 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Chuck Lever" <cel@kernel.org>
Cc: "Jeff Layton" <jlayton@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <dai.ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSD: return NFS4ERR_EXIST for a guarded OPEN of a
 non-regular object
In-reply-to: <c0c96e2f-ba29-4b46-915b-23399810d384@app.fastmail.com>
References: <178876623368.207413.16768374723232216468@noble.neil.brown.name>
  <c0c96e2f-ba29-4b46-915b-23399810d384@app.fastmail.com>
Date: Tue, 08 Sep 2026 07:46:34 +1000
Message-id: <178881759413.207413.2578491257666165749@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Tue, 08 Sep 2026, Chuck Lever wrote:
>=20
> On Mon, Sep 7, 2026, at 3:30 AM, NeilBrown wrote:
> > From: NeilBrown <neil@brown.name>
> >
> > Commit db8b567ffa98 ("nfsd: (almost) always open file in
> > nfsd4_create_file()") moved the regular-file type check ahead of the
> > createmode logic.  A GUARDED4, EXCLUSIVE4, or EXCLUSIVE4_1 OPEN that
> > finds a directory or symbolic link under the requested name now fails
> > with NFS4ERR_ISDIR or NFS4ERR_SYMLINK instead of NFS4ERR_EXIST.
> >
> > RFC 8881 Section 18.16.3 requires NFS4ERR_EXIST when a guarded create
> > finds any object under that name, or when an exclusive create's
> > verifier does not match. The type-specific errors in Section 18.16.4
> > apply to opening an existing file, which only UNCHECKED4 does.
> >
> > do_lookup_open() is passed O_EXCL precisely when UNCHECKED4 is
> > requested, so it can choose whether to return NFS4ERR_EXIST or
> > one of the other errors.
> >
> > Fixes: db8b567ffa98 ("nfsd: (almost) always open file in nfsd4_create_fil=
e()")
> > Signed-off-by: NeilBrown <neil@brown.name>
> > ---
> >  fs/nfsd/nfs4proc.c | 4 +++-
> >  1 file changed, 3 insertions(+), 1 deletion(-)
> >
> > Hi Chuck,
> >  I took the liberty of reusing your commit message - thanks!
> >
> > NeilBrown
> >
> >
> > diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> > index 33dc92d48ce0..067e24514dad 100644
> > --- a/fs/nfsd/nfs4proc.c
> > +++ b/fs/nfsd/nfs4proc.c
> > @@ -240,7 +240,9 @@ static struct file *do_lookup_open(struct path *paren=
t,
> >  		 */
> >  		int err =3D nfsd_check_obj_isreg(child);
> >=20
> > -		if (err)
> > +		if (oflags & O_EXCL)
> > +			filp =3D ERR_PTR(-EEXIST);
> > +		else if (err)
> >  			filp =3D ERR_PTR(err);
> >  		else
> >  			filp =3D dentry_open(&path, oflags, current_cred());
> >
> > --=20
> > 2.50.0.107.gf914562f5916.dirty
>=20
> Hi Neil -
>=20
> O_EXCL is set for GUARDED4 only, so this logic leaves EXCLUSIVE4 and
> EXCLUSIVE4_1 still returning the incorrect type-specific errors.

True...

I really don't like having to test all the different errno values,
partly because we will need to add ENODEV when we switch to
vfs_lookup_open() and partly because they are all over-loaded.
I'd rather return the dentry found and let nfsd sort out what to do with
it, but Christian didn't like the way I did that (O_PATH open).
Maybe I can find a better way...

Let's go with your solution for now.

Thanks,
NeilBrown


>=20
>=20
> --=20
> Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
>=20

