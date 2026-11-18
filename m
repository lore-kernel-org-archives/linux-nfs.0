Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.221.48
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795010641;
	b=pTMmDQzFAwf5FoBNfJYTW+KH5EyQ7M+xdKdJG0QQ3YGsH6aXn/1/6SSvqM8cq1OkJCkg
	 5RsrAsRlkcZFRn7fiD55fP6wpaj/dQMqhbHEnRI585wjn8V2NjZxIgU9QQLBwtTIO9bko
	 eaTf3Hhh6AghxBtWFP7sTy1IJiWmIy3BT83uHgtc5561eLyEFRmr6pK9e631pBGCfv0VV
	 xT8x8/2ORkuA4YBZfnutrptejFa8/T7lMG9/FIg9Hrtz1WM7qACI6HW2BaayZh1oB/Gqu
	 eCX4eOsjNe7vq2MALWClyjgyC2UfXDM/KvSRGaUYgFQkwGio9qW6SnXikkzql1PaFkQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795010641;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Mime-Version:Content-Type:Date:Message-Id:To:Cc:Subject:From:X-Mailer:
	 References:In-Reply-To;
	bh=+uwi0okOO21nN8029G5kKeS0+aK14PL+obDOFNYM53E=;
	b=y5uBofTvFaoz6VZHMDVcJwZFmRfP5oqBSqEZuXrD3OUtXJhwPt/ZUqSyaLL3o9/e9rJb
	 5Yw9iArf98CvEcnYIBqAL+WO+OIskPgQm5/FS/PnDfsCWcW5zgxZkfN9ux+z4Nhmm8L6D
	 Zdd0CcYplfj/9nPuI6t+AsFkF6n84yefOIRmMMWxUFJPyuj0Vf1Wlnd9+dRRki50Efg7I
	 +jAQgkX5UYSLVgCoT3EI7E33oRm0JCajBXeXA33CFZabCfR3LTyDHJHvbQhzQThyML2Me
	 ZGTka4ipt4pq82ghH0pUBoADnKc2rDFDsQQR3hE/LyUpP3ztvOqJ9Cvev627YIwNSEA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=JGPO2haG;
	arc=none smtp.remote-ip=209.85.221.48
Received: from mail-wr1-f48.google.com (mail-wr1-f48.google.com [209.85.221.48])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 88DF960A260F
	for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 14:04:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 88DF960A260F
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=JGPO2haG
Received: by mail-wr1-f48.google.com with SMTP id ffacd0b85a97d-490c3ae81d3so663154f8f.2
        for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 06:04:00 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795010639; x=1795615439; darn=vger.kernel.org;
        h=in-reply-to:references:from:subject:cc:to:message-id:date
         :content-type:mime-version:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=+uwi0okOO21nN8029G5kKeS0+aK14PL+obDOFNYM53E=;
        b=JGPO2haGwzUQSz9syBu2Ro7Ot85HLEGbqqcUz25csQFarPKfEFyGhUPIj0Fr4x22Ja
         1eUS80KrZvharuC6DphOL/NKbzOx93PjTcsQ1kIJSOISxCfPPYi/1TlfP42+rKFOxurE
         p6s2xQ4QHzx3d5IcZy43EMXXO4uAsD8JAaJBi/8PJ30V9uqRrmb6XqlcMj4ep6VAs8jw
         ZPMWUbE55PvIRfbJzQoOBBTMis27muSb8pzcNQ6toICnzjiAQQ0Nbg0Iu4aPhCDx2g8j
         2crfA4J3sLQj0aMsv5t57o0JWza0sAwU7/08+is8x/pmkOVwaBhhBuy+gjb6vmEIuP4n
         AJJw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795010639; x=1795615439;
        h=in-reply-to:references:from:subject:cc:to:message-id:date
         :content-type:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=+uwi0okOO21nN8029G5kKeS0+aK14PL+obDOFNYM53E=;
        b=hyXcjRgrKw08HgGvhRzuWA/xrllmmGCuULTX78L43VeJ/L1gY4EVVQNAA8+YxzZnPB
         dtudUiLev9RZ4hWSm6QlARi0NNv7118QFqyIOqcu0CRI+P1J0B+qIk8ikY38J5yENiDN
         NQGU4M4U0IzhVPGplj4RTj1+F3gBhvXJqufayiczjWIJtNYgBX85jdoHGasBl7vhCP9r
         3TfQAZQXPjkH3K0lHKJv7SLbZhYgqcUoI5NTR/aj/G5v61NCo5YeXxuuzTAbv5v5aswZ
         OBj50uakF8xNDrxouBDefl0zsRXee5QOgn6uOtzfkBU1NhkkFRZQF2oucpWNgyWL4WEa
         ZsIw==
