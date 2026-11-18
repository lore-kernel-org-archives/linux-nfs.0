Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795009530;
	b=3fYgxIsZJjId/BD+9j4sZpb2NSrQs4RPeCNxnL3FPL7vEjutBcC34+LSusVN3e+cYOYn
	 2oypZOw65n9JNcF3b9N5HTmrUiUJ1Q9sO0wCPNuq9E+Pf3T30dgNCa8zLfBN0MKFD2fWh
	 TO7o27iGHvLRn9yC6Mv80FNbyh78eNLNFwd5Iwuqcmj3T1tXdmKQqssQ+HuIZAS7sNdFH
	 Qv4LhC1zmUDGnKqZtz75wY49iMczPsW5KbunUuQ6q//G+q9JNWOY8y2RfH3NRP7pDh8cO
	 S/E56YxUTS3F0kkNgtQEFJM6E8+F6l1/avqCSwykfawN5BYYEWrHg6biGnS3zc+WbiQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795009530;
	h=Received:DKIM-Signature:Message-ID:Subject:From:To:Cc:Date:
	 In-Reply-To:References:Autocrypt:Content-Type:
	 Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=/tLyxxp49tYPKdKpdIyoS5eOkOmJEFw7wQiyYWfw6go=;
	b=unKdRBvvqkZRD0Rc06J6eAKRiaLfTaeZwBRCt6w5LzYcaOReJgHx7WEOEwWm4xLMpiGu
	 5tqLaRs7o9Auq/JE4QIlQOA0ceoReR9gibQ93nThDiclzMAUOGazx/fvgmPF7TWOUeC8n
	 jl15/Bdi/k8fDFBjyPZKfLJfH+hQ95G8oD4kesoi6dN6LVAd+qEccT7i3jie3rzBaDDtt
	 2TvotW/t02cI+4pCyEcuPS3KgTqSqFhHFjfbUrZxKqSpDWjWnP4gt0hX0ocas3wfP/SHB
	 GeJE+hthXeys4taFP9YkIEk3i/+ZtxZk1R+Nk1SDtoOxp5o7RXh9GwreQ0+ALZeKSkA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=D25H066h;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CBD1A606A32C;
	Wed, 18 Nov 2026 13:45:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=D25H066h
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E7E011F000C4;
	Wed, 18 Nov 2026 13:45:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795009530;
	bh=/tLyxxp49tYPKdKpdIyoS5eOkOmJEFw7wQiyYWfw6go=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=D25H066h60CpHG/SqLDevtzxMx4QagCblHqARsKmTJbKOPXT15KrRUXPB3ZbDYiTQ
	 m4UOB4Tq/6/lKYa2HJut8BGR6emkTQ+ipeNkTqNmN08S3Uejxhsk02Wd/R6q8WpUzM
	 icz8G8nXS8LjjlLqTfgEAsxMC/iDV+aqvAnLucNJL+6LBKdxsjATSfUWuIzHroYinC
	 K0oyxgM8id3uPEveVlpcJoAUk0S1rEbBx4wUy5uMC7PQ3ocIIJD7ed0WF+mGatxmm8
	 N1ihkf5hyUJZiNQoWOs+BmEBC8rUMpcQBAhXmFzw0nLm6+BJxuFJA4Q1QyTswNbmXj
	 1Q0yHT2mdKjzA==
Message-ID: <a2889a0bfb26e329ecf2eed6d2318bfcbbb0ff2c.camel@kernel.org>
Subject: Re: [RFC PATCH v4 00/10] add provenance time (ptime)
From: Jeff Layton <jlayton@kernel.org>
To: Amir Goldstein <amir73il@gmail.com>, koraynilay <koray.fra@gmail.com>
Cc: David Sterba <dsterba@suse.com>, Namjae Jeon <linkinjeon@kernel.org>, 
 Sungjong Seo <sj1557.seo@samsung.com>, Alexander Viro
 <viro@zeniv.linux.org.uk>, Christian Brauner	 <brauner@kernel.org>, Trond
 Myklebust <trondmy@kernel.org>, Anna Schumaker	 <anna@kernel.org>, Chuck
 Lever <cel@kernel.org>, Konstantin Komarov	
 <almaz.alexandrovich@paragon-software.com>, Paulo Alcantara
 <pc@manguebit.org>,  Chris Mason <mason@kernel.org>, Yuezhang Mo
 <yuezhang.mo@sony.com>, Jan Kara <jack@suse.cz>, NeilBrown	
 <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo	
 <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, Ronnie Sahlberg	
 <ronniesahlberg@gmail.com>, Shyam Prasad N <sprasad@microsoft.com>, Bharath
 SM	 <bharathsm@microsoft.com>, Sergey Senozhatsky
 <senozhatsky@chromium.org>,  ChenXiaoSong <chenxiaosong@chenxiaosong.com>,
 "Darrick J . Wong" <djwong@kernel.org>, Sean Smith	
 <defendthedisabled@gmail.com>, Andrey Albershteyn <aalbersh@kernel.org>, 
 Pedro Falcato <pfalcato@suse.de>, Pali =?ISO-8859-1?Q?Roh=E1r?=
 <pali@kernel.org>, 	linux-btrfs@vger.kernel.org,
 linux-kernel@vger.kernel.org, 	linux-fsdevel@vger.kernel.org,
 exfat@lists.linux.dev, ntfs3@lists.linux.dev, 	linux-cifs@vger.kernel.org,
 linux-nfs@vger.kernel.org, linux-api@vger.kernel.org
