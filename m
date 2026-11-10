Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794324902;
	b=yePmPjqXw5zdRGgr5YpE+JyigiMT10MSvUTjzGxlMoH33LhPiltQzGdy+6oL5we+03qw
	 b6y6lAD+GcKYdY7FDOUqNvkg1dCNfiQHiibkLX4ksyvUxEMU1LCjcq/HLa04ZaQ0XtAFz
	 FvGzjf0oNeQRXQ894G7smeHr84mg9l++Nz9D6QTaNg6N1pSJMffGHiCA39EINI7PgXPkR
	 eUMhJsR0OQVoTALKKUBEWDMiDnsiAZtX8n4eo7lLs4BpjeVFQOc6XAREcFp+SbfT/itOI
	 ZsJLxBEP268UKBGbxDZ1un2TaCB+qQMYBSdICsgbcPwscj5DM30OY9pOasLvc854xwQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794324902;
	h=Received:DKIM-Signature:Message-ID:Subject:From:To:Cc:Date:
	 In-Reply-To:References:Autocrypt:Content-Type:
	 Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=yiQ/WykeEs4pSbStHIwElRZluiLMvCD6UkzGdVndLK4=;
	b=xyfhf5icwmaSK5WaC6C3J4lVmPfh9iPmcAJbU3eO9Yu47jMtMGIWTzcPsHNCgZb/Rn2s
	 w4SQvt+0C6CkarH0jvsOAv1bCGJnMfcEz0znBu4P2H4URbRTWYbHPV+4ZGpnBUCgXRo+o
	 WABwYzD9zxgWeWZ+7pziQLT5RnjV5zVzjapxh/XnXUAuwMGGC2X9uHGTZe+TK8YAE/gtN
	 gc5FQD4npqDYEuGuMrLOsVgtS3XMEAzYYu8F4iqKjUVQ1K4DEc5xDJfuAyo6F99vSe3TC
	 ktIThsLZYrOVHOf7TcGunBpagrPKcIhAQjxjFSOI6HH44yH2yifPMY0KB73f4Mb6MRw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=NV7TCcUp;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 782C160A2616;
	Tue, 10 Nov 2026 15:35:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=NV7TCcUp
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 25CEE1F0089F;
	Tue, 10 Nov 2026 15:35:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794324902;
	bh=yiQ/WykeEs4pSbStHIwElRZluiLMvCD6UkzGdVndLK4=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=NV7TCcUpx3FcXZJiHKoy1IDgR/Y9FUC5E0C99Gj5KhyLKjUKto3Ayg3flRr55Q9Hx
	 lddPB2gIJhpY5qtBpquO6dVP4k1+l/bSDYg3lkc6HKqKTo2lQh3mFg7+JIUM8pn5wK
	 vkye4Y1sp2mEEC4l4vioO/rsXncyZFp9kABQb65YraXN7YNiuYbEYgMF84bpqjQ7aL
	 F9crdjuDM2uL/gW2dRHIXKNI57eVa+efL/mzzKA9gb6MELR2T5UosNm1UnMAjPxLQ7
	 7B/rycOrgEVVCOP4Xsl37d+hDqcewvWxkBh8tEZlTM7U4Is+K4A9UJ/rw/24netUNT
	 12LNg4IrwkYsA==
Message-ID: <7ef1bdb584ddeb5a383f8c2f9fef47ff3fba931f.camel@kernel.org>
Subject: Re: [PATCH v3 0/8] nfsd: more delegated timestamp fixes
From: Jeff Layton <jlayton@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, Olga
 Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom
 Talpey <tom@talpey.com>, Alexander Viro	 <viro@zeniv.linux.org.uk>,
 Christian Brauner <brauner@kernel.org>, Jan Kara	 <jack@suse.cz>
Cc: Tom Haynes <loghyr@gmail.com>, linux-nfs@vger.kernel.org, 
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Date: Tue, 10 Nov 2026 10:34:50 -0500
In-Reply-To: <20261109-deleg-cb-getattr-times-v3-0-710c7244a6ea@kernel.org>
References: <20261109-deleg-cb-getattr-times-v3-0-710c7244a6ea@kernel.org>
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