X-Forwarded-Encrypted: i=1; AL+hErEN/AsIY6nEub0X5ajQF1R21pbsA3G6ncn6eyU160ItUg3D3BrDxooBUtzBwayRv+WhzuOeAXr06e4=@vger.kernel.org
X-Gm-Message-State: APuU4Z9hvre3NKWgA7oWxHrZ8C7UvyBbqnSDjO9S1KpqOdMRw3dlI0Jl
	K9aAfCnxHj2KDDB3poTvFen6zo53t1tdFx7lR+epKcBlQmJpItC7rs5J
X-Gm-Gg: AZFdTZcQwcwQvqyQKpO4XFk5Kj0lCUfIVuSUkF7W53xMABT7mKlvO4Dl+hoDog8CQwC
	BkKll3f+YtRoS3tLBugCo+DVX/DUNWVisz7PnIrMrIPX2HpZAnn/xqg4vcF4eDGJLEBAi37mR0l
	DNUyCZM+4kqA2xgPAfjSnlOtW9pToDdq5E58xyHHE4xn3wymbjXg36GodGevHzukirLJrSAQQVd
	IxzCSH5IN7W0UBCVIv0Q1CAkE8aad+9ErkCeC9sEqvOyLTJhFOlpGzwbqXjZTQC5pkCX1YWqu5b
	67N/hQPIC6sJCEOgYn4HIOUf0iaUIDdca5GVLI0MNCb9ISbjQR9S0eUp9Tz1ZeiKmjbuRcSxo1o
	lfQmBMZlAon7AIJn67WGJP8I6DA0ODf6YzlyE7Qo8iujpGYbdWp4mWxR7QfUwK9ljWk4VRZ/BR1
	agjy7vAJwnWUNkwVQdvZfWBrvO9hWTKMxW/ouBqmYHHBAJ/n75Q92aZEo5Dh9jI5SzZdbZ66pPR
	8eDJS5XAxtis5wERkp+gjLWJbggTFvfv5cCEcxHjJyvEdisFU2AukX85MK2uyEqLCXNwwrdgC7X
	xzww88EuKkJl2UXfUWbOyedXBPxeOUJ64lNqnWOFEBTyzRbaIQDKhkm35obRrfhEAtU=
X-Received: by 2002:a05:6000:41c3:b0:48e:20ed:d5e7 with SMTP id ffacd0b85a97d-4a63de5249fmr5373556f8f.34.1795010638556;
        Wed, 18 Nov 2026 06:03:58 -0800 (PST)
Received: from localhost (mob-176-246-251-118.net.vodafone.it. [176.246.251.118])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-4a65560b2a1sm4737224f8f.32.2026.11.18.06.03.52
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 18 Nov 2026 06:03:57 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
Mime-Version: 1.0
Content-Type: multipart/signed;
 boundary=4827e7d7bbe23dd35858a8366dc75e2a45dd46e9129f07e8a6f88ac53c0e;
 micalg=pgp-sha512; protocol="application/pgp-signature"
Date: Wed, 18 Nov 2026 15:03:50 +0100
Message-Id: <DMYE5VTQIU4R.7PNKJGR0DST0@gmail.com>
To: "Jeff Layton" <jlayton@kernel.org>, "Amir Goldstein"
 <amir73il@gmail.com>, "koraynilay" <koray.fra@gmail.com>