Date: Wed, 18 Nov 2026 05:45:28 -0800
In-Reply-To: <CAOQ4uxjcvAKTaGXO0=BpbtgoEPmN7GKieVbX1ZpZR38H1Z3j9g@mail.gmail.com>
References: <20261115180343.576773-1-koray.fra@gmail.com>
	 <fc53ec55d315a4b96ec1e6f250ad3763f2189755.camel@kernel.org>
	 <DMXXOPD9UDNP.2YP9ROMHFLM9E@gmail.com>
	 <CAOQ4uxjcvAKTaGXO0=BpbtgoEPmN7GKieVbX1ZpZR38H1Z3j9g@mail.gmail.com>
Autocrypt: addr=jlayton@kernel.org; prefer-encrypt=mutual;
 keydata=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
 QZIQXVeAA+smfTT0tDrisj1U5x6ZB9b3nBg65kc=
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-3.fc44) 
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0

On Wed, 2026-11-18 at 09:14 +0100, Amir Goldstein wrote:
> On Wed, Nov 18, 2026 at 2:09=E2=80=AFAM koraynilay <koray.fra@gmail.com> =
wrote:
> >=20
> > Hello and thanks for replying,
> >=20
> > On Wed Nov 18, 2026 at 12:53 AM CET, Jeff Layton wrote:
> > > On Sun, 2026-11-15 at 19:03 +0100, koraynilay wrote:
> > > > This is an initial implementation of a new timestamp to indicate th=
e
> > > > time when a file/directory was initially created.
> > > >=20
> > > > This patch series takes inspiration from the one by Sean Smith
> > > > <defendthedisabled@gmail.com> [1], but using
> > > > file_setattr()/file_getattr() as suggested by Darrick J. Wong
> > > > <djwong@kernel.org> in [2].
> > > >=20
> > > > The semantics of this new timestamp should be at least these:
> > > > - it should be the same as btime on a newly created file
> > > > - it's user-settable, so it can be preserved for backups, filesyste=
m
> > > >   conversions, archives and any similar operation
> > > > - it should be preserved every time mtime gets preserved
> > > >=20
> > > > and the correspondence with the other timestamps is as follows:
> > > >=20
> > > > ctime <-> btime
> > > > mtime <-> ptime
> > > >=20
> > >=20
> > > I'm not sure how to interpret the correspondence above.
> >=20
> >   |-----\_-----------------|-----------|
> >   |       \_      change/  |   birth/  |
> >   |         \_ modification|  creation |
> >   |           \------------|-----------|
> >   | inode time |   ctime   |   btime   |
> >   |------------|-----------|-----------|
> >   | file time  |   mtime   |   ptime   |
> >   |------------|-----------|-----------|
> >=20
> > ("file" as in "the concept of this file", I'd say "file content" but
> > that would be incorrect for symlinks)
> >=20
> > so ctime is "inode change time", btime is "inode birth/creation time",
> > while mtime is "file content change/modification time" and ptime would
> > be "file content creation time" (same as Window's or MacOS's creation
> > time).
> >=20
> > Does this make more sense?
> >=20
> > >=20
> > > > Examples:
> > > > 1) a .zsh_history file created in 2019, then after a few years the =
user
> > > >    decides to switch to another filesystem, copying the .zsh_histor=
y to
> > > >    the new home, in that case btime would have the timestamp of the=
 copy
