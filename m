Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.42
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1794989681;
	b=AOhxo2BLO+ZHP00WgcinOIGkBbPlV0brjig4VhNZBFuQyzh00+eXnm0yMu4V/i0VHFom
	 kZy207o5so81kjTdlM9bf1hNbq1shvv0e47gb38DpyJXg0HPn1gCOuecvKRfDVeRfNODK
	 0f1cZrxci9g6HKKL07qE/cHWtOsQlnGKrBXPGS9IRiekhmje9KC1HFFKM73kQudRQm5Km
	 1og3V58H0OMrsCRQxgBSjb7RMLFaoF/+O1DCgCYFNqE77iQ+Ui1TXJ2fQzjAQu/Zd3VCk
	 bQcHMPu21so2CWwerkAqPjvYkcdQwst5ew+vc/vEe+/8aWBbig/WyFfhR6fvUX6D2Zw==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794989681;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=f8SWgY1YH+4bFNiX+nGGrQJeABb8LOo2f5Gpt9qbuno=;
	b=vn2B79VIEG6fY6zyt/sf7RnpWt3Y4Xjls0/SObvanKFUPy0D7WptJcvuzlmkncEc0dgC
	 JW5ljvdPbU71qCR5VX5NIKMQQ7P5ZBEi8hvZyPJtVR48Po8BlcyWgVyia6+tUI3lumzHo
	 CTJ0ksXRKWzNrJaM9s1YWDqMyKegrWM/+vQ63Sar4528jznqcB73LP6j7v/br55CCCOVS
	 gL6Rte6HPihOSgC98Nha8WEjFpKy1XThl8R3/bcRDWZfhPhGZAaHHjre8/TblCPbWju/h
	 dGnFScR36tL0IZ3dZOApiPjFtWhGZIt48L4ZnoN+ZvE5VGPLPgkYUCM6iBqSldWv5Yw==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=bVqyZ6iR;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.42