On Mon, 2026-11-09 at 15:36 -0500, Jeff Layton wrote:
> This version fixes the existing patches and adds some new ones to fix
> problems that agentic review spotted. Note that there is also a
> companion client-side series that fixes some related issues.
>=20
> The catch with this version is that we need a fix to
> inode_set_ctime_deleg(), and that lives in fs/inode.c. We'll either need
> to get Christian to take that one or get his blessing to merge it via
> the nfsd tree. It's a pretty small patch, so the latter might be OK.
>=20
> Original cover letter follows:
>=20
> Chuck recently added a new DELEG27 pynfs test that fails against nfsd.
> These patches fix the behavior of delegated timestamps (again), such
> that DELEG27 now passes.
>=20
> I also ran some tests with the git regression testsuite which turns out
> to be very sensitive to timestamp bugs, and that turned up a few more
> server-side bugs.
>=20
> Signed-off-by: Jeff Layton <jlayton@kernel.org>
> ---
> Changes in v3:
> - "Honor delegated timestamps when change and size match":
>   - record applied times from SETATTR too, so a stale CB_GETATTR reply
>     can't move them backward
>   - record ctime from the inode; atime/mtime from the untruncated values
>   - move the vet/record prototypes to nfs4ctl.h
> - "don't stamp over an applied delegated mtime at DELEGRETURN":
>   - share the vetting between SETATTR and CB_GETATTR
>   - set dl_setattr only after the holder's mtime is applied
>   - test dl_setattr under inode_lock at DELEGRETURN
> - "don't vet delegated times against an exclusive-create verifier":
>   also set the floors for read timestamp delegations
> - "mark the delegation written on COPY/CLONE instead of stamping c/mtime"=
:
>   - look up the nfs4_file for every async COPY
>   - remove the now-unused nfsd_update_cmtime_attr()
> - New: fs: check a fine-grained time before clamping a delegated ctime
> - New: nfsd: check a fine-grained time before clamping a delegated mtime
> - New: nfsd: raise delegated time floors after a size-changing SETATTR
> - Kernel-doc, comment and commit message fixes
> - Link to v2: https://lore.kernel.org/r/20261106-deleg-cb-getattr-times-v=
2-0-8433618ab9a1@kernel.org
>=20
> Changes in v2:
> - "Honor delegated timestamps when change and size match" reworked:
>   - set ATTR_FORCE when applying the holder's times
>   - record applied times in dl_[amc]time; vet and record under inode_lock
>   - vet SETATTR's delegated times in nfsd_setattr() under inode_lock
>   - also mark file modified on a holder WRITE whose mtime didn't pass dl_=
mtime
>   - always report ncf_initial_cinfo as the change attr for timestamp dele=
gations
>   - catch the holder's own server-side changes (SETATTR, xattrs, etc.)
>     via a change attribute saved at grant
>   - log, rather than fail the GETATTR, if applying the holder's times fai=
ls
> - New: don't stamp over an applied delegated mtime at DELEGRETURN
> - New: don't vet delegated times against an exclusive-create verifier
> - New: mark the delegation written on COPY/CLONE instead of stamping c/mt=
ime
> - Link to v1: https://lore.kernel.org/r/20261102-deleg-cb-getattr-times-v=
1-0-ca0326d88623@kernel.org
>=20
> ---
> Jeff Layton (8):
>       nfsd: Report vetted delegated timestamps in GETATTR replies
>       nfsd: Honor delegated timestamps when change and size match
>       nfsd: don't stamp over an applied delegated mtime at DELEGRETURN
>       nfsd: don't vet delegated times against an exclusive-create verifie=
r
>       nfsd: mark the delegation written on COPY/CLONE instead of stamping=
 c/mtime
>       fs: check a fine-grained time before clamping a delegated ctime
>       nfsd: check a fine-grained time before clamping a delegated mtime
>       nfsd: raise delegated time floors after a size-changing SETATTR
>=20
>  fs/inode.c             |  16 ++-
>  fs/nfsd/nfs4callback.c |   2 +-
>  fs/nfsd/nfs4ctl.h      |  15 +++
>  fs/nfsd/nfs4proc.c     | 101 +++++++++--------
>  fs/nfsd/nfs4state.c    | 292 +++++++++++++++++++++++++++++++++++++------=
------
>  fs/nfsd/nfs4xdr.c      |  10 +-
>  fs/nfsd/state.h        |   6 +-
>  fs/nfsd/vfs.c          |   6 +
>  fs/nfsd/vfs.h          |   4 +
>  fs/nfsd/xdr4.h         |   9 +-
>  10 files changed, 325 insertions(+), 136 deletions(-)
> ---
> base-commit: d692f252c52b8d1b4bc7481554f314df31ed8249
> change-id: 20261102-deleg-cb-getattr-times-8aa926029b16
>=20
> Best regards,

Sashiko found some other problems with this. At this point, I'm fairly
convinced that we need to just redesign how all of this works to be
less racy. I'm still working out the details, but hold off on reviewing
or merging this series for now.

Thanks,
--=20
Jeff Layton <jlayton@kernel.org>
