Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F319A346AE8
	for <linux-nfs@vger.kernel.org>; Mon, 13 Apr 2026 22:19:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776118792; cv=none; b=lZwZnS+um2C1jCeIbeSPtUn8iMXFX+5lhHayacbeF+sn98svVzge2su7Z4wiWP4Wv2xu/CimzpLKy6OazFp7bwiFocAm+LeVhzhtJd7Djvh/r4z8alzMuOrcQQcN1X0l9eUVzoSs4B7El28VmW9/+HBtEACICQ5cDsEbRobU42Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776118792; c=relaxed/simple;
	bh=92zm+CFg2bz3rF8b0WYa3omPnfDKv5qM5295U3dDSgU=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=uZ2RVrD0SUaeG7QXGLWhojiuM8a6bdMdGdxG6U8ARv5K0zMgp8A37loLl53EsixX1PhTuz25+6Mjyif8j2qS515nnCK1x/LvvU36Q0OIL7vGLW9DqGkMmhlzGGYhCFgAUfAnjYHxOItt5tyKD17CWCzNBtsdrzln5T7QE3KX8MI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=d++qGb/l; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="d++qGb/l"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 860FBC2BCAF;
	Mon, 13 Apr 2026 22:19:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1776118791;
	bh=92zm+CFg2bz3rF8b0WYa3omPnfDKv5qM5295U3dDSgU=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=d++qGb/l+TRBmrHyKe9PeSLx8XhfZzCKi1fPlQ7y8/Nl90walQ8Eo/NA5ZZ3uYVZL
	 tvObcrYiHNudm1mPIOCvrDDmQpxMhjWwTJk3vqF2DJHSejb3QyqiRKjPPYE/P0zstn
	 KQQwoE3GtGTvn6946du1W4ORVh8jWEWiHM6hKOTGt/DFo7N7+AZ0Fdac3IzFnqEhUc
	 ZIGU9er/48Fk0USWFsIWpq9GAXwaoxd2HhtMBFfAEc8smKOrwnp79m/hy8c/zqE9Ka
	 H95XJxC4WRLfsi3d+bvh0nCxOlgjuwPcY8zFhnmkiSO+/2KJmpbSxw5scHkAekHZ4a
	 WPxtPWAyJQUtw==
Message-ID: <42bbd9bd83e0887c469a555bc5c76ec06aee722c.camel@kernel.org>
Subject: Re: [PATCH 1/1] Don't always trust server inode size while client
 holds write delegation
From: Trond Myklebust <trondmy@kernel.org>
To: Dai Ngo <dai.ngo@oracle.com>, anna@kernel.org
Cc: linux-nfs@vger.kernel.org
Date: Mon, 13 Apr 2026 15:19:51 -0700
In-Reply-To: <20260401185322.2691848-1-dai.ngo@oracle.com>
References: <20260401185322.2691848-1-dai.ngo@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.58.3 (3.58.3-1.fc43) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

Hi Dai,

On Wed, 2026-04-01 at 11:52 -0700, Dai Ngo wrote:
> With a write delegation, the server permits the client to buffer
> writes
> and associated metadata updates (including file size changes) locally
> and
> defer propagating them to the server. As a result, the server-
> reported
> GETATTR size may legitimately lag behind the client=E2=80=99s cached size=
 for
> the
> duration of the delegation, so it must not be treated as
> authoritative.
>=20
> This patch modifies nfs_wcc_update_inode to update the cached inode
> size
> only when the client does not hold a write delegation or the
> cache_validity
> of the nfs_inode has the NFS_INO_INVALID_SIZE bit set.
>=20
> Signed-off-by: Dai Ngo <dai.ngo@oracle.com>
> ---
> =C2=A0fs/nfs/inode.c | 7 +++++--
> =C2=A01 file changed, 5 insertions(+), 2 deletions(-)
>=20
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 4786343eeee0..21161ebbd953 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -1649,8 +1649,11 @@ static void nfs_wcc_update_inode(struct inode
> *inode, struct nfs_fattr *fattr)
> =C2=A0			&& (fattr->valid & NFS_ATTR_FATTR_SIZE)
> =C2=A0			&& i_size_read(inode) =3D=3D
> nfs_size_to_loff_t(fattr->pre_size)
> =C2=A0			&& !nfs_have_writebacks(inode)) {
> -		trace_nfs_size_wcc(inode, fattr->size);
> -		i_size_write(inode, nfs_size_to_loff_t(fattr-
> >size));
> +		if ((!nfs_have_write_delegation(inode)) ||
> +			(NFS_I(inode)->cache_validity &
> NFS_INO_INVALID_SIZE)) {
> +			trace_nfs_size_wcc(inode, fattr->size);
> +			i_size_write(inode,
> nfs_size_to_loff_t(fattr->size));
> +		}
> =C2=A0	}
> =C2=A0}
> =C2=A0

Under what circumstances are you seeing this making a difference?
Please see the call to nfs_writeback_check_extend() in
nfs_writeback_update_inode() which is supposed to prevent the issue
you're talking about.

--=20
Trond Myklebust
Linux NFS client maintainer, Hammerspace
trondmy@kernel.org, trond.myklebust@hammerspace.com
