Received: from mail-yx1-f47.google.com (mail-yx1-f47.google.com [74.125.224.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 99B6F4F3907
	for <linux-nfs@vger.kernel.org>; Mon, 12 Oct 2026 20:44:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=74.125.224.47
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791837846; cv=pass; b=NH3ycj33dzBSnMjLAEhhGEcudn5ye3O1oyaGcuZKaAJh+TedZwDUzQ+L1jLG5z0TI23S557wFPQt4Guln0MHDg3XAvwTQa8BFwdcydPkTLvtu22S4DiRgO0xpxaUB13DjmHxhgoP9U6kYTflqtGSJhqc08ro6E7CaZPN7kt1Ax4=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791837846; c=relaxed/simple;
	bh=QjRpgYjJa+kkNqeLuccwGd0OHr83JO9DtZuhqfen5Hg=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=MUPDOQba32atD9fKUMl1mJQZmdf/NeIvfyGFttZW/13SOOAINiDpBEo8uu/qYHNF4e6woVbyeQgUliqopw2J9Xp6d2+crLtoz07j/kN6PDvqmKLffBhoYO2/IBSNYjBr2c8nCver5yST2U26f9U1JVLwAuFL6oPhiNvYMvwxaTQ=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com; spf=pass smtp.mailfrom=purestorage.com; dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.b=D7u/48+B; arc=pass smtp.client-ip=74.125.224.47
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=purestorage.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.b="D7u/48+B"
Received: by mail-yx1-f47.google.com with SMTP id 956f58d0204a3-6768ced47aeso2018814d50.1
        for <linux-nfs@vger.kernel.org>; Mon, 12 Oct 2026 13:44:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1791837842; cv=none;
        d=google.com; s=arc-20260327;
        b=D5Hrj9XlhmJQyO8SpMoVgxYCShPpGjAtXT+Y8Fqzz8bkaZ9AGs35FeAMwLTNUdmo5N
         ylgIIMECIMuQXpLEHMH0GK5CdSL+j6WgO5XWIfICJDxU8OCr9YjUK4Xk56o/XpK3Ughj
         iZmhFy94iY8hjNKR4L2tsTBZkbDS62+DssjYv2SI4QKhFe+TpElmKE96UjCnLT3jBbHZ
         x65uqvHie8vjcmRkTdIkdj9Ixsmtjysr6PtATLE382TmQi6mlIuZXk6lclURRQTm7hCQ
         SjhNEsdV5TRYk+QWJIMH2ZqcblFp1BWrRQxzstSRGx5HzBzpWmle4pu5rlVPA0rMr1Bx
         vCGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=JSUNRjKa8PC9uvL/lbt0WMhZ7tNYQSXReFk4D0bdIN0=;
        fh=mGQRXyb+myJ5jDfAi9/UQgjFZe9CzgR4a4uKHIj91HE=;
        b=BkJhPhIXEmu/KWUng9MP7TwiLyokdrUiZplam3HD7GFxe4GedoSyZkvoB/7lzhvsNH
         sIi17YgQB11NKdwQhYJqT0aPHz94DIgRO8una16NhzNfBBZjp7yu7OnaHV8+olAVhndQ
         gGZmMLuUPrJrB7Jt+Jyo3y5IPbtldHLqUfKoX5aUpwB0bxf81KGKpZIsMyt6o6PTVTgL
         9zr8dQDqOgyMyPSt7qemaLwg02lcJ9p3wdg72R3i0sBqjAZKd/OXhxyV5mmTbTg7TCJY
         D06Q1+DQB30kdeVR3Blx6oJjr+cEikGB/RmIgz5qiTCXRO+QmkSlysE40rJRiYcLca5V
         W/3Q==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=everpuredata.com; s=google; t=1791837842; x=1792442642; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=JSUNRjKa8PC9uvL/lbt0WMhZ7tNYQSXReFk4D0bdIN0=;
        b=D7u/48+BkhquwqL83JibC6JgxsN8Kx3M8KTl/EaWI0hClIeSKBnGxRAjYIKcIaerP1
         AhCuc8cIBuUPAxBh7w+Bs589EVhpMlgFN87LPvmI2TGtD+Obrkvk/F9SnK2bk0bYrb31
         35plovSOrFZfREygGZ/UHXx9VgASlDVumkHxFw1+JmmX9M8FJPA2pBfL2yZgSxoE5wHK
         lOZj/LZASEkfcOshiZL552Iby9uW96zVEbXodU4Z8ZgEiDaBpCyT2QBs/Gbk+A70BYzj
         fK8SRtswc3xcyuBcQ81gMnFr3khxkPj1eu3Hk1rYWLWcR+qRbaVRX/OcvOe41QX+0CUA
         hubA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791837842; x=1792442642;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=JSUNRjKa8PC9uvL/lbt0WMhZ7tNYQSXReFk4D0bdIN0=;
        b=Ov0S5OFVhPZLh4KcPgAQRsd7xMxWBgKzXQxeW0aTOMv/3kF68wT2DulRWgdzRIAgpo
         s9ILGnKGpJl1FNk3LQ3GLDkWUvifvqhf6ox4DHMfJ6IsXupCBbcikvfU9dr12NW4tFJz
         A5tm/54cNWI3VV8U6Mhxe3PJRR6BHnYxaT05I1LEtzQ83GfYMqz/R9rAUXcb2ej6SoMX
         E3bvwrzp3VhnV9e1U89FevtrnivgAoj/fMnk/kzJbw1lNUis+fR0Hu7yGTAC+7543T8L
         NQ6+oC9yhZlbR2zN4FXIqgmFmGfIAej7/ZHMPOXSadjmDpVbv+I3gPZbBD1dKk6tyfAz
         XjjA==
X-Gm-Message-State: AFq9FYKVR3NHDckb79mmUXQ9zqBH1OqNVCwgMaIS0G/nT2bslnRAJMph
	n9cObSRk0sbXVL5z5BRaZI41pZRE0zKDCM0/3pQfWWx5Ywjd7LbqnqV0v3fRAm92JSZYMO1jlmC
	AvLtjtyvKx28aHKECv/JgaxQa082suIZGguAT4v2aBg==
X-Gm-Gg: AYBFou3GzdCROJrACrytZ7m3TiKb/kKNXpp3SeaNc1sXNWKycKnTEPMmENAb0tLCUXm
	4RSZnq1RdqFqYNolrO9DL/AIsjkndPaOXc2BMDXil4dkCkJzOr4/DdWkPwZRtyWBu+V8FmSY3Bb
	oV6es/Trz1i16SKckz2jawf84OC/rRkJNubVTcwyWxHv9opNoRECRJFGJxQstqEhPMM2Tx7swOs
	DzZ+eKX12f4EuQpf8lJqU1REx7NAcAVSeddLVsjdFEgMplNC/QPMc5nBL74mt4jzb8Wv0z2g9Ip
	VW3qrLD01jBCGioKensHiY00RanKlDHgerhgOrCM+qWly6oC1JEZ2exAdjDwiHxhTQ==
X-Received: by 2002:a05:690e:4091:b0:677:cb45:a45e with SMTP id
 956f58d0204a3-67935edb58dmr4559555d50.6.1791837842225; Mon, 12 Oct 2026
 13:44:02 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20261008222843.63319-1-lubao@everpuredata.com>
 <20261008222843.63319-2-lubao@everpuredata.com> <6855034f0b219b0b8e6a6f47aef802cf2803e42b.camel@kernel.org>
In-Reply-To: <6855034f0b219b0b8e6a6f47aef802cf2803e42b.camel@kernel.org>
From: Lucheng Bao <lubao@everpuredata.com>
Date: Mon, 12 Oct 2026 13:43:49 -0700
X-Gm-Features: AclHuK_zSM-dUK2eIXZMsKsuxHoHvQIrPR1gRleHlxNa7Z9fN_xJLD3dP1iHjxA
Message-ID: <CAHPUM33UGE849kviu4cngY7SwscHrrf=qTqkp=8OLiTX9SCcBQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] NFSv4/pNFS: prevent i_size regression while
 layoutcommit is outstanding
To: Trond Myklebust <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org, Anna Schumaker <anna@kernel.org>, 
	linux-kernel@vger.kernel.org, tmenninger@everpuredata.com, 
	jcurley@everpuredata.com, stable@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, Oct 8, 2026 at 9:43=E2=80=AFPM Trond Myklebust <trondmy@kernel.org>=
 wrote:
>
> On Thu, 2026-10-08 at 22:28 +0000, Lucheng Bao wrote:
> > Commit ac46bd374c9a ("pNFS: Ensure we layoutcommit before
> > revalidating
> > attributes") replaced outstanding-layoutcommit attribute filtering
> > with
> > synchronization before explicit revalidation. For layouts requiring
> > LAYOUTCOMMIT, OPEN attributes can still shrink i_size before metadata
> > synchronization completes.
>
> The client can't police OPEN. It has no idea which file will be
> affected (particularly when doing an open-by-filename) so unlike the
> case of an explicit truncate() call, it can't serialise with the
> truncate.
> It is therefore up to the server to resolve any ambiguity, either by
> recalling or revoking the layout before allowing the OPEN truncate to
> proceed.
>

Thanks for the quick review. I think the OPEN-truncate is a different
scenario from the one this patch is targeting, and my changelog invited
that reading -- let me describe the actual race.

Agreed for a truncating OPEN (or a SETATTR size), that's a real size
change, the client can't serialise an open-by-name against it, and the
server has to recall or revoke conflicting layouts. This patch isn't
about that case and doesn't touch that path.

The race here involves no truncate and no second client. It's a single
client doing O_APPEND over an nconnect mount:

  1. the client WRITEs the appended data to the data server and it
     completes;
  2. the client arms LAYOUTCOMMIT -- the MDS does not know the new
     size yet;
  3. before that LAYOUTCOMMIT is processed, the client's own next OPEN
     carries a GETATTR, and the MDS answers it with the pre-commit size;
  4. the OPEN reply and the LAYOUTCOMMIT reply travel on different
     nconnect connections and are processed out of order, so the
     smaller, stale size is applied to i_size after the writes;
  5. the next O_APPEND then computes its offset from the regressed
     i_size and overwrites the previous append.

So the smaller size isn't a truncate, it's the MDS size legitimately
lagging until LAYOUTCOMMIT (RFC 8881 section 12.5.4 "It is important to
note that the level of synchronization is from the point of view of the
client that sent the LAYOUTCOMMIT. For file-based layouts, synchronization
of attributes between the metadata and storage devices, primarily the size
attribute, is required."). The check is in the generic size path and keys o=
nly
on whether this client has an outstanding LAYOUTCOMMIT for data it has
written but not yet committed.

This is the same protection the client already applies to buffered
writes via !nfs_have_writebacks(): don't let the server shrink i_size
below data the client has written but the server doesn't know about yet.
The only difference is the "server doesn't know yet" window. For plain
buffered I/O it's "dirty pages not yet sent"; for a layout requiring
LAYOUTCOMMIT it's "written to the data server, LAYOUTCOMMIT
outstanding." In fact, once the DS write completes, the pages are no
longer counted by nfs_have_writebacks(), yet the size still isn't known
to the MDS until the commit, that gap is exactly what this extends the
existing check to cover.

> >
> > Commit d8c951c313ed ("NFSv4.1: Don't trust attributes if a pNFS
> > LAYOUTCOMMIT is outstanding") moved LAYOUTCOMMIT post-op attribute
> > processing after cleanup, leaving another unprotected window after
> > NFS_INO_LAYOUTCOMMITTING is cleared.
>
> This is unrelated to the above problem, so fixes for this issue need to
> be in a separate patch.
>

Will fix in v2.

> >
> > Extend the existing writeback checks to reject smaller sizes while a
> > LAYOUTCOMMIT is pending or in flight, preserving size increases and
> > WCC
> > checks. Process the reply's attributes and establish their generation
> > barrier before cleanup removes that protection.
> >
> > Fixes: d8c951c313ed ("NFSv4.1: Don't trust attributes if a pNFS
> > LAYOUTCOMMIT is outstanding")
> > Fixes: ac46bd374c9a ("pNFS: Ensure we layoutcommit before
> > revalidating attributes")
> > Cc: stable@vger.kernel.org
> > Signed-off-by: Lucheng Bao <lubao@everpuredata.com>
> > ---
> >  fs/nfs/inode.c    | 8 ++++++--
> >  fs/nfs/nfs4proc.c | 2 +-
> >  2 files changed, 7 insertions(+), 3 deletions(-)
> >
> > diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> > index 3022454f7698..11432f521b04 100644
> > --- a/fs/nfs/inode.c
> > +++ b/fs/nfs/inode.c
> > @@ -1636,7 +1636,9 @@ static void nfs_wcc_update_inode(struct inode
> > *inode, struct nfs_fattr *fattr)
> >       if ((fattr->valid & NFS_ATTR_FATTR_PRESIZE)
> >                       && (fattr->valid & NFS_ATTR_FATTR_SIZE)
> >                       && i_size_read(inode) =3D=3D
> > nfs_size_to_loff_t(fattr->pre_size)
> > -                     && !nfs_have_writebacks(inode)) {
> > +                     && !nfs_have_writebacks(inode)
> > +                     && (nfs_size_to_loff_t(fattr->size) >=3D
> > i_size_read(inode)
> > +                             ||
> > !pnfs_layoutcommit_outstanding(inode))) {
>
> Under what circumstance is the client legally supposed to be able to
> call nfs_wcc_update_inode() with NFS_ATTR_FATTR_PRESIZE set, while
> there is an outstanding layoutcommit?
>

It is nfs_post_op_update_inode_force_wcc() from
nfs4_layoutcommit_release(). With
nconnect and overlapping LAYOUTCOMMITS, an earlier LAYOUTCOMMIT can complet=
e
and apply its (smaller) committed size via force_wcc while a later
LAYOUTCOMMIT --
for data already written past that point -- is still in flight.
