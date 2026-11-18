Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.50
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795019817;
	b=rwDL/DDVRsR3iuu8CtygYTfjkExYHxRRDruFkQDX8ZwOZPFmBOCaUnagGXjdMmD+TzEd
	 xia4Va2//YLwq8AWBqjl3SencZ56Uv8uZLfcNarxKFXXXkv8Ogfk6KuTfMVgofwjjJ+Wn
	 5mh1qkW4JGlJNFJO9EftJdHwMYp+5NC0n5X5LuuD90Njgva6C9qdntplp0smj0coXMWeJ
	 1flaKdoQhhe5pP0a2utBl40j9hcS2b1brA9IHK6z65Pqa5YsseIsLY5Ws1Ku1T/L6T+eb
	 qRoFRUS1FMGFfGE4R30f8UN25wilAIfOiYxyom3Uq4IZ56i9Nz0VmdVoYg/dJhagWPg==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795019817;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=ThJWWn15R7JIY3hayjLwOhu3LzqQd50Rds3OyAm+UpI=;
	b=wuTkglfcbsZ7nze2sd5cR80X6FLnKYgx9eEqGVqDWKMSyntVhlt37Zov2cRNQnS87+rD
	 jFFd+a71I9/6c9lwtxe9/kfGwdMXDZQ6InZfFbZzgUzdPQDJsIeuf28+7ZDF3IRcMBHDe
	 iNChxD/FFFqUrPXVOhwkDM+DhbXw1qq06N0KzG51gWSapyWGHqvQiMMVXoh6Ef5kxwBvL
	 TVKklGN4S5v5/TTJQhEPKEMlLh9sspjytj7BavcVk6YyMU50yL+cHmfhCebMtwMNq+YdW
	 E8/4D+WYSjX7S9K4PQpKjV4zFqfR8WS3Me34udhl5yQvP3O0kNggwITWWIzgUtPPWXw==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=Q928FUfp;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.50
Received: from mail-ed1-f50.google.com (mail-ed1-f50.google.com [209.85.208.50])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 338DF606A32A
	for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 16:36:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 338DF606A32A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=Q928FUfp
Received: by mail-ed1-f50.google.com with SMTP id 4fb4d7f45d1cf-6b8815693e2so1678040a12.0
        for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 08:36:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795019814; cv=none;
        d=google.com; s=arc-20260327;
        b=Bi7QNFcfjUeUEWjZ5hUtk47bJHDC29qgwGvLBliWCL/rL67PqmHipbao2KvbbLTQAo
         aLdANpgCVP2I6TkvKNnmPhL9DfnBpInJHi2jsEgwvTTaFNv0TniPz7z8VHFQCKht/KHz
         DsC1oiVDUpWFhNqa2hr1I//tmWndBjhmnNxzjJjgtkK6ScPF4uoAIhKl8C1lNmhB7zv+
         K8gZRV6/K4PNSGETCKgeU18eGsVb9BPpXZ8RL3tu2yOJMz5frHj7cJMCK/0oLMDICFNJ
         nmyyKtOdnhP7qB4K/aJToRmC5LWEI+mHDOknuQ8/NEu8KQgkJVbCQAZYzvBldd3g1KpG
         NnYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=ThJWWn15R7JIY3hayjLwOhu3LzqQd50Rds3OyAm+UpI=;
        fh=egz6+XOY4E/8aDJovlEutj/AV4PNjMtBr55LWM9l8/8=;
        b=PCvZJEyvsiyacs6TZuMsi3fKoK6tUj543fltclgYbBLJ3uuNCt/gRSFGx+FFJrOXno
         VTWP+IWYLd8QBmMQQt9Y32a6WNn4nI+E9+xFAyWj3c8uLW3Yql+mzNAXEkyU+/I5duZS
         pAiT+i2UQehO6wnZqBQGDkt48DcmzNCyXhKCPFPH4E9FEDWimpXTfRGjPHq/YdWHrRZ8
         v3TUX0PsaaElF9ljSA95CdH9WYGyVxU1XJixL6dZUP7p59ZERMJwJXStbF2qsqpv6NOt
         5XnEBrGnm7mtROFT5+Md34AsAnoC5pC0dnEasP6l41lHhlrpUOpZCNCdmbgmiY5o2wnZ
         NdKg==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795019814; x=1795624614; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=ThJWWn15R7JIY3hayjLwOhu3LzqQd50Rds3OyAm+UpI=;
        b=Q928FUfp2LnQkjGEnKMIMu+nIXWPV8Mw0HjVjFDQa7MZUVLuYPLFwnsc7iiHqC360u
         Kp8IRabh9aATlCbBIrXYC8LB4ujsA2WowQnPl0onFZOSJ5rVYhQ50HD2q0pTUJXyKimM
         OUL77cTMfVDMrYjz/NQW0TKyEQpYRFMt7Ju+HVxVGfRQjrSAY87Mpzq+C/2x9bC6NTow
         OtYFWyMzdvLEcoERGP5aXpJZMZOJljjkWPd07rML7zS6cDn/RnBxJCXaYM/7fpaXHvui
         3d3div9gMzI9ed77/rJrBt7B9+fw7rgFDQ4NESvylFpmE6QFtWC5GnB6Lj4Ro4sGb6Nt
         AJ7g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795019814; x=1795624614;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=ThJWWn15R7JIY3hayjLwOhu3LzqQd50Rds3OyAm+UpI=;
        b=sKbOi0HmN6EpANV3lsRsjVoBYTKRhZXiy6DQVwXM2tHae87YF4KDB6SZ9dm/9v+Phf
         lDDFsQfw4gOkSV4XtYuvPG6H60p53IDko75nBsOffLwdyqDDJqexEzm8INacQJ9ytaUW
         o89MF/Zndg03AEL1L+4NoPuSRaTyAFmcZMXj+E5BHeDbCpWCISwEtADhZ0nc3V5JpEMt
         J0T7w1xPw/O4kypfx7R4evJ0zoSSSQzEabwkpZAoA7zhcRDbQgrLVdce8IBgsZnrh+zO
         KJguzIPzozHD0btS7WyGjWtx7jvaDN2eVSrg9tlVzdgbRF32wXo7Yr2j0Z/IseKg94J7
         xlDg==