Received: from mail-ed1-f42.google.com (mail-ed1-f42.google.com [209.85.208.42])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 78005606A336
	for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 08:14:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 78005606A336
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=bVqyZ6iR
Received: by mail-ed1-f42.google.com with SMTP id 4fb4d7f45d1cf-6b8627e0eb2so971133a12.2
        for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 00:14:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1794989679; cv=none;
        d=google.com; s=arc-20260327;
        b=Qck6o9NdUuBGj/YXcQvFJKZDoz6uVbnUt3S4QmNbFSNgnMQchTYxRPpO4I2ar/IQdw
         kYGjMM4EthcLbiXbBqLX9WpGT5oa9lXrgCes3hKBp1aSijDjPseKJNcWU/73p661TDZg
         jWS3JcxjLIHJnZ3inCXuDXM84KlOGRJ5mVUNAVa9VEJgOE1W0DOa+ine/6A4QDmO922+
         OlXRMdToujqC2EGj2nK0Uuobo0Wzqj5vdkL4qpFF9aZy6CFgTGuHjKTP6uEktS/4qztY
         X+qNZy8ywEmEbAPuND19dTUns8i7Zixyav3Vy7auADPgmyO2t7Q5qWZda1hw2EYKoVcZ
         JrHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=f8SWgY1YH+4bFNiX+nGGrQJeABb8LOo2f5Gpt9qbuno=;
        fh=5jgv+dsSLS7AWImvVNPgq7EOCtI+lMlWtS6uc/R93zs=;
        b=bToY9gDEtqHmp8fwuKlPlPARNoWVph53mx6zuRnL9uFyuw+whVOemRqfXjfKkd3/+c
         8R2BD1XcU297wEtyMu6kGIfP7IQ6VBYgOQWS0rPc9pWK5Aq8Kn/QsMOEcMvXkcweGDqi
         5pyP+9fVTioaLnWtaUzSMv3ls+DKABu7kISEKdtlUz8h3AdUysSsQTxQ6TycLUcRbdSn
         TwVoQjaDLuOtwmVVtJgiTVy0VmXNhxxfYwlHlpMPwyNV2CRVZv7/Rptj68yRZztZ9fBK
         rN1QYRwdWLcNynePkr2KKQgPX5lMkKdKlBPGoLEiXmdpGBq/3fCMNkEbQZJrQN7JUb6G
         k/8A==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794989679; x=1795594479; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=f8SWgY1YH+4bFNiX+nGGrQJeABb8LOo2f5Gpt9qbuno=;
        b=bVqyZ6iR+949xPd6+oRH+pJJbmyMoELIq53xWXMQ451p/fKNNZdKcOpI9/A8alXfA7
         d8N3OoU3DymfPc8tPe4Salh6oRfnCaSqpwhreg2Vxtvk3MjRBol00gxXtzCQBbF0osfX
         ECcdWKYfrY9kW8sVyoN7dLMAsPR1PyhXUswWqc86R7EQAWslTF37WjQWecZzLNNh3c/Q
         n3pEDjXXG50hyBExJ3ffJJu5eCc4FBvbdoSjBOjDRvVaTXZm5ZGTRFzHrzmPHIp6QhhL
         fk61MtUay1wjEhxV4Xrh2fdZFnn+2YRcRe5unWI0laAHXjmaBURQmXQmwJAooKbgdsBA
         0qHw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794989679; x=1795594479;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=f8SWgY1YH+4bFNiX+nGGrQJeABb8LOo2f5Gpt9qbuno=;
        b=WStZt5Os/n9SkJdzyA1rzB5NQyoNNY0U512NspoLVyDSW4+gsZlDBUmRwRdAOur/Hn
         mX4BJhD7OvDH6fnwl65jVsMhkLuRyYSjKDEW7tcPcHuae9ssNgvSiCdTekU+H2gjzcXK
         OIuPDSSs6MqrugyqcEMQfKK4K5CShFxVfGjNUXMp10m8D3xzYk6j4rfGR1HRhoPelnoF
         V31TkEfL4gt7ouw3Vqm+tq8VJJ6RoBVVQhS8hJm/d5ULmcw6fTtNEavdc+WcPzfIWWTL
         1Rw1Tz5/zu46mLOYRXV8b3Cq4s3BoW4qLsitfSBW3eznhwIYtqUur9WgnEbfGC3zhIfW
         RJNg==
X-Forwarded-Encrypted: i=1; AL+hErGfKvlrT6BUQbnTvZTADCDokI2JsTQmqyCc7O4wkxuCsJoKnwZTlpgXhTKTFvHrnfMlnq+Y4e8QQl0=@vger.kernel.org
X-Gm-Message-State: APuU4Z8mkcM9ZvD49SfJO6pCgOPZ7SPsZqCW3lJFYJEZlUfQAChE4JSU
	Jc4kuQLQi0+SYyVK8lK3EWea1KgSu9U44R1JisQtWAcWRI5ijOgd60y1+F5cwwbvzI7N0kENCyA
	aoLfviYVhNCaPDvZ2J6KP0CtBrF5iti0=
X-Gm-Gg: AYBFou3tO21RdxC/hL+W8Ky7JBIaE8CjGbJQR4VbW9CXUCoMzJ+xKaM9W6pAY9XBEpq
	myozrK8Uti5OqUMA9OBtpPcqCe0gWEvVLvgUvVbN1gT0U30cbz0qf8WRjodc+Acy+7UtsKhJkZl
	9d8sHRC+q3AOaXwMhviIK2vKVwbTX6oNI6arGlS5GB7r5rOloQYqqjdYsbBtUu1xrjxX0yLM6kR
	h8bj7Kro4Ob0bbLemFPzj8s9aqBqb2ggL+yexdYZZViY76+8Hl+Vh1U8AaIxgzpar0DXOcQuDvA
	yfT/aA+WV+4FcXttXraaEqvgtRF0sSxnqIBZhn1mxzncVPh7t9L/0wkAMYc54qkyMVa3mqFZVSn
	qJ2UOK6WdEfvuB6nNKa3kstiaMn/+P0zuwnDodV0PBc5FmQ883NUnrzHh53CkPGlD8GlzyQ==
