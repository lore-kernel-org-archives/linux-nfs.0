Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795468982;
	b=rLWRNKoRo+ZuEaRJT7T3RaqU+U48ye5cWg8JhkJnThNySdNkLXgN1AxfLOyAPqlRhEMJ
	 /DfP4OeBDuZ4AP3fpz/vLCbyWMNH4dBIQHV6qVZdPhTtgMDEAE24NM8ARgykSNiwcUxWL
	 QRpec2DWjtDYvpnFEMITqWWH/wu/epEs1R/vKxsoWDKmvC9yQAg2/BQ9rM++k7IIw512L
	 Y/NlxS/n8OvHu9jTVCYEFWSLVCbK2yEhMjqNeOd3iKLA2S7z8LsrBoM60LdOL13h2gADy
	 ofJvDwA6kw1bbVKNUF4Dwdnw80VykFHuukS7TBcKKoNLxxtw21ELilmyaRawDPolJhw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795468982;
	h=Received:DKIM-Signature:Message-ID:Subject:From:To:Cc:Date:
	 In-Reply-To:References:Content-Type:Content-Transfer-Encoding:
	 User-Agent:MIME-Version;
	bh=2VgX+LQLrR/nEwf3lTgTerUJrhKVO8Vn415W9R8T5a0=;
	b=FrTcAFek4wG2LP8r8kT7eG3fSUFzrirwpj5q/WGU1f20nZMVMr7xsrwit1eXU1S7KGA6
	 aoIRBzwIdzEUl/kxSMYCBvWO9Y9w5eY66rdclXu+cy64htBjZf5ars8tzlYLmJ+Cbd9w+
	 8nQzLBvEgYIXfXbpC5m8qyw+IqcCW1OzwVb5d1KObJ0WRXpJbWcxA04lHCNIrCJBzenel
	 Yjydjcu9a+fUMARlQVgZ3fuFgT0rOk8QFZzQM97J+MgFa4iraY9Rzkz95clTQWGPh6iwS
	 3OvdlOwPPcsPIhRTRc91CtyP6NS633Z/CcAKb+CloC4sFjmnf6fz6yVsdKA2RYIgfUA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="DGWH/a+D";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 10455606A321;
	Mon, 23 Nov 2026 21:23:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=DGWH/a+D
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F3B441F000CF;
	Mon, 23 Nov 2026 21:23:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795468981;
	bh=2VgX+LQLrR/nEwf3lTgTerUJrhKVO8Vn415W9R8T5a0=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=DGWH/a+Dd41RJPm2n3C6rBO0EhKVCt6Es6XfW5fLsdpFGrVJMA9/Q+IJHVtHCAXOB
	 iehG/zBZ3I7jQYEd4qP0XtLd1AI+3NOJXOCRVXhjnVrvAoBFhpf+iUonyJnHAa0QSg
	 9zWlDcW/0G5lrQSp3hZzXG9cBoih/h6FRlBpQ9il8nXh3aoNk9vi1DE0FW91HkQmbF
	 k9iYS8Czct/5VCoAvhjb3CirRnMsThyMDQQ7+bapUcjJ+BK5AiGWb4ddqWoM7bDJB9
	 D+DpGvpb50LB6tG/3wFSuC1hR5vfjTrWolPGHhGl0cLXUqzoxCWON9b72THGhcY/vc
	 TnwAg+uNVBULg==
Message-ID: <21053572ab2e8743fe4ba47464d21e719ec445b1.camel@kernel.org>
Subject: Re: [PATCH RFC] NFS: don't wait for writeback on close() with a
 write delegation
From: Trond Myklebust <trondmy@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: Chuck Lever <cel@kernel.org>, linux-nfs@vger.kernel.org, 
	linux-kernel@vger.kernel.org
Date: Mon, 23 Nov 2026 16:23:00 -0500
In-Reply-To: <185ae981c8250143bc519151d3d4f937a76b9a92.camel@kernel.org>
References: <20261116-nfs-space-limit-v1-1-fcc1335169a7@kernel.org>
			 <c9d7a4bf79247d7cfcd23460d351412c343d546c.camel@kernel.org>
		 <7c31f905f202512fb0ef1cb63f0714fffa24640f.camel@kernel.org>
	 <185ae981c8250143bc519151d3d4f937a76b9a92.camel@kernel.org>
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

