Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.54
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795024254;
	b=yOSufhJsXQ3K32ROwvijVRDXODLYr4ZhIU0cVOtoR62stJOPF9YomFJPx3JUfPO2CxcW
	 y7SCK77ZsrmsR/ScgKvPNpJTckp1udzp98zn6Ld/PUtNK+FOzMQu32p4FDMLI0cRUaa55
	 vQroiCwQzBeMC0SmxNs+1PhPH6lfLnspY89MKUqDILeCufyg5L+/uYoUlI1KIeOvGfQdv
	 yaoorjqz/VkBmzozJqb3UPiCEfNZ9nf7lmrSuZL+M9hX9+QlHYluGVRHVzU7an3/LmmRG
	 JjTtT7pM0HImrl8E09D8MhegNfHZNey3TVnyh5MYSjT7NSC5Rz/mSdrd6MBknWXyqsA==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795024254;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=BliQBsLi8Tf+bGa80m+pxZeHcLThIeJfSszhbNvQWjc=;
	b=1XwzDdvr5iD7vfG6e+L0f4oapHAvs6f2yGvi5E+3DXh2DFtzc5sbn7BGTa/JTneTuTAq
	 bKUbJ48kozLbrqK3vyXTUkOOYaqRATFavddbMA4qPB0r0LMDrDCy2fHytkhbciPjYdtja
	 PeJTYgNqLxuHoeQAN9DzTZCMyJ5yDvEt/cx4ZlDhJdDczi5HJ3FbUZ9YeM5xu/11ePsNT
	 uCY/skU17GZqyENtcL64iLroiTqaSvUVDyHH4zERgyMUcU4LR8mYR8yecWKM1pwZYCk7C
	 TqxWnzAGkUgFXDnvRSO+VDUNFZd8DvqSu32R5QxuKyyXMs7O5PKaxyNuqZBt3Z1SUEw==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=t0urFzns;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.54
Received: from mail-ed1-f54.google.com (mail-ed1-f54.google.com [209.85.208.54])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E6D9B60A260C
	for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 17:50:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E6D9B60A260C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=t0urFzns
Received: by mail-ed1-f54.google.com with SMTP id 4fb4d7f45d1cf-6b8786bb305so1993417a12.0
        for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 09:50:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795024252; cv=none;
        d=google.com; s=arc-20260327;
        b=rrqMZJeUwyYF+d8hT2p44dr/XUS3+LD2ELVhvCZURqfMDjo3tNlcQ8K0M1vmDoisLW
         LvRVSoAoGAtSARS3z8CiQe7mxMIwAsbZC7Uxdhtm3eccOHSSm84r4vOHGXLbeKsc/eLo
         n4SilvOV0IIHF2xNASbuzf96fOqM7kLWFMnB/IgwcHT5ICCzgEse+cZLcKi1XS5YLTT2
         ttT36aesng7D3hg9Nf7Q/TFk6pMZ2d2UuC7tsmNknjEIaXgP1ea9cWZCWLl5Qh7DYk3S
         hrMmuxyr8rifeCG6eAos4FH3q8mEeu2ZLY9iNGEwGKfaBgpoH0Y7k4vphUQdw3lGxwlR
         zAVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=BliQBsLi8Tf+bGa80m+pxZeHcLThIeJfSszhbNvQWjc=;
        fh=9JAWgqUlc5M8EmmgpdSvGhyUwWA0eLSj/11RQMWqda8=;
        b=qxH25bY2rNVBlzKhdPcL4hG3n2pUDmgY+t53ErkS8l7F7Z+ML4GXNcvPz6x5ft80RJ
         zsrwglEpymQTfpavuFTFECHei3Ashdqyu+F/EcQEBywmxzZmIfCLQCvj3j0jLZSQlzbQ
         QCsSf8CXg6i+S0THuAJo35nrB2OBi5Rg4qN3tGa1QsQga89rw8DlDKhH9fhFwQd/MTf/
         ET0tvJYhigcRGXUbZdzwD5lvPrs73WqcHDZQdY1cIvF8wCPF/LgUddNBD4zsOJ7CjKzz
         odZ5OtAefe7Q06LsLwXmDh1Pdx8/79YK4VdtBTZsc98gFmGRelO1RUCT35igbpsbsffS
         7spw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795024252; x=1795629052; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=BliQBsLi8Tf+bGa80m+pxZeHcLThIeJfSszhbNvQWjc=;
        b=t0urFznsvrKRqixemRUZFc9mgXym3XN1YMBmj0waBLyV3CsdgnHy8xmpMpLBOjvFSO
         4OyVbjrHe3QbmjmaFHziwXJZHZ3OpkdyrRZKOYWCdCJexvqSmUuVu4fnaP7X0VKW/H2Q
         uU2+obaBKEAHGKd8XWt2iDtAO+W46sMhQn7B0F4IN3mylmD+1QrZ9esi0QvoH9kZT9bX
         EBKM7Z1u6o+AxA5zR70zZUIovWhwqLZJa6oEexWqxHL96XtNRn01UmHNOonMpcB3gc6f
         RbyVXVt9WSJBogGVLF5lTsidaWxQ5lTI8ZoKmu6C/MRJ9rExNu7Xb6AIdnGzmI6derxu
         Duww==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795024252; x=1795629052;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=BliQBsLi8Tf+bGa80m+pxZeHcLThIeJfSszhbNvQWjc=;
        b=KKKG/P5Tg9Snpjc/7tjPflAtB7kY0/hFfTTNxsP4qJjZdxqGRbAuuVseZknqCKEn5J
         UkzFCneNIOB93/2MuHLkFPrYulPIrFCGJbi5Ltlt4sG8YNuaOTzDO7IyTuFGYU114nPH
         ls+dG8hgtZwnn9ocbomdOdTeoYsOTlnn0v4eX+n962E/RT2E8oCRZBYiHtoQfwmunjAg
         pujAHeKyX8LznxjY9If4Ue+/FRXMqZI3XuvN24dH9XBiDlGXGDCpCjScgmZv4KLZ9V14
         nA16msSfea1VIqpHSFdIk4lsoxGLbXA9i4vG8KJwH+dj4fXBxgdFANxm+NKGd26/t/xr
         gNMA==