Cc: "David Sterba" <dsterba@suse.com>, "Namjae Jeon"
 <linkinjeon@kernel.org>, "Sungjong Seo" <sj1557.seo@samsung.com>,
 "Alexander Viro" <viro@zeniv.linux.org.uk>, "Christian Brauner"
 <brauner@kernel.org>, "Trond Myklebust" <trondmy@kernel.org>, "Anna
 Schumaker" <anna@kernel.org>, "Chuck Lever" <cel@kernel.org>, "Konstantin
 Komarov" <almaz.alexandrovich@paragon-software.com>, "Paulo Alcantara"
 <pc@manguebit.org>, "Chris Mason" <mason@kernel.org>, "Yuezhang Mo"
 <yuezhang.mo@sony.com>, "Jan Kara" <jack@suse.cz>, "NeilBrown"
 <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo"
 <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>, "Ronnie Sahlberg"
 <ronniesahlberg@gmail.com>, "Shyam Prasad N" <sprasad@microsoft.com>,
 "Bharath SM" <bharathsm@microsoft.com>, "Sergey Senozhatsky"
 <senozhatsky@chromium.org>, "ChenXiaoSong" <chenxiaosong@chenxiaosong.com>,
 "Darrick J . Wong" <djwong@kernel.org>, "Sean Smith"
 <defendthedisabled@gmail.com>, "Andrey Albershteyn" <aalbersh@kernel.org>,
 "Pedro Falcato" <pfalcato@suse.de>, =?utf-8?q?Pali_Roh=C3=A1r?=
 <pali@kernel.org>, <linux-btrfs@vger.kernel.org>,
 <linux-kernel@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
 <exfat@lists.linux.dev>, <ntfs3@lists.linux.dev>,
 <linux-cifs@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
 <linux-api@vger.kernel.org>
Subject: Re: [RFC PATCH v4 00/10] add provenance time (ptime)
From: "koraynilay" <koray.fra@gmail.com>
X-Mailer: aerc 0.22.0-0-gc2f86b7abde3
References: <20261115180343.576773-1-koray.fra@gmail.com>
 <fc53ec55d315a4b96ec1e6f250ad3763f2189755.camel@kernel.org>
 <DMXXOPD9UDNP.2YP9ROMHFLM9E@gmail.com>
 <CAOQ4uxjcvAKTaGXO0=BpbtgoEPmN7GKieVbX1ZpZR38H1Z3j9g@mail.gmail.com>
 <a2889a0bfb26e329ecf2eed6d2318bfcbbb0ff2c.camel@kernel.org>
In-Reply-To: <a2889a0bfb26e329ecf2eed6d2318bfcbbb0ff2c.camel@kernel.org>

--4827e7d7bbe23dd35858a8366dc75e2a45dd46e9129f07e8a6f88ac53c0e
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=UTF-8

On Wed Nov 18, 2026 at 2:45 PM CET, Jeff Layton wrote:
> On Wed, 2026-11-18 at 09:14 +0100, Amir Goldstein wrote:
>> On Wed, Nov 18, 2026 at 2:09=E2=80=AFAM koraynilay <koray.fra@gmail.com>=
 wrote:
>> >=20
>> > Hello and thanks for replying,
>> >=20
>> > On Wed Nov 18, 2026 at 12:53 AM CET, Jeff Layton wrote:
>> > > On Sun, 2026-11-15 at 19:03 +0100, koraynilay wrote:
>> > > > This is an initial implementation of a new timestamp to indicate t=
he
>> > > > time when a file/directory was initially created.
>> > > >=20
>> > > > This patch series takes inspiration from the one by Sean Smith
>> > > > <defendthedisabled@gmail.com> [1], but using
>> > > > file_setattr()/file_getattr() as suggested by Darrick J. Wong
>> > > > <djwong@kernel.org> in [2].
>> > > >=20
>> > > > The semantics of this new timestamp should be at least these:
>> > > > - it should be the same as btime on a newly created file
>> > > > - it's user-settable, so it can be preserved for backups, filesyst=
em
>> > > >   conversions, archives and any similar operation
>> > > > - it should be preserved every time mtime gets preserved
>> > > >=20
>> > > > and the correspondence with the other timestamps is as follows:
>> > > >=20
>> > > > ctime <-> btime
>> > > > mtime <-> ptime
>> > > >=20
>> > >=20
>> > > I'm not sure how to interpret the correspondence above.
>> >=20
>> >   |-----\_-----------------|-----------|
>> >   |       \_      change/  |   birth/  |
>> >   |         \_ modification|  creation |
>> >   |           \------------|-----------|
>> >   | inode time |   ctime   |   btime   |
>> >   |------------|-----------|-----------|
>> >   | file time  |   mtime   |   ptime   |
>> >   |------------|-----------|-----------|
>> >=20
>> > ("file" as in "the concept of this file", I'd say "file content" but
>> > that would be incorrect for symlinks)
>> >=20
>> > so ctime is "inode change time", btime is "inode birth/creation time",
>> > while mtime is "file content change/modification time" and ptime would
>> > be "file content creation time" (same as Window's or MacOS's creation
>> > time).
>> >=20
>> > Does this make more sense?
>> >=20
>> > >=20
>> > > > Examples:
>> > > > 1) a .zsh_history file created in 2019, then after a few years the=
 user
