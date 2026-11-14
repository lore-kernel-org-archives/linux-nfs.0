Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794656933;
	b=1Ehk6PdXD6GHG9ZvlhbR4N8tyTtWmlGNLkXEUKjVSZNayXailMDEnMa/5H5TeemLx1lP
	 ScNkVm9PcFOw6d6gnqJspe9uNBCf+5P5puEFqUCXY2BIY/jbyye/GzinI6m7sCsK4vp+L
	 gVe4yGWjRj1eu8R//9kFV8qS5/vCaFqhIp2j1KOIDu6POB8Ak3KkL4gCosHDnFlof9Evl
	 j4On4mF45AOXWHn0SXmRcIXyWk9rBemhTX5JHpL5U0HbMy3Cp5iSFX5PgjiZ/BgArnH5E
	 YvWLIzWXcoSvUwle5U7DYiDtA1zRxPKnO1aAYW9Ec7d3kEIayefwZP3ey8Kaqi6z2GQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794656933;
	h=Received:DKIM-Signature:Message-ID:Subject:From:To:Cc:Date:
	 In-Reply-To:References:Autocrypt:Content-Type:
	 Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=ffBvyljZwir56F/o+pX+z6WA5o/3P/Rv7qQXfu5q+ms=;
	b=x6nzBUQkIlwCq0PwzMJL+tILvTwP+7NwiQEQx2EkY0KimD9aKxIY3FupnBwomfMvc4CS
	 P6B95NcPbmCkCmbWwv4IPI3k+i0HUY6J6kocvsLUrnNEh67osCTtLALxc8cljDnAaplsc
	 1OoD6/iwfLFKpnwZV2kGYK7feS2WSR4fg/UsDJe9/0etSlh47twSWKZVq9UO4v2yFhIyw
	 bvj+WZLGPPPY2RKxTnn/jctZ5e/F4qVL0M289bueCQHNi1qQR9FOVgPS8jpHLr1EOe75i
	 vsDE4lczS7D6QAy1Bgm8iGb1BOs+r3cnyiKd4hnCxpFIIaLScV0nXNXAvi6+VMQRVDg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ecu0Cg2y;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B53E5606A323;
	Sat, 14 Nov 2026 11:48:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ecu0Cg2y
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6A2961F000C4;
	Sat, 14 Nov 2026 11:48:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794656933;
	bh=ffBvyljZwir56F/o+pX+z6WA5o/3P/Rv7qQXfu5q+ms=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=ecu0Cg2ydLJNywqcQhRPjlnB40j5NeGKQ9VNL1F8kEZFKiXUtCAXQGGbnNcEX3ZG6
	 8+CGfQlW44Kzg3dRkViDeEbtFbA+/ftciETZSczaTUFrgj9on5U7wT1hyJeeTp/vWO
	 np2lWLBh4vX9pi14FkLoO6RhtZ1Ga9VQeNIVNsugtaZdgbt733hj6CJ2yh8s2ZAors
	 LqjPkzRumRgzhCS8GUxEC1lntZTgZlNqQcIdKlaDLczRtmhg1+RR2VXeORTfb64YKj
	 RllChRKY8EXylk6wmxkycSd8B3tUwzNpVYXnQmcO6JJaEC/FwrK9bTs9vDrnEUKh20
	 h13rzWPGC/mIQ==
Message-ID: <41522fcf40be21bb11409189204bb62ffac47ae4.camel@kernel.org>
Subject: Re: nfsd: delegated timestamps get written to frozen filesystems
From: Jeff Layton <jlayton@kernel.org>
To: Christian Brauner <brauner@kernel.org>, Chuck Lever <cel@kernel.org>
Cc: NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, Jan Kara
 <jack@suse.cz>, 	linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
	linux-kernel@vger.kernel.org
Date: Sat, 14 Nov 2026 06:48:50 -0500
In-Reply-To: <20261114-abdrehen-mahnwache-farbpalette-9c31774145cc@brauner>
References: <20261114-abdrehen-mahnwache-farbpalette-9c31774145cc@brauner>
Autocrypt: addr=jlayton@kernel.org; prefer-encrypt=mutual;
 keydata=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
 QZIQXVeAA+smfTT0tDrisj1U5x6ZB9b3nBg65kc=
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.62.1 (3.62.1-1.fc45) 
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0