> > > >    and ptime would have the 2019 timestamp (just like mtime would h=
ave
> > > >    been preserved)
> > > > 2) a symlink created in 2020 from the home directory to a /path goi=
ng
> > > >    through the same process as the .zsh_history, in this case it wo=
uld
> > > >    also make sense to sync the ptime to the 2020 timestamp instead =
of
> > > >    keeping only the btime (so the inode creation time).
> > > >=20
> > > > The proof-of-concept code (for testing) for stat(1) and cp(1) is
> > > > available at https://github.com/koraynilay/coreutils (master branch=
)
> > > > (Note: these coreutils code changes are a prototype and won't be
> > > > submitted upstream as-is, but they work as expected in simple stat =
and
> > > > cp -a/--preserve=3Dptime tests)
> > > >=20
> > > > Lastly, the name "provenance" and "ptime" are not final, I personal=
ly
> > > > don't have a strong opinion on any name, but while testing with sta=
t(1)
> > > > I noticed that "Provenance" is definitely too long for the normal
> > > > output, so another option which would fit well is "Origin time",
> > > > abbreviated as "ntime" (OrigiN time) and not as "otime", as that wo=
uld
> > > > conflict with btrfs' internal naming and create confusion.
> > > >=20
> > > > v2 changes:
> > > > - fix permission bypass leading to ptime update on immutable and
> > > >   append-only files (found by sashiko[3])
> > > > - normalize ptime timestamp as done in fs/attr.c:notify_change() (f=
ound
> > > >   by sashiko[3])
> > > > - fix wording in vfs patch to be like the cover-letter
> > > >=20
> > > > v3 changes:
> > > > - vfs: reject setting ptime with -EOPNOTSUPP on filesystems that do=
 not
> > > >   support it instead of silently ignoring it (found by sashiko[4])
> > > > - vfs: fix not being able to clear immutable and append-only on fil=
es
> > > >   with ptime, and allow updating immutable/append-only atomically a=
long
> > > >   with ptime (found by sashiko[4])
> > > > - btrfs: validate on-disk ptime nanoseconds and reset to otime if
> > > >   invalid (found by sashiko[4])
> > > > - btrfs: avoid re-assigning ptime on unrelated chattr calls (found =
by
> > > >   sashiko[4])
> > > > - add ntfs3 and exfat support as suggested by Amir Goldstein[5], bu=
t no
> > > >   vfat, smb, or nfs4 yet as they are a bit more complex
> > > > - move the introduction of fileattr_has_fsx_mask() from the btrfs p=
atch
> > > >   to a standalone patch in the series
> > > > - btrfs: add fileattr_[gs]et to symlink and special file operations
> > > >=20
> > > > v4 changes:
> > > > - vfs: implement fsx_xflags_mask as suggested by Amir Goldstein[6];
> > > > - add SMB (ksmbd/cifs) and nfs (nfsd/nfs) support as requested in
> > > >   previous threads;
> > > >=20
> > > > Note:
> > > > to apply this patch 2 previous patches[7][8] from the ksmbd/cifs
> > > > subsystem are needed.
> > > >=20
> > > > New Question:
> > > > should I rename fileattr_has_fsx_mask() to something like
> > > > fileattr_has_unsupported_fsx() and keep its code as-is, or should I=
 add
