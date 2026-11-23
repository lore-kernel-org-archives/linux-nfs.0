Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.49
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795447127;
	b=hC1BfXjIYUvDb6gDA9fyYhYXsHso1//GlhZWvvOFbvCCSRTbfoIbat9nJWhWT1UZF/7F
	 mC6OQhPSJpawn790HzlgXH7hfo/Kt48OTybj038Ko6Ic4/2gokLet8A2fes13Cxgarh99
	 OgnG8WHcz8NQN4PhaB4ocI+hbj+49EHjf65O+NqjKNShtSe9CZKbstLXfuLAjLGz+3KG7
	 z+5y+oLOQPGrzpGfeJndYNMvD8/6NKEOPP1v/RpLD0QVwR0nQuwMiJxXvqK8KR2SfKd0B
	 nktJeq6lz2ONL+JfYhh6GfKcFRWv/tcK7nejkzF+thxpf9a+F+SA2hjYO+I4j8vhPaA==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795447127;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=FQauslTrJye8WtEKr4/uMYFLXtDrCWIYYsnNnENx50w=;
	b=NZ+VHl180rKbakFxN/YGZHYoYfxGPU3bgdstpkNkNnOo+P6VKqM/DqgoGZQMk0FSafq1
	 3PSfFEhiABHyVSVaPevl5nZ4VEdn3ohtgaNCFe1kw49nG3vOKl8sdQEhmaQtE8wYX1ZK+
	 HxNBzRGeZMmH8jX5U0ZUvSWzzNJavzquNfJdyBOM5H3NOoerMsxnxsKepjLypLS7QT2bE
	 3zqTNpfvJ45iq277fdUdOfsZOEYsp/HCzelbiZiugur2V5C4zG/tsG52aa8f1BkXN1ddv
	 TfPn4N3bVwJmWOu2VU+99UU1miey+3sHe9/dOV+z4BH2Juxx31iD+y4gQe99MOko4eQ==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=tnOVRIK8;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.49
Received: from mail-ed1-f49.google.com (mail-ed1-f49.google.com [209.85.208.49])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9B900606A31E
	for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 15:18:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 9B900606A31E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=tnOVRIK8
Received: by mail-ed1-f49.google.com with SMTP id 4fb4d7f45d1cf-6b87a92c17eso4778633a12.3
        for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 07:18:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795447125; cv=none;
        d=google.com; s=arc-20260327;
        b=h8tddcQmQEvJhf3lABYZYHymx2bIv0XrCmKfXXq9JXoa5UeZbETYmVruzSHn8GeXjo
         PsHBF7FKy65MiJq69nRLqW7iPCUNVEXMe5lho0zVf4l3BPR44dQEUL0aWUJt2a18pANU
         u9ZsnSuYhk4ccSoEsu3wBZk48Gt09ohIhiXfRc4VLl3+l26uqESDr8CdXm048+06I2IO
         YmEMiiWwbyojqw8R8U8MCiU8chE6hMVe8f2ondaj4rwb9TN8ETnqNiwfjjtpJZqhjSHH
         a8PDRddqeZnRoTyTKL3rzS50s6IxcTLBmzukrC2vbfg6OS96kjf7KEjpeYmZSlhykOM3
         2l1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=FQauslTrJye8WtEKr4/uMYFLXtDrCWIYYsnNnENx50w=;
        fh=GD0lm2za3L1OMbcFLfq83Pt5E4XJh0at91UAdA88sFA=;
        b=Ma0MU8VD0MwjxvJyhBGXvSGpa07taWHY6K3EGQ42v9g3um1p+GCT/YkmEZSakWboJ2
         x1sXgkV3fRRwsDs6Gegtt/BSIw00D6urs59fGIQgs8T5Fc9kbA499PBbDeKgZX1urdeY
         fy8d+0IM1sYlTfrsXbcj9WR8PYiqKdQo7GgjfqMfhswrsHBAE0lcAVlT56bdM87pNNkK
         afFfQY66chn70eGT8qhPNIphH0vvKvv/PuT/srf1w5Yekflff/LwspzfzDI1E0IasH1Z
         GVP/p13BoRqxFdFc6Clnxbz8gjKWlrlyfu4j8a4r06pe6lSo2KmThynCCi3kORFk+hC5
         Zjbg==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795447125; x=1796051925; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=FQauslTrJye8WtEKr4/uMYFLXtDrCWIYYsnNnENx50w=;
        b=tnOVRIK872Am/h1zBxtrm624YwtnAaM1ODFpUf4BIJQhjvNzDIVKPp0Tc0+kuNgK+T
         P6zbEiDvzhGQMmXVnvEgssD5Os9Kxz71/UfuvuNfnMWhsGjmbEY+8raprIJ9X6wrs9+P
         t+n4QGoPL0En++2BIFCjCTfGW7tcR93V3ClOyWg2gSS8rvl/rQevnj+NbA2pmKoegUTq
         wAOmepamNX26KktT8XanGPaaDNNp/wDvhl8maLDsDH89HC5UHE/TdVVYvF0O7DiHJyEN
         CZVx9d478DNjHDgR4foo1kre37sD3glA5umfoInRNznQIrbXZtcPjA2+5t6yJceHDFpe
         Nzlg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795447125; x=1796051925;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=FQauslTrJye8WtEKr4/uMYFLXtDrCWIYYsnNnENx50w=;
        b=If864O5F9iyUQ5Z6rUFcJ+xgQtmXaA9rDHFPD4rED+JmZpNL3YnWFYH5pSblYv3lgL
         u2GAP1YecrB2j27g+OsBJmShF9HOdQMHFPiypV5jHpMqggIL1AbPgh9ttWhiRU2Z0TZI
         odYAeuqzNYBGzwBoM9j7W0o/c5uaoyeis8Y1eeLpcOCp/RYaYP/BN5kIhExvZu2hoj1r
         OlmyE6I5cdFaljac2PpvOvfEvwMP4eBJbrd8znrhyBBBFUmYmX+rtQPgGXkGpG7vmJPx
         f8YmgpP+jrxHWn9i6y5611tbgMxLpeNoQGtba9ypt6oQzjlw/7KjmZKf2/thApxPSXRz
         dvVA==
