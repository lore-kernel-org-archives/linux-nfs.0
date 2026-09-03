Received: from mail-ej1-f54.google.com (mail-ej1-f54.google.com [209.85.218.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 745294E8DF0
	for <linux-nfs@vger.kernel.org>; Thu,  3 Sep 2026 21:33:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.218.54
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788471215; cv=pass; b=cT+KYr2BbaJhdWKEDfLLUwVCVsROERBjKJpJgyL32SAXXd+CY00jgteK2w6xry9urvv3L3Op7hyRpDkNIB4mbQWE04DU3ZKg2X/xeHGXoo/J1yf5MmlYwv36Y48vCld/OBJXzf9C3g4KT4ewuGXb8udA/V50LLoPa7ky3z1bVUc=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788471215; c=relaxed/simple;
	bh=4sV5o2LnLacmH1bmfW2THh/q+hBIFXcB4YpirQ0rJ9Q=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Content-Type; b=SNAS1dpOyjrvSlQ6eVNtRVPEvWV7d3iXQfQ1UJeIrMHYjNaAlmQlB+5dx8LzMUwe4hvdzdEJzKn3U8Xcvbp8z/GrBwlGUNtBY1mJ5YL1LKZwop09UOK2l5MJSTJ9JxFAwmdLuhjzMg/1HJPuhRsUdo8PN37zntSz09WGN9ZVZek=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=r8b3Te3F; arc=pass smtp.client-ip=209.85.218.54
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="r8b3Te3F"
Received: by mail-ej1-f54.google.com with SMTP id a640c23a62f3a-c25344a8c6cso40331566b.0
        for <linux-nfs@vger.kernel.org>; Thu, 03 Sep 2026 14:33:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1788471211; cv=none;
        d=google.com; s=arc-20260327;
        b=kxCM9LIf0GEZWgPbAkoH8C1PTIbA1ubeGp6b2Z9l0ndDBBWuU/YvuXGXEFjJEkRghB
         xjaIX3IJrMlN94XLOY4cRkf0COb0qaM20FzsTk17XdpzvJMFCVFk6/tyFaKCMcoPB2k9
         /vk/viuv5bu097nRV3/KNPkc6e3Z0pvp0o7ztDZoSM1HT6aUW2Ks0hhCR4EyKAj6AGMf
         GzwERmjXN0lFjhwUG7v+B/lI6NtFc4By+WIZPTMOmZi3f9vgRkXkl2O/GqWH2Xl4TMLO
         X/yI0QzvAzdgIS7NIawPfFJa4V5L+RAeJGH05yKrqqOY1Nf/R0wV5VD9NiSXqonIVb19
         dK4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=buYAkWy9TJavT3HNO3fmaixq5C4x3pWIIbhCvYFZwPc=;
        fh=A3pMOUK00huGibGCZBFsLekFLVbB5hHGKjUNNKwO+5E=;
        b=eSfUkueGetfgTErkyVZsu8ce+EiZqo7+8Bxty+wzO1adCjWeS69lAJBUm/iRRROFxh
         8+4mRgdeQtQHJDFlUcMST8otK4olt+mikLmxnKzyBzOORiSj9GFgqsO7p8/CBgdYVG06
         k81VzHIMOMnyg4oBXzg76nSU9pW8sCa50V5uBbvOEahHW8ZT5YOEtb242Z0g+035jwDI
         PB3r9M6XwOKsWreQemDFR6NhxMBWmIu3b23mypqKqNPaG3TG2SYYd7pYdGPJ+2aEET/5
         l0vbQb/imrKsLS6ntpkZsfcG8YFHbC2ws6i7m+DXiSScsICduL4cKYCITXa7nW1VTi2F
         JQWw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1788471211; x=1789076011; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:to:subject:message-id:date
         :from:in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=buYAkWy9TJavT3HNO3fmaixq5C4x3pWIIbhCvYFZwPc=;
        b=r8b3Te3FygDRwZydiwyYbPilH9tkNpHVwid6b0RNlgcu/f0udednuAeIZ8BTOEH9vB
         kWslE2dgoaEzJQn/963JInLsQ6vwFBNVg/95HLfUzj8eE2kBmFwbwQ31Z48PIPdc/f7L
         fpFqeELvM1aIecb5bbn7KI8p4NbST3RBLg1gqHg4uKKqHqAtbIVof/GNu7ap4rk/3RwO
         EYhP8+E8wV85VUReFS6T/lY0VlFwjW5VAmBE+Ti5cSAUW2CVAQ2uAcNFDLKdl4zqqdB7
         pzNdjz2XqpftZmiEyZYj+8GHzHjpyGsxc8JheTZ5UoWKHObngRWT1eIUw5rj5Mz48Jca
         pXYg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788471211; x=1789076011;
        h=content-transfer-encoding:content-type:to:subject:message-id:date
         :from:in-reply-to:references:mime-version:x-gm-gg:x-gm-message-state
         :from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=buYAkWy9TJavT3HNO3fmaixq5C4x3pWIIbhCvYFZwPc=;
        b=OlJQxsLbcB2HT9LkKD0r6tFVTDy2droQKpXEWeG0ItLFdOvFDvSukousLFkP961lK2
         PMgInnOgAUJYe+lygqWJi5mVOKupp6igzPaq77kMwH56npZKvWFGHRa/Uq/L73VUFo/a
         NpEbLntdSO/cokRyHJMBxARC6n4BaCk/rxEndWZ7N8EZQ96zP5ooM2h5ELCKWcOStwlf
         CIhfc9EbOWxWiyBuu3m05ExeQc4IJN0Aeqhsu7zyxxyMHHyDENBpSVvaUBBb0ZMBSPS1
         Ou810nBeRJWIQk3wuUc+1QlhdQ9wIJiwUx5F7N4k+ctcdr9ffARk7JJKegMqMIq4amoh
         OcCw==
X-Gm-Message-State: AFuF++nIrij2jPFOqZeyjCIyHlYq2syk24qauxkiH8pDqk4RHzAWfGNY
	iCV9lcznqQY0Bq8qliKAQSb5WBsy0munnc+AZfLVeGo//0o8ASNB98iekClI9oKou/CRNK1B6cA
	EMKtfUvY/9lJeOoCLgcKoYQv8NoN4H2eASGY/
X-Gm-Gg: AYBFou3PuTjZckyLQlxSadQjoKOTgPCmv4lvmWbEaKD6v9knBv2xOx4oCjTRchhs6v2
	SbQnEAm3EQRd6QcTwhuuJ726jxFmCowO4Gc7p16OzPJV95k7qjnoHsYQwNzVaXfkEauchObxZEO
	CAn1+wmotAtvRC7iFuHwOfNGDWmw235hRTfFyLi5IIXGurEe7CN7ldQbbjvXAd4JkSPpr6KBxBC
	9HOC09oCUnkCbdeRmtek5ahWCi6tr6Pl/nwrPxKf4UK0Iqv5U/+4WIblfTiIkKjqRWPhXcYyZG1
	RKhFrIghftEhOLagGfhVaDumhhw65u+pAn73c5RJSgKxvA==
X-Received: by 2002:a17:906:f591:b0:c20:f529:2d6a with SMTP id
 a640c23a62f3a-c260ca339fdmr88922766b.22.1788471211246; Thu, 03 Sep 2026
 14:33:31 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <CAKAoaQmueOn57kBhXxCqky2w_fUpaTjPyBgt0mfn7RGLY3eL9g@mail.gmail.com>
In-Reply-To: <CAKAoaQmueOn57kBhXxCqky2w_fUpaTjPyBgt0mfn7RGLY3eL9g@mail.gmail.com>
From: Martin Wege <martin.l.wege@gmail.com>
Date: Thu, 3 Sep 2026 23:32:00 +0200
X-Gm-Features: AcwNN1XxL70Sm5kjbhOFpfvt_41aQk9xmKBwBxUANlMcp_T4BQfmFfNCEaHRlNU
Message-ID: <CANH4o6NXhHCzYXFS12LJeDWOpD5RnneW0iUp=sHM0DaRmAmHew@mail.gmail.com>
Subject: Fwd: [Ms-nfs41-client-devel] [Announcement] NFSv4.2/NFSv4.1
 filesystem client Windows driver binaries for Windows 10/11+WindowsServer
 2019/2022/2025 for testing, 2026-09-03 ...
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
filesystems, Windows Alternate Streams (Win32 streams) support
(requires NFSv4 named stream support),
xcopy.exe/cmd.exe copy/MS Explorer file copy acceleration via NFS
server side copies, and copy-by-block-cloning are IMO the most
interesting new features.

PS: Windows x86-64 users can now use the kernel module without the
kernel testsigning mode, just execute bash
/lib/msnfs41client/contrib/opensource_driver_bb/opensource_driver_bootbypas=
s.bash
after /sbin/msnfs41client install

Thanks,
Martin

---------- Forwarded message ---------
From: Roland Mainz <roland.mainz@nrubsig.org>
Date: Thu, Sep 3, 2026 at 12:49=E2=80=AFPM
Subject: [Ms-nfs41-client-devel] [Announcement] NFSv4.2/NFSv4.1
filesystem client Windows driver binaries for Windows
10/11+WindowsServer 2019/2022/2025 for testing, 2026-09-03 ...
To: <ms-nfs41-client-devel@lists.sourceforge.net>


Hi!


----

We've created a set of test binaries for the NFSv4.2/NFSv4.1
filesystem client driver for Windows 10 (32bit x86, x86-64, ARM64),
Windows 11 (x86-64, ARM64)+Windows Server 2019/2022/2025 (x86-64,
ARM64), based on https://github.com/kofemann/ms-nfs41-client (commit
id #448d4492cd7075bccdda94fc013f2af80c78d8d0, git bundle in tarball),
for testing and feedback.

** FULL release readme:
http://www.nrubsig.org/people/gisburn/work/msnfs41client/releases/testing/m=
snfs41client_cygwin_64bit32bit_binaries_20260903_10h14m_git448d449.html
http://www.nrubsig.org/people/gisburn/work/msnfs41client/releases/testing/m=
snfs41client_cygwin_64bit32bit_binaries_20260903_10h14m_git448d449.readme

** Download URL (all architectures+platforms):
http://www.nrubsig.org/people/gisburn/work/msnfs41client/releases/testing/m=
snfs41client_cygwin_64bit32bit_binaries_20260903_10h14m_git448d449.tar.bz2

** Download hash sums:
SHA2-256(msnfs41client_cygwin_64bit32bit_binaries_20260903_10h14m_git448d44=
9.html)=3D
3f7dba4d602bb00a161554ed688e23cabb852be4c3a13254464f423868928fa4
SHA2-256(msnfs41client_cygwin_64bit32bit_binaries_20260903_10h14m_git448d44=
9.readme)=3D
1d049e25b52f154f49621405771dc6ba6895e511d7fed6cf28450905db0676d7
SHA2-256(msnfs41client_cygwin_64bit32bit_binaries_20260903_10h14m_git448d44=
9.tar.bz2)=3D
0a38545458257cac50daf111eb7c6bcdf9636c618d1574eec39de0c8d2f6d081


** Major changes since the 2026-08-01 release:
- many NFSv4.1 callback fixes
- many Network Provider fixes
- cleanup in XDR code for better stability
- the Network Provider no longer depends on debug *.dll and now should
work reliable in Win11 Explorer&co
- krb5/SSPI fixes
- Creating virtual disks from (sparse) files on a NFSv4.1 filesystem
now works with OFSMount
- ms-nfs41-client can now be *build* on Win10 with a 32bit
kernel+32bit VS2019 (previous versions worked on Windows with 32bit
kernels, but building the sources required a 64bit Windows)

** Major changes since the 2026-06-01 release:
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
