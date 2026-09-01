Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B6BA847ECDD;
	Tue,  1 Sep 2026 17:09:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788282559; cv=none; b=ILbN/hlEHx++HiGSfd+VEUjlFSIlTaJVQwkq8Ob1f9/dQYTnjmQ74KqXPlgiu/LQytSP50/GjeNKgTTCpw6iOqL0R/icCRmoPjQ5XBCNpF5yf7+k5/azXeBwN4ZHDYO3BwmPHbFpl0pJ/LG7E6zfUMM+4GcXLdw/ZDImcxyDZAo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788282559; c=relaxed/simple;
	bh=QmIQi50CDRxkqFEhgMVEMoLmiC4RETD8fMqVnWWOHyc=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=Rt4sGPS4nAfbly6If2Ncgxdk+kBBsmZSN3d3jONW0PkqipNM7L6+/4DrYqsI4w/75eQaiJ83rCN/QywTdn6VLDqeiBjeYUL8hEtiYyZ1bHbfLcz6EAPopoj+ueieL6B0FUNR4t7fAEPxloJsrUaRmbolbvmgfRCiTdYraHcDzWU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=HvpxBTQm; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="HvpxBTQm"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5DAB81F000E9;
	Tue,  1 Sep 2026 17:09:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788282557;
	bh=TGSn5dtg1waC38dglTeKDSErn0jwBarwcBAqBGsH7fQ=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=HvpxBTQmd04p8B5b9ziWGciNyT0WhO66aj21rRugBkf6N8jD0cfgepyMYhFE45ddt
	 3fYzNuddP/P0zI8yeEs0+YSo5nVsS/jW+lkCVSOtuwprQ4/mkeqB8WfblA/TNmK7dh
	 BufVOt84sGB55M2hlwpqqlNqUHRR/bF1FvuKklqjlmVJ/6LHWLTyhS5ym20uhaQGkA
	 1VHnDqUFFf8AadR/nFF+UmGLygyYF8B2OAMTdGOj11ksefq2hUscT2lLsK1UJi0jdM
	 7QvQO+xdxBYXbjy8VBMy81Mf5skd2PF693vwwWm0hmNjC62C+clTudQwFL5OUdM/d6
	 qxtD9lPPyuJFg==
Message-ID: <6cf26aa1e2a4b92e94d425a014427d2fd8da1367.camel@kernel.org>
Subject: Re: [PATCH] nfsd: accept a backdated timestamp from a delegation
 holder
From: Jeff Layton <jlayton@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, Olga
 Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom
 Talpey <tom@talpey.com>
Cc: Thomas Haynes <loghyr@gmail.com>, linux-nfs@vger.kernel.org, 
	linux-kernel@vger.kernel.org
Date: Tue, 01 Sep 2026 13:09:14 -0400
In-Reply-To: <d5af1492-5bc3-4ac8-b4e8-d454b7caafdf@app.fastmail.com>
References: <20260901-delegts-v1-1-9937f7ee4370@kernel.org>
	 <d5af1492-5bc3-4ac8-b4e8-d454b7caafdf@app.fastmail.com>
