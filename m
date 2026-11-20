Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795197889;
	b=yomLq5zmu9cIcEX751ZyJTu1NdxZPmD4qGmBPwoGa9nOTTMFT1MQl+3h1526egSUt7hU
	 0/vsOF2CwCguHfYDxKWvVEqDf5tgLiNij4gRcB+0eZ+RweOcnOwjmS+mP+JzPEA3c9I52
	 Sdglzv9Y2aJxQm1cL8av6wPyMrVgoDMWGi1+8w4O1344Undy+oluxNeOwVbmBhl55pHc7
	 k02g5f99OgqvQMxIjm5nFltFTIbxVGYiGv2SXced3gfV0RHxfjmlUS0yBUxzkz3d/gXUI
	 msOosl5k7j88Me7x7xLxtT7kipfq04JqDPy/DNhJid2CwL6Ig62wntIjucFf6zAE3CQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795197889;
	h=Received:DKIM-Signature:Message-ID:Subject:From:To:Cc:Date:
	 In-Reply-To:References:Content-Type:Content-Transfer-Encoding:
	 User-Agent:MIME-Version;
	bh=DygjEKi38o3GasFml85WxiMAFWjjX0WD7EifQHPGL/A=;
	b=zhJR2TqByh5C75eedsfzcPVhyTVQ5BecZ/9usSmxB6lDN2LzeCjxpjoID34YQqMwzA3R
	 XrQoF+0D+tKvUbj2NSCvoh7VEgDgnB38AmDtfkO++NQc7kBjf000tlbw3XOq1QOhDxbpW
	 QSoYSJr4rGy2h6tRC0qgsjFXYXiFJb8yQLQAM7+PHP1mBO+QEJiywh2UVVvLjG9u7MsSe
	 VbW7YaoUNhieH/wbKATIAiPMddw01++gJzHX4Lof2qE5FtjHrPJ9L445GwKT/yRMaTSEu
	 BFlhsNiIUa4+xxP5Jp8LTZKusk/llPUIwOpSxP/f+n3isKBIRGBO4qNCYbIw19IgWCA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=c1QJwoP9;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D365B606A895;
	Fri, 20 Nov 2026 18:04:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=c1QJwoP9
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 18C1D1F000D4;
	Fri, 20 Nov 2026 18:04:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795197889;
	bh=DygjEKi38o3GasFml85WxiMAFWjjX0WD7EifQHPGL/A=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=c1QJwoP9Js9ylOiblL15IpwU7TGs+iGcXN00rM4AAIZ7SJFgu/4iMiI7as4QmmsOf
	 K6yCYGonCPBX0mcJqnsX4xgl4mmoXhSa0AjCgpxb3CF+M4rPGQIFDYhZunhXfikw7K
	 dfA/WXhd2eOQ15vH0MOKh0NVYMftV4hUW5G6ExgeTVCJk6U/adQYIp9rHi50/6Raxe
	 C7uZaASE1cNrPGYAbD/+sWREQOB0RgMqywL1e4HqZ6C7imfg7V6Z6W10sa4XCewWOF
	 Wq8DhN4vKsJK32JG1Mjk8vnJXvkyGD1x01OP9zBTgONtkOclCcVaZc8q5uqPoMOJ5z
	 QqrPpmm66yISg==
Message-ID: <c9d7a4bf79247d7cfcd23460d351412c343d546c.camel@kernel.org>
Subject: Re: [PATCH RFC] NFS: don't wait for writeback on close() with a
 write delegation
From: Trond Myklebust <trondmy@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: Chuck Lever <cel@kernel.org>, linux-nfs@vger.kernel.org, 
	linux-kernel@vger.kernel.org
Date: Fri, 20 Nov 2026 10:04:48 -0800
In-Reply-To: <20261116-nfs-space-limit-v1-1-fcc1335169a7@kernel.org>
References: <20261116-nfs-space-limit-v1-1-fcc1335169a7@kernel.org>
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

