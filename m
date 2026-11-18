Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.218.46
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1794987856;
	b=DShsAgIAPiHYSGCUtlXo0n3kaBAmIC/O2WFqx3fIi9k9fmgJSRO9Gc6DY4TGo452o1UW
	 RbiZYc8bxFzV4xAwcAzy0jZGDxYfXbVmR4kaT2MoBKIYxvIJDJesasNiQq5Z20J7hXEx1
	 5q+xRCdy5ayYeuH19mVpYt1vG8n7xBthPf5jeOUuXkshAc0koU8uTPJ3KMFjssg58jB1H
	 yksdMB3Ar/l3fNmAW/4ZQsQkJoUB/o6mkJFG2O02iiPKmDmmzwxyj8WfEViUhGRVfxvNV
	 LPZkbF191RLuJZdwTx53aUe4beJwwqxeXvYqtx/8bAwBFpZQyfvWmElUEujnj9Udytw==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794987856;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=n4AlrOV2bTkxElEMddERWhd2tmhmmQ/VeiiLUiTK5Jw=;
	b=v1nwU53rKBxebm8SeWIz33IW+HUw4OFjqr6lYxEK17KnThoGBNVdL1IjlJ3ST+AXFEJW
	 0Ca9XdK9QUU8orCQWKadI6Fl1e67fD2uffzCLzIf1WOvNwi2GUbetg8er4bKnL3DGS82U
	 UOg54CYSmIQzSWjeMfzwvr1AbWD8IJxnwj97MtMuDlJyHWtMObMVEd3yeKDSKEKgQwcl6
	 Hm95qT/fmO0J0eKl2jQpdLUDR1mP+U8rXB5hBansl2ZRB1ks1FZn2c4lCoXIIuNkbAfCA
	 2kImGVH+h05ne7AecJrYP5CTmtEVZq1EwDMAQv66GsqYHdPvpNcHJcefUNESDKgPLTg==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=a90oyekV;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.218.46
Received: from mail-ej1-f46.google.com (mail-ej1-f46.google.com [209.85.218.46])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CF7B4606A338
	for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 07:44:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org CF7B4606A338
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=a90oyekV
Received: by mail-ej1-f46.google.com with SMTP id a640c23a62f3a-c5067a2411bso80384566b.2
        for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2026 23:44:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1794987854; cv=none;
        d=google.com; s=arc-20260327;
        b=M1dTns1nOVR2xTSmOJhGdnpJ1houvi9NN6CX3moW5Rk6GygUnXHhFdua5f15b2YQxg
         rBwoaqlSREQ989QNRjxy2xLqunU6BCtIe33z8XRfDCZEQ++UD0BBApgsbJY53ofeXSyW
         5t7eAqfsckMYzWJw2IfX1Wivk7FRjADDqmBn1c/AjQaiaDJvnjtXjXMnxXEkdALL+raI
         Mn4rR/hHMyA0rUhq1hLg3gmBEQlOo4tZiuwawHgcRqt21pV3IvWzQ0iApISqjC34cuZb
         CNjFhK/EJOL/kkvWfPMFR3PgYsMnjwy+rVx/Kj7BBXizSozscfA71CDO0+t8qsQG3n1I
         0o7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=n4AlrOV2bTkxElEMddERWhd2tmhmmQ/VeiiLUiTK5Jw=;
        fh=+MuCUptRyN8FCwaQhULCNTTnGQWeAe1uVRRKFNj529E=;
        b=gz6UekUWYOypYFCMW+FfhB5pmAOJc2JIRQ+kVQy5k2fwJNq+XOYSVymaPhigDRmUeD
         hwimOcnIcm3pziQKFCXVLl8WZD8vJbjlQ+oHK3NtIKtfYUthOPOvmNr9uYBoaGDyQa2a
         JzDdMy34LPRiJUFAg5e0PP/d7Wy7X90KyoLmxsgnGxB9TugHiUvJSk0GX03yas3sReRN
         OR15ie23xwyPuiji0R9ZfAl6ykCjpefgNTizbUP1Q78M5rVBqk0CEM5JnpBbi72QbqXt
         Fc7miaQX/cIYbTDV2DbeDmQZZKAN6CmE47A9OJGUhn9X2xvURE71pZkkZFcl3UTazfBF
         qA4Q==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794987854; x=1795592654; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=n4AlrOV2bTkxElEMddERWhd2tmhmmQ/VeiiLUiTK5Jw=;
        b=a90oyekVEtWSbiQRFscTKUuOugQqsd/uPA+FKR2IB/q1W1t8taa8KZshmfMtrhj1sD
         LqlTnKmsQhen50SBtfcKu6ft+wmIP8g2pM86rjRDF5dOKhx6HkBJjAXW7T1Tl+HJbYGM
         9Z/N8X+v0TSuGqaim2wrUn/cNQfHBvaUNsmrozwAN8tX044VAK/I37vtJhmtoyIAOWLA
         XYHsu5zGuiaBInhEXWSkPT9Ljesxk0waBX2hq58DlHTNOBoHWFxCJ3W007gohZobfiCi
         lUKynaBj5mnjW9OxWobgOEENOt4UOL2ebqhsSIkfnMawpK0ePLqbjCd09xHI9SQgG63a
         TzFw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794987854; x=1795592654;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=n4AlrOV2bTkxElEMddERWhd2tmhmmQ/VeiiLUiTK5Jw=;
        b=otB3p+fId+Mux4ZmsbETeV7/IGenK5CF7cPvwf7JYAuBdLPLoO7ciE7qGbZ6gzIYHJ
         TuQxuXwQMcpQMtifaOOayEOSEo4KRfDo4u0nY0c1m8IZoUWZv+LthS/to/NIJRyYCbpv
         Sdwp62rmHIK6JhMGY5v7wxKlbxdEhjVpC3nBc2Xtf5e4BsqbpFMlIAqEUE6xm2nMW2uP
         B0eVl+w8woD973GwyJsKNfM13PeNJcUG6G8xAx9opahzIAe+Fg0LIlC3S/pqQgBTvvl8
         /Dgnwg2FShGwru9OsCU/rqICXIGtUUqbWt50EFZRS45U3t2ce4skoe9ubMJsgFguv/XS
         PYmw==
