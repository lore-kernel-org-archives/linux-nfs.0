Received: from fhigh-b6-smtp.messagingengine.com (fhigh-b6-smtp.messagingengine.com [202.12.124.157])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 934E74ED1AC;
	Tue, 22 Sep 2026 20:50:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.157
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790110230; cv=none; b=fntVjNeAaqwy0IygA+CPYGp24T168318pIWkkAZiYv6IY+O4XBuMReMTMU0P0BQAosX/MWOeFUwcEBck2NHfSIU+D2iYQ/Z5y0/6z/zgHRXnz8MPSt3TSdYuO9DsDpPjODpUkIDCkMjTI49+FbIc7wMDXj6TNjHA69yRlYmKgmE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790110230; c=relaxed/simple;
	bh=HbgCPzgoAKay2IMV+ycxnDXMpBwaWGsOh9mCKh23T2I=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=pm66uiy4bHcU0L4a2RQW0ost8gtqTp0n7OkJRVk32YG4MYug8uXPaclj9HQW42/cXqnxL2gQrHiqOlUbkBTNW/wnRLz+RWVx9hi4e1z0GZF4NtBlE0k60xDKgLFGA32JiYfGAYM/4PkQO5PY90CSoIOyVx5v+1aUaRQhndXrAog=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=lagOQRgN; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=lhh9PPre; arc=none smtp.client-ip=202.12.124.157
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="lagOQRgN";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="lhh9PPre"
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailfhigh.stl.internal (Postfix) with ESMTP id E95187A00C8;
	Tue, 22 Sep 2026 16:50:06 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-06.internal (MEProxy); Tue, 22 Sep 2026 16:50:07 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1790110206; x=1790196606; bh=gBk8S0l/2e3+GtAciCVbs4AYRTzJIY+8BCB
	sKo2GZJ8=; b=lagOQRgNC/TfEsXp3NVXbbcx9jbsfbFhyfalYCnj76VN/19M1r6
	KgA0vocqrBil1WE79fFyYr4+01OD7oyaOEiv9ENrkWEPKjV+4kKjD3j2P2Ka8m+H
	YmzBhwO74UMlWwgs8iLj40XOLv3bOzB4ZJsPt2w2212CGJYon2XJIZtk69dmec7C
	3QsW8yq7QZh28gLRlC/rVIvpzQFmtCEOeBgqGPDeipRhRtGoSqGHCvVa3cTcCikO
	XYKYLO4OI+lzHrYGJjxymFnBpUEsB0aAWRWJV1IeInsNueiuYa5jbXScAHF6jTmj
	cwAM/YKqCvB2+15ZjWTiFEDwl5ZIdoWoBoQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1790110206; x=
	1790196606; bh=gBk8S0l/2e3+GtAciCVbs4AYRTzJIY+8BCBsKo2GZJ8=; b=l
	hh9PPre5vD2ttPIBX12gDk5KtL3xtNp7g90nYifsTNbjIi3D2upTbX85pdcscs+Q
	pR1NyvHYi0aB6MpGZt3febZt/trm+wT0JGXcUsrPkfgBjhZu2/2sytQrn7dPBpfd
	mPtFPd6SbIAdPqO34CxUJor39CZs2NLHR5+3axPZwR9jfoTiF+pPb8WDdSZjYcWR
	/HtW6XPm+MqsT7k7ro+cI0oMLCKN20gDu7NCrqUoIz0TbVwZQ8xS6exXmgZvr6GE
	NdoeNBlAcxq+UkZ7RxJUgR581IY8mAD6WVi9jevZ27aKmrf0wNk8MFdmxxAjuBCt
	549Hnjjb6pJHXsgSKtTJA==
X-ME-Sender: <xms:_umyakePbVoxTflREMV19kxOb4xkLR2JpY7R2cNTtuGKLqIVxVRyVw>
    <xme:_umyahLqAyYRPGwb2UdkKIOe7slt5Ip2_PZKM7SU-P4bHdIznHyZt_CM6Ot8b_17T
    YHeMofJ8ffKLdzAlQTzoaKVRsVWFdMGjvfERTxfl67OzgYdH2Q>
X-ME-Received: <xmr:_umyakhMlybWP2FozaLbD1LQOVzmH9TSbbUzA4f5TlfSakfx_Qmsf-p3UMWNv3U3o8Zk6WhRxYmAKR8vyxSk_bsZzHoADhE>
X-ME-Proxy-Cause: dmFkZTFGysTC7TzCzVoSP9+sAC92X3mLNvOTcRxStzmIwDQ+HB/it5VtDQ54r5Ko+5scrm
    YVjbu87IdZfcv9BsxgM+oMQIqKM3vWoqPP+dW/wtW97wvR2QDsTWzRKWZkZxt9SFRiR8tp
    GS4kacOGWPS+6rq1CQWvvNjGEm4dGFKdRw3P67LPVHTNe4jI/QaixdMRkCWkSixEpKygIE
    q3WFEctywLUpdg/CW1Z0gKhbnkl2rLrMeWymj4oVTjyPW2v25UeV5pF/5DCz59EbgIIc5N
    IMFC+smh5r7G7ixtlA9yn4WwAGe1nT0qEXf+Us97OKPpwHmjPXebpMWTb4pBcrbqGHX4PZ
    vJ1ER04myVA8tGViPmRFKdbLyKpzcQOnTnL7o9Wm7Bwno1Hdmq2H5LuWPtn70e8eQrWuAb
    TqJSxCpSWOa5hInFaoLS5CJ6jjE7Ti7zom4Dc0b6joPpihzYx859agJTbgdZebX9gAtJK9
    v54QPniA1JrLPy7Zaqxmu/2k0B4OZBEpLOWANSl0YJ+GV2IkiBfg9HQqIFdNhFGgRYuX4y
    wkgK9QRlVOwth9Fq0lLQZrCOovSraCXcMMqczPnw/SeYaKpqy6fx3G9ZZmxdRRbKoQtde5
    qu525YC9i423Gik7/OXOio8gI7fH/0x8hwcNS42dw0LinaXzkwS5Ei+r02yQ