On Mon, 2026-11-16 at 15:55 -0500, Jeff Layton wrote:
> Commit 5445b1fbd123 ("NFSv4: Respect the server imposed limit on how
> many changes we may cache") made close() write back, COMMIT and wait
> whenever outstanding requests exceed the write delegation's
> space_limit. Servers that send a limit of 0, knfsd included,
> therefore
> get no close() benefit from write delegations, which knfsd now grants
> even on write-only opens.
>=20
> That flush buys nothing:
>=20
> - CTO: no other client can open the file until the delegation is
> =C2=A0 recalled, and the recall writes back our dirty data first.
> - Error reporting is all that's left, and it's pointless. close() is
> =C2=A0 not required to flush, and most filesystems don't, so checking for
> =C2=A0 writeback errors there is unreliable at best: the failing writebac=
k
> =C2=A0 may not have happened yet. Applications that care must fsync(),
> =C2=A0 which this doesn't change; errors are still recorded in the mappin=
g
> =C2=A0 and reported there.
> - RFC 8881 says only that the client "should" abide by space_limit;
> =C2=A0 exceeding it leaves the server's behavior undefined, and knfsd jus=
t
> =C2=A0 returns NFS4ERR_NOSPC/NFS4ERR_DQUOT on WRITE or COMMIT.
>=20
> Go back to just starting writeback on close() whenever we hold a
> write
> delegation. In testing against a knfsd patched to send a nonzero
> space_limit, single-threaded create/write/close went from ~92 to
> ~1,500 files/s.
>=20
> User-visible change: ENOSPC/EDQUOT for data written just before
> close()
> now shows up only via fsync(), not close().
>=20
> For now, the pagemod_limit is still decoded but unused.
>=20
> Signed-off-by: Jeff Layton <jlayton@kernel.org>
> ---
> I started looking at wiring up space_limit for nfsd's write
> delegations,
> but afrer looking at how the client uses it, I think we're best off
> just
> not bothering to respect it at all. Thoughts?
> ---
> =C2=A0fs/nfs/delegation.c | 25 -------------------------
> =C2=A0fs/nfs/delegation.h |=C2=A0 1 -
> =C2=A0fs/nfs/nfs4file.c=C2=A0=C2=A0 |=C2=A0 7 ++++---
> =C2=A03 files changed, 4 insertions(+), 29 deletions(-)
>=20
> diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
> index ad774316f716..3a141d5ee0bd 100644
> --- a/fs/nfs/delegation.c
> +++ b/fs/nfs/delegation.c
> @@ -1587,31 +1587,6 @@ bool nfs4_copy_delegation_stateid(struct inode
> *inode, fmode_t flags,
> =C2=A0=09return ret;
> =C2=A0}
> =C2=A0
> -/**
> - * nfs4_delegation_flush_on_close - Check if we must flush file on
> close
> - * @inode: inode to check
> - *
> - * This function checks the number of outstanding writes to the file
> - * against the delegation 'space_limit' field to see if
> - * the spec requires us to flush the file on close.
> - */
> -bool nfs4_delegation_flush_on_close(const struct inode *inode)
> -{
> -=09struct nfs_inode *nfsi =3D NFS_I(inode);
> -=09struct nfs_delegation *delegation;
> -=09bool ret =3D true;
> -
> -=09rcu_read_lock();
> -=09delegation =3D rcu_dereference(nfsi->delegation);
> -=09if (delegation =3D=3D NULL || !(delegation->type & FMODE_WRITE))
> -=09=09goto out;
> -=09if (atomic_long_read(&nfsi->nrequests) < delegation-
> >pagemod_limit)
> -=09=09ret =3D false;
> -out:
> -=09rcu_read_unlock();
> -=09return ret;
> -}
> -
> =C2=A0int nfs4_delegation_hash_alloc(struct nfs_server *server)
> =C2=A0{
> =C2=A0=09int delegation_buckets, i;
> diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
> index fba4699952b8..75f0edde65ea 100644
> --- a/fs/nfs/delegation.h
> +++ b/fs/nfs/delegation.h
> @@ -83,7 +83,6 @@ void nfs_put_delegation(struct nfs_delegation
> *delegation);
> =C2=A0void nfs_mark_delegation_referenced(struct nfs_delegation
> *delegation);
> =C2=A0int nfs4_have_delegation(struct inode *inode, fmode_t type, int
> flags);
> =C2=A0int nfs4_check_delegation(struct inode *inode, fmode_t type);
> -bool nfs4_delegation_flush_on_close(const struct inode *inode);
> =C2=A0void nfs_inode_find_delegation_state_and_recover(struct inode
> *inode,
> =C2=A0=09=09const nfs4_stateid *stateid);
> =C2=A0void nfs4_inode_make_writeable(struct inode *inode);
> diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
> index 9a434f5dda8d..04f4d8967e5b 100644
> --- a/fs/nfs/nfs4file.c
> +++ b/fs/nfs/nfs4file.c
> @@ -122,10 +122,11 @@ nfs4_file_flush(struct file *file, fl_owner_t
> id)
> =C2=A0=09=09return 0;
> =C2=A0
> =C2=A0=09/*
> -=09 * If we're holding a write delegation, then check if we're
> required
> -=09 * to flush the i/o on close. If not, then just start the
> i/o now.
> +=09 * A write delegation already provides close-to-open
> consistency:
> +=09 * no other client can open the file until it is recalled,
> and the
> +=09 * recall writes back our dirty data. Just start the i/o.
> =C2=A0=09 */
> -=09if (!nfs4_delegation_flush_on_close(inode))
> +=09if (nfs_have_write_delegation(inode))
> =C2=A0=09=09return filemap_fdatawrite(file->f_mapping);
> =C2=A0
> =C2=A0=09/* Flush writes to the server and return any errors */
>=20
> ---
> base-commit: 9d66f26fefacebfeed15de31c1123451a17ff119
> change-id: 20261113-nfs-space-limit-025199334e52
>=20
> Best regards,

Maybe we can call filemap_flush() in order to kick off non-blocking
writes in this situation?

--=20
Trond Myklebust
Linux NFS client maintainer, Hammerspace
trondmy@kernel.org, trond.myklebust@hammerspace.com