X-Forwarded-Encrypted: i=1; AL+hErFDUNzU4JGm4lWIry6Nr+gUbzKY8vGsFX6pG8Z2cmdCqOSK5l08DYcgXoWz2zq3xAPd3Aje+CrFYVc=@vger.kernel.org
X-Gm-Message-State: APuU4Z/709Z0HebapSYOVYDJqFz26U9mxwvtaWphE1J5A1/S5kycTOGL
	DSyJe0h9a3yvU5BLZg8FCT7/t/0VJ+3edOzED7/yW7BtEqCAJzq2USuXCiGrRKtRkWSv9q8fgpC
	WfPhaqx5c49lL+OR2NZ9E4+Nccc6jk/w=
X-Gm-Gg: AYBFou0TIaAtvz7KrEOwDdzOd641k9NSjTPnSjKPPGdbKnPCYQSbx5nXIIwbUZenBVB
	rpgcyDWu2dbGiJLozOuRdds5DyGUDRm53tCj6ktZSuVafAfHSdhNm4ZNZEW5gIatN4Qr7r2NM2n
	xSUZ7fLhSbvPo6+xXMSgsaFZck09+AHA4dubZLPdoMx3cAZEk/RIgKQe3S1kg++0XTIElVSQL88
	/c3TeVe9KWdbqrjd1llaYN9zpevUgVkoF4TTej3pevcs8p0S/aNEnQhQP31670JZ3dQVV7jXrA5
	RtFuAl6IOs3Cnxs2tIKPwTAY9bDLG4CIWiMaMlZkp3uYQUAEZk9lHDCAWEijpImOXlXPvubxaEj
	7mPrKJ1PBG3pyxQQwewZh3zWbV2l9hsOZ2xdq6nCAOx098TM1v/nJUO4xyN/gxEZEjejB8Q==
X-Received: by 2002:a17:906:99c5:b0:c2a:ad55:b3fa with SMTP id
 a640c23a62f3a-c510debbf56mr128472166b.7.1794987854109; Tue, 17 Nov 2026
 23:44:14 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261115180343.576773-1-koray.fra@gmail.com> <20261115180343.576773-8-koray.fra@gmail.com>
 <f297d9ea-ebd7-47f4-ab7b-de5c45980000@app.fastmail.com>
