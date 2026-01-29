Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5AB0C236A73
	for <linux-nfs@vger.kernel.org>; Thu, 29 Jan 2026 16:00:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1769702428; cv=none; b=RBbthOuqOB18A/6QzvYiaWl1iSFUpr23C1pmEFqrHYQa6iqgOcLQiBTVJSfKEL+ZkeqLVmGN0CwF4zm9RlCwRGKUXC3VVGdu7JCS365xUyQgon2IWA4RM2KPW/tNpExcdXxsl+lk52ZkbBpqe5OPDurZ1UuMrSCKdLl/InRkWkg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1769702428; c=relaxed/simple;
	bh=AuHVRqR8uBahUGuGlfmwZYCWE1s8NDVH1dBkrj6XwGE=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=oHa5TkFL2nrfYLrHk0mFzfwM5z45s30go26drp/5H4O7GGuKYahf5z8LlHljoOEK3rdj4IGCsWwdm8bGC2qCaLE2lXw2ea0sfkF/q1GrvaOl/H0e2BUc6VztHAhLT08AdBMbMjGIy2kfAAuej5U+V4AROTcs/DMfdPyNLo5SygE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=OItCVIkC; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="OItCVIkC"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 50E07C4CEF7;
	Thu, 29 Jan 2026 16:00:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1769702428;
	bh=AuHVRqR8uBahUGuGlfmwZYCWE1s8NDVH1dBkrj6XwGE=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=OItCVIkCZaLzIWLcIEqJ+zEI2OuILSEncqY/uwUYjI+HbmvBGggzGn4D2MECyBfjq
	 ERZd3C9AoKpX/7mrBtSqK2pfx2ckOVwZhcZy1hsIua529GEcXpKqlSm8xDjaA23y52
	 RA0EaoYOw3W+LwL9mu2x4LLwI98RUre01B9T0NNwZC3lTiM+FmertTKmXi1RkmnxjQ
	 BIybo/Jp0uB1g+fOOiPPnIYqlk0/htv3ndDTWRj2EWWmdox7aoxhR8ZeY8uOhSAsdU
	 GclyDA3a2158+nsNTv+5IMhXVUQZ6RyUUheQB9KdEyOf4gRLcnr2q2vFd1UIKawY5s
	 Pq8x7HXufIZGA==
Message-ID: <5d5f6605c0ba8751723b588a4d8e1def37e23c78.camel@kernel.org>
Subject: Re: [PATCH 0/6] Fix up NFS client mount option regressions
From: Trond Myklebust <trondmy@kernel.org>
To: Li Lingfeng <lilingfeng3@huawei.com>, Alkis Georgopoulos
 <alkisg@gmail.com>
Cc: linux-nfs@vger.kernel.org, yangerkun <yangerkun@huawei.com>, 
 "chengzhihao1@huawei.com"
	 <chengzhihao1@huawei.com>, "zhangyi (F)" <yi.zhang@huawei.com>, Hou Tao
	 <houtao1@huawei.com>, wangzhaolong1@huawei.com
Date: Thu, 29 Jan 2026 11:00:26 -0500
In-Reply-To: <cb5cd472-8989-451d-9da7-7d250027c27e@huawei.com>
References: <cbd4d74d-21c4-42d6-9442-276fd98313ee@gmail.com>
	 <cover.1764388528.git.trond.myklebust@hammerspace.com>
	 <cb5cd472-8989-451d-9da7-7d250027c27e@huawei.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.58.2 (3.58.2-1.fc43) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Thu, 2026-01-29 at 15:06 +0800, Li Lingfeng wrote:
