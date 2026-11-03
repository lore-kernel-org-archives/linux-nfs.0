Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793712305;
	b=BOorb9JaMcybMlbwb1/z70GcIDEHeWVOdPsW8n5kTqGxrHQ0au1mPG5GcXJWo3+2h4rZ
	 0eQwdyuUa5Kp7OzcMrK/ANS2DPrgIWjDb1z71x+N9XiOdKcIisd/toucULh5dYaHgts5w
	 f4bF0PHLe1cz424R/peV+xcDeXQkCI9Xco1h2nmOZJtRJPW3p698voq3oy18jMD8wiB1A
	 O7Tkq07oD2+nvgn1SA4hep9s1jB+SqtxB6eD0COBsxUrl8aeahuN4amMX6L1rJkSZbxB/
	 zHUWBirk3YIjTtYNf0CCcFGb0KVbJ4/5X9gRPGH+vtacObF3INEPPT5xJZh46NgaKnQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793712305;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=6+pb12k/uFUuiunr+EWtu/59owzI4Wi6if/ld6NXuDI=;
	b=uJbnxGEWWyLVFij6LYUy5qWLVEIIDS42oARohzZipV1/vmeufn/bXzotchAOSkGThkSh
	 IqWxjiOOLU6rebkNIet8I/u/dMYa/FNiOw7aBRK6sjlY7ZX6y5rut8/fSquHSMTyWW8ll
	 EY9VfH9eWJGFzJf7PYGTg1v5tcwq7nSbtvin1rvfcKuMzLUK1XlXGsJYlKqlN+KIevm+S
	 65b/aNpMPtefomzqZmeEOYIpF3c0m7WB6o2a1eW/OfOEVM3wXC9nBIvvBl+hzSyr0nC83
	 WltJSKzztXk2qwgPRfEga0RMloSVPRyVEekbmjgBvumsgW3NrcUkEcMRUYdt5z/0ykg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Qh2jMISf;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B0D88606A328
	for <linux-nfs@vger.kernel.org>; Tue,  3 Nov 2026 13:25:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Qh2jMISf
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 07D561F00919;
	Tue,  3 Nov 2026 13:25:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793712304;
	bh=6+pb12k/uFUuiunr+EWtu/59owzI4Wi6if/ld6NXuDI=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=Qh2jMISfcaW4V3DFjoF60zQTuTE1YQV1icJ2mvyhbYECSWOC+e5uyulI8eLDBnObd
	 apFFRi0JaT1FCVSf/5qFnxNAbW0b90BwUOOanT7raoMddqM44qAXeyrlavpl5kwCrc
	 UW7SVz+lkCiQQXI2kCevcBcNEA79trmEQWfVHyipmteAAsc8t+QBuXmUEo09X/QDwa
	 eedbL5CEfY3at1hqWttaGY4zIrfIpOSOUOtrs1zFwskWlK+z0uixP4UH7E62s05iDG
	 mLZW42zavKa4P/pnDIbFhNb3Cwxwbl//33rmHTJMxATA0As1NZFzLE8QzlC1P1cCyr
	 7Re+DmXdNJGeA==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 51423F40066;
	Tue,  3 Nov 2026 08:25:03 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 03 Nov 2026 08:25:03 -0500
X-ME-Sender: <xms:r-DpamsPqEAA_hANXARBKsgFf1K3dr-OcrAZQJYuc_4Vo3xPowBadQ>
    <xme:r-DpamSGm2FPPpGlA5hvrCfPydzoWLRKZqOjGohiKLkjaRjytj6ZccHVeGMm1rEDY
    URr-dct7Sv_n9BueluuiVyG7Kosryt3Lis1CKMrsyPO8-k7FLsl4E3n>
X-ME-Proxy-Cause: dmFkZTFPwbmYPyqA/0M3cZM9g7lTgdqPMarCnamx5J0z9LzZd1hBCaGHZXOKMp8xFFpmfj
    w79GIQ94vHeBDEQUpoT6rIVNjXTyCP74wyQCdq5b7ikmZn7Ud3v80eMm+Sxghz5cKTIwl9
    zhU5pBkjm3vR93O6BPDSBVvrYBMJTaO2dScNUNOvYiVu2TOGMLVtDsQ2sZunuUv8WwIF8k
    gOJKElEWjc7Owd9KSwrIJH9pbBzGp6Ggey7FAUPqfbpZOMT/SoLy42hXHwFRBXfsX4m6YS
    7BFCnPIPd7JstutY2HVtUeqJF+0Bujc1vnoFXbmQjaZRsTWZXXIEgTjqsGtsjfuDr3V+Qa
    3aUdqwRPpDHc0z9eSd2nwzNTkqfsaalb9xD2UwWQCYSvhXUaVeRAIviswp+khn690lNJOW
    xLpx2BkVrw961aO/OOtv/3jxb1kKmiCFn4+6uYAdRw/L+I6bsJVjL14pyLMQU+JYOFWDkz
    I5vXCntofbl+IfyvNQaI0MKohbJSRg2qbX8kjiFg+FRw1AS9oFsWPg+J5ZEPtrP88XDi7c
    Yc5ic9z10HF/xf5MVw/vVzIKLuAkV2/m8oOxms9YW9D8UA8dISMsQsTAAn9KOaKx0JzAWM
    eMcD5ESjvWUxMnDWK7QtNU8BPWkobzAsdoBzvtCPUMkcL4vaTcxg2XxnGQgg
