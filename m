Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 968093CF022;
	Sun, 11 Oct 2026 12:07:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791720464; cv=none; b=Vjs+aTWr/TzvFSCQc+yaku9feYiV+qOlc0Swf6C9Unq9Bi9w1lmzlyVI+/tyD4xfhM84scveSeCXDapedrIMS7qlaseoOxaTrKcGPlyTy6SLku2ZQhyWfUzl6RNDIBZlVle/Gyu7L6bYcNIlchFhd+cZ4siDuaJ9xQfbssl5NDw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791720464; c=relaxed/simple;
	bh=7N2q9l5nBXyZzPAwAnlgHaJXYTaIxTpsZkpSTN5koro=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=FkwGhx3rBVc2aq1M3j9pHK8Ngilh9ib8rYNMmsyVwpkh/5RCrl0KnN6XsQWtO1Bm+IaHMynKc4MljfunxnVklXdqjuV0eI/Wm8lCA/Cr3ceaRjvViyb30gBluX4BdCKinmNen09+pQ9srNLiPfqk7Ry4wdmTW4JQ9CBnyNVJRfU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Wy3JL97O; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Wy3JL97O"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8B60C1F0089B;
	Sun, 11 Oct 2026 12:07:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791720459;
	bh=1/BM11TaH1DkAq8nCc5GVlPtgZDkWqiFYSD/goVwjiI=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=Wy3JL97OVL1UrMF5h243ciRiSvtZzn3Kfy7DPC0jPU3sgCSjJDA1zio3xOlx2gmDb
	 WMQvLH9jhis3283wxN5wkxbbK/EcOArvIsu+GfHJ9v5P9uSeAlzaBTWXrQW+Ktdpyo
	 kdUpNZjQ8TRhISq33VOUk2PPv1EqfDQOPNVdZoy8CQT2QNn7nombG2VtmTW+Clif5M
	 s2CKowx8xn0vZ04u2p43d/noAn3vIMfRh/e77dhK7KsZsI3kfxYZK3R7g5t3MLVW2R
	 oaBnXRH4AOjDvAZHdIWW4zv+qLEcJU98++gAElxvv5kE6k+8QGpsaSyvytYTPnQaB0
	 as1sg0/3JdzPQ==
Message-ID: <1eca2a80d8e90375682adeadcaf8b007ae2cc720.camel@kernel.org>
Subject: Re: [REGRESSION] 7.2.4: nfsd sends CB_OFFLOAD with all-zero
 stateid, async NFSv4.2 COPY never completes
From: Jeff Layton <jlayton@kernel.org>
To: Greg KH <gregkh@linuxfoundation.org>, Lubos Rendek <l.rendek@proxmox.com>
Cc: stable@vger.kernel.org, regressions@lists.linux.dev, Chuck Lever
	 <cel@kernel.org>, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Sun, 11 Oct 2026 08:07:36 -0400
In-Reply-To: <2026101121-staining-scheme-358a@gregkh>
References: <7cc824c4-632d-49df-ae5e-cfcbb5bf76ad@proxmox.com>
	 <2026101121-staining-scheme-358a@gregkh>
Autocrypt: addr=jlayton@kernel.org; prefer-encrypt=mutual;
 keydata=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
 QZIQXVeAA+smfTT0tDrisj1U5x6ZB9b3nBg65kc=
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-2.fc44) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Sun, 2026-10-11 at 09:19 +0200, Greg KH wrote:
> On Sun, Oct 11, 2026 at 06:30:40AM +1100, Lubos Rendek wrote:
> > Since 7.2.4, an NFSv4.2 server-side COPY between two exports of a Linux
> > NFS server never completes, because nfsd sends CB_OFFLOAD with an
> > all-zero stateid.
>=20
> Can you just use git bisect to determine the offending commit?
>=20
> And is this also the same for 7.3-rc?
>=20
>=20

I took a look: I believe this is a bug in 14b978e8d05c ("nfsd: fix
stale s2s_cp_stateids IDR entry for async COPY"), which is d0beaee498e1
in mainline.

In v7.3, this bug gets fixed by f307b4f7ed17 ("nfsd: split nfsd4_copy
into transient and durable async copy objects"), which was part of the
refactor of the async COPY code.

We should probably just take Lubos' two-line fix as a separate one-off
patch for stable. Backporting the COPY code refactor is too risky IMO.

Clanker analysis follows if you're interested. I think it's largely
correct:

-----------------8<-----------------------

=E2=97=86 Diagnosis confirmed: the report is correct, and this is a stable-=
only regression from an
  incomplete backport.

  Root cause is the order of dup_copy_fields() vs nfs4_init_copy_state() in=
 nfsd4_copy():

  =E2=80=A2 result points at the transient &u->copy.cp_res.
  =E2=80=A2 dup_copy_fields() copies cp_res (including cb_stateid) from tra=
nsient to async_copy.
  =E2=80=A2 nfsd4_send_cb_offload() builds CB_OFFLOAD from async_copy->cp_r=
es.

  Pre-d0beaee498e1, mainline did init =E2=86=92 write result->cb_stateid =
=E2=86=92 dup_copy_fields(), so both the
  COPY reply and async_copy->cp_res.cb_stateid got the stateid. But the s2s=
_cp_stateids IDR stored a
  pointer to &u->copy.cp_stateid, which is transient COMPOUND buffer memory=
.

  d0beaee498e1 ("nfsd: fix stale s2s_cp_stateids IDR entry for async COPY",=
 stable 14b978e8d05c)
  fixed the IDR lifetime by doing dup_copy_fields() first, then
  nfs4_init_copy_state(nn, async_copy), then writing only result->cb_statei=
d. That leaves
  async_copy->cp_res.cb_stateid zero, because the dup already happened. Res=
ult: COPY reply has a
  valid stateid, CB_OFFLOAD has all-zero, client can't match it in nfs42_pr=
oc_copy and hangs. This
  matches your packet table exactly.

  Mainline is fixed by f307b4f7ed17 ("nfsd: split nfsd4_copy into transient=
 and durable async copy
  objects"), which moves the durable stateid out of the duplicated struct s=
o it can safely do init =E2=86=92
  write cb_stateid =E2=86=92 dup again. Current code in fs/nfsd/nfs4proc.c:=
2242 has the explicit comment
  "dup after writing cb_stateid; duplicating first would leave the callback=
 stateid zeroed." I
  verified the callback path in fs/nfsd/nfs4proc.c:2104 copies from cp_copy=
.cp_res, and
  dup_copy_fields in fs/nfsd/nfs4proc.c:2051 copies cp_res.

  Your minimal stable fix is the right shape for stable. A plain reorder wo=
n't work on the old
  layout because dup_copy_fields() also copies cp_stateid, so init-then-dup=
 would clobber
  async_copy->cp_stateid with the transient's zero value. Copying the new s=
tateid into both
  result->cb_stateid and async_copy->cp_res.cb_stateid after init preserves=
 the IDR fix and fixes
  the callback. The alternative is backporting the full restructuring serie=
s (f307b4f7ed17,
  80c376183411, etc.), which is heavier for stable.

  #regzbot introduced: v7.2.3..v7.2.4 looks correct. The 6.12 sync-copy obs=
ervation is expected:
  that branch largely forces COPY synchronous, so it doesn't reach the asyn=
c/CB_OFFLOAD path.

  I did not run the reproducer or inspect a 7.2.y tree locally; verificatio=
n was by reading mainline
  and the d0beaee498e1 before/after versions in this checkout.

--=20
Jeff Layton <jlayton@kernel.org>