X-Forwarded-Encrypted: i=1; AL+hErGtJZYCdvCAH0kH4z7Vmqw4dv9oMLYS5yy5KI2zupsl2Hgtu8T80EuROnKFbEYwWS+9mpmAkhtWpYo=@vger.kernel.org
X-Gm-Message-State: APuU4Z/jrH+11OfGh8StDdOI1xVmaE4jd8AHIH5K5Wvx18TFDWjQ1fq4
	ltH6Jt9zUnQ/XxOQwP5DvC8hK8YKEBxtwGVj7KJYSnE8oaGkRc6Sn1nwU9TFXuW4kZH4Dhfx4Wq
	qB0EArZ0mKwM63miju799wAwX0iWIQNM=
X-Gm-Gg: AYBFou1LyljIFN2BgPAByxW8sMHpMT5pIcwyZUI6Gbh9LIe42dlaqG66SBAxUMQSeMn
	HgDwhW7r17gch/+iC1nVfypwYFk0R/jUlQh79uTypop1w16kHGqVGsGArfHVnFPV0DhFxkPdGby
	3m8c3fqZ5TS+KubP9rsWTnS8hgHnVpzQywDmC4D9xUXJkZ5xQopIOeoYVc0yBbK90Hl7/9kEqXw
	M3UYE4oMNiToockIV+7TblmteeB/gtmX2QK/G+OA3dYfOvVToz3g3Lbus1ZoEre+bRgCBCbzWzO
	VF3Ihsm7ZLJ80EDf2PRzEFjyJM91Ed+n0oO8cJGZJFOAxIsmSjBFgbx7ztMkX6b2y5yjb1TR+1M
	g0jdaV5+bxTrPDzV7YvjillOf6OzrkNNTuShwUBNNQVlCCAdcN4jrsE8hqPinMVNfhC5LVCKDqk
	v6q9Wwq+J3oCckR7o=
X-Received: by 2002:a05:6402:5411:b0:6b7:df0c:18d0 with SMTP id
 4fb4d7f45d1cf-6b8a2e6d881mr1966295a12.11.1795024252167; Wed, 18 Nov 2026
 09:50:52 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261115180343.576773-1-koray.fra@gmail.com> <20261118142613.be3r3s6kobkkxnz4@pali>
 <DMYFBDIV4Y08.35ZKR5G86U1H7@gmail.com> <20261118151605.lqtn5fz423kuswk5@pali>
 <DMYHPLWKPSH3.MUM1IIZZIWNR@gmail.com> <CAOQ4uxiwpdC-fKkqS5kiZ515q9MenC0jX4USV1idN7h2njx45Q@mail.gmail.com>
 <7126bdd0ff59e9ea9bc58702af2ecb38096330e8.camel@kernel.org>
