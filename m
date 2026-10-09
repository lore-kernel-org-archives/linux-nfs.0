Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E6D2032470F;
	Fri,  9 Oct 2026 04:43:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791521003; cv=none; b=C3cCedw0CdCSPU9tIQYcaWXLlhNh4QIqcw+cvRxY4Bx1xglU/IY8tEKU9FXKTjr+StfGTrjzovFOj1suyL+ac9PsvvsixsQfp3W7Zzk7U/jdoT+oHjHaxiCjkFyHH6kibViR6z0yeLPFpc2dMJg1lvLBLaez8osDpvRGvAy0+RQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791521003; c=relaxed/simple;
	bh=gYKwme7cGDspest2JH7MvCdf1dDale5YKmGq7Pm2wGs=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=GpM68X8889FmctAn0RjxgeE1mCPsZ5VLsL7/mQ1seF1f3DGNdDVWbzVxvdDAMtCyogQP9jkYxlcT6J87KXXZjh5Xn+m6NwR/P7tKDLx6lKgqghpGNq5eBKU0uWXw4GrqukoPzL/U2sMMCmGRlsF05tXScocHjTcZeu4EeGwvu2g=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Ch1Ek4ET; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Ch1Ek4ET"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A03D21F000FF;
	Fri,  9 Oct 2026 04:43:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791521001;
	bh=e3u7A0jEzt7ajdqOCz62G92JJKZgGXS0eX5q4SHD6jk=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=Ch1Ek4ETx0Pd7yqIbUIQllIhRiwamLh6m7EXR7MoxmepcqLbzgd7pGYlxF6ydS8kd
	 ysdhHgzV9lTjQgBnMDMO7Gcfp8mYbEJsmBhHdsxJs+J8Zwm/fm4KBjPViYuKAAuNEz
	 js+TsviwVGicyMe55CHrnEsruUGfSLAsoOYGPXTNSICnFyCMhfFunRwG95nPezgTat
	 a7v//cvNWHV5UeHHxvSJ4/JR4kR38q84W1TMzA4U/3GXqBubQgCQms/dtweCb19Qd+
	 phfTYi1A+8NJ1aovAAkNLTcyhxHzZUePwfUWtMgDCht12tSJm1tBKHkvZpCYNIZBBN
	 Ti43GwChdR/AQ==
Message-ID: <6855034f0b219b0b8e6a6f47aef802cf2803e42b.camel@kernel.org>
Subject: Re: [PATCH 1/2] NFSv4/pNFS: prevent i_size regression while
 layoutcommit is outstanding
From: Trond Myklebust <trondmy@kernel.org>
To: Lucheng Bao <lubao@everpuredata.com>, linux-nfs@vger.kernel.org, Anna
 Schumaker <anna@kernel.org>
Cc: linux-kernel@vger.kernel.org, tmenninger@everpuredata.com, 
	jcurley@everpuredata.com, stable@vger.kernel.org
Date: Fri, 09 Oct 2026 00:43:19 -0400
In-Reply-To: <20261008222843.63319-2-lubao@everpuredata.com>
References: <20261008222843.63319-1-lubao@everpuredata.com>
	 <20261008222843.63319-2-lubao@everpuredata.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-2.fc44) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Thu, 2026-10-08 at 22:28 +0000, Lucheng Bao wrote:
> Commit ac46bd374c9a ("pNFS: Ensure we layoutcommit before
> revalidating
> attributes") replaced outstanding-layoutcommit attribute filtering
> with
> synchronization before explicit revalidation. For layouts requiring
> LAYOUTCOMMIT, OPEN attributes can still shrink i_size before metadata
> synchronization completes.

The client can't police OPEN. It has no idea which file will be
affected (particularly when doing an open-by-filename) so unlike the
case of an explicit truncate() call, it can't serialise with the
truncate.
It is therefore up to the server to resolve any ambiguity, either by
recalling or revoking the layout before allowing the OPEN truncate to
proceed.

>=20
> Commit d8c951c313ed ("NFSv4.1: Don't trust attributes if a pNFS
> LAYOUTCOMMIT is outstanding") moved LAYOUTCOMMIT post-op attribute
> processing after cleanup, leaving another unprotected window after
> NFS_INO_LAYOUTCOMMITTING is cleared.

This is unrelated to the above problem, so fixes for this issue need to
be in a separate patch.

>=20
> Extend the existing writeback checks to reject smaller sizes while a
> LAYOUTCOMMIT is pending or in flight, preserving size increases and
> WCC
> checks. Process the reply's attributes and establish their generation
> barrier before cleanup removes that protection.
>=20
> Fixes: d8c951c313ed ("NFSv4.1: Don't trust attributes if a pNFS
> LAYOUTCOMMIT is outstanding")
> Fixes: ac46bd374c9a ("pNFS: Ensure we layoutcommit before
> revalidating attributes")
> Cc: stable@vger.kernel.org
> Signed-off-by: Lucheng Bao <lubao@everpuredata.com>
> ---
> =C2=A0fs/nfs/inode.c=C2=A0=C2=A0=C2=A0 | 8 ++++++--
> =C2=A0fs/nfs/nfs4proc.c | 2 +-
> =C2=A02 files changed, 7 insertions(+), 3 deletions(-)
>=20
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 3022454f7698..11432f521b04 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -1636,7 +1636,9 @@ static void nfs_wcc_update_inode(struct inode
> *inode, struct nfs_fattr *fattr)
> =C2=A0	if ((fattr->valid & NFS_ATTR_FATTR_PRESIZE)
> =C2=A0			&& (fattr->valid & NFS_ATTR_FATTR_SIZE)
> =C2=A0			&& i_size_read(inode) =3D=3D
> nfs_size_to_loff_t(fattr->pre_size)
> -			&& !nfs_have_writebacks(inode)) {
> +			&& !nfs_have_writebacks(inode)
> +			&& (nfs_size_to_loff_t(fattr->size) >=3D
> i_size_read(inode)
> +				||
> !pnfs_layoutcommit_outstanding(inode))) {

Under what circumstance is the client legally supposed to be able to
call nfs_wcc_update_inode() with NFS_ATTR_FATTR_PRESIZE set, while
there is an outstanding layoutcommit?

> =C2=A0		trace_nfs_size_wcc(inode, fattr->size);
> =C2=A0		i_size_write(inode, nfs_size_to_loff_t(fattr-
> >size));
> =C2=A0	}
> @@ -2392,7 +2394,9 @@ static int nfs_update_inode(struct inode
> *inode, struct nfs_fattr *fattr)
> =C2=A0		if (new_isize !=3D cur_isize && !have_delegation) {
> =C2=A0			/* Do we perhaps have any outstanding
> writes, or has
> =C2=A0			 * the file grown beyond our last write? */
> -			if (!nfs_have_writebacks(inode) || new_isize
> > cur_isize) {
> +			if ((!nfs_have_writebacks(inode) &&
> +			=C2=A0=C2=A0=C2=A0=C2=A0 !pnfs_layoutcommit_outstanding(inode))
> ||
> +			=C2=A0=C2=A0=C2=A0 new_isize > cur_isize) {
> =C2=A0				trace_nfs_size_update(inode,
> new_isize);
> =C2=A0				i_size_write(inode, new_isize);
> =C2=A0				if (!have_writers)
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 04b1987115d5..1ae047a062b8 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -10093,9 +10093,9 @@ static void nfs4_layoutcommit_release(void
> *calldata)
> =C2=A0{
> =C2=A0	struct nfs4_layoutcommit_data *data =3D calldata;
> =C2=A0
> -	pnfs_cleanup_layoutcommit(data);
> =C2=A0	nfs_post_op_update_inode_force_wcc(data->args.inode,
> =C2=A0					=C2=A0=C2=A0 data->res.fattr);
> +	pnfs_cleanup_layoutcommit(data);
> =C2=A0	put_cred(data->cred);
> =C2=A0	nfs_iput_and_deactive(data->inode);
> =C2=A0	kfree(data);

--=20
Trond Myklebust
Linux NFS client maintainer, Hammerspace
trondmy@kernel.org, trond.myklebust@hammerspace.com
