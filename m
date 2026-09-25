Received: from fout-b8-smtp.messagingengine.com (fout-b8-smtp.messagingengine.com [202.12.124.151])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E134B30D40E;
	Fri, 25 Sep 2026 21:57:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.151
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790373474; cv=none; b=eMknnDwM8RfjdirVtVLT2epO3EUxHcrDKMMmq7/oRPlQeOqIlVCMfVKqzeNeffLT0hs5iQYK+ibkloZ8c8wRZW1S24FIp+VD5aKk9wWq/9YAfn4j2yZrhcjF0mkQ5FJ1eHmvZSQEg+Jd51Ng0R92ISSKjN6nJ6zQ0Sd/mmf9ywY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790373474; c=relaxed/simple;
	bh=BVtT1oimYXf6L1M6L1rWOSYPJ1kryDWcPm1aa3zJT9E=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=U+P9RZsUy1xbbHfoiAKa0phQvb58I3jFjzUBZELiXcnSXon90I5s1koSlhS97E97XLfiKLSo7SSKdqKL5mT/Sh3tmpcGUiGFgRwj8ODg2GTgig4uhSghWQh3H7CcYCg1mpdCn8c2lCbQLXr2CK8mwnIY5jMMRl9vIk6j/DYrKbY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=jfR95egc; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=aFugv3S9; arc=none smtp.client-ip=202.12.124.151
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="jfR95egc";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="aFugv3S9"
Received: from phl-compute-05.internal (phl-compute-05.internal [10.202.2.45])
	by mailfout.stl.internal (Postfix) with ESMTP id C5A901D00089;
	Fri, 25 Sep 2026 17:57:51 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-05.internal (MEProxy); Fri, 25 Sep 2026 17:57:52 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1790373471; x=1790459871; bh=/RjIj1y2GTivD1inkl82M67pIDVGSkn2noi
	p01JecoE=; b=jfR95egc4lZnBghuGqLy5ouk1XVowsneue4b9B9W45PgfIH+pEi
	q70oosqrLUc74ub+GsWzkDEo5li0/VckOWX2Nd4CSB0oerrx4ueOZ8vfa6O4vtPu
	E3IRcxAQzBGuIvLAtZ6nJt24YmmQaR5PN1uqOlfxJeYxX3T0V+j6UjFRcjFtpVS2
	Ng4FFWFw9Y3FJVwjHpRnRu0QwLqyi4+zxsWEbBXmOw8jt9o0FbCjfiwJUxPHXOA4
	YxNrwZCwKEzc9tsdgM482UiFAqWVqLqYx2C93k0ITzV/Y3Md8gGNftkDQr4wHxtn
	WUseA5zNPSyYpZHyi+CSV4wylzjBDBd+2sw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1790373471; x=
	1790459871; bh=/RjIj1y2GTivD1inkl82M67pIDVGSkn2noip01JecoE=; b=a
	Fugv3S9++fORHh4WpjpznSh07MXxyWzE2kBY1FRu+rm455HeRXIZTxmJs+0Jwh87
	fzqWJUpIBQFHqOALUQjxJT7ckrmTgILSh7HPd3wkuq5ZzW78atO+cJsdQt6OYcys
	VrZ/xhc1mp99F8AjCBtwnSYh99BilMNsy1o/5wiB42LCRmHIle7lodIUs9A6BUmY
	vDfxpOMUbpYbA45v+ZTxopWBe9ACy7AZxhS5+9XRgBlIN5Zt4dSQNJFSNJNI33GG
	EwokE8pH/qISLl3PQe04vKcXsL7CYmbCp0kw+O1iNxnT2PF5TBDyJ5mxtoMGp5IC
	Zf8om8MKLmJvRG905IIiA==
X-ME-Sender: <xms:X-62auBAj0nXbhVjLa_ES7lfpmgn73Zt8v1Gt7t8D3GtLLBPgiMZsA>
    <xme:X-62ao6T1t7LqbC-0bFMyvfxIyNAVZkO5JfYV93zZ3pjRSi_siwjgeWS5RPfDwTYr
    55vRpHm3bvZbo42NCfdRQKILLy39h_KjvKgPX_HkoqdsMkXfmc>
