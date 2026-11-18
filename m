Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795023432;
	b=LULAyFV493GXzVnxMikAnLiSIu77CgW0mpwsHJJzZ/bLK15xSbOcaODos8mewX3OxpY7
	 2PbKL44Mc4vlqP1zw5L5+5hbudqquHTJRwkJ0B3v1fC++vZTMdtNKu4OnWOcNkLEB+o/x
	 xnYJrrF2CMQLICW/9IdytQyDCjec0qcaOPZxSn4u+8/eCzwq1zQJ9NDPo0Kf+BokHv91s
	 e3p/G8Ztco1k5vP6gOwj6stzh/BdIQMb6ufw02k42vTtzuGeHVVDp9D7VFvJQHpfsYxa+
	 5mmBpGEa62fd/Tfx1F9VBD8ytcUcxrqs0CfMFNMX0ZScnURVB+ybCun0MrGNhvvhhjQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795023432;
	h=Received:DKIM-Signature:Received:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:
	 Content-Transfer-Encoding:In-Reply-To:User-Agent;
	bh=C04L+fPGYd5TAOvLJsLG4D4wwYpPBdl3W7tBscNs3YM=;
	b=x9Uu8OGtCkFtwEjZ5QYTpqs6csTQy0GBHIaX4RmXkZBQ4J2b3KqJlVwN6Drv7tXezITo
	 pDsjcfGNJjk+Y685NzR/i9oedpK+30NKk7hh4TU9ziyiVpkTuzV6ccMz0akvB+YR7j7E+
	 lWfzz5PJHOwvIbq1Ls1QCqJH6ijgJ1cABj/7IGG4cr6lBAhGb9y4ZFCJWkM7AdjTujv5H
	 GJoQcZVw43a58tWlrT36vXklYbC+FoTtrAcunlkaQ56qXFzvHjBjM2jG9XUajtM6pIdfd
	 X4KPJ59fhy4FbdRoH6d22LZp1NeO6CRwyvYznpj+aU1NNId2yhfz/IjcRHjRZNN86uQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ZCFBQuM2;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 666EE606A334;
	Wed, 18 Nov 2026 17:37:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ZCFBQuM2
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B1B381F000C9;
	Wed, 18 Nov 2026 17:37:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795023432;
	bh=C04L+fPGYd5TAOvLJsLG4D4wwYpPBdl3W7tBscNs3YM=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=ZCFBQuM2qr0YTydXep+xfpU1dVjv7SVlc+QHH2gehLMbGZJzBoVnPmTIYRe0/kZQq
	 yExy3s6Iu/NfYV9LS6HqsUyXBB8/lDUnq9eU4LVSQxmQ5vnmdP0DiHAg9p8A0Qtfns
	 Cjy96AxI5AK3rB78LHZMKt0w4gj8MJx48rRJmVX0Qt46DBzgVM6fzkyFNRuRDh8LDu
	 8x5cOndY6IfJT6DwrzOitiDsvKgEMh/Gas6s8VRqp9zLSDc8uK3BLdclGGdhKQi/Iy
	 Db5taF+mFEdphi5E8f0QokRSOaCoSheSLrqCm0HeGLgeAVY1CaS/WSgVTKF4iVkNwV
	 2OOpFByvj7uFQ==
Received: by pali.im (Postfix)
	id 5CD07846; Wed, 18 Nov 2026 18:37:08 +0100 (CET)
Date: Wed, 18 Nov 2026 18:37:08 +0100
From: Pali =?utf-8?B?Um9ow6Fy?= <pali@kernel.org>
To: Amir Goldstein <amir73il@gmail.com>
Cc: koraynilay <koray.fra@gmail.com>, David Sterba <dsterba@suse.com>,
	Namjae Jeon <linkinjeon@kernel.org>,
	Sungjong Seo <sj1557.seo@samsung.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>, Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Konstantin Komarov <almaz.alexandrovich@paragon-software.com>,
	Paulo Alcantara <pc@manguebit.org>, Chris Mason <mason@kernel.org>,
	Yuezhang Mo <yuezhang.mo@sony.com>, Jan Kara <jack@suse.cz>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	Ronnie Sahlberg <ronniesahlberg@gmail.com>,
	Shyam Prasad N <sprasad@microsoft.com>,
	Bharath SM <bharathsm@microsoft.com>,
	Sergey Senozhatsky <senozhatsky@chromium.org>,
	ChenXiaoSong <chenxiaosong@chenxiaosong.com>,
	"Darrick J . Wong" <djwong@kernel.org>,
	Sean Smith <defendthedisabled@gmail.com>,
	Andrey Albershteyn <aalbersh@kernel.org>,
	Pedro Falcato <pfalcato@suse.de>, linux-btrfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	exfat@lists.linux.dev, ntfs3@lists.linux.dev,
	linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-api@vger.kernel.org, Theodore Tso <tytso@mit.edu>