X-Received: by 2002:a05:6402:5416:b0:6b8:80e3:d595 with SMTP id
 4fb4d7f45d1cf-6b887e538ecmr1261546a12.7.1794989678541; Wed, 18 Nov 2026
 00:14:38 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261115180343.576773-1-koray.fra@gmail.com> <fc53ec55d315a4b96ec1e6f250ad3763f2189755.camel@kernel.org>
 <DMXXOPD9UDNP.2YP9ROMHFLM9E@gmail.com>
In-Reply-To: <DMXXOPD9UDNP.2YP9ROMHFLM9E@gmail.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Wed, 18 Nov 2026 09:14:27 +0100
X-Gm-Features: AclHuK_upvG3jBL3Fku6cqU-UCnIAy6BQnNeYmFbAiOZCbyGrKapHQ1wESeh2WA
Message-ID: <CAOQ4uxjcvAKTaGXO0=BpbtgoEPmN7GKieVbX1ZpZR38H1Z3j9g@mail.gmail.com>
Subject: Re: [RFC PATCH v4 00/10] add provenance time (ptime)
To: koraynilay <koray.fra@gmail.com>, Jeff Layton <jlayton@kernel.org>
Cc: David Sterba <dsterba@suse.com>, Namjae Jeon <linkinjeon@kernel.org>, 
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
	Pedro Falcato <pfalcato@suse.de>, =?UTF-8?Q?Pali_Roh=C3=A1r?= <pali@kernel.org>, 
	linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
	linux-fsdevel@vger.kernel.org, exfat@lists.linux.dev, ntfs3@lists.linux.dev, 
	linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org, 
	linux-api@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, Nov 18, 2026 at 2:09=E2=80=AFAM koraynilay <koray.fra@gmail.com> wr=