In-Reply-To: <f297d9ea-ebd7-47f4-ab7b-de5c45980000@app.fastmail.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Wed, 18 Nov 2026 08:44:02 +0100
X-Gm-Features: AclHuK95FDUZyIgGYH5oXAgwPF3l-5HxSmk1nBdJ9DPBoS5wbYWUIu9nYKyQ4rA
Message-ID: <CAOQ4uxhpMARO_ZMJDeoa044BwufLVnS0o4Fv0abBF=tjaZmtWQ@mail.gmail.com>
Subject: Re: [RFC PATCH v4 07/10] nfsd: add provenance time (ptime) via FATTR4_TIME_CREATE
To: Chuck Lever <cel@kernel.org>
Cc: koraynilay <koray.fra@gmail.com>, David Sterba <dsterba@suse.com>, 
	Namjae Jeon <linkinjeon@kernel.org>, Sungjong Seo <sj1557.seo@samsung.com>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Christian Brauner <brauner@kernel.org>, 
	Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
	Konstantin Komarov <almaz.alexandrovich@paragon-software.com>, 
	Paulo Alcantara <pc@manguebit.org>, Chris Mason <mason@kernel.org>, Yuezhang Mo <yuezhang.mo@sony.com>, 
	Jan Kara <jack@suse.cz>, NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	Ronnie Sahlberg <ronniesahlberg@gmail.com>, Shyam Prasad N <sprasad@microsoft.com>, 
	Bharath SM <bharathsm@microsoft.com>, Sergey Senozhatsky <senozhatsky@chromium.org>, 
	ChenXiaoSong <chenxiaosong@chenxiaosong.com>, "Darrick J. Wong" <djwong@kernel.org>, 
	Sean Smith <defendthedisabled@gmail.com>, Andrey Albershteyn <aalbersh@kernel.org>, 
	Pedro Falcato <pfalcato@suse.de>, =?UTF-8?Q?Pali_Roh=C3=A1r?= <pali@kernel.org>, 
	linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
	linux-fsdevel@vger.kernel.org, exfat@lists.linux.dev, ntfs3@lists.linux.dev, 
	linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org, 
	linux-api@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, Nov 17, 2026 at 11:02=E2=80=AFPM Chuck Lever <cel@kernel.org> wrote=
:
>
>
>
> On Sun, Nov 15, 2026, at 1:03 PM, koraynilay wrote:
> > Implement provenance time (ptime) in NFSD, as introduced in a
> > previous commit ("vfs: add provenance time (ptime)").
> >
> > Map ptime to FATTR4_TIME_CREATE, allowing clients to set it across
> > CREATE, OPEN and SETATTR compounds.
> >
> > If the underlying filesystem supports it, use __vfs_fileattr_set_locked=
()
> > to set it, returning -EOPNOTSUPP in case it's not supported (i.e. when
> > __vfs_fileattr_set_locked() returns -ENOIOCTLCMD).
> >
> > When querying FATTR4_TIME_CREATE, request both STATX_PTIME and
> > STATX_BTIME, preferring ptime over btime if available, and advertise
> > FATTR4_TIME_CREATE support if either ptime or btime is available.
> >
> > Assisted-by: Gemini:3.8-flash-high antigravity-cli-1.5.7
> > Signed-off-by: koraynilay <koray.fra@gmail.com>
>
> > @@ -3646,7 +3649,14 @@ static __be32
> > nfsd4_encode_fattr4_time_access(struct xdr_stream *xdr,
> >  static __be32 nfsd4_encode_fattr4_time_create(struct xdr_stream *xdr,
> >                                             const struct nfsd4_fattr_ar=
gs *args)
> >  {
> > -     return nfsd4_encode_nfstime4(xdr, &args->stat.btime);
> > +     const struct timespec64 *ts;
> > +
> > +     if (args->stat.result_mask & STATX_PTIME)
> > +             ts =3D &args->stat.ptime;
> > +     else
> > +             ts =3D &args->stat.btime;
> > +
> > +     return nfsd4_encode_nfstime4(xdr, ts);
> >  }
>
> I have trouble with this approach.
>
> We've already established that, for the Linux in-kernel NFS server
> implementation, FATTR4_TIME_CREATE reports a file's birth time and
> does not permit NFS clients to modify that.
>
> After this patch is applied, the server reports the ptime instead
> of the btime on some filesystems but not others.

In other words, for some server filesystems FATTR4_TIME_CREATE is
settable and for others it is not.

Isn't the NFSv4 protocol equipt to deal with this complexity?

>
> Essentially this changes the semantics of existing files that have
> a btime set -- technically that's a regression.

I fail to see in what situation this is a regression. Please explain.

The only oddity I can see is that a kernel downgrade could result
in an NFS client's view of FATTR4_TIME_CREATE going backward
in time to birth time, but I don't think this qualifies as a regression.

Thanks,
Amir.
