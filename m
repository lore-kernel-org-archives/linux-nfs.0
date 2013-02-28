Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f169.google.com ([209.85.217.169]:32926 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755321Ab3B1PWp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Feb 2013 10:22:45 -0500
From: Pavel Shilovsky <piastry@etersoft.ru>
To: linux-kernel@vger.kernel.org
Cc: linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, wine-devel@winehq.org
Subject: [PATCH v3 0/7] Add O_DENY* support for VFS and CIFS/NFS
Date: Thu, 28 Feb 2013 19:25:26 +0400
Message-Id: <1362065133-9490-1-git-send-email-piastry@etersoft.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patchset adds support of O_DENY* flags for Linux fs layer. These flags can be used by any application that needs share reservations to organize a file access. VFS already has some sort of this capability - now it's done through flock/LOCK_MAND mechanis, but that approach is non-atomic. This patchset build new capabilities on top of the existing one but doesn't bring any changes into the flock call semantic.

These flags can be used by NFS (built-in-kernel) and CIFS (Samba) servers and Wine applications through VFS (for local filesystems) or CIFS/NFS modules. This will help when e.g. Samba and NFS server share the same directory for Windows and Linux users or Wine applications use Samba/NFS share to access the same data from different clients.

According to the previous discussions the most problematic question is how to prevent situations like DoS attacks where e.g /lib/liba.so file can be open with DENYREAD, or smth like this. That's why one extra flag O_DENYMAND is added. It indicates to underlying layer that an application want to use O_DENY* flags semantic. It allows us not affect native Linux applications (that don't use O_DENYMAND flag) - so, these flags (and the semantic of open syscall that they bring) are used only for those applications that really want it proccessed that way.

So, we have four new flags:
O_DENYREAD - to prevent other opens with read access,
O_DENYWRITE - to prevent other opens with write access,
O_DENYDELETE - to prevent delete operations (this flag is not implemented in VFS and NFS part and only suitable for CIFS module),
O_DENYMAND - to switch on/off three flags above.

Also, this version of the patchset fixes the problem of data races on newely created files: open with O_CREAT can return the -ETXTBSY error for a successfully created file if this files was locked with a deny lock by another task.

The #1 patch adds flags to fcntl, the #2 patch implements VFS part. The patches #3, #4, #5 are related to CIFS-specific changes, #6 and #7 describe NFS and NFSD parts.

The preliminary patch for Samba that replaces the existing use of flock/LOCK_MAND mechanism with O_DENY* flags:
http://git.etersoft.ru/people/piastry/packages/?p=samba.git;a=commitdiff;h=0596193832ace26a1dd54160c7380d071a83115b

The future part of open man page patch:

-----
O_DENYMAND - used to inforce a mandatory share reservation scheme of the file access. If this flag is passed, the open fails with -ETXTBSY in following cases:
1) if O_DENYREAD flag is specified and there is another open with O_DENYMAND flag and READ access to the file;
2) if O_DENYWRITE flag is specified and there is another open with O_DENYMAND flag and WRITE access to the file;
3) if READ access is requested and there is another open with O_DENYMAND and O_DENYREAD flags;
4) if WRITE access is requested and there is another open with O_DENYMAND and O_DENYWRITE flags.

If O_DENYDELETE flag is specified and the open succeded, any further unlink operation will fail with -ETXTBSY untill this open is closed. Now this flag is processed by CIFS filesystems only.

This mechanism is done through flocks. If O_DENYMAND is specified and flock syscall is processed after the open. The share modes are translated into flock according the following rules:
1) O_DENYMAND   -> LOCK_MAND
2) !O_DENYREAD  -> LOCK_READ
3) !O_DENYWRITE -> LOCK_WRITE
-----

Pavel Shilovsky (7):
  fcntl: Introduce new O_DENY* open flags
  vfs: Add O_DENYREAD/WRITE flags support for open syscall
  CIFS: Add O_DENY* open flags support
  CIFS: Use NT_CREATE_ANDX command for forcemand mounts
  CIFS: Translate SHARING_VIOLATION to -ETXTBSY error code for SMB2
  NFSv4: Add O_DENY* open flags support
  NFSD: Pass share reservations flags to VFS

 fs/cifs/cifsacl.c                |   6 +-
 fs/cifs/cifsglob.h               |  12 +++-
 fs/cifs/cifsproto.h              |   9 +--
 fs/cifs/cifssmb.c                |  47 ++++++++--------
 fs/cifs/dir.c                    |  14 +++--
 fs/cifs/file.c                   |  18 ++++--
 fs/cifs/inode.c                  |  11 ++--
 fs/cifs/link.c                   |  10 ++--
 fs/cifs/readdir.c                |   2 +-
 fs/cifs/smb1ops.c                |  15 ++---
 fs/cifs/smb2file.c               |  10 ++--
 fs/cifs/smb2inode.c              |   4 +-
 fs/cifs/smb2maperror.c           |   2 +-
 fs/cifs/smb2ops.c                |  10 ++--
 fs/cifs/smb2pdu.c                |   6 +-
 fs/cifs/smb2proto.h              |  14 +++--
 fs/fcntl.c                       |   5 +-
 fs/locks.c                       | 117 +++++++++++++++++++++++++++++++++++----
 fs/namei.c                       |  44 ++++++++++++++-
 fs/nfs/nfs4xdr.c                 |  24 ++++++--
 fs/nfsd/nfs4state.c              |  46 ++++++++++++++-
 include/linux/fs.h               |   6 ++
 include/uapi/asm-generic/fcntl.h |  14 +++++
 23 files changed, 345 insertions(+), 101 deletions(-)

-- 
1.8.1.2

