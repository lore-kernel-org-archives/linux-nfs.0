Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 638C2394794
	for <linux-nfs@vger.kernel.org>; Mon, 13 Apr 2026 21:21:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776115291; cv=none; b=qY/YFH6nhJTwoJhImYLax4TKloOIiTrdIGZWGJfitXhQ8y2ArS25Uzbr+BrKClqZgXQaVZSfHUXPe0/evxgmanuz1YtzjQDvFZDbGg3KfBUxFHFqA/rvKHbs15qBAF5A488HHbjJMSXU97w9XlyPAKg1vU8KnvZAJmU1htF/8Js=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776115291; c=relaxed/simple;
	bh=zQA7P+IRJJlO1tj3knmnscuKF6MgLC5M68HVH5nqQjQ=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=TPTMLpgpoFxa9DsGez49dNX095LddFH9pX7tZ3f+GzM8PPs+UjnIzKLY5ZKXH04RbivnqHSD7cYjotI7CT1xBrgVSZtEzGLlYZmSt3XE4ry6A2IVw2bWa+5BYdp8hddlRIgspZsAPNHRYLpA8VvEdk4yl3jG/pM6laklgjBkGq0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=hNpKhyKJ; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="hNpKhyKJ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CFE0EC2BCAF;
	Mon, 13 Apr 2026 21:21:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1776115291;
	bh=zQA7P+IRJJlO1tj3knmnscuKF6MgLC5M68HVH5nqQjQ=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=hNpKhyKJgyLFieHoyyDFwNeihdOyM6K9BZnCkkvnZ8iDiNjVORcu9iAcToZWQ+T10
	 40h/AOTCNLKh8zVI38F11R6yuvRy5ahQLqXn5C0G27GNez/Np/J3CcHJJr6Gm82qmX
	 01//b/ZUqW9HcTrxBRX2wePhhatPIP91wU70NryQXKXXgR0xnWWBblEMWejw2g7Eqb
	 M7VBjkIuxJxGLPqJOnvP12RcXtMAjjIRJdLdZRMVyEfrYpv//jInwmqpTB8ywRAWhT
	 5eTBy9AA1ww/6UF5oNcB7k9klWaYCrAzIpFv60mQ83I4iaPM4i65rV9ILf/0cY0b10
	 Xyl5rlp8gsu1A==
Message-ID: <80f40bb9a8ed1c1933d7014d626b1609000ff353.camel@kernel.org>
Subject: Re: [PATCH 1/1] NFSv4.2: fix CLONE attrs in presence of delegated
 attributes
From: Trond Myklebust <trondmy@kernel.org>
To: Olga Kornievskaia <okorniev@redhat.com>, anna@kernel.org
Cc: linux-nfs@vger.kernel.org
Date: Mon, 13 Apr 2026 14:21:29 -0700
In-Reply-To: <20260327151149.25317-1-okorniev@redhat.com>
References: <20260327151149.25317-1-okorniev@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.58.3 (3.58.3-1.fc43) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Fri, 2026-03-27 at 11:11 -0400, Olga Kornievskaia wrote:
> xfstest generic/407 is failing in 2 ways. It detects that after
> doing a clone the client does not update it's mtime and it's ctime.
> CLONE always sends a GETATTR operation and then calls
> nfs_post_op_update_inode() based on the returned attributes.
> Because of the delegated attributes the client ignores updating
> the mtime. Then also, when delegated attributes are present, for
> the change_attr the server replies with the same values as what
> the client cached before and thus the generic/407 would flag that.
> Instead, make sure we invalidate the blocks attr.
>=20
> Fixes: e12912d94137 ("NFSv4: Add support for delegated atime and
> mtime attributes")
> Signed-off-by: Olga Kornievskaia <okorniev@redhat.com>
> ---
> =C2=A0fs/nfs/nfs42proc.c | 10 +++++++++-
> =C2=A01 file changed, 9 insertions(+), 1 deletion(-)
>=20
> diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
> index 7e5c1172fc11..f6a7cfa12225 100644
> --- a/fs/nfs/nfs42proc.c
> +++ b/fs/nfs/nfs42proc.c
> @@ -1306,7 +1306,15 @@ static int _nfs42_proc_clone(struct
> rpc_message *msg, struct file *src_f,
> =C2=A0		if (count =3D=3D 0 && res.dst_fattr->valid &
> NFS_ATTR_FATTR_SIZE)
> =C2=A0			count =3D nfs_size_to_loff_t(res.dst_fattr-
> >size) - dst_offset;
> =C2=A0		nfs42_copy_dest_done(dst_f, dst_offset, count,
> oldsize_dst);
> -		status =3D nfs_post_op_update_inode(dst_inode,
> res.dst_fattr);
> +		nfs_update_delegated_mtime(dst_inode);
> +		if (!nfs_have_delegated_attributes(dst_inode))
> +			status =3D nfs_post_op_update_inode(dst_inode,
> +							=C2=A0
> res.dst_fattr);
> +		else {
> +			spin_lock(&dst_inode->i_lock);
> +			nfs_set_cache_invalid(dst_inode,
> NFS_INO_INVALID_BLOCKS);
> +			spin_unlock(&dst_inode->i_lock);
> +		}

Why not call nfs_post_op_update_inode() instead of setting
NFS_INO_INVALID_BLOCKS? It should be safe to do so.

> =C2=A0	}
> =C2=A0
> =C2=A0	kfree(res.dst_fattr);

--=20
Trond Myklebust
Linux NFS client maintainer, Hammerspace
trondmy@kernel.org, trond.myklebust@hammerspace.com