X-ME-Received: <xmr:X-62ait1kFO_RbFAPskgGGiSm7Vtbh55H2S_0jAd9kvFR-MUZd0iyLaGhqZ7HgiHyzBELrQVdBLvSZ-9TRWeAmQX6060IAY>
X-ME-Proxy-Cause: dmFkZTEt/QJYEZuZ01nbRBfqooGzIJIFRE2UCP4rUy/Y9P7110llfKJLmv4+yaPCVPcG9N
    8UawB2XRoa6qFMi5aUAV6MMZ0OHg/sEjgsY2ZmyM4boEAh36bOqxolbYkx9t/nZQ2vZ5xl
    ZA+lbBdn51dh3p24p8KUmvh5YZ0pBaxVVXnOpAa4ZgQVwZt1oa6eXGqHd9jDdWFvwxeoWZ
    UXgr+hclw0Q1Wk/h6m8duN/Nh1ldO7IQzru/+SFXkCQwU/rZ2jvo2remYjP8DjWiMrx1mM
    b2jT/jOoLS2+iHenpB9draUnsqxh2GwiFaX/P9/zQV8Spa8l5KmzLZMfhVbvHWiYetWcID
    xcQ+Zuxv7M8rdpYknsT0WFsqqewvALjuYd4lp66v32TeHmcUuruHvfGKqhRDu+TUbAyb+g
    3NpNOSQz3lRGf3qej327ksdS4Dd53dY5L4ifT2UTDYKDDn9Szsry9Ir1F9bO5hdU/pql75
    AN+m1mFfhyKXI69sKGa6LP8VmtwUyqrAflTVfwf5R914Z6L2IuTTfnXOX9LmBPaOr11T+H
    FEbTvipC2v9F3PCE4gDVtZnDbCXWARE4e+PUu6Dwi/Zr0wXLxqBugQ9EeTqhA8+WyE9c0X
    uv5O8n8Y997XVTTPv5IH3o3quRSGX9jsauQ40p+Apa1Az1y6BIPAMqs1I+Mw
X-ME-Proxy: <xmx:X-62aow2PEm0l_y07l0HkLDjIpKMOZZknA7TcFBkuwBhZJWg9CtMdw>
    <xmx:X-62aiYG5JPhyk8oTAZ7tln2w-Wij1GWKBM0hxFyP9nYrrbQY_7KZQ>
    <xmx:X-62av5pYB-XtNnQ8PXVXdjjkBKKHA0IEDTBqKsCWNDedbSxhYY2ng>
    <xmx:X-62ap7ylDtmcBoD5r2WQ6KGDBLpLNVufrqElDKt6KtXHJ8Q7iQIag>
    <xmx:X-62am0OuUyPm6Eb23w6qo16w3UF33oXdFkQ0UwC_hmjg3CRUNmXUt3d>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 25 Sep 2026 17:57:45 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Jeff Layton" <jlayton@kernel.org>
Cc: "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Christian Brauner" <brauner@kernel.org>, "Chuck Lever" <cel@kernel.org>,
 "Jori Koolstra" <jkoolstra@xs4all.nl>, "Mateusz Guzik" <mjguzik@gmail.com>,
 "Dorjoy Chowdhury" <dorjoychy111@gmail.com>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 "Andreas Gruenbacher" <agruenba@redhat.com>, gfs2@lists.linux.dev,
 "Ilya Dryomov" <idryomov@gmail.com>, "Alex Markuze" <amarkuze@redhat.com>,
 "Viacheslav Dubeyko" <slava@dubeyko.com>, ceph-devel@vger.kernel.org,
 "Paulo Alcantara" <pc@manguebit.org>, "Namjae Jeon" <linkinjeon@kernel.org>,
 linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 10/14] nfsd: make EEXIST checks in nfsd4_create_file()
 more consistent.
