Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795022559;
	b=xTGArVEHpKqE3sR36GFt9CQalGu0sDEzf4TBAhnq3L13eykV58Ohw9/Xj/Of00qAKade
	 8SoC6dHy9oniDwqW96sA/wV1PIDldingAoW4AGH/xS1FqW/Ip3Ht1Kygoqxe0ozVUd2Ax
	 Cp9+oNGNEev0CDABQ8IKodET17pABGGWUcBXjqoYtfzxhlfasxQKHjwX2v4kKeZ5WDrHy
	 WOy/vYe0kHLFxTKlg3qA13C6+uMzAl8D9aNMeIXVf5FEawzalSwHnm7snqk+zcQuFOFNY
	 K9ldZvoQ2EXwsJpEl1r90YYdBNBtm9U7eCgacri9eRXeODIsM59Of01XGfAy+XdXK1A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795022559;
	h=Received:DKIM-Signature:Received:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:
	 Content-Transfer-Encoding:In-Reply-To:User-Agent;
	bh=VotAYrBtciufD00EQtINMlP1oNamOH3kYvCTKgTHmis=;
	b=1DO/hIui2ujgyOAtRd5RJiu/Slm2qX0E64a5DQ79lHAr92WzKxEmKFAW4As4GJqQVJK/
	 iUzSMaefHzx6pkbwXT1M6F0dLENq5wiY1gcmCYQgmswQZt7u4pEXhZcTUAj9a7ldXZAt5
	 +VkRGbrwVLeNQFkytNvMbykl9DIfdEpqq18jKyCvLbRV1iTGs8+/T63nEeVV7dWXvTHab
	 UssMloahLsGr7pv3ndrotUIitEbN1EMV/qkIWmb45gtJPGn3BA6cIrSjJaRKyqNVzcCSa
	 elMTCcHe5hv1W2/dA2oOdBMGRSVhlNs/nHI/TKublmYOC20d8+0PaKWrwPG8rD2yLVw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BUA2NnkU;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CB0AB606A331;
	Wed, 18 Nov 2026 17:22:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BUA2NnkU
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 30A2E1F000C6;
	Wed, 18 Nov 2026 17:22:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795022559;
	bh=VotAYrBtciufD00EQtINMlP1oNamOH3kYvCTKgTHmis=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=BUA2NnkUtEhAhDoFcOydn+vYU6Gy11rI6zu0ZctN8zT5MsWTYcceGQH2zQKxT467B
	 MqO9i4BJkGrg7RMW7whc4n2wzW5KfvNJUrkFRM2ryxFatYQiVQW2rwr2YNs9ije56d
	 GdyFNtlZGcLUVxyyZ2/ejye7oP6DshENT/1GdUEt3v57nIoXBt2lLhfO6sxhhph/0n
	 4MkX2qwnMYHvLwdIZIBM/3Hh3Wyll2hpYgtCzIJsXs39Iz2Lq++vw3pvLzdPSS+/Mq
	 pXlnxQ2G2+LFYaMUOi2UA5hJAAOiID700DXLNd522hrfS2vcC5IqtJ3z9aQgdF+m8i
	 SUK7KFtHmsZ7A==
Received: by pali.im (Postfix)
	id 3AC89846; Wed, 18 Nov 2026 18:22:36 +0100 (CET)
Date: Wed, 18 Nov 2026 18:22:36 +0100
From: Pali =?utf-8?B?Um9ow6Fy?= <pali@kernel.org>
To: koraynilay <koray.fra@gmail.com>
Cc: David Sterba <dsterba@suse.com>, Namjae Jeon <linkinjeon@kernel.org>,
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
	Pedro Falcato <pfalcato@suse.de>,
	Amir Goldstein <amir73il@gmail.com>, linux-btrfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	exfat@lists.linux.dev, ntfs3@lists.linux.dev,
	linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-api@vger.kernel.org
Subject: Re: [RFC PATCH v4 00/10] add provenance time (ptime)
Message-ID: <20261118172236.t65ytycs7ruxjrhg@pali>
References: <20261115180343.576773-1-koray.fra@gmail.com>
 <20261118142613.be3r3s6kobkkxnz4@pali>
 <DMYFBDIV4Y08.35ZKR5G86U1H7@gmail.com>
 <20261118151605.lqtn5fz423kuswk5@pali>
 <DMYHPLWKPSH3.MUM1IIZZIWNR@gmail.com>
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
In-Reply-To: <DMYHPLWKPSH3.MUM1IIZZIWNR@gmail.com>
User-Agent: NeoMutt/20180716