X-Forwarded-Encrypted: i=1; AL+hErGF+tt4qPSsd5PPrUY93fINGT2CYx7UANnSb+4YNI3xQOGKhqjGAYnqJyOuplhsywcCpf5T4/hVrSM=@vger.kernel.org
X-Gm-Message-State: APuU4Z/Q8+ZiyQfa6DFxE7hSPMkmJ5xQp8qH3etAPzx8EkVLcluno2EF
	F5nUsVyoZoQnO/+ELPglQLflgEu6a7k8Qz7Cs/7hP/EzWV/iOCKAt/+elC2LhAxfQmqUdXfxcAI
	kBGIiakDknIucC7a3Pcw34iKRP8mGN5U=
X-Gm-Gg: AYBFou3bYX11vlEE6ZqN4oVjKzjMkQXOZY3SKcDodAYP0AnNLzqs0sF15J/xoTprR4i
	bpoz4X4wK+Y/FaZfOD8b4jgVIe1dV3nrP2ZDqXt53Z9TET7pkdOnuUnwEa9/0NhePtumy1kfW2D
	+6pQXj9fQ5J7JHjsF42YZc65Q7ULgZ2QZL2fhyUumN7Xwy+/RWSyqMd/eYNiLjo9N6YNDkxd/nq
	w6hQhm9/wFYtHYYrM8X9CHIorufbJvNGJfJ5Ec5KKquijQl5l8VZsXmfch0DCnl1qa6Y3TyDe2Z
	7O3T4PiFZaI2LI89Bj8dlKo3tEr6PhPNoxXupDayAlxe/hhd4F/tsfYb4rhEZYDdmv110sS/e9D
	hOIkfzuzsDmOWBVF9EOvkvmmQwSrIymZ6S8wHqae3BtQNMI77afltsfeMrvbiV4KIr6qksg==
X-Received: by 2002:a05:6402:c711:20b0:6b7:b12e:1638 with SMTP id
 4fb4d7f45d1cf-6b887effc26mr1999145a12.37.1795019814317; Wed, 18 Nov 2026
 08:36:54 -0800 (PST)
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
 <f297d9ea-ebd7-47f4-ab7b-de5c45980000@app.fastmail.com> <CAOQ4uxhpMARO_ZMJDeoa044BwufLVnS0o4Fv0abBF=tjaZmtWQ@mail.gmail.com>
 <cd49ce48-58d7-4341-b4fc-34e63daf3c52@app.fastmail.com>