In-reply-to: <1d617af0ddc11ae773808aa6a876d9d3f91e7115.camel@kernel.org>
References: <20260919022441.3305170-1-neilb@ownmail.net>
  <20260919022441.3305170-11-neilb@ownmail.net>
  <1d617af0ddc11ae773808aa6a876d9d3f91e7115.camel@kernel.org>
Date: Sat, 26 Sep 2026 07:57:43 +1000
Message-id: <179037346359.37859.1143675174370412093@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Thu, 24 Sep 2026, Jeff Layton wrote:
> On Sat, 2026-09-19 at 12:06 +1000, NeilBrown wrote:
> > From: NeilBrown <neil@brown.name>
> >=20
> > nfsd4_create_file() has two places that check if an "eexists" style
> > error is needed - only if create_mode is not NFS4_CREATE_UNCHECKED.
> >=20
> > One if when checking the error code from do_lookup_open(), one when
> > checking if ->op_created wasn't set.
> >=20
> > These are not consistent - one tests if op_createmode IS
> > NFS4_CREATE_UNCHECKED, the other tests if it isn't.
> >=20
> > Rearrange the second piece of code so that the tests look similar.
> > This will make some following patches a bit cleaner.
> >=20
> > Signed-off-by: NeilBrown <neil@brown.name>
> > ---
> >  fs/nfsd/nfs4proc.c | 33 +++++++++++++++++----------------
> >  1 file changed, 17 insertions(+), 16 deletions(-)
> >=20
> > diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> > index 3a82af381a8d..6e443503d0b7 100644
> > --- a/fs/nfsd/nfs4proc.c
> > +++ b/fs/nfsd/nfs4proc.c
> > @@ -462,23 +462,24 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct sv=
c_fh *fhp,
> >  		open->op_created =3D true;
> > =20
> >  	if (!open->op_created) {
> > -		if (open->op_createmode =3D=3D NFS4_CREATE_UNCHECKED) {
> > -			/* NFSv4 protocol requires change attributes
> > -			 * even though no change happened.
> > -			 */
> > -			fh_fill_post_noop(fhp);
> > -
> > -			/*
> > -			 * In NFSv4, we don't want to truncate the file
> > -			 * now. This would be wrong if the OPEN fails for
> > -			 * some other reason. Furthermore, if the size is
> > -			 * nonzero, we should ignore it according to spec!
> > -			 */
> > -			open->op_truncate =3D (d_is_reg(child) &&
> > -					     (iap->ia_valid & ATTR_SIZE) &&
> > -					     !iap->ia_size);
> > -		} else
> > +		if (open->op_createmode !=3D NFS4_CREATE_UNCHECKED) {
> >  			status =3D nfserr_exist;
> > +			goto out;
> > +		}
> > +		/* NFSv4 protocol requires change attributes
> > +		 * even though no change happened.
> > +		 */
> > +		fh_fill_post_noop(fhp);
> > +
> > +		/*
> > +		 * In NFSv4, we don't want to truncate the file
> > +		 * now. This would be wrong if the OPEN fails for
> > +		 * some other reason. Furthermore, if the size is
> > +		 * nonzero, we should ignore it according to spec!
> > +		 */
>=20
> Some mention of where in the spec that's written would be helpful for
> posterity. I think it's RFC 8881 =C2=A7 18.16.3.
>=20

I've added

		 * RFC 8881 =C2=A7 18.16.3. says:
		 *   When an UNCHECKED4 create encounters an existing
		 *   file, the attributes specified by createattrs are
		 *   not used, except that when createattrs specifies
		 *   the size attribute with a size of zero, the
		 *   existing file is truncated.


> > +		open->op_truncate =3D (d_is_reg(child) &&
> > +				     (iap->ia_valid & ATTR_SIZE) &&
> > +				     !iap->ia_size);
> >  		goto out;
> >  	}
> >  	/* file was created */
>=20
> Reviewed-by: Jeff Layton <jlayton@kernel.org>

Thanks,
NeilBrown


>=20