ote:
>
> Hello and thanks for replying,
>
> On Wed Nov 18, 2026 at 12:53 AM CET, Jeff Layton wrote:
> > On Sun, 2026-11-15 at 19:03 +0100, koraynilay wrote:
> >> This is an initial implementation of a new timestamp to indicate the
> >> time when a file/directory was initially created.
> >>
> >> This patch series takes inspiration from the one by Sean Smith
> >> <defendthedisabled@gmail.com> [1], but using
> >> file_setattr()/file_getattr() as suggested by Darrick J. Wong
> >> <djwong@kernel.org> in [2].
> >>
> >> The semantics of this new timestamp should be at least these:
> >> - it should be the same as btime on a newly created file
> >> - it's user-settable, so it can be preserved for backups, filesystem
> >>   conversions, archives and any similar operation
> >> - it should be preserved every time mtime gets preserved
> >>
> >> and the correspondence with the other timestamps is as follows:
> >>
> >> ctime <-> btime
> >> mtime <-> ptime
> >>
> >
> > I'm not sure how to interpret the correspondence above.
>
>   |-----\_-----------------|-----------|
>   |       \_      change/  |   birth/  |
>   |         \_ modification|  creation |
>   |           \------------|-----------|
>   | inode time |   ctime   |   btime   |
>   |------------|-----------|-----------|
>   | file time  |   mtime   |   ptime   |
>   |------------|-----------|-----------|
>
> ("file" as in "the concept of this file", I'd say "file content" but
> that would be incorrect for symlinks)
>
> so ctime is "inode change time", btime is "inode birth/creation time",
> while mtime is "file content change/modification time" and ptime would
> be "file content creation time" (same as Window's or MacOS's creation
> time).
>
> Does this make more sense?
>
> >
> >> Examples:
> >> 1) a .zsh_history file created in 2019, then after a few years the use=
r
> >>    decides to switch to another filesystem, copying the .zsh_history t=
o
> >>    the new home, in that case btime would have the timestamp of the co=
py
> >>    and ptime would have the 2019 timestamp (just like mtime would have
> >>    been preserved)
> >> 2) a symlink created in 2020 from the home directory to a /path going
> >>    through the same process as the .zsh_history, in this case it would
> >>    also make sense to sync the ptime to the 2020 timestamp instead of
> >>    keeping only the btime (so the inode creation time).
> >>
> >> The proof-of-concept code (for testing) for stat(1) and cp(1) is
> >> available at https://github.com/koraynilay/coreutils (master branch)
> >> (Note: these coreutils code changes are a prototype and won't be
> >> submitted upstream as-is, but they work as expected in simple stat and
> >> cp -a/--preserve=3Dptime tests)
> >>
> >> Lastly, the name "provenance" and "ptime" are not final, I personally
> >> don't have a strong opinion on any name, but while testing with stat(1=
)
> >> I noticed that "Provenance" is definitely too long for the normal
> >> output, so another option which would fit well is "Origin time",
> >> abbreviated as "ntime" (OrigiN time) and not as "otime", as that would
> >> conflict with btrfs' internal naming and create confusion.
> >>
> >> v2 changes:
> >> - fix permission bypass leading to ptime update on immutable and
> >>   append-only files (found by sashiko[3])
> >> - normalize ptime timestamp as done in fs/attr.c:notify_change() (foun=
d
> >>   by sashiko[3])
> >> - fix wording in vfs patch to be like the cover-letter
> >>
> >> v3 changes:
> >> - vfs: reject setting ptime with -EOPNOTSUPP on filesystems that do no=
t
> >>   support it instead of silently ignoring it (found by sashiko[4])
> >> - vfs: fix not being able to clear immutable and append-only on files
> >>   with ptime, and allow updating immutable/append-only atomically alon=
g
> >>   with ptime (found by sashiko[4])
> >> - btrfs: validate on-disk ptime nanoseconds and reset to otime if
> >>   invalid (found by sashiko[4])
> >> - btrfs: avoid re-assigning ptime on unrelated chattr calls (found by
> >>   sashiko[4])
> >> - add ntfs3 and exfat support as suggested by Amir Goldstein[5], but n=
o
> >>   vfat, smb, or nfs4 yet as they are a bit more complex
> >> - move the introduction of fileattr_has_fsx_mask() from the btrfs patc=
h
> >>   to a standalone patch in the series
> >> - btrfs: add fileattr_[gs]et to symlink and special file operations
> >>
> >> v4 changes:
> >> - vfs: implement fsx_xflags_mask as suggested by Amir Goldstein[6];
> >> - add SMB (ksmbd/cifs) and nfs (nfsd/nfs) support as requested in
> >>   previous threads;
> >>
> >> Note:
> >> to apply this patch 2 previous patches[7][8] from the ksmbd/cifs
> >> subsystem are needed.
> >>
> >> New Question:
> >> should I rename fileattr_has_fsx_mask() to something like
> >> fileattr_has_unsupported_fsx() and keep its code as-is, or should I ad=
d
> >> the fsx_xflags_mask & ~allowed check in it and keep the name as-is? (o=
r
> >> both?)
> >>
> >> Thanks.
> >>
> >> [1]: https://lore.kernel.org/20260405195007.1306-2-DefendTheDisabled@g=
mail.com
> >> [2]: https://lore.kernel.org/20260407014129.GC6192@frogsfrogsfrogs
> >> [3]: https://sashiko.dev/#/patchset/20261027220532.736352-1-koray.fra%=
40gmail.com
> >> [4]: https://sashiko.dev/#/patchset/20261028134728.294127-1-koray.fra%=
40gmail.com
> >> [5]: https://lore.kernel.org/CAOQ4uxiuy0VwZj+3M-zRqQ49WTpHZpiaQ+6MZ8z8=
WdLjyQM_zA@mail.gmail.com/
> >> [6]: https://lore.kernel.org/CAOQ4uxjtuTDT63vJdYaq+RHQEQFLTksp66e46OMN=
99WhJz3SbA@mail.gmail.com/
> >> [7]: https://lore.kernel.org/linux-cifs/20261112111637.184045-2-koray.=
fra@gmail.com/
> >> [8]: https://lore.kernel.org/linux-cifs/20261115155308.415734-1-koray.=
fra@gmail.com/
> >>
> >>
> >> koraynilay (10):
> >>   vfs: add provenance time (ptime)
> >>   vfs: add fileattr_has_fsx_mask()
> >>   ntfs3: make crtime user-settable using ptime
> >>   exfat: make crtime user-settable using ptime
> >>   btrfs: add provenance time (ptime)
> >>   vfs: add __vfs_fileattr_set_locked() for inode_lock()'d callers
> >>   nfsd: add provenance time (ptime) via FATTR4_TIME_CREATE
> >>   nfs: add provenance time (ptime) via FATTR4_TIME_CREATE
> >>   ksmbd: add provenance time (ptime) and map it to CreationTime
> >>   cifs: add provenance time (ptime) and map it to SMB's CreationTime
> >>
> >>  fs/btrfs/btrfs_inode.h          |   4 +
> >>  fs/btrfs/delayed-inode.c        |   6 ++
> >>  fs/btrfs/inode.c                |  29 +++++-
> >>  fs/btrfs/ioctl.c                |  24 ++++-
> >>  fs/btrfs/print-tree.c           |   1 +
> >>  fs/btrfs/tree-log.c             |   3 +
> >>  fs/exfat/exfat_fs.h             |   2 +
> >>  fs/exfat/file.c                 |  42 ++++++++-
> >>  fs/exfat/namei.c                |   1 +
> >>  fs/file_attr.c                  | 156 ++++++++++++++++++++++++++-----=
-
> >>  fs/nfs/inode.c                  |  27 +++++-
> >>  fs/nfs/internal.h               |   2 +
> >>  fs/nfs/nfs4proc.c               |  56 +++++++++++-
> >>  fs/nfs/nfs4xdr.c                |  19 ++--
> >>  fs/nfs/symlink.c                |   1 +
> >>  fs/nfsd/nfs4proc.c              |   9 ++
> >>  fs/nfsd/nfs4xdr.c               |  40 +++++---
> >>  fs/nfsd/vfs.c                   |  17 ++++
> >>  fs/nfsd/vfs.h                   |   4 +-
> >>  fs/nfsd/xdr4.h                  |   3 +
> >>  fs/ntfs3/file.c                 |  20 +++-
> >>  fs/ntfs3/frecord.c              |   8 +-
> >>  fs/smb/client/cifsfs.c          |   8 ++
> >>  fs/smb/client/inode.c           |   7 +-
> >>  fs/smb/client/ioctl.c           | 109 ++++++++++++++++------
> >>  fs/smb/server/smb2pdu.c         |  37 +++++---
> >>  fs/smb/server/vfs.c             |  43 ++++++++-
> >>  fs/smb/server/vfs.h             |   1 +
> >>  fs/stat.c                       |   2 +
> >>  include/linux/fileattr.h        |  29 +++++-
> >>  include/linux/nfs_xdr.h         |   3 +
> >>  include/linux/stat.h            |   1 +
> >>  include/uapi/linux/btrfs_tree.h |   3 +-
> >>  include/uapi/linux/fs.h         |   9 +-
> >>  include/uapi/linux/stat.h       |   7 +-
> >>  35 files changed, 614 insertions(+), 119 deletions(-)
> >>
> >>
> >> base-commit: 3bc1fb9c3b20cd478c83496ab16addecb401770d
> >> prerequisite-patch-id: 049ae0eba275b5be35a238833107e0b251a55aa2
> >> prerequisite-patch-id: 614f0bc9411391403d4e9702bafeb31b0ec04ec1
> >> prerequisite-patch-id: ddf636b9d33d82ea206ce265d817371350bf8858
> >
> > I think this is going to be very hard to do properly, because the
> > kernel can't really manage this on its own. Something in userland is
> > going to have to set this value if you want to update it to something
> > other than the original inode instantiation time (aka btime).
> >
> > It really sounds like what you want is the ability to make the btime
> > settable. Personally I think the decision to forbid that was wrong-
> > headed and that it should have been settable from userland from the
> > beginning. Maybe we should just revisit that decision.
>

