Received: from fhigh-b4-smtp.messagingengine.com (fhigh-b4-smtp.messagingengine.com [202.12.124.155])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EFA7D47B423;
	Fri, 25 Sep 2026 22:14:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.155
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790374484; cv=none; b=aBS9lulJdPA6JiEMAGF++pkQTLkccWu5WPrsUiCNSstGOP5dkoA1JGUxnooTKfl5NhebpscgHk2dSlq2VRe6c0npF+5wdYSoWwGdvC4jDaNREcctsLx7Vp7Xk3O5VJsi/v/vQSTgprZNODPOcJA4FsiekCkdDcJYaYP0t97iw9w=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790374484; c=relaxed/simple;
	bh=9yFT5k1DHaKTUfm7mwJMdnNNBfVM6mxGO3VBHWZqEdY=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=GF/BpUWrXMShLkXPfYrDgI2YMKoEQtp43ISpWukVrMJ4FPGkh95MNz/A4DPunPqckQJmkWLoyrHKpCQLGwsBwWKAddhVtYQoSX4C6lNw+n7AcPPSj2FF/LhETMWQu+EMyRpfsrR62jOX6KKEcKaP4yUx1olt7FE9NDcn8EG6iDM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=dWebssn3; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=WVlJzscC; arc=none smtp.client-ip=202.12.124.155
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="dWebssn3";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="WVlJzscC"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfhigh.stl.internal (Postfix) with ESMTP id CECBE7A00F7;
	Fri, 25 Sep 2026 18:14:41 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-04.internal (MEProxy); Fri, 25 Sep 2026 18:14:42 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1790374481; x=1790460881; bh=NSt+J91SNF0OreTv2nDx4qKb24dqzoL9dMI
	f8pEl86c=; b=dWebssn3gtev2dyQqfWI+F9OXtnwgYzFJkmVBb7IY1WtWZNanya
	AxZRWcq6urJtVCgMsGpg2DsXTH6bgozv5LxOaeCkOIGxJ55eOfBFico5pqWh6z9D
	qeakHJ0eKDsmN2eSWHT1/Dzxra13x/UtH45lUw2GSGDmibizPQxBB3ABgeTRmCbT
	kUSsxWN2We8wgmB/icf6udd+QdR3ySqIYEW3Hu9vMXsA4Q9UD2UeUXMrFYqw8+wi
	Q3eIpg2odwdA+XBzAzK0QPb+/Kax5H8id6Hsuy9y5eyCZGnZZduZvYfWmodBPdpZ
	pTkx1zn6c+abAZ4yhBSnyVr49zLJOjJfMGA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1790374481; x=
	1790460881; bh=NSt+J91SNF0OreTv2nDx4qKb24dqzoL9dMIf8pEl86c=; b=W
	VlJzscCGpfgzQDOPxB9NnUbT/z2K48pzmTs5DpPwOYiMG8ZH5blmCN7+AzoqWj+4
	x3xdj02PXUxeIPuapUYr9oYYzQAvqM2LZa9Z9E/zeZn1Jj53wjnF0nNp2TcWBE+Y
	XZtwDxZ8A37D+tW7B5TZXmnNksvHLTXnRtppqRreGOyaLiz6FZEF5CsVYodkdLPL
	n96lqSByyAmu+i6zolVV7SxLf07mapZ0xwNaWrw3KLv2x0E30GoFXS/4E6SyKzKH
	psbZ6XpxYDThtHj7OI1PLvraWbZSM/5DghZ3kj9y26nCvEAZHysnVCg0oCaBM484
	fpa0FK1upCRC/lNtdY7Hw==
X-ME-Sender: <xms:UfK2am59nvuI41_R6jE2a5ecSg5LE4X-83oV0mNs-SU5xmETBJEz8g>
    <xme:UfK2agTwolbkmq50NYC__3X8IWYBwrhfGVQvYqQgJplSrFVA7Oyef_DBZF-A-TSmo
    0JOJQm6ybWfubIo0R79YO8DyHiEhuaS6568gcUrCG_z4S6hA5Y>