In-Reply-To: <7126bdd0ff59e9ea9bc58702af2ecb38096330e8.camel@kernel.org>
From: Amir Goldstein <amir73il@gmail.com>
Date: Wed, 18 Nov 2026 18:50:40 +0100
X-Gm-Features: AclHuK8-cETfcc5mQcfuFgReFzNL3uUqtJJFv8XHOum7KdV27M9jJ90gtN64MvU
Message-ID: <CAOQ4uxidYWNVmoPgxKrxesXTxpMB-JqUZx9p6xXZWD5m+hJ+JA@mail.gmail.com>
Subject: Re: [RFC PATCH v4 00/10] add provenance time (ptime)
To: Jeff Layton <jlayton@kernel.org>
Cc: koraynilay <koray.fra@gmail.com>, =?UTF-8?Q?Pali_Roh=C3=A1r?= <pali@kernel.org>, 
	David Sterba <dsterba@suse.com>, Namjae Jeon <linkinjeon@kernel.org>, 
	Sungjong Seo <sj1557.seo@samsung.com>, Alexander Viro <viro@zeniv.linux.org.uk>, 
	Christian Brauner <brauner@kernel.org>, Trond Myklebust <trondmy@kernel.org>, 
	Anna Schumaker <anna@kernel.org>, Chuck Lever <cel@kernel.org>, 
	Konstantin Komarov <almaz.alexandrovich@paragon-software.com>, 
	Paulo Alcantara <pc@manguebit.org>, Chris Mason <mason@kernel.org>, Yuezhang Mo <yuezhang.mo@sony.com>, 
	Jan Kara <jack@suse.cz>, NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	Ronnie Sahlberg <ronniesahlberg@gmail.com>, Shyam Prasad N <sprasad@microsoft.com>, 
	Bharath SM <bharathsm@microsoft.com>, Sergey Senozhatsky <senozhatsky@chromium.org>, 
	ChenXiaoSong <chenxiaosong@chenxiaosong.com>, "Darrick J . Wong" <djwong@kernel.org>, 
	Sean Smith <defendthedisabled@gmail.com>, Andrey Albershteyn <aalbersh@kernel.org>, 
	Pedro Falcato <pfalcato@suse.de>, linux-btrfs@vger.kernel.org, 
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
	exfat@lists.linux.dev, ntfs3@lists.linux.dev, linux-cifs@vger.kernel.org, 
	linux-nfs@vger.kernel.org, linux-api@vger.kernel.org, 
	Theodore Tso <tytso@mit.edu>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, Nov 18, 2026 at 6:36=E2=80=AFPM Jeff Layton <jlayton@kernel.org> wr=
ote:
>
> On Wed, 2026-11-18 at 18:28 +0100, Amir Goldstein wrote:
...
> > Guys,
> >
> > Let's take a step back.
> >
> > If this discussion is proving anything is that the btime/ptime
> > duality is a big headache and it's going to be a source of confusion to=
 users
> > even if we come up with some smart pants consistent semantics.
> >
> > As Jeff writes, I think we should consider making btime mutable
> > be a per-fs choice and not an API limitation.
> >
> > A filesystem can even decide to store both the forensics btime
> > alongside the user settable crtime.
> >
> > There are some precedents in xfs with settable UUID which is
> > a different field then the origin UUID from mkfs.
> >
> > Fs that have immutable btime have a few choices:
> > 1. Keep it immutable
> > 2. Start making it muttbale (like the Win fs)
> > 3. Start making the user visible btime (STATX_BTIME) mutable
> >     but keep the forensics btime on-disk for, well, forensics
> >
> > If btime becomes settable via options 2 or 3, this could require
> > admin opt-in (e.g. tune2fs -O crtime).
> >
> > With option 3 the crtime feature would be ROCOMPAT
> > With option 2, it could probably be COMPAT. Maybe.
> >
> > If we accept this story and the major fs maintainers are
> > in agreement with this plan, then I think the missing piece
> > is making the "settable mask" visible to users via the new API.
> >
> > IOW, we need to somehow export FS_XFLAG_RDONLY_MASK
> > to userspace instead of only exporting the supported mask.
> > And then with the addition of xflags_mask, we could also
> > -EINVAL on users trying to set readonly flags/values.
> >
> > Perhaps a single xflags_settable_mask is enough.
> >
> > For file_setattr(), xflags_mask is anyway a set-those mask.
> > For file_getattr(), does it matter if we get an answer
> > Filesystem does not support casefold on this file
> > OR
> > Filesystem does not have casefold on this file and
> > you cannot set casefold on this file
> >
> > It's kind of the same, isn't it?
> >
> > What do you say?
> >
> > Shall we drop PTIME in favor of "is BTIME settable?" API?
> > Leaving STATX_BTIME exactly as is.
> >
> >
>
> +1
>
> I think this is the better approach.
>
> Looking over some of the earlier discussions around this since 2010
> (!?!): I think some of the XFS devs objected to making it settable for
> forensic reasons. So, on XFS you might need to rev the on-disk format
> if you want to do it there to preserve the "historical" btime, and
> maybe some xfs userland work to make it accessible for forensics.

XFS_IOC_FSBULKSTAT will likely continue to publish the original bs_btime.
if a mutable field is added it could be published as bs_crtime.

For forensics this should be enough.

>
> For the record, the statx manpage documents the btime field very
> sparsely:
>
>        stx_btime
>               The file's creation timestamp.
>
> There is no documented guarantee that this will be immutable, AFAICT.

Yes, and it really isn't immutable for cifs already.
It's just that we don't have a standard API to change it.

Thanks,
Amir.