Frankly, I don't think this decision was made at all.

There are only 2 types of filesystems in Linux today:
1. btime is constant (xfs, etx4, btrfs,...)
2. crtime is settable in principle but not via a standardized Linux
API (ntfs, cifs, ...)

AFAIK, btrfs in this series is the only filesystem which is going to
have two deviated copies of btime and ptime.
For all the rest, the deviation is artificial in statx.

So the questions to ask are:
1. Do btrfs developers prefer to store a new settable ptime or
    making otime/btime settable with this new API?
2. Will any other fs in the future want to store settable ptime along
    side the legacy immutable btime?

My take on these question is:
- Personally I would love to see ptime support in xfs in the future and wou=
ld
  willing to contribute to this work, because I have hard evidence from the
  performance benefits that it brings to smb server workloads
- Judging by past experience with i_version bump interpretation on xfs,
  I find it hard to believe that xfs developer would agree to making the
  legacy btime settable

Hence the distinction in statx API is needed, but for most filesystems
it is a pure semantic way of saying "I do/don't have settable birth time".

> Originally I just wanted to have btime settable, yes, and if btime was
> settable I wouldn't have made this RFC PATCH either, but after reading
> the already existing discussions about it, I can understand having an
> "immutable inode creation time", like ctime exists, so even after making
> btime settable, a new timestamp would be necessary anyway (e.g. for the
> people who want btime to exist as a forensics timestamp).
>