Subject: Re: [RFC PATCH v4 00/10] add provenance time (ptime)
Message-ID: <20261118173708.ax4t7zzklr5jvf2t@pali>
References: <20261115180343.576773-1-koray.fra@gmail.com>
 <20261118142613.be3r3s6kobkkxnz4@pali>
 <DMYFBDIV4Y08.35ZKR5G86U1H7@gmail.com>
 <20261118151605.lqtn5fz423kuswk5@pali>
 <DMYHPLWKPSH3.MUM1IIZZIWNR@gmail.com>
 <CAOQ4uxiwpdC-fKkqS5kiZ515q9MenC0jX4USV1idN7h2njx45Q@mail.gmail.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAOQ4uxiwpdC-fKkqS5kiZ515q9MenC0jX4USV1idN7h2njx45Q@mail.gmail.com>
User-Agent: NeoMutt/20180716

On Wednesday 18 November 2026 18:28:04 Amir Goldstein wrote:
> On Wed, Nov 18, 2026 at 5:50 PM koraynilay <koray.fra@gmail.com> wrote:
> >
> > On Wed Nov 18, 2026 at 4:16 PM CET, Pali Rohár wrote:
> > > On Wednesday 18 November 2026 15:58:02 koraynilay wrote:
> > >> On Wed Nov 18, 2026 at 3:26 PM CET, Pali Rohár wrote:
> > >> > Hello,
> > >> >
> > >> > I have just one issue with the userspace API. It does not allow me to
> > >> > figure out what is the source of statx btime field. If it is fs ptime or
> > >> > fs btime because this RFC implementation is mixing both fs ptime and
> > >> > fs btime into the statx btime field.
> > >> >
> > >> > I have feeling that this is quite a mess in API and I would like to see
> > >> > a clear distinguish between btime and ptime in the API, like there is a
> > >> > difference in the fs storage.
> > >> >
> > >> > If the btime is used for forensic analysis then somehow I would expect
> > >> > that the statx would not report / not fill changeable ptime value into
> > >> > the statx btime.
> > >>
> > >> Hi, for native linux filesystems it will report ptime as PTIME and btime
> > >> as BTIME (also semnatically).
> > >
> > > That is fine.
> > >
> > >> for the windows-like ones that only have
> > >> ptime (semantically) I think it's reasonable to not expect btime to be
> > >> immutable, since they are meant to be used with other OSs who lack btime
> > >> semantics.
> > >
> > > The problem is here that the RFC statx API does not provide this
> > > information that the fs lacks btime semantics and instead it fills
> > > non-immutable ptime value there.
> > >
> > > I'm pointing only about this inconsistency.
> > >
> > >> > It would be really helpful if the statx API on inode can differ between:
> > >> >
> > >> > 1. btime is present and its value is ..., ptime is not supported
> > >> > 2. btime is not supported, ptime is set to value ...
> > >> > 3. btime is present and its value is ..., ptime is set to value ...
> > >> > 4. both btime and ptime are not supported
> > >> >
> > >> > This should cover all cases of different filesystems and also allows
> > >> > userspace to do proper backup of both ptime and btime fields (if it want
> > >> > to do forensic analysis or anything else).
> > >>
> > >> These should already all be covered by STATX_BTIME/PTIME and their
> > >> fields in struct statx, the only problems are windows-like filesystems,
> > >> which IMO shuold be handled as mentioned above.
> > >
> > > Exactly, I pointed out about these problems. I somehow expect that the
> > > new API would be generic and uniform across filesystem. IMHO it does not
> > > matter if the filesystem is windows-like or not (there are also FreeBSD
> > > fs and also others which allows to modify that time). So better
> > > description is fs belongs to category 2. from my above description.
> >
> > Ah yes, I used windows-like to mean "only have ptime semantics", so same
> > as your category 2.
> >
> > >> Of course, as in the other discussion, I'm open to changing ptime
> > >> NTFS/exFAT/... support to remove btime altogether and only use ptime for
> > >> their own crtime if that's what wanted (I'm fairly impartial on this
> > >> specific issue).
> > >
> > > I'm giving some ideas how to possible handle this situation:
> > >
> > > 1. do not fill btime it at all when it is not available (remove btime
> > >    altogether - the case like you wrote above)
> >
> > This would be the most semantically correct option, but would break at
> > least 1 script/program/use case.
> >
> > > 2. when userspace ask both ptime and btime, then do not fill btime
> > >    (remove btime altogether - but only for that new case)
> >
> > This probably is the best compromise.
> >
> > > 3. fill btime with ptime value, but add a new output flag indicating that
> > >    the btime is not present at all and instead kernel filled ptime value
> > >    into the statx btime field
> >
> > I don't really like this, it adds complexity and uses memory/1 flag big
> > for a single specific field, IMO it's not worth it.
> >
> > > 4. let statx btime as currently is, and add two new statx fields:
> > >    immutable_btime and ptime. immutable_btime would be filled only if the
> > >    fs supports real btime (so not for ntfs/extfat crtime) and ptime would
> > >    be what is currently in RFC
> >
> > I think this is also too complex.
> >
> > > Ideas 2. 3. and 4. should be fully backward compatible as it would
> > > affect statx output only when called with new flags.
> >
> > Then 2. is probably the best way to go forward (maybe I'll include it in
> > some way in v5), but I think we should let each filesystem maintainer
> > decide if they think their users want to have statx report their own
> > crtime as btime, ptime or both (native linux ones would of course
> > report btime as btime and ptime as ptime).
> >
> 
> Guys,
> 
> Let's take a step back.
> 
> If this discussion is proving anything is that the btime/ptime
> duality is a big headache and it's going to be a source of confusion to users
> even if we come up with some smart pants consistent semantics.
> 
> As Jeff writes, I think we should consider making btime mutable
> be a per-fs choice and not an API limitation.
> 
> A filesystem can even decide to store both the forensics btime
> alongside the user settable crtime.
> 
> There are some precedents in xfs with settable UUID which is
> a different field then the origin UUID from mkfs.
> 
> Fs that have immutable btime have a few choices:
> 1. Keep it immutable
> 2. Start making it muttbale (like the Win fs)
> 3. Start making the user visible btime (STATX_BTIME) mutable
>     but keep the forensics btime on-disk for, well, forensics
> 
> If btime becomes settable via options 2 or 3, this could require
> admin opt-in (e.g. tune2fs -O crtime).
> 
> With option 3 the crtime feature would be ROCOMPAT
> With option 2, it could probably be COMPAT. Maybe.
> 
> If we accept this story and the major fs maintainers are
> in agreement with this plan, then I think the missing piece
> is making the "settable mask" visible to users via the new API.
> 
> IOW, we need to somehow export FS_XFLAG_RDONLY_MASK
> to userspace instead of only exporting the supported mask.
> And then with the addition of xflags_mask, we could also
> -EINVAL on users trying to set readonly flags/values.
> 
> Perhaps a single xflags_settable_mask is enough.
> 
> For file_setattr(), xflags_mask is anyway a set-those mask.
> For file_getattr(), does it matter if we get an answer
> Filesystem does not support casefold on this file
> OR
> Filesystem does not have casefold on this file and
> you cannot set casefold on this file
> 
> It's kind of the same, isn't it?
> 
> What do you say?
> 
> Shall we drop PTIME in favor of "is BTIME settable?" API?
> Leaving STATX_BTIME exactly as is.
> 
> Thanks,
> Amir.

From the beginning I had a feeling that this is not an option at all and
that is why all that ptime-way was chosen.

So thanks for brining this up. I like this your idea. It address the
original problem with backup/restore of "create time".

But I would like to point out about another thing in this your idea. It
would be nice to have an API to retrieve that "forensics on-diks btime"
in case there would be filesystems which choose option 3.