>> > > >    decides to switch to another filesystem, copying the .zsh_histo=
ry to
>> > > >    the new home, in that case btime would have the timestamp of th=
e copy
>> > > >    and ptime would have the 2019 timestamp (just like mtime would =
have
>> > > >    been preserved)
>> > > > 2) a symlink created in 2020 from the home directory to a /path go=
ing
>> > > >    through the same process as the .zsh_history, in this case it w=
ould
>> > > >    also make sense to sync the ptime to the 2020 timestamp instead=
 of
>> > > >    keeping only the btime (so the inode creation time).
>> > > >=20
>> > > > The proof-of-concept code (for testing) for stat(1) and cp(1) is
>> > > > available at https://github.com/koraynilay/coreutils (master branc=
h)
>> > > > (Note: these coreutils code changes are a prototype and won't be
>> > > > submitted upstream as-is, but they work as expected in simple stat=
 and
>> > > > cp -a/--preserve=3Dptime tests)
>> > > >=20
>> > > > Lastly, the name "provenance" and "ptime" are not final, I persona=
lly
>> > > > don't have a strong opinion on any name, but while testing with st=
at(1)
>> > > > I noticed that "Provenance" is definitely too long for the normal
>> > > > output, so another option which would fit well is "Origin time",
>> > > > abbreviated as "ntime" (OrigiN time) and not as "otime", as that w=
ould
>> > > > conflict with btrfs' internal naming and create confusion.
>> > > >=20
>> > > > v2 changes:
>> > > > - fix permission bypass leading to ptime update on immutable and
>> > > >   append-only files (found by sashiko[3])
>> > > > - normalize ptime timestamp as done in fs/attr.c:notify_change() (=
found
>> > > >   by sashiko[3])
>> > > > - fix wording in vfs patch to be like the cover-letter
>> > > >=20
>> > > > v3 changes:
>> > > > - vfs: reject setting ptime with -EOPNOTSUPP on filesystems that d=
o not
>> > > >   support it instead of silently ignoring it (found by sashiko[4])
>> > > > - vfs: fix not being able to clear immutable and append-only on fi=
les
>> > > >   with ptime, and allow updating immutable/append-only atomically =
along
>> > > >   with ptime (found by sashiko[4])
>> > > > - btrfs: validate on-disk ptime nanoseconds and reset to otime if
>> > > >   invalid (found by sashiko[4])
>> > > > - btrfs: avoid re-assigning ptime on unrelated chattr calls (found=
 by
>> > > >   sashiko[4])
>> > > > - add ntfs3 and exfat support as suggested by Amir Goldstein[5], b=
ut no
>> > > >   vfat, smb, or nfs4 yet as they are a bit more complex
>> > > > - move the introduction of fileattr_has_fsx_mask() from the btrfs =
patch
>> > > >   to a standalone patch in the series
>> > > > - btrfs: add fileattr_[gs]et to symlink and special file operation=
s
>> > > >=20
>> > > > v4 changes:
>> > > > - vfs: implement fsx_xflags_mask as suggested by Amir Goldstein[6]=
;
>> > > > - add SMB (ksmbd/cifs) and nfs (nfsd/nfs) support as requested in
>> > > >   previous threads;
>> > > >=20
>> > > > Note:
>> > > > to apply this patch 2 previous patches[7][8] from the ksmbd/cifs
>> > > > subsystem are needed.
>> > > >=20
>> > > > New Question:
>> > > > should I rename fileattr_has_fsx_mask() to something like
>> > > > fileattr_has_unsupported_fsx() and keep its code as-is, or should =
I add
>> > > > the fsx_xflags_mask & ~allowed check in it and keep the name as-is=
? (or
>> > > > both?)
>> > > >=20
>> > > > Thanks.
>> > > >=20
>> > > > [1]: https://lore.kernel.org/20260405195007.1306-2-DefendTheDisabl=
ed@gmail.com
>> > > > [2]: https://lore.kernel.org/20260407014129.GC6192@frogsfrogsfrogs
>> > > > [3]: https://sashiko.dev/#/patchset/20261027220532.736352-1-koray.=
fra%40gmail.com
>> > > > [4]: https://sashiko.dev/#/patchset/20261028134728.294127-1-koray.=
fra%40gmail.com
>> > > > [5]: https://lore.kernel.org/CAOQ4uxiuy0VwZj+3M-zRqQ49WTpHZpiaQ+6M=
Z8z8WdLjyQM_zA@mail.gmail.com/
>> > > > [6]: https://lore.kernel.org/CAOQ4uxjtuTDT63vJdYaq+RHQEQFLTksp66e4=
6OMN99WhJz3SbA@mail.gmail.com/
>> > > > [7]: https://lore.kernel.org/linux-cifs/20261112111637.184045-2-ko=
ray.fra@gmail.com/
>> > > > [8]: https://lore.kernel.org/linux-cifs/20261115155308.415734-1-ko=
ray.fra@gmail.com/
>> > > >=20
>> > > >=20
>> > > > koraynilay (10):
>> > > >   vfs: add provenance time (ptime)
>> > > >   vfs: add fileattr_has_fsx_mask()
>> > > >   ntfs3: make crtime user-settable using ptime
>> > > >   exfat: make crtime user-settable using ptime
>> > > >   btrfs: add provenance time (ptime)
>> > > >   vfs: add __vfs_fileattr_set_locked() for inode_lock()'d callers
>> > > >   nfsd: add provenance time (ptime) via FATTR4_TIME_CREATE
>> > > >   nfs: add provenance time (ptime) via FATTR4_TIME_CREATE
>> > > >   ksmbd: add provenance time (ptime) and map it to CreationTime
>> > > >   cifs: add provenance time (ptime) and map it to SMB's CreationTi=
me
>> > > >=20
>> > > >  fs/btrfs/btrfs_inode.h          |   4 +
>> > > >  fs/btrfs/delayed-inode.c        |   6 ++
>> > > >  fs/btrfs/inode.c                |  29 +++++-
>> > > >  fs/btrfs/ioctl.c                |  24 ++++-
>> > > >  fs/btrfs/print-tree.c           |   1 +
>> > > >  fs/btrfs/tree-log.c             |   3 +
>> > > >  fs/exfat/exfat_fs.h             |   2 +
>> > > >  fs/exfat/file.c                 |  42 ++++++++-
>> > > >  fs/exfat/namei.c                |   1 +
>> > > >  fs/file_attr.c                  | 156 ++++++++++++++++++++++++++-=
-----
>> > > >  fs/nfs/inode.c                  |  27 +++++-
>> > > >  fs/nfs/internal.h               |   2 +
>> > > >  fs/nfs/nfs4proc.c               |  56 +++++++++++-
>> > > >  fs/nfs/nfs4xdr.c                |  19 ++--
>> > > >  fs/nfs/symlink.c                |   1 +
>> > > >  fs/nfsd/nfs4proc.c              |   9 ++
>> > > >  fs/nfsd/nfs4xdr.c               |  40 +++++---
>> > > >  fs/nfsd/vfs.c                   |  17 ++++
>> > > >  fs/nfsd/vfs.h                   |   4 +-
>> > > >  fs/nfsd/xdr4.h                  |   3 +
>> > > >  fs/ntfs3/file.c                 |  20 +++-
>> > > >  fs/ntfs3/frecord.c              |   8 +-
>> > > >  fs/smb/client/cifsfs.c          |   8 ++
>> > > >  fs/smb/client/inode.c           |   7 +-
>> > > >  fs/smb/client/ioctl.c           | 109 ++++++++++++++++------
>> > > >  fs/smb/server/smb2pdu.c         |  37 +++++---
>> > > >  fs/smb/server/vfs.c             |  43 ++++++++-
>> > > >  fs/smb/server/vfs.h             |   1 +
>> > > >  fs/stat.c                       |   2 +
>> > > >  include/linux/fileattr.h        |  29 +++++-
>> > > >  include/linux/nfs_xdr.h         |   3 +
>> > > >  include/linux/stat.h            |   1 +
>> > > >  include/uapi/linux/btrfs_tree.h |   3 +-
>> > > >  include/uapi/linux/fs.h         |   9 +-
>> > > >  include/uapi/linux/stat.h       |   7 +-
>> > > >  35 files changed, 614 insertions(+), 119 deletions(-)
>> > > >=20
>> > > >=20
>> > > > base-commit: 3bc1fb9c3b20cd478c83496ab16addecb401770d
>> > > > prerequisite-patch-id: 049ae0eba275b5be35a238833107e0b251a55aa2
>> > > > prerequisite-patch-id: 614f0bc9411391403d4e9702bafeb31b0ec04ec1
>> > > > prerequisite-patch-id: ddf636b9d33d82ea206ce265d817371350bf8858
>> > >=20
>> > > I think this is going to be very hard to do properly, because the
>> > > kernel can't really manage this on its own. Something in userland is
>> > > going to have to set this value if you want to update it to somethin=
g
>> > > other than the original inode instantiation time (aka btime).
>> > >=20
>> > > It really sounds like what you want is the ability to make the btime
>> > > settable. Personally I think the decision to forbid that was wrong-
>> > > headed and that it should have been settable from userland from the
>> > > beginning. Maybe we should just revisit that decision.
>> >=20
>>=20
>> Frankly, I don't think this decision was made at all.
>>=20
>> There are only 2 types of filesystems in Linux today:
>> 1. btime is constant (xfs, etx4, btrfs,...)
>> 2. crtime is settable in principle but not via a standardized Linux
>> API (ntfs, cifs, ...)
>>=20
>
> CephFS is in this category too. I explicitly made it settable so we
> could set it when restoring backups.

