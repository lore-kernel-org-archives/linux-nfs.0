Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795023393;
	b=P6eS5QSlxcozYE4j8QkXOPHJjHHArXSoUuTQCiLRAjwXlfDU2W+IrMeH2HplU/LiG7mf
	 O4fZqjlduV70QbRN3YBpBbpUO6J9fWlNEXgdaTLGAP0LzqVK2hI1oE8kZSzqkPHD+/Xgt
	 DfKRJtyOGfo75SNeKINCfn0jTDUcgz68lGzepBxN0A/VvDNAN4E79ZIgAmStV5KFCg/Kr
	 0MFcEJP6eJ9dFMmvmIwJqtYS5akOREG0UWm0do4USTc9hlyLN2n+/Ho3+4YdPTUrnq4bv
	 s0rvzcbxFfMY7nLMcZsWiSvaGhGOr2j9Y5BC/h6nZUXt5vCXEQjWtgH/R+RNHMVbV3Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795023393;
	h=Received:DKIM-Signature:Message-ID:Subject:From:To:Cc:Date:
	 In-Reply-To:References:Autocrypt:Content-Type:
	 Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=fISkMohQ453A9rmPuNy3JF7zy+TDGxd037Y6qsyUdqo=;
	b=DXCQxTmG+LoriUHbH1dw13FsgffP6OqQnBU0j9qXfY5uABU/sYeRvYN4Tj89KCOFe9kH
	 wHdC4TyWy3I9+LTLqSGgHCtKfp5fFoQAJKqnXWOIO3ehOyHnhb6Q++5uGkJrsx/C3OY+4
	 LjfqhWr56fTvulB16CrjAQQ66y3u5ZA+bk7BTPjre8oBQ9AGYeZuSJdJThg8uct/x3Kn1
	 p6MCR5Qo/tdUvjiiaxnu8ckzOWkY2dqb7CP2DNW6GNT1+re1duI9rzIE3035B8FLeTtFl
	 h1Q+BKv6PS+S7wzoituftZcQW+jewWKcC0ze1YMUqeWO7sCEYoauBM2eznnKtaiuNtQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=MyoOrTaW;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2597D606A330;
	Wed, 18 Nov 2026 17:36:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=MyoOrTaW
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D2EAE1F000C4;
	Wed, 18 Nov 2026 17:36:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795023392;
	bh=fISkMohQ453A9rmPuNy3JF7zy+TDGxd037Y6qsyUdqo=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=MyoOrTaWoBH9gevTvcDGL0ySmY+ij5ZUpTH5kxsZGFXO3GhMXvPulkmygZ8Fo+ITW
	 kSi2k4cqZ5P+89wthoxzPwdm1xL3Vdfb4sihju7MDtJmO1tw4Sr5IRD7GTwYh0FoiC
	 rdTN+N98qsfeiDDChCKyXBW0C/4CIf71XNLqt88wyqFmYfX2gOIrZ5WQaQgerKtrlz
	 NWAszTrtW1k8aVb4r7qWrUo+LkcCIhg2VASTcoNBjDUOce6ZKF71PG31O+ngy9BvvH
	 wWWD8M9dt6hu1VcekTbgkZw5r6Q4sxLtfXGd4Fx20BvjGYCFoWxjwUAPir3kL9ZD/4
	 dOhDp+0dy3d+A==
Message-ID: <7126bdd0ff59e9ea9bc58702af2ecb38096330e8.camel@kernel.org>
Subject: Re: [RFC PATCH v4 00/10] add provenance time (ptime)
From: Jeff Layton <jlayton@kernel.org>
To: Amir Goldstein <amir73il@gmail.com>, koraynilay <koray.fra@gmail.com>
Cc: Pali =?ISO-8859-1?Q?Roh=E1r?= <pali@kernel.org>, David Sterba	
 <dsterba@suse.com>, Namjae Jeon <linkinjeon@kernel.org>, Sungjong Seo	
 <sj1557.seo@samsung.com>, Alexander Viro <viro@zeniv.linux.org.uk>, 
 Christian Brauner	 <brauner@kernel.org>, Trond Myklebust
 <trondmy@kernel.org>, Anna Schumaker	 <anna@kernel.org>, Chuck Lever
 <cel@kernel.org>, Konstantin Komarov	
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
 Pedro Falcato <pfalcato@suse.de>, linux-btrfs@vger.kernel.org,
 linux-kernel@vger.kernel.org, 	linux-fsdevel@vger.kernel.org,
 exfat@lists.linux.dev, ntfs3@lists.linux.dev, 	linux-cifs@vger.kernel.org,
 linux-nfs@vger.kernel.org, linux-api@vger.kernel.org,  Theodore Tso	
 <tytso@mit.edu>