On Sat, 2026-11-14 at 10:35 +0100, Christian Brauner wrote:
> Hey,
>=20
> I'm working on a freeze protection series. This fell out of it and I
> can't just fix it myself.
>=20
> Can I leave you with fixing this?
>=20

Yes. I'm currently working on a patchset to rework how delegated
timestamps are handled. I'll plan to roll some freeze protection into
the series (or in a trailing one if that's more suitable). No promises
on the timeframe though.

Cheers!
Jeff

> cb_getattr_update_times() and nfsd_update_cmtime_attr() call
> notify_change() under inode_lock() but nothing takes freeze protection
> for the export. So they modify filesystems that are frozen. On ext4 that
> trips the WARN_ON() in ext4_journal_check_start().
>=20
> Reproduced on v7.4-rc1 with two NFSv4.2 clients, the second one in its
> own network namespace:
>=20
> - client A opens a file O_RDWR and gets a write delegation
> - the export gets frozen
> - client A writes 64k into the file and keeps it open, so the data
>   stays in its page cache
> - client B runs stat on the file
>=20
> nfsd sends CB_GETATTR to client A, sees the file was modified and
> updates the timestamps on the frozen filesystem:
>=20
>   WARNING: fs/ext4/ext4_jbd2.c:90 at ext4_journal_check_start+0x1f6/0x2d0=
, CPU#0: nfsd/444
>   Call Trace:
>    __ext4_journal_start_sb+0x7a/0x470
>    ext4_dirty_inode+0xa1/0x120
>    __mark_inode_dirty+0x154/0x1110
>    ext4_setattr+0x2bd/0x24e0
>    notify_change+0x81c/0xee0
>    nfsd4_deleg_getattr_conflict+0x7f0/0x1370
>    nfsd4_encode_fattr4+0x3c3/0x1290
>    nfsd4_encode_getattr+0xd1/0x1d0
>    nfsd4_encode_operation+0x285/0xf80
>    nfsd4_proc_compound+0x5e2/0x23c0
>    nfsd_dispatch+0x26d/0x870
>    svc_process_common+0xfed/0x19a0
>    svc_process+0x600/0xb90
>    svc_recv+0x1969/0x2650
>    nfsd+0x2f8/0xcd0
>=20
> The inode's mtime and ctime on the server change while it is frozen.
> That was with delegated timestamps turned off, the
> cb_getattr_update_times() path with them on is the same.
>=20
> I think nfsd_update_cmtime_attr() has the same problem
> but I haven't reproduced that variant. It runs from:
>=20
> - nfsd4_copy(), nfsd4_do_async_copy(), nfsd4_clone()
> - nfsd4_finalize_deleg_timestamps() <- nfs4_unlock_deleg_lease() <-
>   destroy_unhashed_deleg(), which is reached from DELEGRETURN,
>   nfs4_open_delegation(), the laundromat via revoke_delegation(), admin
>   revocation, client teardown and nfs4_state_shutdown_net()
>=20
> mnt_want_write_file() on the delegation's file before inode_lock() would
> do for GETATTR, COPY, CLONE and DELEGRETURN.
>=20
> But the laundromat and nfs4_state_shutdown_net() shouldn't block on a
> frozen export, I think? Lease expiry for the whole net would stall and
> nfsd shutdown would hang until the thaw. Those probably want
> sb_start_write_trylock() and skip the timestamp update while frozen.
>=20
> The OPEN with truncate path in nfsd4_truncate() had the same problem.
> I've got a fix for that one in my series.
>=20
> This goes back to 7e8ae8486e44 ("fs/nfsd: fix update of inode attrs in
> CB_GETATTR") and e5e9b24ab8fa ("nfsd: freeze c/mtime updates with
> outstanding WRITE_ATTRS delegation").

--=20
Jeff Layton <jlayton@kernel.org>
