Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795014969;
	b=1MztOJome2HG7D4DQVb5U9xp7r82vf3YZkcaO4kdMFuJxDPy+56ki+prBeHSPh8b4vVM
	 OeppxtiDiTyLfbVMEOQ5wMN02ZM+/Vu8VIA6UDq+RfEB0EvGaLWQKyjpRHLt6DdQuXAkX
	 musel8sBhchnv4GnR4PgZCDvSU5KgWjIdAEdrbpyi5BysQOGAunybY7ShgDoNCJx4GDGk
	 u2m1oJmJ6XsIGhTrPwQ1XoAYFlZn2el+M/SkgMuoeAQHtcqGj3CFTdle/zVfwqKfjlp1U
	 3XVVdyTrQfTfAf8RtpjWEcGzZUhVG9Q8Ztlm0qvi68v6U9JsTxNbm5cLa/E4uw6xEnw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795014969;
	h=Received:DKIM-Signature:Received:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:
	 Content-Transfer-Encoding:In-Reply-To:User-Agent;
	bh=VJRW+Ov1+hJWYf0GjjALdvkeKgyKhKIHCpws0o2fknE=;
	b=JjmTaWPzzZRSkdbhDvyRrNGHMWHvq6Cm9QAAivPz214NS+FrGPckFyVXks961ayY8GB8
	 w89z+FLjIHnqDqMuVmLkD3sDcd0Q0jh0dhHcqU52NOIOW5Fj/R3Hafq2xj8wxEASNs/KI
	 PEkI53FB7q/RkS3P255xUurhQJYjvqncsmSXxKO76SLPoM86V5peiB6CwHZ7u3voq2Uw3
	 muS0cGrDK/fUPfTnba+s4pMBZ3sAhwlbMFwM1hxaaoR0ZXa5bhvM7+jKeXNavauVymCgD
	 h+u6VMUTMMX03pHpG34A+ACEoIRxmEGZR2xOHbSjvlJ66ZtINbi5R5XzkttrCI/88tw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=TSlE7NJ2;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 98318606A31C;
	Wed, 18 Nov 2026 15:16:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=TSlE7NJ2
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C1D381F000C5;
	Wed, 18 Nov 2026 15:16:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795014969;
	bh=VJRW+Ov1+hJWYf0GjjALdvkeKgyKhKIHCpws0o2fknE=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=TSlE7NJ24ZHrQjqby7BRumprQ+X4+8LqupeU9Ic0A3522Ds17DPzXVFZwe0JBd6ho
	 GubLLYFIVNsVAPkFJEvH648kigG7kxnWoxItJWVuGvXDtAx4ld9RpbXs2YF/i/pHvg
	 IoJDOWDprbfsVrCrmYBi1JtGbscpSjFHgPu7D9ywJ1hYx1lAHMMhOR3mSl4KulHKpe
	 fhpajsplHwzdx8QTl+uVQSdbOq7HlfNFgYkCBr2s9W1RH2pLT9VZRBVaMQu/2EN3Lh
	 S10sgG+OG9bMfh1RookXtJuizdsgEup+XRBW62lyyeePfaTh9PHAuvEFSXv7+XdBtx
	 FZ53ZvVrlCnDQ==
Received: by pali.im (Postfix)
	id 9787F846; Wed, 18 Nov 2026 16:16:05 +0100 (CET)
Date: Wed, 18 Nov 2026 16:16:05 +0100
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
Message-ID: <20261118151605.lqtn5fz423kuswk5@pali>
References: <20261115180343.576773-1-koray.fra@gmail.com>
 <20261118142613.be3r3s6kobkkxnz4@pali>
 <DMYFBDIV4Y08.35ZKR5G86U1H7@gmail.com>
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
In-Reply-To: <DMYFBDIV4Y08.35ZKR5G86U1H7@gmail.com>
User-Agent: NeoMutt/20180716

On Wednesday 18 November 2026 15:58:02 koraynilay wrote:
> On Wed Nov 18, 2026 at 3:26 PM CET, Pali Rohár wrote:
> > Hello,
> >
> > I have just one issue with the userspace API. It does not allow me to
> > figure out what is the source of statx btime field. If it is fs ptime or
> > fs btime because this RFC implementation is mixing both fs ptime and
> > fs btime into the statx btime field.
> >
> > I have feeling that this is quite a mess in API and I would like to see
> > a clear distinguish between btime and ptime in the API, like there is a
> > difference in the fs storage.
> >
> > If the btime is used for forensic analysis then somehow I would expect
> > that the statx would not report / not fill changeable ptime value into
> > the statx btime.
> 
> Hi, for native linux filesystems it will report ptime as PTIME and btime
> as BTIME (also semnatically).

That is fine.

> for the windows-like ones that only have
> ptime (semantically) I think it's reasonable to not expect btime to be
> immutable, since they are meant to be used with other OSs who lack btime
> semantics.

The problem is here that the RFC statx API does not provide this
information that the fs lacks btime semantics and instead it fills
non-immutable ptime value there.

I'm pointing only about this inconsistency.

> > It would be really helpful if the statx API on inode can differ between:
> >
> > 1. btime is present and its value is ..., ptime is not supported
> > 2. btime is not supported, ptime is set to value ...
> > 3. btime is present and its value is ..., ptime is set to value ...
> > 4. both btime and ptime are not supported
> >
> > This should cover all cases of different filesystems and also allows
> > userspace to do proper backup of both ptime and btime fields (if it want
> > to do forensic analysis or anything else).
> 
> These should already all be covered by STATX_BTIME/PTIME and their
> fields in struct statx, the only problems are windows-like filesystems,
> which IMO shuold be handled as mentioned above.

Exactly, I pointed out about these problems. I somehow expect that the
new API would be generic and uniform across filesystem. IMHO it does not
matter if the filesystem is windows-like or not (there are also FreeBSD
fs and also others which allows to modify that time). So better
description is fs belongs to category 2. from my above description.

> Of course, as in the other discussion, I'm open to changing ptime
> NTFS/exFAT/... support to remove btime altogether and only use ptime for
> their own crtime if that's what wanted (I'm fairly impartial on this
> specific issue).

I'm giving some ideas how to possible handle this situation:

1. do not fill btime it at all when it is not available (remove btime
   altogether - the case like you wrote above)

2. when userspace ask both ptime and btime, then do not fill btime
   (remove btime altogether - but only for that new case)

3. fill btime with ptime value, but add a new output flag indicating that
   the btime is not present at all and instead kernel filled ptime value
   into the statx btime field

4. let statx btime as currently is, and add two new statx fields:
   immutable_btime and ptime. immutable_btime would be filled only if the
   fs supports real btime (so not for ntfs/extfat crtime) and ptime would
   be what is currently in RFC

Ideas 2. 3. and 4. should be fully backward compatible as it would
affect statx output only when called with new flags.

> Thanks,
> koraynilay
> 
> >
> > Pali