Date: Wed, 18 Nov 2026 09:36:31 -0800
In-Reply-To: <CAOQ4uxiwpdC-fKkqS5kiZ515q9MenC0jX4USV1idN7h2njx45Q@mail.gmail.com>
References: <20261115180343.576773-1-koray.fra@gmail.com>
	 <20261118142613.be3r3s6kobkkxnz4@pali>
	 <DMYFBDIV4Y08.35ZKR5G86U1H7@gmail.com>
	 <20261118151605.lqtn5fz423kuswk5@pali>
	 <DMYHPLWKPSH3.MUM1IIZZIWNR@gmail.com>
	 <CAOQ4uxiwpdC-fKkqS5kiZ515q9MenC0jX4USV1idN7h2njx45Q@mail.gmail.com>
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

On Wed, 2026-11-18 at 18:28 +0100, Amir Goldstein wrote:
> On Wed, Nov 18, 2026 at 5:50=E2=80=AFPM koraynilay <koray.fra@gmail.com> =
wrote:
> >=20
> > On Wed Nov 18, 2026 at 4:16 PM CET, Pali Roh=C3=A1r wrote:
> > > On Wednesday 18 November 2026 15:58:02 koraynilay wrote:
> > > > On Wed Nov 18, 2026 at 3:26 PM CET, Pali Roh=C3=A1r wrote:
> > > > > Hello,
> > > > >=20
> > > > > I have just one issue with the userspace API. It does not allow m=
e to
> > > > > figure out what is the source of statx btime field. If it is fs p=
time or
> > > > > fs btime because this RFC implementation is mixing both fs ptime =
and
> > > > > fs btime into the statx btime field.
> > > > >=20
> > > > > I have feeling that this is quite a mess in API and I would like =
to see
> > > > > a clear distinguish between btime and ptime in the API, like ther=
e is a
> > > > > difference in the fs storage.
> > > > >=20
> > > > > If the btime is used for forensic analysis then somehow I would e=
xpect
> > > > > that the statx would not report / not fill changeable ptime value=
 into
> > > > > the statx btime.
> > > >=20
> > > > Hi, for native linux filesystems it will report ptime as PTIME and =
btime
> > > > as BTIME (also semnatically).
> > >=20
> > > That is fine.
> > >=20
> > > > for the windows-like ones that only have
> > > > ptime (semantically) I think it's reasonable to not expect btime to=
 be
> > > > immutable, since they are meant to be used with other OSs who lack =
btime
> > > > semantics.
> > >=20
> > > The problem is here that the RFC statx API does not provide this
> > > information that the fs lacks btime semantics and instead it fills
> > > non-immutable ptime value there.
> > >=20
> > > I'm pointing only about this inconsistency.
> > >=20
> > > > > It would be really helpful if the statx API on inode can differ b=
etween:
> > > > >=20
> > > > > 1. btime is present and its value is ..., ptime is not supported
> > > > > 2. btime is not supported, ptime is set to value ...
> > > > > 3. btime is present and its value is ..., ptime is set to value .=
..
> > > > > 4. both btime and ptime are not supported
> > > > >=20
> > > > > This should cover all cases of different filesystems and also all=
ows
> > > > > userspace to do proper backup of both ptime and btime fields (if =
it want
> > > > > to do forensic analysis or anything else).
> > > >=20
> > > > These should already all be covered by STATX_BTIME/PTIME and their
> > > > fields in struct statx, the only problems are windows-like filesyst=
ems,
> > > > which IMO shuold be handled as mentioned above.
> > >=20
> > > Exactly, I pointed out about these problems. I somehow expect that th=
e
> > > new API would be generic and uniform across filesystem. IMHO it does =
not
> > > matter if the filesystem is windows-like or not (there are also FreeB=
SD
> > > fs and also others which allows to modify that time). So better
> > > description is fs belongs to category 2. from my above description.
> >=20
> > Ah yes, I used windows-like to mean "only have ptime semantics", so sam=
e
> > as your category 2.
> >=20
> > > > Of course, as in the other discussion, I'm open to changing ptime
> > > > NTFS/exFAT/... support to remove btime altogether and only use ptim=
e for
> > > > their own crtime if that's what wanted (I'm fairly impartial on thi=
s
> > > > specific issue).
> > >=20
> > > I'm giving some ideas how to possible handle this situation:
> > >=20
> > > 1. do not fill btime it at all when it is not available (remove btime
> > >    altogether - the case like you wrote above)
> >=20
> > This would be the most semantically correct option, but would break at
> > least 1 script/program/use case.
> >=20
> > > 2. when userspace ask both ptime and btime, then do not fill btime
> > >    (remove btime altogether - but only for that new case)
> >=20
> > This probably is the best compromise.
> >=20
> > > 3. fill btime with ptime value, but add a new output flag indicating =
that
> > >    the btime is not present at all and instead kernel filled ptime va=
lue
> > >    into the statx btime field
> >=20
> > I don't really like this, it adds complexity and uses memory/1 flag big
> > for a single specific field, IMO it's not worth it.
> >=20
> > > 4. let statx btime as currently is, and add two new statx fields:
> > >    immutable_btime and ptime. immutable_btime would be filled only if=
 the