X-Forwarded-Encrypted: i=1; AL+hErGVOMIexxwB14TEWUH6ocU8G6Gke4yXplHbWhW8rArJn8yFwPR1lbT3CXIqs+APM7jcFrLO0DCH4l4=@vger.kernel.org
X-Gm-Message-State: APuU4Z9Z9575h4i+rXPhudHptQm+HwZe6NARuB12f7a5uY2ypSGJDQnP
	qIboPco2qbk3F57Crgownhu3PQKX6pKL+Ia3UBcrXGlmyQFI6LgW6Lxn9PqtxdWou1F8tQzdAoj
	jGQKgthHGfdDtfirU7Ngwh7IsHfTK5C8=
X-Gm-Gg: AZFdTZcIv3Y0CJ0cMIFObjZUi6jy6ghmSYJE9bqmOM+FUkeBXUnvBsgMnKefIX5ub1R
	9Qfq8aRdoTUiThdBjCdKW4PYz6kDUSP94Is2bZ4I7mzMziDB2xJh8ar8rg1J2imveeYnY/6M6C2
	SFi2a+KARBidRoENFlgwrKkKanLbRcPB0/WDfPY25CuyiUrVgPYm7/nE33jhjl1hAcpaZnp+QS3
	MKrX8MtqnuWOzNZxb9TBKsbCaOoKZprvPmmzYaKKMP/251P8ZlBC8JTwnJXlIcr+QT5hKjtPUZj
	JbnAYN+YSHQp2Tgo8d+iHskzq67aFRqRmaWzjG03aXLW0b6U96RKM/KeQwZyG4MOvPrdNMb7GND
	TqjgQA+Y+07GPulLTJRV/87vltsTsk7mqwUK7QP/IHZRge3tsYvgekWWWSbtSh2yAR1E47e8=
X-Received: by 2002:a05:6402:23d0:b0:6b1:b97b:744 with SMTP id
 4fb4d7f45d1cf-6ba37ec18e4mr7070716a12.32.1795447124603; Mon, 23 Nov 2026
 07:18:44 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261122000856.536902-1-koray.fra@gmail.com> <20261122000856.536902-4-koray.fra@gmail.com>
 <CAOQ4uxgc6pP+_xvJMbqj6wOdGzS75Vn6x6i_vUfCJDD46DAA_Q@mail.gmail.com>
 <DN2N0BY83OY2.1OV3ZAZFSWCDG@gmail.com> <CAOQ4uxg9O-R_SUPAZ75ESGB99-4Z4EEUKGMkCF2f-sXkGPq1GA@mail.gmail.com>
 <DN2NVGUNO0GA.89JAB2PVI0LA@gmail.com> <CAOQ4uxjuAN0FdxGr_-OccO5qnUuLF5oxOq7L_545tG3+36EKFw@mail.gmail.com>
