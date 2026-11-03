Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=178.154.239.94
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793706042;
	b=3E7ooXtlKa0wiwZ8sssjB0QPgLVqJ5JUdI5mBs8+2if1Rx6H3vq68S52FhnpzOWRqMRh
	 NNtcergOdiBWk+u6H6FJhCq9skmqeaKX9yAqndXmuObp3RSuJspWPignOk6BTj+IGsldZ
	 Kg7kRGAMk3QvqBgM3DxNni0nyupoGMdAbnLt3Ke+i/xbYH67hi5DFm84e2kPGDEH3H95g
	 vM69M3h8wyXR8p/njw6sO+tUtymd6JzUOCGOADwuDP9996BttF0yDiRS8Kq1QZ2zNoXve
	 qdk7x37yWaZfPRWlStWSQFVIQTL+rtykfh4dunCBR+qyWDhn2HHMaOKFeXhb8N+L1Lg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793706042;
	h=DMARC-Filter:Received:Received:X-Yandex-Fwd:DKIM-Signature:Date:From:
	 To:Cc:Subject:Message-ID:X-Mailer:MIME-Version:Content-Type:
	 Content-Transfer-Encoding;
	bh=VB1JvaFCsJRPdnzJG1iBOdkvJELGIQiMHFOB04cTo7E=;
	b=sptNXHlIuaGoXU5mwhH8l9QSXykuz3Wy03zFLh+88QM//ZZEqLY/7+89GcQI72VWCPHv
	 C/O6PrT/CZ692OnohgE+YClqX7dO6h7SyChx74iYPUM9Fj0rRRacCUJaCTPfFuiExXA51
	 hszPj5ilMVkLXgVWuWnLhdcoM0kmob9P0Cqmri33DZtOdR6GoHYEvWo0dvkS/IzbTb7md
	 ptTznFE3fUIG8DyWBFZEeWdRp1EiyWW+xy6HwoTW9YIk4VU24mCV5ni5x9iDSGhNWV/38
	 5k3z4nM1s0yF5HPO3Py/PVLpi+S0jmzQOLn2eGb5m0Ac3UtiSwqo/WNZ4c24/T0XJwA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=homerow.info;
	spf=pass smtp.mailfrom=homerow.info;
	dkim=pass header.d=homerow.info header.i=@homerow.info header.a=rsa-sha256 header.s=mail header.b=d1HHxQyL;
	arc=none smtp.remote-ip=178.154.239.94
Received: from forward401a.mail.yandex.net (forward401a.mail.yandex.net [178.154.239.94])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 398C6606A329;
	Tue,  3 Nov 2026 11:40:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 398C6606A329
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=homerow.info
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=homerow.info
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=homerow.info header.i=@homerow.info header.a=rsa-sha256 header.s=mail header.b=d1HHxQyL
Received: from mail-nwsmtp-smtp-production-main-54 (mail-nwsmtp-smtp-production-main-54.yp-c.yandex.net)
	by forward401a.mail.yandex.net (postfix) with ESMTPS id 2076CC3875;
	Tue, 03 Nov 2026 14:40:32 +0300 (MSK)
Received: by mail-nwsmtp-smtp-production-main-54 with ESMTPSA id TeJRK6QhCSw0-SHz7tSYQ;
	Tue, 03 Nov 2026 14:40:31 +0300
X-Yandex-Fwd: 1
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=homerow.info;
	s=mail; t=1793706031;
	bh=VB1JvaFCsJRPdnzJG1iBOdkvJELGIQiMHFOB04cTo7E=;
	h=Message-ID:Subject:To:From:Cc:Date;
	b=d1HHxQyLrh5MRz+d5gy++PCaJfjjydHNGow0Ldy23P62+hQC23tMFDOU/oi9nJwIP
	 deXh22Xkrj+DHCM/aUhNEv1pqUd/nyYQzPUX5rbCKphEziHpgt0iU/bghgYApy3/pR
	 T0wAKgGtVwgrAmVS3WGenYJFhjMWsSBIn7kV0/vI=
Authentication-Results: mail-nwsmtp-smtp-production-main-54; dkim=pass header.i=@homerow.info
Date: Tue, 3 Nov 2026 12:40:27 +0100
From: Marco <lists@homerow.info>
To: Chuck Lever <cel@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: NFS client: mkdir on existing, uncached dir returns EROFS instead
 of EEXIST under ro bind mount
Message-ID: <20261103124027.39f703e7@homerow>
X-Mailer: Claws Mail 4.4.0 (GTK 3.24.52; x86_64-pc-linux-gnu)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi,

on Linux 6.12.48 (Debian 13) and 7.1.6 (Debian 14), calling mkdir()
on a directory that already exists on an NFSv4.2 mount, through a
read-only bind mount, returns EROFS instead of EEXIST, as long as
the directory has not been looked up (e.g. listed via readdir of its
parent) by this client yet. Also reproducible on Debian 14 with a
custom compiled 7.3.1 kernel.

This breaks Flatpak/bubblewrap, which creates mount points with
mkdir() and treats EEXIST as success but EROFS as fatal. With the
Flatpak tree on NFS, apps fail after each reboot with "bwrap: Can't
mkdir parents for ...: Read-only file system" until the tree has
been walked once. The issue only occurs on NFS mounts, local
file systems work fine with Flatpak/bubblewrap.

To reproduce:

# vanilla Debian install (stock kernel or 7.3.1, same result)

# set it up (root)
apt install nfs-kernel-server
mkdir -p /mnt/nfstest /etc/exports.d /srv/nfstest
echo '/srv/nfstest 127.0.0.1(rw,sync,no_subtree_check,no_root_squash)' > /e=
tc/exports.d/nfstest.exports
mount -t tmpfs -o size=3D16m tmpfs /srv/nfstest
mkdir -p /srv/nfstest/reprotest1/sub
exportfs -ra
mount -t nfs4 -o vers=3D4.2 127.0.0.1:/srv/nfstest /mnt/nfstest

# test (as regular user)

# 1st invocation
unshare -rm sh -c 'mount --bind "$1" "$1" && mount -o remount,bind,ro "$1" =
&& mkdir "$1/sub"' sh /mnt/nfstest/reprotest1
# =E2=86=92 mkdir: cannot create directory =E2=80=98/mnt/nfstest/reprotest1=
/sub=E2=80=99: Read-only file system

# walk the file system
ls /mnt/nfstest/reprotest1
# =E2=86=92 sub

# 2nd invocation
unshare -rm sh -c 'mount --bind "$1" "$1" && mount -o remount,bind,ro "$1" =
&& mkdir "$1/sub"' sh /mnt/nfstest/reprotest1
# =E2=86=92 mkdir: cannot create directory =E2=80=98/mnt/nfstest/reprotest1=
/sub=E2=80=99: File exists

strace of the original failure (bwrap):
  mkdirat(7, "app", 0700)   =3D -1 EEXIST (File exists)
  mkdirat(8, "share", 0700) =3D -1 EROFS (Read-only file system)
  (but "share" exists)

I believe this behaviour is not intended. Let me know if I should
provide more info.

Note: I'm not subscribed, so please CC me.

Regards
Marco