On Wednesday 18 November 2026 17:50:39 koraynilay wrote:
> On Wed Nov 18, 2026 at 4:16 PM CET, Pali Rohár wrote:
> > On Wednesday 18 November 2026 15:58:02 koraynilay wrote:
> >> On Wed Nov 18, 2026 at 3:26 PM CET, Pali Rohár wrote:
> >> > Hello,
> >> >
> >> > I have just one issue with the userspace API. It does not allow me to
> >> > figure out what is the source of statx btime field. If it is fs ptime or
> >> > fs btime because this RFC implementation is mixing both fs ptime and
> >> > fs btime into the statx btime field.
> >> >
> >> > I have feeling that this is quite a mess in API and I would like to see
> >> > a clear distinguish between btime and ptime in the API, like there is a
> >> > difference in the fs storage.
> >> >
> >> > If the btime is used for forensic analysis then somehow I would expect
> >> > that the statx would not report / not fill changeable ptime value into
> >> > the statx btime.
> >> 
> >> Hi, for native linux filesystems it will report ptime as PTIME and btime
> >> as BTIME (also semnatically).
> >
> > That is fine.
> >
> >> for the windows-like ones that only have
> >> ptime (semantically) I think it's reasonable to not expect btime to be
> >> immutable, since they are meant to be used with other OSs who lack btime
> >> semantics.
> >
> > The problem is here that the RFC statx API does not provide this
> > information that the fs lacks btime semantics and instead it fills
> > non-immutable ptime value there.
> >
> > I'm pointing only about this inconsistency.
> >
> >> > It would be really helpful if the statx API on inode can differ between:
> >> >
> >> > 1. btime is present and its value is ..., ptime is not supported
> >> > 2. btime is not supported, ptime is set to value ...
> >> > 3. btime is present and its value is ..., ptime is set to value ...
> >> > 4. both btime and ptime are not supported
> >> >
> >> > This should cover all cases of different filesystems and also allows
> >> > userspace to do proper backup of both ptime and btime fields (if it want
> >> > to do forensic analysis or anything else).
> >> 
> >> These should already all be covered by STATX_BTIME/PTIME and their
> >> fields in struct statx, the only problems are windows-like filesystems,
> >> which IMO shuold be handled as mentioned above.
> >
> > Exactly, I pointed out about these problems. I somehow expect that the
> > new API would be generic and uniform across filesystem. IMHO it does not
> > matter if the filesystem is windows-like or not (there are also FreeBSD
> > fs and also others which allows to modify that time). So better
> > description is fs belongs to category 2. from my above description.
> 
> Ah yes, I used windows-like to mean "only have ptime semantics", so same
> as your category 2.
> 
> >> Of course, as in the other discussion, I'm open to changing ptime
> >> NTFS/exFAT/... support to remove btime altogether and only use ptime for
> >> their own crtime if that's what wanted (I'm fairly impartial on this
> >> specific issue).
> >
> > I'm giving some ideas how to possible handle this situation:
> >
> > 1. do not fill btime it at all when it is not available (remove btime
> >    altogether - the case like you wrote above)
> 
> This would be the most semantically correct option, but would break at
> least 1 script/program/use case.
> 
> > 2. when userspace ask both ptime and btime, then do not fill btime
> >    (remove btime altogether - but only for that new case)
> 
> This probably is the best compromise.
> 
> > 3. fill btime with ptime value, but add a new output flag indicating that
> >    the btime is not present at all and instead kernel filled ptime value
> >    into the statx btime field
> 
> I don't really like this, it adds complexity and uses memory/1 flag big
> for a single specific field, IMO it's not worth it.
> 
> > 4. let statx btime as currently is, and add two new statx fields:
> >    immutable_btime and ptime. immutable_btime would be filled only if the
> >    fs supports real btime (so not for ntfs/extfat crtime) and ptime would
> >    be what is currently in RFC
> 
> I think this is also too complex.
> 
> > Ideas 2. 3. and 4. should be fully backward compatible as it would
> > affect statx output only when called with new flags.
> 
> Then 2. is probably the best way to go forward (maybe I'll include it in
> some way in v5),

My preference is 1. or 2. Just wanted to give more alternative
solutions.

> but I think we should let each filesystem maintainer
> decide if they think their users want to have statx report their own
> crtime as btime, ptime or both (native linux ones would of course
> report btime as btime and ptime as ptime).

statx syscall API is or rather should not be filesystem specific.
If every filesystem decides to fill members differently then how could
somebody write reasonable userspasce application? It would contain lot
of spaghetti code like this:

  statx(...buf...);
  if (fs == fs_type1) {
    process_buf_for_type1(buf);
  } else if (fs == fs_type2) {
    process_buf_for_type2(buf);
  } else if ...

And such thing is not API anymore.

If every filesystem decides on its own how it fills, then it would not
be able to write "rsync"-like backup or forensic tool to copy data to
some other storage (does not have to be fs) or even to different
filesystem on linux.

Things for which filesystems could decide how to handle are private fs
ioctl calls which are specific for individual filesystems.

> Thanks,
> koraynilay
> 
> >> Thanks,
> >> koraynilay
> >> 
> >> >
> >> > Pali
> 
> 