X-ME-Proxy: <xmx:_umyavQuIh4_uFQMziqBazPujayfi78zaJtmCevr-qMEqqvIU7aNlA>
    <xmx:_umyauUR8VaVtikifacjDQeoVTNmj4QO6WWbZXs26PpWDHybwq8zgA>
    <xmx:_umyarTKgz77oxpda6SGQ3OIkq8fnzafLd6M5cY1rQ6tjP3bRRiz8w>
    <xmx:_umyagnb30MkohdMHXnpSrNsc1IY5Sd2F47IwEruXsL5iFaebPP5AQ>
    <xmx:_umyah2Mhd2Du9D9IB1gJgdzzoLogePuCJBRKzkrLKYvyQducFM_bzOv>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 22 Sep 2026 16:50:04 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Jimmy Zuber" <jamz@amazon.com>
Cc: "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
 stable@vger.kernel.org
Subject:
 Re: [PATCH RESEND] NFS: Fix stale negative cache on failed nfs_mkdir()
In-reply-to: <20260922175656.2833041-1-jamz@amazon.com>
References: <20260922175656.2833041-1-jamz@amazon.com>
Date: Wed, 23 Sep 2026 06:49:59 +1000
Message-id: <179011019969.37859.10884923411198387227@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Wed, 23 Sep 2026, Jimmy Zuber wrote:
> Since commit 8376583b84a1 ("nfs: change mkdir inode_operation to return
> alternate dentry if needed"), nfs_mkdir() no longer drops the dentry on
> RPC failure.  A negative cache value can then result in spurious ENOENT
> results for further operations within that directory, such as open or
> stat.
>=20
> We observed this breaking some applications where an EEXIST on mkdir
> caused the application to assume the directory to exist, only to fail
> operations within that directory due to the retained negative cache
> entry.  The other create paths, nfs_create() and nfs_mknod(), still drop
> the dentry on failure.  This patch restores the previous behavior.
>=20
> Fixes: 8376583b84a1 ("nfs: change mkdir inode_operation to return alternate=
 dentry if needed")
> Cc: stable@vger.kernel.org # v6.15+
> Signed-off-by: Jimmy Zuber <jamz@amazon.com>

Reviewed-by: NeilBrown <neil@brown.name>

Thanks for finding and reporting this!

NeilBrown


> ---
>=20
> Resend of:
> https://lore.kernel.org/linux-nfs/20260819015111.2743908-1-jamz@amazon.com/
>=20
> No change to the patch itself; rebased onto v7.3-rc4 and Cc'ing NeilBrown as
> the author of the Fixes: commit.  nfs_mkdir() in v7.3-rc4 still returns the
> error without unhashing @dentry, and vfs_mkdir()'s error path only calls
> end_creating()/end_dirop(), which unlocks the parent and dputs the dentry, =
so
> the hashed negative dentry survives in the dcache.
>=20
> We reproduced this against a local knfsd export over NFSv4.1.  The export is
> mounted several times with "nosharecache" so that each mount acts as an
> independent client with its own dcache:
>=20
>   # /etc/exports
>   /srv/nfs 127.0.0.1(rw,sync,no_subtree_check,no_root_squash,fsid=3D0)
>=20
>   for i in $(seq 0 5); do
>       mount -t nfs4 -o vers=3D4.1,nosharecache,acdirmin=3D30,acdirmax=3D60 \
>           127.0.0.1:/ /mnt/nfs$i
>   done
>=20
> For each of 40 new cache/<id> directories, every mount stats the directory =
to
> seed a negative entry, then all mounts race to mkdir it.  The winner writes=
 a
> file and renames it, and the losers that got EEXIST then read that file bac=
k.
> On a vanilla v6.17 kernel, the 200 loser reads were:
>=20
>   unpatched:   read OK   0 / ENOENT 200
>   patched:     read OK 200 / ENOENT   0
>=20
>  fs/nfs/dir.c | 2 ++
>  1 file changed, 2 insertions(+)
>=20
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index 49394123b..a26c459ff 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -2490,6 +2490,8 @@ struct dentry *nfs_mkdir(struct mnt_idmap *idmap, str=
uct inode *dir,
>  	trace_nfs_mkdir_enter(dir, dentry);
>  	ret =3D NFS_PROTO(dir)->mkdir(dir, dentry, &attr);
>  	trace_nfs_mkdir_exit(dir, dentry, PTR_ERR_OR_ZERO(ret));
> +	if (IS_ERR(ret))
> +		d_drop(dentry);
>  	return ret;
>  }
>  EXPORT_SYMBOL_GPL(nfs_mkdir);
>=20
> base-commit: c4e9f74da4389a6b3e505d329d99232915a6b9cd
> --=20
> 2.50.1
>=20
>=20