On Mon, 2026-11-23 at 16:18 -0500, Trond Myklebust wrote:
> On Mon, 2026-11-23 at 14:43 -0500, Jeff Layton wrote:
> > On Fri, 2026-11-20 at 10:04 -0800, Trond Myklebust wrote:
> > > On Mon, 2026-11-16 at 15:55 -0500, Jeff Layton wrote:
> > > > Commit 5445b1fbd123 ("NFSv4: Respect the server imposed limit
> > > > on
> > > > how
> > > > many changes we may cache") made close() write back, COMMIT and
> > > > wait
> > > > whenever outstanding requests exceed the write delegation's
> > > > space_limit. Servers that send a limit of 0, knfsd included,
> > > > therefore
> > > > get no close() benefit from write delegations, which knfsd now
> > > > grants
> > > > even on write-only opens.
> > > >=20
> > > > That flush buys nothing:
> > > >=20
> > > > - CTO: no other client can open the file until the delegation
> > > > is
> > > > =C2=A0 recalled, and the recall writes back our dirty data first.
> > > > - Error reporting is all that's left, and it's pointless.
> > > > close()
> > > > is
> > > > =C2=A0 not required to flush, and most filesystems don't, so
> > > > checking
> > > > for
> > > > =C2=A0 writeback errors there is unreliable at best: the failing
> > > > writeback
> > > > =C2=A0 may not have happened yet. Applications that care must
> > > > fsync(),
> > > > =C2=A0 which this doesn't change; errors are still recorded in the
> > > > mapping
> > > > =C2=A0 and reported there.
> > > > - RFC 8881 says only that the client "should" abide by
> > > > space_limit;
> > > > =C2=A0 exceeding it leaves the server's behavior undefined, and
> > > > knfsd
> > > > just
> > > > =C2=A0 returns NFS4ERR_NOSPC/NFS4ERR_DQUOT on WRITE or COMMIT.
> > > >=20
> > > > Go back to just starting writeback on close() whenever we hold
> > > > a
> > > > write
> > > > delegation. In testing against a knfsd patched to send a
> > > > nonzero
> > > > space_limit, single-threaded create/write/close went from ~92
> > > > to
> > > > ~1,500 files/s.
> > > >=20
> > > > User-visible change: ENOSPC/EDQUOT for data written just before
> > > > close()
> > > > now shows up only via fsync(), not close().
> > > >=20
> > > > For now, the pagemod_limit is still decoded but unused.
> > > >=20
> > > > Signed-off-by: Jeff Layton <jlayton@kernel.org>
> > > > ---
> > > > I started looking at wiring up space_limit for nfsd's write
> > > > delegations,
> > > > but afrer looking at how the client uses it, I think we're best
> > > > off
> > > > just
> > > > not bothering to respect it at all. Thoughts?
> > > > ---
> > > > =C2=A0fs/nfs/delegation.c | 25 -------------------------
> > > > =C2=A0fs/nfs/delegation.h |=C2=A0 1 -
> > > > =C2=A0fs/nfs/nfs4file.c=C2=A0=C2=A0 |=C2=A0 7 ++++---
> > > > =C2=A03 files changed, 4 insertions(+), 29 deletions(-)
> > > >=20
> > > > diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
> > > > index ad774316f716..3a141d5ee0bd 100644
> > > > --- a/fs/nfs/delegation.c
> > > > +++ b/fs/nfs/delegation.c
> > > > @@ -1587,31 +1587,6 @@ bool nfs4_copy_delegation_stateid(struct
> > > > inode
> > > > *inode, fmode_t flags,
> > > > =C2=A0=09return ret;
> > > > =C2=A0}
> > > > =C2=A0
> > > > -/**
> > > > - * nfs4_delegation_flush_on_close - Check if we must flush
> > > > file
> > > > on
> > > > close
> > > > - * @inode: inode to check
> > > > - *
> > > > - * This function checks the number of outstanding writes to
> > > > the
> > > > file
> > > > - * against the delegation 'space_limit' field to see if
> > > > - * the spec requires us to flush the file on close.
> > > > - */
> > > > -bool nfs4_delegation_flush_on_close(const struct inode *inode)
> > > > -{
> > > > -=09struct nfs_inode *nfsi =3D NFS_I(inode);
> > > > -=09struct nfs_delegation *delegation;
> > > > -=09bool ret =3D true;
> > > > -
> > > > -=09rcu_read_lock();
> > > > -=09delegation =3D rcu_dereference(nfsi->delegation);
> > > > -=09if (delegation =3D=3D NULL || !(delegation->type &
> > > > FMODE_WRITE))
> > > > -=09=09goto out;
> > > > -=09if (atomic_long_read(&nfsi->nrequests) < delegation-
> > > > > pagemod_limit)
> > > > -=09=09ret =3D false;
> > > > -out:
> > > > -=09rcu_read_unlock();
> > > > -=09return ret;
> > > > -}
> > > > -
> > > > =C2=A0int nfs4_delegation_hash_alloc(struct nfs_server *server)
> > > > =C2=A0{
> > > > =C2=A0=09int delegation_buckets, i;
> > > > diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
> > > > index fba4699952b8..75f0edde65ea 100644
> > > > --- a/fs/nfs/delegation.h
> > > > +++ b/fs/nfs/delegation.h
> > > > @@ -83,7 +83,6 @@ void nfs_put_delegation(struct nfs_delegation
> > > > *delegation);
> > > > =C2=A0void nfs_mark_delegation_referenced(struct nfs_delegation
> > > > *delegation);
> > > > =C2=A0int nfs4_have_delegation(struct inode *inode, fmode_t type,
> > > > int
> > > > flags);
> > > > =C2=A0int nfs4_check_delegation(struct inode *inode, fmode_t type);
> > > > -bool nfs4_delegation_flush_on_close(const struct inode
> > > > *inode);
> > > > =C2=A0void nfs_inode_find_delegation_state_and_recover(struct inode
> > > > *inode,
> > > > =C2=A0=09=09const nfs4_stateid *stateid);
> > > > =C2=A0void nfs4_inode_make_writeable(struct inode *inode);
> > > > diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
> > > > index 9a434f5dda8d..04f4d8967e5b 100644
> > > > --- a/fs/nfs/nfs4file.c
> > > > +++ b/fs/nfs/nfs4file.c
> > > > @@ -122,10 +122,11 @@ nfs4_file_flush(struct file *file,
> > > > fl_owner_t
> > > > id)
> > > > =C2=A0=09=09return 0;
> > > > =C2=A0
> > > > =C2=A0=09/*
> > > > -=09 * If we're holding a write delegation, then check if
> > > > we're
> > > > required
> > > > -=09 * to flush the i/o on close. If not, then just start
> > > > the
> > > > i/o now.
> > > > +=09 * A write delegation already provides close-to-open
> > > > consistency:
> > > > +=09 * no other client can open the file until it is
> > > > recalled,
> > > > and the
> > > > +=09 * recall writes back our dirty data. Just start the
> > > > i/o.
> > > > =C2=A0=09 */
> > > > -=09if (!nfs4_delegation_flush_on_close(inode))
> > > > +=09if (nfs_have_write_delegation(inode))
> > > > =C2=A0=09=09return filemap_fdatawrite(file->f_mapping);
> > > > =C2=A0
> > > > =C2=A0=09/* Flush writes to the server and return any errors */
> > > >=20
> > > > ---
> > > > base-commit: 9d66f26fefacebfeed15de31c1123451a17ff119
> > > > change-id: 20261113-nfs-space-limit-025199334e52
> > > >=20
> > > > Best regards,
> > >=20
> > > Maybe we can call filemap_flush() in order to kick off non-
> > > blocking
> > > writes in this situation?
> >=20
> > This sounds like a good idea, but agentic review came up with this,
> > and
> > it seems to be valid, AFAICT:
> >=20
> > ------------8<-------------
> > - filemap_flush() =E2=86=92 WB_SYNC_NONE: it skips folios already in
> > flight,
> > but it can block on server-wide congestion caused by other files.
> >=20
> > - filemap_fdatawrite() =E2=86=92 WB_SYNC_ALL: it may wait on this file'=
s
> > own
> > rewritten in-flight folios, which a create/write/close workload
> > rarely
> > hits. It never waits on congestion, and a small file gets a
> > FILE_SYNC
> > WRITE with no COMMIT.
> > ------------8<-------------
> >=20
> > I think we may want to switch this code back to using
> > filemap_fdatawrite()
> > like it did before. Thoughts?
>=20
> Urgh...
>=20
> OK, I've got to stop and ask why commit 2f1f31042ef0 ("nfs: Block on
> write congestion") only applies congestion control to the
> WB_SYNC_NONE
> case?
>=20
> Also, why does it not re-check for congestion in the loops further
> down
> in nfs_writepages where it's adding fuel to the congestion fire?
>=20
> Put differently: If we're going to apply congestion control, then why
> are we not doing so consistently here?

Another note: this is almost certainly completely borked for the pNFS
case, since nfss->write_congestion_wait is global to the metadata
server. In the pNFS case, you can have lots of data servers that have
completely independent congestion characteristics.

--=20
Trond Myklebust
Linux NFS client maintainer, Hammerspace
trondmy@kernel.org, trond.myklebust@hammerspace.com