Ah ok, should I try adding support for it using this API in the next
version? (either by making btime settable like with SMB/NFS or adding
ptime as new?)

>
>> AFAIK, btrfs in this series is the only filesystem which is going to
>> have two deviated copies of btime and ptime.
>> For all the rest, the deviation is artificial in statx.
>>=20
>> So the questions to ask are:
>> 1. Do btrfs developers prefer to store a new settable ptime or
>>     making otime/btime settable with this new API?
>> 2. Will any other fs in the future want to store settable ptime along
>>     side the legacy immutable btime?
>>=20
>> My take on these question is:
>> - Personally I would love to see ptime support in xfs in the future and =
would
>>   willing to contribute to this work, because I have hard evidence from =
the
>>   performance benefits that it brings to smb server workloads
>> - Judging by past experience with i_version bump interpretation on xfs,
>>   I find it hard to believe that xfs developer would agree to making the
>>   legacy btime settable
>>=20
>
> Maybe? The main reason for that was that XFS uses i_version  as
> internally as a change counter for any inode change. I doubt that it
> uses btime internally like that.
>
> The only reason I can see to _not_ make btime settable is for
> forensics: maybe having the inode btime be immutable would make it
> harder to disguise when an inode was instantiated, but I imagine that
> would be defeatable with offline tools anyway.
>
> If people are using the btime in this way, then it would be nice for
> them to speak up and give us some details about this usage. How does
> keeping it immutable help you?

