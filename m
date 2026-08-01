Received: from mail-ed1-f44.google.com (mail-ed1-f44.google.com [209.85.208.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 38A7A346E64
	for <linux-nfs@vger.kernel.org>; Sat,  1 Aug 2026 21:17:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.208.44
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785619025; cv=pass; b=uShJgy6xnmBJhqF4cpL4gAmOusRLBUQOEvwWWpYjIx73++TeLmEKpqg7r3Fipa59r394ANAchrt4LonAwRXaEGY99q3XDh2pbBjXnAv4513Lypo7rjkiHjH2K+godNpc879HQkwSYoNUABmdqh4WPk5vleqiJDfHw94sx/Gx9p0=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785619025; c=relaxed/simple;
	bh=hj5XqV182Ino7rhTDhbWpVkAKj4V2kALGSg5EfPYAl4=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Content-Type; b=ipqELYjAwICO1+MQlW12tU8FSjhz0yr6gPJyhgmG8l5A7BZqXS+NtQKHG1JIfXM4GB8cCi9O24TxcUWGfTHLk5AMMjnCPf7hA4mIvBABXiL18dsFF9a1BQ4VT7aEPxLZp+I8tLxoBUJcYgIeMz5V1o0ZFR9BXTY0iUlzuRQmSJE=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=IP5y0ljj; arc=pass smtp.client-ip=209.85.208.44
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="IP5y0ljj"
Received: by mail-ed1-f44.google.com with SMTP id 4fb4d7f45d1cf-69c5fda04a8so3920126a12.1
        for <linux-nfs@vger.kernel.org>; Sat, 01 Aug 2026 14:17:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1785619021; cv=none;
        d=google.com; s=arc-20260327;
        b=pfc3pGcX/YafNe6+Zo4xZUa8qTx8BNutO42VXC+pY9tncQGAR/LquMS/fj3wevBgSV
         PD/ZSYjgtUHFUnd7j9o/IYY4bQQn5byeMtypz7TFVR2KTHv1x57HKoNjDxDtlJJY41NN
         IeBo4sevprplEFnzWIfhR06F6FmLP5CGv7sM3L9nlhdXJbaNIhoLBWP2ywfL8lvFLs8t
         ju4k/X9n6G2x1gt8hNJs8mNpB9aY6t2cW76TZ7apvNei4IZdPSwKVnazgUAuff+WjdLu
         fNElCrfa0gVyYbCBK8HjW9M+iAKtlrvFf1kvnGG0+s0vgYy2EKjmiG7oiN2GW+BK0Dvx
         YBhA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=1gZ0o4HzzxRHTPg4JTA+syJru76qsdwz5KrEva4+XLQ=;
        fh=A3pMOUK00huGibGCZBFsLekFLVbB5hHGKjUNNKwO+5E=;
        b=LITP9HBJzFsqFiG+isEsrXdk5/ZhuuAs8tRwjTf9EbGphk+hhZBGiTF/3GDL4Vna+l
         Urf58DZY3AkwNkiqyPKokjAm0BZ9rFkOzord+YufGga2zWCxGUnKZixCKPhOkxDlg6ny
         obXsztEnWzpDRc/VX0vihghywsqKNvbnYfvtjr7A7mJKwarsJ1sODwxMeyTgIloKORWX
         +R7ZDKvLAdeR7E9Zxwxm6SXSJUmsAJzh0nHHlrwK3LX9oKXtZeSJmNT5YMbPrfH1YVRt
         yQzMX+c9LWOIhGoHZoH7s1JjGhGiEV0r35Sz7to0erWGcoWwVD9onxWj3E3KpZfZpGtb
         mNKQ==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1785619021; x=1786223821; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:to:subject:message-id:date
         :from:in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=1gZ0o4HzzxRHTPg4JTA+syJru76qsdwz5KrEva4+XLQ=;
        b=IP5y0ljj1IQd81VLkJVUPK4GKYANNjrnZC5qOZuPp4ShsPD7XN5DcaQeI5x4kbZh2k
         fx7Um7inj6QBjS9fRrUq7m+Gs2j4Pqlp87VxbLc3CDWXWRk0dvfmtcXkPtjzGr+SZdjb
         IbKmbdy8tzcyHILc/kROirdNND2KEHO43TOAHmfW30US9FQDY1n98TrXSaodmK4QVsec
         f93wPVpZamy3m0cPqC2ufwj08ug5XQBmKOiDYxNcisWN897ijwVHB9gOumvr24k9JE2n
         5hnOD8eboL0YsPb528pGTcuyh5JOIGcxxrbZxshFuZp9W2N7ucxNALf+T69aIf6lAP8C
         hWrA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1785619021; x=1786223821;
        h=content-transfer-encoding:content-type:to:subject:message-id:date
         :from:in-reply-to:references:mime-version:x-gm-gg:x-gm-message-state
         :from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=1gZ0o4HzzxRHTPg4JTA+syJru76qsdwz5KrEva4+XLQ=;
        b=Ls6zXqyr9M4ZFIKfECH9vfjwUvFLQYiMM+PUUjYiYYJqD4WKp3KnyWgqviJC3xtxHb
         yoGZSZ1sbh/k9UOEA3Yr9r1mBlYIJzZOVY4O2I+y+elvIv5UM3i4Juor4BMUdwZIsgSf
         tGGOFDPx//bwt1FiR8MwecTO84SxFXhW8n6Il4gvl3xfR8iZjm/6GHuENEzM5z3lxFYL
         FN8b8Jdp8Qp3nhvmcsccWo6Zi/thXvwK6XExu1RmaxJNiTnHoI+xPxEErwVj3Yw4aEUb
         0pNvffrWOKuRvcbSf9hjgK8vyeTAw8I2bUrUdWem6batcGQoMu3fVnFR5DH5DADMuf/S
         xyeg==
X-Gm-Message-State: AOJu0Yx3WJ+RLA5CUHUWs0YB9diu5kUL0eJjPPzxwSpYt0QZUM3Xk6ll
	TIF7iEY7WRqlMdBM2h4cxhUrhyNu98w3sa76PbsTpr6SL9cr6nFiFhu3+cnBP+bYYN7m3Q4Zb9M
	O4m0g4FzTZjLaopYr7gaPL9j2qN6bwu1k3c8N0QQ=
X-Gm-Gg: AR+sD10rNNvrD24sQSKOLIMVvxw0NScReOWtcmA6rVkCKLJxg7j0JsHeP/0Q15i+YgG
	kDzv7vf8jDCRh1VsiL3uYZTk5Zo5aVnqVNOiR9Nsvncj2hOtlLeW/g20MfRb1z4ZBwhEEpM86/1
	RZlUmb+3OxQXNCFJZS3nKhpw0l8CuIG1GuhtHSquWhMlV5jwWqSzrOxFZuL1A9uBuZdwRg7C4vN
	hAQbrVDnfJ01Xv9MW/3ZUEzOVxmnY0A6B8e0bHWHCSXh1d995VyjfrphMPkKRETSvHrxZLFtgW7
	INayrcz5nUn0E1rNC8OcHSKw25EhJD5Kfajjxx+L49fOc743zfuUY24=
X-Received: by 2002:a05:6402:52d2:b0:699:fbe4:16d5 with SMTP id
 4fb4d7f45d1cf-6a0a7c5ef72mr2919568a12.1.1785619021074; Sat, 01 Aug 2026
 14:17:01 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <CAKAoaQnARGZ1_usbjChS12QpmakaJebx2DD6jcyRVABsQzyvbw@mail.gmail.com>
In-Reply-To: <CAKAoaQnARGZ1_usbjChS12QpmakaJebx2DD6jcyRVABsQzyvbw@mail.gmail.com>
From: Martin Wege <martin.l.wege@gmail.com>
Date: Sat, 1 Aug 2026 23:15:00 +0200
X-Gm-Features: AUfX_mxv2zTvPlJVlQxm4PGx6lupfmvgoii3E47iI_INXxkVpdpyvzEDcfoElIc
Message-ID: <CANH4o6PiCYcQsas7x-v0eCPd=Yh+Y9YRhskVPtX66AVFhhgPGw@mail.gmail.com>
Subject: Fwd: [Ms-nfs41-client-devel] [Announcement] NFSv4.2/NFSv4.1
 filesystem client Windows driver binaries for Windows 10/11+WindowsServer
 2019/2022/2025 for testing, 2026-08-01 ...
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hello,

Please test the binaries. The NFSv4.2/4.1 client is for Windows 10/11
ARM64+AMD64+x86 and Windows Server 2019+2022+2025/AMD64, but
Interoperability feedback with NFSv4.1/NFSv4.2 servers based on Linux
6.6+ LTS and 6.19+/7.2 would be great.

News:
See announcement below; New idmapper which maps any NFS user/group to
any Windows user/group, support for Linux 7.2 case-insensitive NFS
filesystems, Windows Alternate Streams (Win32 streams) support,
xcopy.exe/cmd.exe copy/MS Explorer file copy acceleration via NFS
server side copies, and copy-by-block-cloning are IMO the most
interesting new features.

PS: Windows x86-64 users can now use the kernel module without the
kernel testsigning mode, just edit /sbin/msnfs41client and change
"use_secureboot=3Dfalse" to "use_secureboot=3Dtrue", and execute bash
/lib/msnfs41client/contrib/opensource_driver_bb/opensource_driver_bootbypas=
s.bash
after /sbin/msnfs41client install

Thanks,
Martin

---------- Forwarded message ---------
From: Roland Mainz <roland.mainz@nrubsig.org>
Date: Sat, Aug 1, 2026 at 4:22=E2=80=AFPM
Subject: [Ms-nfs41-client-devel] [Announcement] NFSv4.2/NFSv4.1
filesystem client Windows driver binaries for Windows
10/11+WindowsServer 2019/2022/2025 for testing, 2026-08-01 ...
To: <ms-nfs41-client-devel@lists.sourceforge.net>


Hi!


----

We've created a set of test binaries for the NFSv4.2/NFSv4.1
filesystem client driver for Windows 10 (32bit x86, x86-64, ARM64),
Windows 11 (x86-64, ARM64)+Windows Server 2019/2022/2025 (x86-64,
ARM64), based on https://github.com/kofemann/ms-nfs41-client (commit
id #a2eb45f0ecb915260bc47dbcc783bf80771a815e, git bundle in tarball),
for testing and feedback.

** FULL release readme:
http://www.nrubsig.org/people/gisburn/work/msnfs41client/releases/testing/m=
snfs41client_cygwin_64bit32bit_binaries_20260801_13h39m_gita2eb45f.html
http://www.nrubsig.org/people/gisburn/work/msnfs41client/releases/testing/m=
snfs41client_cygwin_64bit32bit_binaries_20260801_13h39m_gita2eb45f.readme

** Download URL (all architectures+platforms):
http://www.nrubsig.org/people/gisburn/work/msnfs41client/releases/testing/m=
snfs41client_cygwin_64bit32bit_binaries_20260801_13h39m_gita2eb45f.tar.bz2

** Download hash sums:
SHA2-256(msnfs41client_cygwin_64bit32bit_binaries_20260801_13h39m_gita2eb45=
f.html)=3D
2ee71170d2b093c8cb736341c82ef099b528416fc890b26c51d699a328e93d01
SHA2-256(msnfs41client_cygwin_64bit32bit_binaries_20260801_13h39m_gita2eb45=
f.readme)=3D
af3040ce58ea79381f052e5dc4e87a1ecd5896ef7ef59d4bc3d8c8af52c403a2
SHA2-256(msnfs41client_cygwin_64bit32bit_binaries_20260801_13h39m_gita2eb45=
f.tar.bz2)=3D
caf406f0eb9c3fa0ccc0ea2c24d98d97abe84d00a33ac3b44c897f355153cf63


** Major changes since the last release:
- UNC tag numbers (experimetal), to give mounts an unique UNC path
(and separate NFS server connection) via $ /sbin/nfs_mount -o
unctagnum=3D4000 ... #)
- New winfsinfo subcmd "fsctlnfs41queryidmapinfo" to query the
idmapper data (Win32 user/group names+Cygwin/UWIN/SFU uid/gid, mapped
NFSv4 fatt4_owner/fattr4_owner_group data etc) for a file. This is
intended as diagnostics aid for administrators.
- Idmapper configuration is now obtained via "cygwin_idmapper.ksh"
- New idmapper, which allows to map any NFS server { uid, gid,
fattr4_owner, fattr4_owner_group } to any Windows user/group account.
Mapping is done per mount, so Windows user "abc@windomain" can be user
"def@nfslinux1" on NFS server "linux1" and "xyz@otherlinux2" on NFS
server "otherlinux2". Same applies to groups. Windows localised
builtin accounts are also supported, to handle situations like a
German Window client connecting to a French WindowServer NFSv4.1
server.
Idmapping itself is done with a shell script (for maximum flexibility,
as attemps to handle this with builtin code could NOT cover all
compliciated site setups, including Windows localised account names,
and NFS clients which have to connect to multiple different sites with
completely different NFS server account setups), and also provides
uid/gid values for Cygwin/MSYS2/UWIN (which can now be fully
independent from uid/gid values used by the NFS server)
- Added support for FreeBSD 16.0 NFS server
- More fixes for case-insensitive NFS filesystems (requires FreeBSD
n>=3D 16.0 NFS server, Linux >=3D 7.1 NFS server or Windows Server NFS
server with a case-insensitive filesystem)
- Bugfixes to enable compilation of ReactOS on a NFSv4.1 filesystem
- Support for Win32 named streams/Alternate Data Streams (ADS), if the
NFSv4.x server supports NFS named attributes (e.g. Solaris >=3D 11.4,
Illumos, FreeBSD >=3D 15.0, ...), including NTFS-style renaming support.
This also includes new utilities (e.g. winstreamsutil.exe) to find,
list, create, rename, delete etc. Win32 named streams
- Support for Windows "SRVOpen collapsing", which enables file handles
with the access/permission/etc attributes to share one NFS file handle
(saving open/close round trips to the NFS server)
- Symlinks are now using the group defined by Win32 PrimaryGroup
(which can be set via Cygwin newgrp(1)/|setgid()| or winsg(1))
- Added support for Windows "Extended Create Parameters" |ECP
QUERY_ON_CREATE| |QoCFileStatInformation| and |QoCFileLxInformation|
- Added support for setting a file's ACL at file creation time
- Fixed issues probing sparse files when using the nfs-ganesha NFS server
- Disk and CDROM/DVD images can now be mounted via
https://github.com/gisburn/filedisk-sparse/
- UNC path format changed to <hostname>@<protocol>@<port>, e.g.
ournfsserver@NFS@2049, to support future transport+mount options (e.g.
RDMA , TLS/SSL etc.)
- Window 11/ARM64 is now supported (native aarch64 kernel module and
nfs*.exe userland utilities)
- /sbin/nfs_globalmount, a new tool for Administrators to manage
global/machine-wide mounts which are available to all Windows
users/services/logons
- New "nfsclientdctl" utility to change the NFS client daemon
parameters at runtime
- support for case-insensitive filesystems (e.g. Windows Server NTFS)
- NFS referrals now work with custom (non-TCP/2049) port numbers
- Implemented |FSCTL_OFFLOAD_READ|+|FSCTL_OFFLOAD_WRITE| (e.g. used by
Windows 10 xcopy, Windows Explorer etc) for server-side NFSv4.2 COPY
- Better FreeBSD 14.x/15.0 nfsd compatibility
- More software tested for compatibility: MariaDB, Microsoft Office
2016, Visual Studio 2022 work with msnfs41client
- Volume label is now the nfs://-URL to the server (up to 31
characters for Windows Explorer compatibility)
- Support for user and group names with non-ASCII (e.g. Unicode) names
(like German umlauts) in ms-nfs41-client, winsg.exe etc.
- winsg.exe now has a /P option to run powershell.exe with the requested gr=
oup
- nfs_mount.exe now enforces that normal mounts need nfs://-URLs with
absolute paths, and "public NFS" mounts need relative paths in a
nfs://-URL
- sec=3Dnone support
- Improved /sbin/cygwinaccount2nfs4account script to better handle
creation of Windows Domain accounts on the NFS server side
- *.(exe|dll) executables are now signed with a WDK test signature,
helping with *rare* cases that Windows Defender with paranoid settings
wrongly recognising the binaries as potential threads. A *.cer
certificate file is supplied which can be imported into the Windows
Defender to whitelist the binaries if this happens.
- Support for |FSCTL_DUPLICATE_EXTENTS_TO_FILE|, which allows Windows
11 applications which use |CopyFile2()| (like cmd.exe  copy, xcopy.exe
etc) to copy files via block cloning. Requires NFSv4.2 NFS server with
{ CLONE, SEEK, DEALLOCATE } support, exporting a filesystem which
supports block cloning (e.g. btrfs, xfs). This includes correct
cloning of sparse files.
- Sparse file support (requires NFSv4.2 server { SEEK, ALLOCATE,
DEALLOCATE } and the |FATTR4_WORD1_SPACE_USED| attr), including
hole/data range enumeration, punching holes etc., e.g. $ fsutil sparse
queryrange mysparsefile # and Win32 named stream support
- Improved Windows Extended Attribute (EA) support (requires NFS named
attributes support in the NFS server (e.g. Solaris >=3D 11.4, Illumos,
FreeBSD >=3D 15.0, ...)), including create/read/write/delete
- Support for Storage32-API (e.g. enables use of *.msi installer files
on NFS filesystems)
- Cygwin /usr/bin/svn and Windows '/cygdrive/c/Program
Files/Git/cmd/git' now work
- Illumos NFSv4.2+Solaris 11.4 NFSv4.1 server is now supported
- Windows Server 2022 NFSv4.1 server is now supported (compared to
WS2019 this NFS server version has ACL support)

** Please send comments, bugs, test reports, complaints etc. to the
MailMan mailing list at
https://sourceforge.net/projects/ms-nfs41-client/lists/ms-nfs41-client-deve=
l

----

Bye,
Roland
--
  __ .  . __
 (o.\ \/ /.o) roland.mainz@nrubsig.org
  \__\/\/__/  MPEG specialist, C&&JAVA&&Sun&&Unix programmer
  /O /=3D=3D\ O\  TEL +49 641 3992797
 (;O/ \/ \O;)


_______________________________________________
Ms-nfs41-client-devel mailing list
Ms-nfs41-client-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/ms-nfs41-client-devel