X-ME-Proxy: <xmx:r-Dpaq1BAd3e6JVL8gBwvT33DWZuEDgyn5FK3EGOcqiw0MhpBc6N6A>
    <xmx:r-DparCsPyKLYnsKl3jIHcQhkDTvQ4cECnR3Gwm-67zKqy_OdJcIkw>
    <xmx:r-DpalPo85Oy8hOoLzSz9n0u8kuvb1Gzp9JZlXdmPduVdUTVgLATiQ>
    <xmx:r-DpagbY25CJlM1uL_skfHaO-T5wI-JNiw_bUWjAmzts2LuxykOHPg>
    <xmx:r-DpakvOJW-kmUkBDQdixUqKUHP2i5uImXQAJKrhvZjMRE-T0_KOd-WM>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 2B13E78273B; Tue,  3 Nov 2026 08:25:03 -0500 (EST)
X-Mailer: MessagingEngine.com Webmail Interface
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-ThreadId: Ac-KQ8NXZt8R
Date: Tue, 03 Nov 2026 08:24:43 -0500
From: "Chuck Lever" <cel@kernel.org>
To: Marco <lists@homerow.info>, "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Message-Id: <45cc029f-6e56-4c10-ae9e-33fba627a7d3@app.fastmail.com>
In-Reply-To: <20261103124027.39f703e7@homerow>
References: <20261103124027.39f703e7@homerow>
Subject: Re: NFS client: mkdir on existing, uncached dir returns EROFS instead of
 EEXIST under ro bind mount
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On Tue, Nov 3, 2026, at 6:40 AM, Marco wrote:
> Hi,
>
> on Linux 6.12.48 (Debian 13) and 7.1.6 (Debian 14), calling mkdir()
> on a directory that already exists on an NFSv4.2 mount, through a
> read-only bind mount, returns EROFS instead of EEXIST, as long as
> the directory has not been looked up (e.g. listed via readdir of its
> parent) by this client yet. Also reproducible on Debian 14 with a
> custom compiled 7.3.1 kernel.
>
> This breaks Flatpak/bubblewrap, which creates mount points with
> mkdir() and treats EEXIST as success but EROFS as fatal. With the
> Flatpak tree on NFS, apps fail after each reboot with "bwrap: Can't
> mkdir parents for ...: Read-only file system" until the tree has
> been walked once. The issue only occurs on NFS mounts, local
> file systems work fine with Flatpak/bubblewrap.
>
> To reproduce:
>
> # vanilla Debian install (stock kernel or 7.3.1, same result)
>
> # set it up (root)
> apt install nfs-kernel-server
> mkdir -p /mnt/nfstest /etc/exports.d /srv/nfstest
> echo '/srv/nfstest 127.0.0.1(rw,sync,no_subtree_check,no_root_squash)'=20
> > /etc/exports.d/nfstest.exports
> mount -t tmpfs -o size=3D16m tmpfs /srv/nfstest
> mkdir -p /srv/nfstest/reprotest1/sub
> exportfs -ra
> mount -t nfs4 -o vers=3D4.2 127.0.0.1:/srv/nfstest /mnt/nfstest
>
> # test (as regular user)
>
> # 1st invocation
> unshare -rm sh -c 'mount --bind "$1" "$1" && mount -o remount,bind,ro=20
> "$1" && mkdir "$1/sub"' sh /mnt/nfstest/reprotest1
> # =E2=86=92 mkdir: cannot create directory =E2=80=98/mnt/nfstest/repro=
test1/sub=E2=80=99:=20
> Read-only file system
>
> # walk the file system
> ls /mnt/nfstest/reprotest1
> # =E2=86=92 sub
>
> # 2nd invocation
> unshare -rm sh -c 'mount --bind "$1" "$1" && mount -o remount,bind,ro=20
> "$1" && mkdir "$1/sub"' sh /mnt/nfstest/reprotest1
> # =E2=86=92 mkdir: cannot create directory =E2=80=98/mnt/nfstest/repro=
test1/sub=E2=80=99: File=20
> exists
>
> strace of the original failure (bwrap):
>   mkdirat(7, "app", 0700)   =3D -1 EEXIST (File exists)
>   mkdirat(8, "share", 0700) =3D -1 EROFS (Read-only file system)
>   (but "share" exists)
>
> I believe this behaviour is not intended. Let me know if I should
> provide more info.
>
> Note: I'm not subscribed, so please CC me.
>
> Regards
> Marco

Attn: NFS client maintainers


--=20
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