> > > > the fsx_xflags_mask & ~allowed check in it and keep the name as-is?=
 (or
> > > > both?)
> > > >=20
> > > > Thanks.
> > > >=20
> > > > [1]: https://lore.kernel.org/20260405195007.1306-2-DefendTheDisable=
d@gmail.com
> > > > [2]: https://lore.kernel.org/20260407014129.GC6192@frogsfrogsfrogs
> > > > [3]: https://sashiko.dev/#/patchset/20261027220532.736352-1-koray.f=
ra%40gmail.com
> > > > [4]: https://sashiko.dev/#/patchset/20261028134728.294127-1-koray.f=
ra%40gmail.com
> > > > [5]: https://lore.kernel.org/CAOQ4uxiuy0VwZj+3M-zRqQ49WTpHZpiaQ+6MZ=
8z8WdLjyQM_zA@mail.gmail.com/
> > > > [6]: https://lore.kernel.org/CAOQ4uxjtuTDT63vJdYaq+RHQEQFLTksp66e46=
OMN99WhJz3SbA@mail.gmail.com/
> > > > [7]: https://lore.kernel.org/linux-cifs/20261112111637.184045-2-kor=
ay.fra@gmail.com/
> > > > [8]: https://lore.kernel.org/linux-cifs/20261115155308.415734-1-kor=
ay.fra@gmail.com/
> > > >=20
> > > >=20
> > > > koraynilay (10):
> > > >   vfs: add provenance time (ptime)
> > > >   vfs: add fileattr_has_fsx_mask()
> > > >   ntfs3: make crtime user-settable using ptime
> > > >   exfat: make crtime user-settable using ptime
> > > >   btrfs: add provenance time (ptime)
> > > >   vfs: add __vfs_fileattr_set_locked() for inode_lock()'d callers
> > > >   nfsd: add provenance time (ptime) via FATTR4_TIME_CREATE
> > > >   nfs: add provenance time (ptime) via FATTR4_TIME_CREATE
> > > >   ksmbd: add provenance time (ptime) and map it to CreationTime
> > > >   cifs: add provenance time (ptime) and map it to SMB's CreationTim=
e
> > > >=20
> > > >  fs/btrfs/btrfs_inode.h          |   4 +
> > > >  fs/btrfs/delayed-inode.c        |   6 ++
> > > >  fs/btrfs/inode.c                |  29 +++++-
> > > >  fs/btrfs/ioctl.c                |  24 ++++-
> > > >  fs/btrfs/print-tree.c           |   1 +
> > > >  fs/btrfs/tree-log.c             |   3 +
> > > >  fs/exfat/exfat_fs.h             |   2 +
> > > >  fs/exfat/file.c                 |  42 ++++++++-
> > > >  fs/exfat/namei.c                |   1 +
> > > >  fs/file_attr.c                  | 156 ++++++++++++++++++++++++++--=
----
> > > >  fs/nfs/inode.c                  |  27 +++++-
> > > >  fs/nfs/internal.h               |   2 +
> > > >  fs/nfs/nfs4proc.c               |  56 +++++++++++-
> > > >  fs/nfs/nfs4xdr.c                |  19 ++--
> > > >  fs/nfs/symlink.c                |   1 +
> > > >  fs/nfsd/nfs4proc.c              |   9 ++
> > > >  fs/nfsd/nfs4xdr.c               |  40 +++++---
> > > >  fs/nfsd/vfs.c                   |  17 ++++
> > > >  fs/nfsd/vfs.h                   |   4 +-
> > > >  fs/nfsd/xdr4.h                  |   3 +
> > > >  fs/ntfs3/file.c                 |  20 +++-
> > > >  fs/ntfs3/frecord.c              |   8 +-
> > > >  fs/smb/client/cifsfs.c          |   8 ++
> > > >  fs/smb/client/inode.c           |   7 +-
> > > >  fs/smb/client/ioctl.c           | 109 ++++++++++++++++------
> > > >  fs/smb/server/smb2pdu.c         |  37 +++++---
> > > >  fs/smb/server/vfs.c             |  43 ++++++++-
> > > >  fs/smb/server/vfs.h             |   1 +
> > > >  fs/stat.c                       |   2 +
> > > >  include/linux/fileattr.h        |  29 +++++-
> > > >  include/linux/nfs_xdr.h         |   3 +
> > > >  include/linux/stat.h            |   1 +
> > > >  include/uapi/linux/btrfs_tree.h |   3 +-
> > > >  include/uapi/linux/fs.h         |   9 +-
> > > >  include/uapi/linux/stat.h       |   7 +-
> > > >  35 files changed, 614 insertions(+), 119 deletions(-)
> > > >=20
> > > >=20
> > > > base-commit: 3bc1fb9c3b20cd478c83496ab16addecb401770d
> > > > prerequisite-patch-id: 049ae0eba275b5be35a238833107e0b251a55aa2
> > > > prerequisite-patch-id: 614f0bc9411391403d4e9702bafeb31b0ec04ec1
> > > > prerequisite-patch-id: ddf636b9d33d82ea206ce265d817371350bf8858
> > >=20
> > > I think this is going to be very hard to do properly, because the
> > > kernel can't really manage this on its own. Something in userland is
> > > going to have to set this value if you want to update it to something
> > > other than the original inode instantiation time (aka btime).
> > >=20
> > > It really sounds like what you want is the ability to make the btime
> > > settable. Personally I think the decision to forbid that was wrong-
> > > headed and that it should have been settable from userland from the
> > > beginning. Maybe we should just revisit that decision.
> >=20
>=20
> Frankly, I don't think this decision was made at all.
>=20
> There are only 2 types of filesystems in Linux today:
> 1. btime is constant (xfs, etx4, btrfs,...)
> 2. crtime is settable in principle but not via a standardized Linux
> API (ntfs, cifs, ...)
>=20

CephFS is in this category too. I explicitly made it settable so we
could set it when restoring backups.


