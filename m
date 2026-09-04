Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1100346AF00;
	Fri,  4 Sep 2026 10:31:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788517862; cv=none; b=oj8Q3Ta9LaAQMib5a5SmMRzv8bcDdCIGTV3amFtG2+cTrd/+G8GNUgiMoQDBl87oeQ6B7fkTX7lEFjVIowCMjwg7u3jv3E7C5EJGztq4i5fRm+tKXTuaAhIHt5eIlBAFZd0Lc5rEHE85UjsL0dGTaVbEfCqE1RDR6jCRO7gx5F0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788517862; c=relaxed/simple;
	bh=ERLOHvLBv6usjPgYcxtkyqz5dH2tjXv8iFv/7TN3P0k=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=XWvwK8nMyNpDzaBoH33B6E/z5AN2PMj99t5B25xzxu6FN9VVQIjfB06l9fmjed3WFGSrycKNwetXLfsnlGluwGlHR5J/iqmsGolRS1fgLKzgx8JJMtwBMgDunbpioQKvBQi2Uq67vfJfDCKP+eYCdqllB96ZDzoG+110/UHISjo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=izlRrwoV; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="izlRrwoV"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D549B1F00A3D;
	Fri,  4 Sep 2026 10:30:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788517860;
	bh=SP6ddiw7eBcLy3vVBDzcACmuy68vI4vfWkI0ZNXWS98=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=izlRrwoVT/CR0RStDBkok1Am3vIUBmV6tdQYUNKUjEB2CDE/qaLNEBge3dFgZ36+v
	 sCpve5rWzUKzUf7Ss1cWup4NoifdEUHe16IG8fIDBqewoyJexDEIhJQo61+0LuAOxS
	 jRSMUI6vMX8tCSBPfil7cmg9p2WiRI/38cl+Vs22WhyZzzwgrdgIuDtGXcUl4rkAeS
	 VsZ6Y09tz548+QfdSCJwdbZz5LyPpAZV6eVjXhsI6luli0u16JmcUS+yREWEeaTnn6
	 clepyXVGqVrO1CTff8cp5l287V2OCAEFoLVigltg6tDJ7nsbF61o+uu/mAkUntaZUr
	 bgwnkjyBM5+gA==
Date: Fri, 4 Sep 2026 12:30:55 +0200
From: Christian Brauner <brauner@kernel.org>
To: Chuck Lever <cel@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
	Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>, Thomas Haynes <loghyr@gmail.com>, 
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v2 0/3] fs/nfsd: accept a backdated timestamp from a
 delegation holder
Message-ID: <20260904-einhalten-abwurf-geldanlage-80dc11239cac@brauner>
References: <20260902-delegts-v2-0-383cb289ce88@kernel.org>
 <3caef4ff-9f01-4b09-8e83-12bcb0a1ee17@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <3caef4ff-9f01-4b09-8e83-12bcb0a1ee17@app.fastmail.com>

On Wed, Sep 02, 2026 at 08:03:53PM -0400, Chuck Lever wrote:
> 
> 
> On Wed, Sep 2, 2026, at 2:54 PM, Jeff Layton wrote:
> > The main problem is that an attribute delegation has strict rules about
> > updates can be done, and that prevents applications that backdate
> > timestamps on files after writing them, (e.g. tar -x, cp -p, etc.) from
> > setting them properly.
> >
> > We could fix this on the client by making it always issue an RPC for the
> > SETATTR, but that would harm performance in these common use-cases.
> > This set allows the server to accept some of these backdated mtime
> > updates, by changing how the ctime is handled.
> >
> > It'd be nice to see this in v7.4.
> >
> > Signed-off-by: Jeff Layton <jlayton@kernel.org>
> > ---
> > Changes in v2:
> > - Split the change into three patches
> > - Stamp now in inode_set_ctime_deleg() for a stale update, so nfsd need
> >   not compare
> > - Drop a SETATTR report that matches the inode, so an untouched file
> >   keeps its change attribute
> > - Set dl_setattr only on the branch that carries a c/mtime update
> > - Compare against the inode, not the grant-time snapshots (Chuck)
> > - Set the ctime whenever a CB_GETATTR moves the mtime
> > - Take i_rwsem before the CB_GETATTR comparison
> > - Drop the unused dl_atime, dl_mtime and dl_ctime, and make
> >   nfsd4_vet_deleg_time() static
> > - Link to v1: 
> > https://lore.kernel.org/r/20260901-delegts-v1-1-9937f7ee4370@kernel.org
> >
> > ---
> > Jeff Layton (3):
> >       fs: stamp the current time for a stale delegated ctime update
> >       nfsd: accept a backdated timestamp from a delegation holder
> >       nfsd: compare CB_GETATTR times against the inode
> >
> >  fs/inode.c          | 17 +++++++++++----
> >  fs/nfsd/nfs4proc.c  | 63 +++++++++++++++++++++++++++++++++++++++++++----------
> >  fs/nfsd/nfs4state.c | 49 ++++++++++++++++++++++++++---------------
> >  fs/nfsd/state.h     |  8 -------
> >  4 files changed, 95 insertions(+), 42 deletions(-)
> > ---
> > base-commit: ac579868af0c900d8fd9c8cfe9e10db46ccc5a75
> > change-id: 20260901-delegts-e91a648f1427
> >
> > Best regards,
> > -- 
> > Jeff Layton <jlayton@kernel.org>
> 
> Since the series modifies fs/inode.c, Christian will want to take it
> through the VFS tree.
> 
> Acked-by: Chuck Lever <cel@kernel.org>

Thanks!