X-ME-Received: <xmr:UfK2amnXbYHiBTGz44-Ixf6OmANKJ79qcSpXyQ0Y8ISfNLyCZhMeZygdwoiNyIJLZyF_3nzPbEaVf3BrhKY4B2xMDABl_cU>
X-ME-Proxy-Cause: dmFkZTFXsk/cw9+jagvWIL0k48D0djFLMkJKOY8nFresTqSK9BUSFHtq8iLrWj16b8wv1d
    X9YU2iUH8wnNobJmOZcJu3YXghvwCN9+ZQmTfZ9fi2MuTrvWUmeLRO0b02HBqm8xN4DT58
    KFyMcOd+MiOHa9MIvt5NJmTNivUef0YJW7IyE1GWAwcRN5CZtLXSpJEHM7gHi/CP17FpKX
    IQ4qoy+rZlbGF0M9GimQSvcytf8Km/Gam8Jw0d56PnbZGz1kExL+cXL0IYkAqAF6DIZ2yC
    /R2IV7Z0MoXOq8qFwOaJyYrK10nS6OYJYTfNYMxrM9YXlK516dxeRmhZrx3Hq23N0BU9D4
    R5PjDZWyu88UHyeT7t36qBzjXfbohHXBUHPUxd5/AW9VyTLdq0o/JNc6G1ngne1CV7Bz9G
    qD06ejveENmbD8x72AJ7WYxw9wQ5pxt/K++3UIbAjDucoSQaL8iSoyyZpD012UG5kRddna
    SH805dCLLp62e8mhSL5ZyFc0V4j+0/r6DGZBU3dyT7gjk2PchGsS3roANa8taV3pT9jScB
    EtcmeBF/Uiwo9HERLIZeaiJEY+nazdEkE3m+68OY+jY8h/8v1G6807K6mWN9dLX83iDef8
    pfH5zxh1mR0GA05YE5E74RVJ18E/4jLunyPiGMkU+XHMXHZjSiRHeWQQwFlQ
X-ME-Proxy: <xmx:UfK2avK-6guZmYGmdKAUzWIHUm9Un_3cDp-2Y5I4tkEc012kE_KeXw>
    <xmx:UfK2apS9x3hlyUWywLfyEE3sOQv2UFtwVtwrgjq_lGjmqToU3DeqbA>
    <xmx:UfK2atRXiqgYc11IilAEGrx-tY5eY9wVpAvTdbvgiz6bpoYL4mvIQw>
    <xmx:UfK2arx6ZSO2CqS3yO37qbhSLaLdGHI7Diy-bIMKJqnVpX0gpzOd-A>
    <xmx:UfK2aju5jyPYI_5cGxleDjuRNd2XEc-Zp1rsvoe3yL_cDqiG0avE3NvP>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 25 Sep 2026 18:14:35 -0400 (EDT)
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
Subject:
 Re: [PATCH v2 11/14] nfsd: check for mountpoints after non-creating open.
In-reply-to: <2a78884377a5e537dab390788d66b10fbf2b2726.camel@kernel.org>
References: <20260919022441.3305170-1-neilb@ownmail.net>
  <20260919022441.3305170-12-neilb@ownmail.net>
  <2a78884377a5e537dab390788d66b10fbf2b2726.camel@kernel.org>
Date: Sat, 26 Sep 2026 08:14:32 +1000
Message-id: <179037447238.37859.18391584540984494231@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Thu, 24 Sep 2026, Jeff Layton wrote:
> LLM review:
>=20
> > diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> > index 6e443503d0b7..3d37754f787b 100644
> > --- a/fs/nfsd/nfs4proc.c
> > +++ b/fs/nfsd/nfs4proc.c
>=20
> [ ... ]
>=20
> > @@ -466,6 +454,14 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc=
_fh *fhp,
> >  			status =3D nfserr_exist;
> >  			goto out;
> >  		}
> > +		/* We opened an existing file, it might be a junction. */
> > +		if (unlikely(nfsd_mountpoint(child, fhp->fh_export) =3D=3D 1)) {
> > +			dget(child);
> > +			nfsd_filp_close(open->op_filp);
> > +			open->op_filp =3D NULL;
> > +			goto do_cross_mnt;
> > +		}
> > +
>=20
> [ ... ]
>=20
> > @@ -511,6 +507,21 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc=
_fh *fhp,
> >  out:
> >  	nfsd_attrs_free(&attrs);
> >  	return status;
> > +
> > +do_cross_mnt:
> > +	exp =3D exp_get(fhp->fh_export);
> > +
> > +	status =3D nfsd_cross_mnt(rqstp, &child, &exp);
> > +	if (status =3D=3D nfs_ok)
> > +		status =3D fh_compose(resfhp, exp,
> > +				    child, fhp);
>=20
> When the new junction check triggers, resfhp was already composed
> earlier in nfsd4_create_file(), so the fh_compose() in do_cross_mnt
> runs a second time on the same handle:
>=20
> fs/nfsd/nfsfh.c:fh_compose() {
> 	...
> 	if (fhp->fh_dentry) {
> 		printk(KERN_ERR "fh_compose: fh %pd2 not initialized!\n",
> 		       dentry);
> 	}
> 	...
> 	fhp->fh_dentry =3D dget(dentry); /* our internal copy */
> 	fhp->fh_export =3D exp_get(exp);
> 	...
> }
>=20
> The first composed dentry and export references are overwritten
> without being released. Should resfhp be released before crossing,
> or the mountpoint check done before the first compose?

Is LLM making me lazy?  Or was I already lazy?

I think the fh_compose() should be moved after the mountpoint check.

Thanks,
NeilBrown