Autocrypt: addr=jlayton@kernel.org; prefer-encrypt=mutual;
 keydata=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
 QZIQXVeAA+smfTT0tDrisj1U5x6ZB9b3nBg65kc=
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-1.fc44) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Tue, 2026-09-01 at 11:19 -0400, Chuck Lever wrote:
> On Tue, Sep 1, 2026, at 9:09 AM, Jeff Layton wrote:
> > A client with an attribute delegation reports the file times in a
> > SETATTR at DELEGRETURN. nfsd ignores a time that moves backwards. It
> > then stamps the c/mtime with the current time, so the file keeps the
> > DELEGRETURN time. cp -p, rsync -t and tar -x lose timestamps.
> >=20
> > The client applies an explicit utimensat() to its own inode. It sends n=
o
> > SETATTR while it holds the delegation, so the backdated value reaches
> > nfsd only as TIME_DELEG_MODIFY. The client can send an RPC for each tim=
e
> > change instead. That also works, but it loses the caching that the
> > delegation allows.
> >=20
> > The delegation makes the client the authority for these times, so treat
> > its SETATTR as a statement of fact. The client can set the same value
> > with an ordinary SETATTR, which nfsd applies without a check.
> >=20
> > - nfsd accepts a backwards atime or mtime.
> > - An mtime that moves backwards sets the ctime to the current time.
> >   The ctime never moves backwards.
> > - nfsd still clamps a future time.
> > - The CB_GETATTR path keeps the old rule. A backwards time there shows
> >   a stale report.
> >=20
> > RFC 9754 says that the server ignores a time before the original time.
> > This patch does not follow that sentence. The same section also says
> > that the server MUST accept the change or MUST reject it with
> > NFS4ERR_DELAY. A silent discard does neither. A retry after
> > NFS4ERR_DELAY carries the same backdated value, so that option cannot
> > succeed.
> >=20
> > There is still one gap: nfsd cannot tell an explicit utimensat() from a
> > report of a write. An mtime after the delegation and before the current
> > time therefore sets the ctime to that mtime, instead of to "now". RFC
> > 9754 requires this. Fixing that would require the client to issue an RP=
C
> > for the mtime.
> >=20
> > Fixes: 3952f1cbcbc4 ("nfsd: fix SETATTR updates for delegated timestamp=
s")
> > Signed-off-by: Jeff Layton <jlayton@kernel.org>
> > Assisted-by: Claude:claude-opus-5
>=20
>=20
> Hi Jeff, LLM-generated review suggested the below finding is a blocker.
>=20
> > diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> > index bb74eef43938..fa3a43c20e95 100644
> > --- a/fs/nfsd/nfs4proc.c
> > +++ b/fs/nfsd/nfs4proc.c
>=20
> [ ... ]
>=20
> > @@ -1302,21 +1315,23 @@ vet_deleg_attrs(struct nfsd4_setattr *setattr, =
struct nfs4_delegation *dp)
> >  	struct timespec64 now =3D current_time(dp->dl_stid.sc_file->fi_inode)=
;
> >  	struct iattr *iattr =3D &setattr->sa_iattr;
> > =20
> > -	if ((setattr->sa_bmval[2] & FATTR4_WORD2_TIME_DELEG_ACCESS) &&
> > -	    !nfsd4_vet_deleg_time(&iattr->ia_atime, &dp->dl_atime, &now))
> > -		iattr->ia_valid &=3D ~(ATTR_ATIME | ATTR_ATIME_SET);
> > +	if (setattr->sa_bmval[2] & FATTR4_WORD2_TIME_DELEG_ACCESS)
> > +		clamp_deleg_time(&iattr->ia_atime, &now);
> > =20
> >  	if (setattr->sa_bmval[2] & FATTR4_WORD2_TIME_DELEG_MODIFY) {
> > -		if (nfsd4_vet_deleg_time(&iattr->ia_mtime, &dp->dl_mtime, &now)) {
> > -			iattr->ia_ctime =3D iattr->ia_mtime;
> > -			if (nfsd4_vet_deleg_time(&iattr->ia_ctime, &dp->dl_ctime, &now))
> > -				dp->dl_setattr =3D true;
> > -			else
> > -				iattr->ia_valid &=3D ~(ATTR_CTIME | ATTR_CTIME_SET);
> > -		} else {
> > -			iattr->ia_valid &=3D ~(ATTR_CTIME | ATTR_CTIME_SET |
> > -					     ATTR_MTIME | ATTR_MTIME_SET);
> > -		}
> > +		clamp_deleg_time(&iattr->ia_mtime, &now);
> > +
> > +		/*
> > +		 * The ctime must not move backwards. Carry the mtime into it
> > +		 * only when that advances it; otherwise clear ATTR_CTIME_SET so
> > +		 * that notify_change() stamps the ctime with the current time,
> > +		 * which is what a local utimensat() would do.
> > +		 */
> > +		iattr->ia_ctime =3D iattr->ia_mtime;
> > +		if (!nfsd4_vet_deleg_time(&iattr->ia_ctime, &dp->dl_ctime, &now))
>                                                              ^^^^^^^^^^^^
>=20
> Is dp->dl_ctime the right value to compare against here?  It is sampled
> once, when the delegation is granted, and nothing refreshes it after
> that:
>=20
> fs/nfsd/nfs4state.c:nfs4_open_delegation() {
>     ...
> 	dp->dl_atime =3D stat.atime;
> 	dp->dl_ctime =3D stat.ctime;
> 	dp->dl_mtime =3D stat.mtime;
>     ...
> }
>=20
> Is there anything that stops a client from sending more than one SETATTR
> with TIME_DELEG_MODIFY while it holds the delegation?
>=20
> Say the first one carries an mtime T5 that is later than dl_ctime.
> nfsd4_vet_deleg_time() returns true, ATTR_CTIME_SET stays set, and the
> inode ctime becomes T5.
>=20
> If a second SETATTR then backdates the mtime to T3, where dl_ctime < T3 <
> T5, the comparison is still against the grant-time dl_ctime.  It returns
> true again, so ATTR_CTIME_SET stays set and T3 is carried into ia_ctime.
>=20
> notify_change() -> setattr_copy() -> inode_set_ctime_deleg() then drops
> that update, because T3 is older than the T5 already in the inode:
>=20
> fs/inode.c:inode_set_ctime_deleg() {
>     ...
> 	/* If the update is older than the existing value, skip it. */
> 	if (timespec64_compare(&update, &cur_ts) <=3D 0)
> 		return cur_ts;
>     ...
> }
>=20
> The mtime moves back to T3 and the ctime stays at T5, so the ctime is
> neither carried from the mtime nor stamped with the current time.  That
> looks different from the comment just above it, and from the commit
> message: "An mtime that moves backwards sets the ctime to the current
> time."
>=20
> Would comparing against the inode's current ctime work better here?  The
> inode is already in hand for the current_time() call at the top of the
> function.
>=20
>=20

Yes, I think we do want to rework it to do that. Additionally, I
noticed another race condition that we ought to fix while we're in
here.

I'll be sending a v2, but I think we have to push some of this handling
into the VFS layer so that it's done under more consistent locking and
properly uses the mgtime infrastructure.

--=20
Jeff Layton <jlayton@kernel.org>