> Hi Trond,
>=20
> =E5=9C=A8 2025/11/29 12:06, Trond Myklebust =E5=86=99=E9=81=93:
> > From: Trond Myklebust <trond.myklebust@hammerspace.com>
> >=20
> > The recent changes to suppress the 'ro' and 'rw' mount options when
> > mounting the same NFS filesystem with different settings are
> > causing
> > confusion with users, and are an unnecessary restriction. They
> > represent
> > a functionality regression.
> >=20
> > The following patch set reverts the regressions, before applying a
> > different set of fixes to address the original problem, which was
> > one of
> > the NFSv4 mount automounter code failing to propagate the correct
> > mount
> > options.
> >=20
> > Trond Myklebust (6):
> > =C2=A0=C2=A0 Revert "nfs: ignore SB_RDONLY when remounting nfs"
> > =C2=A0=C2=A0 Revert "nfs: clear SB_RDONLY before getting superblock"
> > =C2=A0=C2=A0 Revert "nfs: ignore SB_RDONLY when mounting nfs"
> > =C2=A0=C2=A0 NFS: Automounted filesystem should inherit ro,noexec,nodev=
,sync
> > flags
> > =C2=A0=C2=A0 NFS: Fix inheritance of the block sizes when automounting
> > =C2=A0=C2=A0 NFS: Fix up the automount fs_context to use the correct cr=
ed
> >=20
> > =C2=A0 fs/nfs/client.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 | 21 +++++++++++++++++----
> > =C2=A0 fs/nfs/internal.h=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0 |=C2=A0 3 +--
> > =C2=A0 fs/nfs/namespace.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 | 1=
6 +++++++++++++++-
> > =C2=A0 fs/nfs/nfs4client.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 | 18 +++=
+++++++++++----
> > =C2=A0 fs/nfs/super.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 | 33 +++------------------------------
> > =C2=A0 include/linux/nfs_fs_sb.h |=C2=A0 5 +++++
> > =C2=A0 6 files changed, 55 insertions(+), 41 deletions(-)
> After this series of patches was merged, I found that the issue
> described
> in link [1] has appeared again.
>=20
> [root@nfs-client1 ~]# mount /dev/sda /mnt2
> [root@nfs-client1 ~]# echo "/mnt2 *(rw,no_root_squash,fsid=3D0)"
> >/etc/exports
> [root@nfs-client1 ~]# systemctl restart nfs-server
> [root@nfs-client1 ~]# mount -t nfs -o ro,vers=3D4 127.0.0.1:/ /mnt/sdaa
> [root@nfs-client1 ~]# mount -t nfs -o rw,vers=3D4 127.0.0.1:/ /mnt/sdaa
> [root@nfs-client1 ~]# mount -t nfs -o ro,vers=3D4 127.0.0.1:/ /mnt/sdaa
> [root@nfs-client1 ~]# mount -t nfs -o rw,vers=3D4 127.0.0.1:/ /mnt/sdaa
> [root@nfs-client1 ~]# mount | grep nfs4
> 127.0.0.1:/ on /mnt/sdaa type nfs4=20
> (ro,relatime,vers=3D4.2,rsize=3D1048576,wsize=3D1048576,namlen=3D255,hard=
,fat
> al_neterrors=3Dnone,proto=3Dtcp,timeo=3D600,retrans=3D2,sec=3Dsys,clienta=
ddr=3D12
> 7.0.0.1,local_lock=3Dnone,addr=3D127.0.0.1)
> 127.0.0.1:/ on /mnt/sdaa type nfs4=20
> (rw,relatime,vers=3D4.2,rsize=3D1048576,wsize=3D1048576,namlen=3D255,hard=
,fat
> al_neterrors=3Dnone,proto=3Dtcp,timeo=3D600,retrans=3D2,sec=3Dsys,clienta=
ddr=3D12
> 7.0.0.1,local_lock=3Dnone,addr=3D127.0.0.1)
> 127.0.0.1:/ on /mnt/sdaa type nfs4=20
> (ro,relatime,vers=3D4.2,rsize=3D1048576,wsize=3D1048576,namlen=3D255,hard=
,fat
> al_neterrors=3Dnone,proto=3Dtcp,timeo=3D600,retrans=3D2,sec=3Dsys,clienta=
ddr=3D12
> 7.0.0.1,local_lock=3Dnone,addr=3D127.0.0.1)
> 127.0.0.1:/ on /mnt/sdaa type nfs4=20
> (rw,relatime,vers=3D4.2,rsize=3D1048576,wsize=3D1048576,namlen=3D255,hard=
,fat
> al_neterrors=3Dnone,proto=3Dtcp,timeo=3D600,retrans=3D2,sec=3Dsys,clienta=
ddr=3D12
> 7.0.0.1,local_lock=3Dnone,addr=3D127.0.0.1)
> [root@nfs-client1 ~]# uname -a
> Linux nfs-client1 6.19.0-rc7+ #178 SMP PREEMPT_DYNAMIC Thu Jan 29=20
> 14:06:54 CST 2026 x86_64 x86_64 x86_64 GNU/Linux
> [root@nfs-client1 ~]#
>=20
> [1]=20
> https://lore.kernel.org/all/20241114045303.1656426-1-lilingfeng3@huawei.c=
om/
>=20
> Thanks,
> Lingfeng.

What does the output of "cat /proc/fs/nfsfs/volumes" show? Does it show
more than 2 devices associated with that fsid?
=20
--=20
Trond Myklebust
Linux NFS client maintainer, Hammerspace
trondmy@kernel.org, trond.myklebust@hammerspace.com