I agree, I do understand the possible reasons for keeping it, but
personally I don't have any use for immutable btime (tho, it is nice to
have also that information available).

>> Hence the distinction in statx API is needed, but for most filesystems
>> it is a pure semantic way of saying "I do/don't have settable birth time=
".
>>=20
>> > Originally I just wanted to have btime settable, yes, and if btime was
>> > settable I wouldn't have made this RFC PATCH either, but after reading
>> > the already existing discussions about it, I can understand having an
>> > "immutable inode creation time", like ctime exists, so even after maki=
ng
>> > btime settable, a new timestamp would be necessary anyway (e.g. for th=
e
>> > people who want btime to exist as a forensics timestamp).
>> >=20
>>=20
>> Right, but every filesystem (e.g. btrfs) can still make an independent
>> choice whether storing one or two copies is desired.
>> The API does not limit those choices.
>>=20
>> > > Failing that, why not just track this in an xattr of some sort, sinc=
e
>> > > this is really just an opaque blob once you allow it to be settable.=
 If
>> > > the xattr isn't present, then you can just use the value of the btim=
e
>> > > as-is. FWIW, I think samba does this today, so you could try to sync
>> > > with its behavior here.
>> >=20
>> > (This is copied and adapted from [2])
>> >=20
>> > I actually have been using fully userspace xattrs[1] for a few months,
>> > mostly for backups, and it "works"; but last month I wanted to merge 2
>> > FSs (and have another merge I have to do), so I ran [1] on all files a=
nd
>> > then compared all metadata/data between source and destination and
>> > noticed there were quite a lot of files that didn't have the xattr set=
.
>> > So I looked online and learned that xattrs only work on regular
>> > files/directories, not on symlinks or anything else (and the missing
>> > ones were of symlinks).
>> > This is what prompted me to search more if anyone had already proposed=
 a
