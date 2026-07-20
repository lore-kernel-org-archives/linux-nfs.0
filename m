Received: from mail-43101.protonmail.ch (mail-43101.protonmail.ch [185.70.43.101])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 338AD38C2A0
	for <linux-nfs@vger.kernel.org>; Mon, 20 Jul 2026 03:18:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=185.70.43.101
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784517523; cv=none; b=TSDb7OXt3+euDm71M3WNy44gPOWSbW2ADYiZbVMoO7x6CpkPubcFxcpkoi7zN7tiCcnr/5gpnSzMENGfXQ9CV5EOQqoLbInp9LuhmudwSnd8qc8orlqpfRuXNSeiOgsB4Llv8FXkm7G2vBgAgU97jMNuwD78om3MwDbccQf5Zjc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784517523; c=relaxed/simple;
	bh=iAh58rF1DzP2PBwFYBBXRLMHW04vBLDsH0Uaz1PZNVQ=;
	h=Date:To:From:Subject:Message-ID:MIME-Version:Content-Type; b=CFG8jhVhIz8auQ4B6XWrw6eDg1y1PPklJzUgO5CSqpdLR71EWowKCmhUtVTX1KwnGJO+8Xa1EY5iRKOFqXAbWe1bAQ+bBhRwTBhlagfs4fGoxQ8Kkh0P9jvEIjd+Gs4gK368Bd/LYhs285wuMrPjeGfKbYmI8lMRHiiTL3AMZEQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=proton.me; spf=pass smtp.mailfrom=proton.me; dkim=pass (2048-bit key) header.d=proton.me header.i=@proton.me header.b=SPEZHu2q; arc=none smtp.client-ip=185.70.43.101
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=proton.me
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=proton.me
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=proton.me header.i=@proton.me header.b="SPEZHu2q"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=proton.me;
	s=protonmail; t=1784517514; x=1784776714;
	bh=3kJro2eOBqhsrvHp7va/fsg9z3nYmeF3TL9wm56mPKs=;
	h=Date:To:From:Subject:Message-ID:Feedback-ID:From:To:Cc:Date:
	 Subject:Reply-To:Feedback-ID:Message-ID:BIMI-Selector;
	b=SPEZHu2qsevXFanheOQjPHvk0VUN9jmXbvtP+cVV4OwydS1YoEhJBoYQTAl7KO7TD
	 X1wMLLSYODUXQDU56YbA2IZJQELTSUOplFWJMVTWRndGKOUHHvvBozcYAHIiEI7YKX
	 cn4LEzVJ9QprgQPfvUEgIckIzCfEQQLj49oPY0eJ5Z/TmKJnWHqbDxqitWXQaupW4i
	 vZALrQaKh3AS5J79WRXbddCyp2SvXK8yhe3ODqwuCRwllJt0g9QcnPS8ru/8cxfdsj
	 iFR56Z5Cyl7h42gYKHbVJZzUqmVe1X7dtiiQVPBB2mABpsYKSjZNBBujwF2pPv9BfZ
	 cw67Ay2GIac8A==
Date: Mon, 20 Jul 2026 03:18:30 +0000
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
From: Michael <michaely4ng@proton.me>
Subject: [BUG] NFSv4.2: futimens() returns success without sending SETATTR
Message-ID: <nMlXgkbm-9ZP_fFN16OpzFd4kwNlyXq169-6CoOE4nuHyTsmGaFeJgzuhj3grRboJKg9RapKov2_FJ1E3BCL0oZ7UNzF0pgwwhVC6VOVJYQ=@proton.me>
Feedback-ID: 153107444:user:proton
X-Pm-Message-ID: 0b8c65af1041a86a4c0c50969c9c542dbdca64d7
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hello,

I am seeing a reproducible NFSv4.2 timestamp issue where an fd-based timest=
amp update returns success but does not appear to send an NFS SETATTR opera=
tion or update the server-side inode.

Client environment:

Distribution: Fedora 44
Kernel version: 7.1.3 x86_64
GNU coreutils version: 9.10
NFS utilities version: 2.8.7

Reproducible with both 7.1.3-cachyos1.lto.fc44.x86_64 and the stock Fedora =
7.1.3-201.fc44.x86_64 kernel.

NFS mount options:

home:/tank on /mnt/tank type nfs4 (rw,relatime,vers=3D4.2,rsize=3D1048576,w=
size=3D1048576,namlen=3D255,hard,fatal_neterrors=3Dnone,proto=3Dtcp,timeo=
=3D50,retrans=3D2,sec=3Dsys,clientaddr=3D169.254.87.187,local_lock=3Dnone,a=
ddr=3D169.254.42.42,_netdev,x-systemd.automount,x-systemd.mount-timeout=3D5=
,x-systemd.idle-timeout=3D15min)

Also reproducible with the noac option.

NFS server export options:

/tank           169.254.0.0/16(rw)


The failing case is the fd-based form (futimens) used by GNU touch:

touch -d '2004-02-29 16:21:42' /mnt/tank/test

Relevant strace output:

openat(AT_FDCWD, "/mnt/tank/test",
       O_WRONLY|O_CREAT|O_NOCTTY|O_NONBLOCK, 0666)
    =3D 3</mnt/tank/test>

utimensat(0</mnt/tank/test>, NULL,
          [{tv_sec=3D1078032102, tv_nsec=3D0},
           {tv_sec=3D1078032102, tv_nsec=3D0}], 0)
    =3D 0

The file descriptor has been duplicated to fd 0 by coreutils before the uti=
mensat() call.

Observed behaviour:

1. utimensat() returns success.
2. stat on the NFS client temporarily shows the requested atime and mtime.
3. The server-side backing inode remains unchanged.
4. The NFS client SETATTR counter does not increment.
5. After client attribute revalidation, the client timestamp reverts to the=
 unchanged server timestamp.
6. sync and a clean unmount do not propagate the timestamp change.

Example client-side result immediately after touch:

Access: 2004-02-29 16:21:42.000000000 +1100
Modify: 2004-02-29 16:21:42.000000000 +1100
Change: 2026-07-20 09:54:29.303441484 +1000

At the same time, the server-side inode still shows:

Access: 2026-07-20 09:50:16.502885123 +1000
Modify: 2026-07-20 09:50:16.502885123 +1000
Change: 2026-07-20 09:50:16.502885123 +1000

The client and server report the same inode number and birth timestamp, so =
they appear to be referring to the same file.

As a control, a pathname-based utimensat() works correctly:

utimensat(AT_FDCWD, "/mnt/tank/test",
          [{tv_sec=3D1078032102, tv_nsec=3D0},
           {tv_sec=3D1078032102, tv_nsec=3D0}], 0)
    =3D 0

For the pathname-based call:

1. The NFS client SETATTR counter increments.
2. The server-side inode timestamp is updated immediately.

This therefore appears specific to the fd-based futimens() / utimensat(fd, =
NULL, ...) path.


The minimal distinction is:

fd-based timestamp update:
    returns success
    no SETATTR observed
    server inode unchanged
    update later disappears

pathname-based timestamp update:
    returns success
    SETATTR observed
    server inode updated

Please let me know if further information or testing is required.

Regards,
Michael Yang