> > >    fs supports real btime (so not for ntfs/extfat crtime) and ptime w=
ould
> > >    be what is currently in RFC
> >=20
> > I think this is also too complex.
> >=20
> > > Ideas 2. 3. and 4. should be fully backward compatible as it would
> > > affect statx output only when called with new flags.
> >=20
> > Then 2. is probably the best way to go forward (maybe I'll include it i=
n
> > some way in v5), but I think we should let each filesystem maintainer
> > decide if they think their users want to have statx report their own
> > crtime as btime, ptime or both (native linux ones would of course
> > report btime as btime and ptime as ptime).
> >=20
>=20
> Guys,
>=20
> Let's take a step back.
>=20
> If this discussion is proving anything is that the btime/ptime
> duality is a big headache and it's going to be a source of confusion to u=
sers
> even if we come up with some smart pants consistent semantics.
>=20
> As Jeff writes, I think we should consider making btime mutable
> be a per-fs choice and not an API limitation.
>=20
> A filesystem can even decide to store both the forensics btime
> alongside the user settable crtime.
>=20
> There are some precedents in xfs with settable UUID which is
> a different field then the origin UUID from mkfs.
>=20
> Fs that have immutable btime have a few choices:
> 1. Keep it immutable
> 2. Start making it muttbale (like the Win fs)
> 3. Start making the user visible btime (STATX_BTIME) mutable
>     but keep the forensics btime on-disk for, well, forensics
>=20
> If btime becomes settable via options 2 or 3, this could require
> admin opt-in (e.g. tune2fs -O crtime).
>=20
> With option 3 the crtime feature would be ROCOMPAT
> With option 2, it could probably be COMPAT. Maybe.
>=20
> If we accept this story and the major fs maintainers are
> in agreement with this plan, then I think the missing piece
> is making the "settable mask" visible to users via the new API.
>=20
> IOW, we need to somehow export FS_XFLAG_RDONLY_MASK
> to userspace instead of only exporting the supported mask.
> And then with the addition of xflags_mask, we could also
> -EINVAL on users trying to set readonly flags/values.
>=20
> Perhaps a single xflags_settable_mask is enough.
>=20
> For file_setattr(), xflags_mask is anyway a set-those mask.
> For file_getattr(), does it matter if we get an answer
> Filesystem does not support casefold on this file
> OR
> Filesystem does not have casefold on this file and
> you cannot set casefold on this file
>=20
> It's kind of the same, isn't it?
>=20
> What do you say?
>=20
> Shall we drop PTIME in favor of "is BTIME settable?" API?
> Leaving STATX_BTIME exactly as is.
>=20
>=20

+1

I think this is the better approach.

Looking over some of the earlier discussions around this since 2010
(!?!): I think some of the XFS devs objected to making it settable for
forensic reasons. So, on XFS you might need to rev the on-disk format
if you want to do it there to preserve the "historical" btime, and
maybe some xfs userland work to make it accessible for forensics.

For the record, the statx manpage documents the btime field very
sparsely:

       stx_btime
              The file's creation timestamp.

There is no documented guarantee that this will be immutable, AFAICT.
--=20
Jeff Layton <jlayton@kernel.org>