> AFAIK, btrfs in this series is the only filesystem which is going to
> have two deviated copies of btime and ptime.
> For all the rest, the deviation is artificial in statx.
>=20
> So the questions to ask are:
> 1. Do btrfs developers prefer to store a new settable ptime or
>     making otime/btime settable with this new API?
> 2. Will any other fs in the future want to store settable ptime along
>     side the legacy immutable btime?
>=20
> My take on these question is:
> - Personally I would love to see ptime support in xfs in the future and w=
ould
>   willing to contribute to this work, because I have hard evidence from t=
he
>   performance benefits that it brings to smb server workloads
> - Judging by past experience with i_version bump interpretation on xfs,
>   I find it hard to believe that xfs developer would agree to making the
>   legacy btime settable
>=20

Maybe? The main reason for that was that XFS uses i_version  as
internally as a change counter for any inode change. I doubt that it
uses btime internally like that.

The only reason I can see to _not_ make btime settable is for
forensics: maybe having the inode btime be immutable would make it
harder to disguise when an inode was instantiated, but I imagine that
would be defeatable with offline tools anyway.

If people are using the btime in this way, then it would be nice for
them to speak up and give us some details about this usage. How does
keeping it immutable help you?

> Hence the distinction in statx API is needed, but for most filesystems
> it is a pure semantic way of saying "I do/don't have settable birth time"=
.
>=20
> > Originally I just wanted to have btime settable, yes, and if btime was
> > settable I wouldn't have made this RFC PATCH either, but after reading
> > the already existing discussions about it, I can understand having an
> > "immutable inode creation time", like ctime exists, so even after makin=
g
> > btime settable, a new timestamp would be necessary anyway (e.g. for the
> > people who want btime to exist as a forensics timestamp).
> >=20
>=20
> Right, but every filesystem (e.g. btrfs) can still make an independent
> choice whether storing one or two copies is desired.
> The API does not limit those choices.
>=20
> > > Failing that, why not just track this in an xattr of some sort, since
> > > this is really just an opaque blob once you allow it to be settable. =
If
> > > the xattr isn't present, then you can just use the value of the btime
> > > as-is. FWIW, I think samba does this today, so you could try to sync
> > > with its behavior here.
> >=20
> > (This is copied and adapted from [2])
> >=20
> > I actually have been using fully userspace xattrs[1] for a few months,
> > mostly for backups, and it "works"; but last month I wanted to merge 2
> > FSs (and have another merge I have to do), so I ran [1] on all files an=
d
> > then compared all metadata/data between source and destination and
> > noticed there were quite a lot of files that didn't have the xattr set.
> > So I looked online and learned that xattrs only work on regular
> > files/directories, not on symlinks or anything else (and the missing
> > ones were of symlinks).
> > This is what prompted me to search more if anyone had already proposed =
a
> > new timestamp (instead of making btime settable) and found the email
> > thread from april linked in the cover letter, which gave me the excuse
> > to finally work on a proper patch.
> >=20
>=20
> I am tired of repeating my arguments (and finding my own quotes)
> about why using xattrs is a poor replacement for in-inode ptime.
> AI agents can easily find those quotes for those who are interested
> so I won't bother, I just say that smbd already uses xattr to store
> the creation time - it's just bad for performance and disk usage in
> metadata intensive workloads.
>=20
> > > That seems a lot simpler than adding an entirely new inode timestamp
> > > that is always going to be a copy of the btime, except in rare cases.
> > > Having to patch all of the on-disk filesystems with a new per-inode
> > > field is a lot more work.
> >=20
> > > This patch is quite simple, but changing btrfs, then ext4, xfs, etc i=
s a
> > > mess, and inevitably you can't get these timestamps until you upgrade=
 your
> > > filesystems.
> >=20

Weird. I didn't write the above sentence.

>=20
> Jeff, this is standard "how to make progress".
> I completely don't agree with this argument.
> We cannot use this argument to block progress.
> Is it already a long standing practice for userspace file servers (samba)
> to probe the host filesystem for specific features and fall back to
> alternative implementation if they are not supported.
>=20
> There will be nothing new in this case, that's the only way to
> make forward progress - define the API, make support queryable,
> implement the feature in some filesystems, implement consumers, repeat.
>=20
> Also for nfsd, that's the only way to ever implement settable
> FATTR4_TIME_CREATE which is the protocol allows.
> This is never going to be possible with custom xattrs.
> So I must say that I don't understand the objection from you and Chuck
>=20

I'm not saying that to try and block progress. I'm just pointing out
that it is a rather heavy lift to add a new inode field. This will
require revving the on-disk format for most local filesystems, and it
will take years to roll out. If we can get away with just making the
btime settable, that seems like a much simpler way to do this.

FWIW, Omar Sandoval apparently tried to add AT_UTIME_BTIME to
utimensat() back in 2019, but it never made it in. It might be good to
look over the objections to it then to see if they can be overcome.
--=20
Jeff Layton <jlayton@kernel.org>