In-Reply-To: <CAOQ4uxjuAN0FdxGr_-OccO5qnUuLF5oxOq7L_545tG3+36EKFw@mail.gmail.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Mon, 23 Nov 2026 16:18:32 +0100
X-Gm-Features: Aa3M54oObGzmT9EyX7FArFQpCHBYwqipULgBnYau0_-PZcRo8HGalO_VEERbt3I
Message-ID: <CAOQ4uxgyKcB8GjE5_S9fgMv9oC_dKKaypDWEf-eXEkFeo5e89g@mail.gmail.com>
Subject: Re: [PATCH 3/3] ntfs: switch to the new xflags fileattr API
To: koraynilay <koray.fra@gmail.com>
Cc: Namjae Jeon <linkinjeon@kernel.org>, Hyunchul Lee <hyc.lee@gmail.com>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Christian Brauner <brauner@kernel.org>, 
	Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, Jan Kara <jack@suse.cz>, 
	"Darrick J . Wong" <djwong@kernel.org>, Andrey Albershteyn <aalbersh@kernel.org>, =?UTF-8?Q?Pali_Roh=C3=A1r?= <pali@kernel.org>, 
	Lauri Gates <lauri.gates@gmail.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <dgc@kernel.org>, 
	linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, 
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
	ntfs@lists.linux.dev, linux-nfs@vger.kernel.org, linux-api@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, Nov 23, 2026 at 3:55=E2=80=AFPM Amir Goldstein <amir73il@gmail.com>=
 wrote:
>
> On Mon, Nov 23, 2026 at 3:31=E2=80=AFPM koraynilay <koray.fra@gmail.com> =
wrote:
> >
> > On Mon Nov 23, 2026 at 3:14 PM CET, Amir Goldstein wrote:
> > > On Mon, Nov 23, 2026 at 2:50=E2=80=AFPM koraynilay <koray.fra@gmail.c=
om> wrote:
> > >>
> > >> On Mon Nov 23, 2026 at 2:00 PM CET, Amir Goldstein wrote:
> > >> > On Sun, Nov 22, 2026 at 1:09=E2=80=AFAM koraynilay <koray.fra@gmai=
l.com> wrote:
> > >> >>
> > [...]
> > >> > Rule:
> > >> >
> > >> > You cannot add a flag to common without carefully auditing all
> > >> > filesystems that support the legacy flag.
> > >>
> > >> Yeah, sashiko pointed out a problem in f2fs, and I could reproduce i=
t in
> > >> testing, where adding COMPR to COMMON makes f2fs crash, it also need=
s
> > >> NOCOMP in COMMON.
> > >>
> > >
> > > I don't think this is correct, or at least not enough.
> > > My agent said that this breaks or changes things on  f2fs/ext4/ubifs
> > > I didn't bother to check if all of them are true - I doubt it
> > > bottom line - need careful audit and good testing.
> >
> > Yes, definitely.
> >
> > >
> > >> > FS_XFLAG_ENCRYPT can go into common but must also
> > >> > go to FS_XFLAG_RDONLY_MASK because it's read-only for
> > >> > all existing fs.
> > >> >
> > >> > COMPR is rw for some fs and ro for others.
> > >> > As with CASEFOLD, you cannot make it COMMON before
> > >> > converting all casefold fs to new API so that each can say
> > >> > whether it wants RO or RW.
> > >>
> > >> How's CASEFOLD currently handled? in the v2 I'm drafting, I added
> > >> fileattr_mask_to_legacy() and fileattr_legacy_to_mask(), which conve=
rt
> > >> between the old format (filtering by FS_XFLAGS_MASK) and the new mas=
k
> > >> format.
> > >>
> > >
> > > Good question.
> > > Need to check this.
> >
> > Can you do that? If not, I'll check tonight, no problem.
> >
>
> CASEFOLD is set in FS_XFLAG_RDONLY_MASK and NOT set
> in COMMON
>
> Therefore, doing set with the old xflags API for the common flags always
> preserves the old CASEFOLD.
>
> This is kind of ugly and works but its hard to see the design there
> so hopefully all the new helpers and masks will sort this and make it
> more explicit.
>
> IOW, ENCRYPT can use the VERITY RDONLY and COMMON
> precedent because it is read-only across all fs (via this API).
>
> COMPR (for the purpose of ntfs patch) can follow the precedent
> of CASEFOLD of RDONLY and ~COMMON, which somehow works.
>
> Note that for fs that were converted to the xflags_mask API,
> COMMON should be irrelevant.
>
> COMMON is only used in SET to do GET and preserve the ~COMMON
> bits of the "other" API flavor.
>
> With the xflags_mask API, unless we adopt the "verify" feature
> there needs to be no internal GET with user SET and then COMMON
> is not used at all relevant at all for those fs (e.g. ntfs) only the
> _fill_ converters are important.
>

The statement above came out too strong

The internal GET is still needed for the permission checks (immutable, etc)=
,
and for converted fs COMMON still matters for the legacy ioctls, but it is
not used when the new xflags_masks API is used.

I would love it if we could get rid of the internal GET, by moving the
IMMUTABLE|APPEND checks to the fs fileattr_prep_ helpers.
But this can wait, you should not be distracted by this now.


Thanks,
Amir.