Right, but every filesystem (e.g. btrfs) can still make an independent
choice whether storing one or two copies is desired.
The API does not limit those choices.

> > Failing that, why not just track this in an xattr of some sort, since
> > this is really just an opaque blob once you allow it to be settable. If
> > the xattr isn't present, then you can just use the value of the btime
> > as-is. FWIW, I think samba does this today, so you could try to sync
> > with its behavior here.
>
> (This is copied and adapted from [2])
>
> I actually have been using fully userspace xattrs[1] for a few months,
> mostly for backups, and it "works"; but last month I wanted to merge 2
> FSs (and have another merge I have to do), so I ran [1] on all files and
> then compared all metadata/data between source and destination and
> noticed there were quite a lot of files that didn't have the xattr set.
> So I looked online and learned that xattrs only work on regular
> files/directories, not on symlinks or anything else (and the missing
> ones were of symlinks).
> This is what prompted me to search more if anyone had already proposed a
> new timestamp (instead of making btime settable) and found the email
> thread from april linked in the cover letter, which gave me the excuse
> to finally work on a proper patch.
>

I am tired of repeating my arguments (and finding my own quotes)
about why using xattrs is a poor replacement for in-inode ptime.
AI agents can easily find those quotes for those who are interested
so I won't bother, I just say that smbd already uses xattr to store
the creation time - it's just bad for performance and disk usage in
metadata intensive workloads.

> > That seems a lot simpler than adding an entirely new inode timestamp
> > that is always going to be a copy of the btime, except in rare cases.
> > Having to patch all of the on-disk filesystems with a new per-inode
> > field is a lot more work.
>
> > This patch is quite simple, but changing btrfs, then ext4, xfs, etc is =
a
> > mess, and inevitably you can't get these timestamps until you upgrade y=
our
> > filesystems.
>

Jeff, this is standard "how to make progress".
I completely don't agree with this argument.
We cannot use this argument to block progress.
Is it already a long standing practice for userspace file servers (samba)
to probe the host filesystem for specific features and fall back to
alternative implementation if they are not supported.

There will be nothing new in this case, that's the only way to
make forward progress - define the API, make support queryable,
implement the feature in some filesystems, implement consumers, repeat.

Also for nfsd, that's the only way to ever implement settable
FATTR4_TIME_CREATE which is the protocol allows.
This is never going to be possible with custom xattrs.
So I must say that I don't understand the objection from you and Chuck

Thanks,
Amir.