>> > new timestamp (instead of making btime settable) and found the email
>> > thread from april linked in the cover letter, which gave me the excuse
>> > to finally work on a proper patch.
>> >=20
>>=20
>> I am tired of repeating my arguments (and finding my own quotes)
>> about why using xattrs is a poor replacement for in-inode ptime.
>> AI agents can easily find those quotes for those who are interested
>> so I won't bother, I just say that smbd already uses xattr to store
>> the creation time - it's just bad for performance and disk usage in
>> metadata intensive workloads.
>>=20
>> > > That seems a lot simpler than adding an entirely new inode timestamp
>> > > that is always going to be a copy of the btime, except in rare cases=
.
>> > > Having to patch all of the on-disk filesystems with a new per-inode
>> > > field is a lot more work.
>> >=20
>> > > This patch is quite simple, but changing btrfs, then ext4, xfs, etc =
is a
>> > > mess, and inevitably you can't get these timestamps until you upgrad=
e your
>> > > filesystems.
>> >=20
>
> Weird. I didn't write the above sentence.

Yes, I copy-pasted from the linked email and since it was raising the
same issue I kept it along yours (I should've probably used >>).

>>=20
>> Jeff, this is standard "how to make progress".
>> I completely don't agree with this argument.
>> We cannot use this argument to block progress.
>> Is it already a long standing practice for userspace file servers (samba=
)
>> to probe the host filesystem for specific features and fall back to
>> alternative implementation if they are not supported.
>>=20
>> There will be nothing new in this case, that's the only way to
>> make forward progress - define the API, make support queryable,
>> implement the feature in some filesystems, implement consumers, repeat.
>>=20
>> Also for nfsd, that's the only way to ever implement settable
>> FATTR4_TIME_CREATE which is the protocol allows.
>> This is never going to be possible with custom xattrs.
>> So I must say that I don't understand the objection from you and Chuck
>>=20
>
> I'm not saying that to try and block progress. I'm just pointing out
> that it is a rather heavy lift to add a new inode field. This will
> require revving the on-disk format for most local filesystems, and it
> will take years to roll out. If we can get away with just making the
> btime settable, that seems like a much simpler way to do this.
>
> FWIW, Omar Sandoval apparently tried to add AT_UTIME_BTIME to
> utimensat() back in 2019, but it never made it in. It might be good to
> look over the objections to it then to see if they can be overcome.

That would also be fine for me, tho adding ptime as a new timestamp does
increase completeness, which would be better IMO.

Thanks,
koraynilay

--4827e7d7bbe23dd35858a8366dc75e2a45dd46e9129f07e8a6f88ac53c0e
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iHUEABYKAB0WIQRJ2XvJtXGwULYEerQ0bnTtJTDoOAUCav2wRgAKCRA0bnTtJTDo
OLi8AP9On9SVdP2pKaY1bWdUmRmtD+y7ePm2dX8InXgjigrpogEA8jJF9kAz0j67
U81poULRLeUHl4UqJ/jCdHtr6gV6YQM=
=E9c9
-----END PGP SIGNATURE-----

--4827e7d7bbe23dd35858a8366dc75e2a45dd46e9129f07e8a6f88ac53c0e--