In-Reply-To: <cd49ce48-58d7-4341-b4fc-34e63daf3c52@app.fastmail.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Wed, 18 Nov 2026 17:36:41 +0100
X-Gm-Features: AclHuK_Wot5qcfi8_9CAebWCtd31KyKZ5gW_T2w6JAANm_7TsCfaaSyfxQBsTLM
Message-ID: <CAOQ4uxjme9sJ5LGNDnP6rEKZLTJzX_ZdcMohgu2iLULK96GPOA@mail.gmail.com>
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

On Wed, Nov 18, 2026 at 5:09=E2=80=AFPM Chuck Lever <cel@kernel.org> wrote:
>
>
>
> On Wed, Nov 18, 2026, at 2:44 AM, Amir Goldstein wrote:
> > On Tue, Nov 17, 2026 at 11:02=E2=80=AFPM Chuck Lever <cel@kernel.org> w=
rote:
> >>
> >>
> >>
> >> On Sun, Nov 15, 2026, at 1:03 PM, koraynilay wrote:
> >> > Implement provenance time (ptime) in NFSD, as introduced in a
> >> > previous commit ("vfs: add provenance time (ptime)").
> >> >
> >> > Map ptime to FATTR4_TIME_CREATE, allowing clients to set it across
> >> > CREATE, OPEN and SETATTR compounds.
> >> >
> >> > If the underlying filesystem supports it, use __vfs_fileattr_set_loc=
ked()
> >> > to set it, returning -EOPNOTSUPP in case it's not supported (i.e. wh=
en
> >> > __vfs_fileattr_set_locked() returns -ENOIOCTLCMD).
> >> >
> >> > When querying FATTR4_TIME_CREATE, request both STATX_PTIME and
> >> > STATX_BTIME, preferring ptime over btime if available, and advertise
> >> > FATTR4_TIME_CREATE support if either ptime or btime is available.
> >> >
> >> > Assisted-by: Gemini:3.8-flash-high antigravity-cli-1.5.7
> >> > Signed-off-by: koraynilay <koray.fra@gmail.com>
> >>
> >> > @@ -3646,7 +3649,14 @@ static __be32
> >> > nfsd4_encode_fattr4_time_access(struct xdr_stream *xdr,
> >> >  static __be32 nfsd4_encode_fattr4_time_create(struct xdr_stream *xd=
r,
> >> >                                             const struct nfsd4_fattr=
_args *args)
> >> >  {
> >> > -     return nfsd4_encode_nfstime4(xdr, &args->stat.btime);
> >> > +     const struct timespec64 *ts;
> >> > +
> >> > +     if (args->stat.result_mask & STATX_PTIME)
> >> > +             ts =3D &args->stat.ptime;
> >> > +     else
> >> > +             ts =3D &args->stat.btime;
> >> > +
> >> > +     return nfsd4_encode_nfstime4(xdr, ts);
> >> >  }
> >>
> >> I have trouble with this approach.
> >>
> >> We've already established that, for the Linux in-kernel NFS server
> >> implementation, FATTR4_TIME_CREATE reports a file's birth time and
> >> does not permit NFS clients to modify that.
> >>
> >> After this patch is applied, the server reports the ptime instead
> >> of the btime on some filesystems but not others.
> >
> > In other words, for some server filesystems FATTR4_TIME_CREATE is
> > settable and for others it is not.
> >
> > Isn't the NFSv4 protocol equipt to deal with this complexity?
>
> Not a question of whether NFSv4 _can_ do it. It's whether it _should_
> and whether opaquely choosing a settable vs. an immutable timestamp
> on the server is the right design.
>
>
> >> Essentially this changes the semantics of existing files that have
> >> a btime set -- technically that's a regression.
> >
> > I fail to see in what situation this is a regression. Please explain.
>
> Any consumer that depends on btime being read-only is now screwed.
>

Who is the consumer in this context?
An NFS client?

Can't an NFS client be connected to another NFS server
implementation which does allow this?

I can't wrap my head around the problem.

Thanks,
Amir.
