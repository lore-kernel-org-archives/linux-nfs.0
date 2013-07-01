Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f44.google.com ([209.85.215.44]:39027 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752735Ab3GAQm6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Jul 2013 12:42:58 -0400
From: Pavel Shilovsky <piastry@etersoft.ru>
To: linux-kernel@vger.kernel.org
Cc: linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, wine-devel@winehq.org
Subject: [PATCH v7 0/7] Add O_DENY* support for VFS and CIFS/NFS
Date: Mon,  1 Jul 2013 20:49:52 +0400
Message-Id: <1372697399-21361-1-git-send-email-piastry@etersoft.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Main changes from v6:
1) Fix LOCK_DELETE mandatory lock detection for O_DENYDELETE opens.
2) Add ESHAREDENIED error code definition for alpha, mips, parisc and sparc arches.
3) Remove code changes in do_last function if sharelocks are disabled.

Main changes from v5:
1) O_DENYDELETE is now supported by VFS.
2) ESHAREDENIED erro code is introduced to be returned on sharelock conflicts.
3) forcemand dependancy is removed. CIFS module detects if it should use NTCreateAndX command according to existence of O_DENY flags.
4) Term 'deny lock' is replaced by 'sharelock' (function names, code comments, patch descriptions).

Main changes from v4:
1) deny_lock_file uses FS_DOES_SHARELOCK flag from fs_flags to determine whether to use VFS locks or not.
2) Make nfs code return -EBUSY for share conflicts (was -EACCESS).

Main changes from v3
1) O_DENYMAND is removed, sharelock mount option is introduced.
2) Patch fcntl.h and VFS patches are united into one.
3) flock/LOCK_MAND is disabled for sharelock mounts.

This patchset adds support of O_DENY* flags for Linux fs layer. These flags can be used by any application that needs share reservations to organize a file access. VFS already has some sort of this capability - now it's done through flock/LOCK_MAND mechanism, but that approach is non-atomic. This patchset builds new capabilities on top of the existing one but doesn't bring any changes into the flock call semantic.

These flags can be used by NFS (built-in-kernel) and CIFS (Samba) servers and Wine applications through VFS (for local filesystems) or CIFS/NFS modules. This will help when e.g. Samba and NFS server share the same directory for Windows and Linux users or Wine applications use Samba/NFS share to access the same data from different clients.

According to the previous discussions the most problematic question is how to prevent situations like DoS attacks where e.g /lib/liba.so file can be open with DENYREAD, or smth like this. That's why extra mount option 'sharelock' is added for switching on/off O_DENY* flags processing. It allows us to avoid use of these flags on critical places (like /, /lib) and turn them on if we really want it proccessed that way.

The patchset introduces 3 new flags:
O_DENYREAD - to prevent other opens with read access,
O_DENYWRITE - to prevent other opens with write access,
O_DENYDELETE - to prevent delete operations (this flag can't be implemented for NFS due to the protocol restrictions).

The patchset avoids data races problem on newely created files: open with O_CREAT can return new -ESHAREDENIED error code for a successfully created file if this files was locked with a sharelock by another task. Also, it turns off flock/LOCK_MAND capability for mounts with 'sharelock' option. This lets us not mix one share reservation approach with another.

The #1 and #2 patches add flags to fcntl and implements VFS part. The patches #3 and #4 are related to CIFS-specific changes, #5 and #6 describe NFS and NFSD parts, #7 turns off flock/LOCK_MAND for mounts with 'sharelock' option.

The preliminary patch for Samba that replaces the existing use of flock/LOCK_MAND mechanism with O_DENY* flags:
http://git.etersoft.ru/people/piastry/packages/?p=samba.git;a=commitdiff;h=173070262b7f29134ad6b2e49a760017c11aec4a

The future part of open man page patch:

-----
O_DENYREAD, O_DENYWRIYE, O_DENYDELETE - used to inforce a mandatory share reservation scheme of the file access. If these flag is passed, the open fails with -ESHAREDENIED in following cases:
1) if O_DENYREAD flag is specified and there is another open with READ access to the file;
2) if O_DENYWRITE flag is specified and there is another open with WRITE access to the file;
3) if READ access is requested and there is another open with O_DENYREAD flags;
4) if WRITE access is requested and there is another open with O_DENYWRITE flags.

If O_DENYDELETE flag is specified and the open succeded, any further unlink operation will fail with -ESHAREDENIED untill this open is closed. Now this flag is processed by VFS and CIFS filesystem.

This mechanism is done through flocks. If O_DENY* flags are specified, flock syscall is processed after the open. The share modes are translated into flock according the following rules:
1) !O_DENYREAD   -> LOCK_READ   | LOCK_MAND
2) !O_DENYWRITE  -> LOCK_WRITE  | LOCK_MAND
3) !O_DENYDELETE -> LOCK_DELETE | LOCK_MAND
---

Pavel Shilovsky (7):
  VFS: Introduce new O_DENY* open flags
  VFS: Add O_DENYDELETE support for VFS
  CIFS: Add share_access parm to open request
  CIFS: Add O_DENY* open flags support
  NFSv4: Add O_DENY* open flags support
  NFSD: Pass share reservations flags to VFS
  locks: Disable LOCK_MAND support for MS_SHARELOCK mounts

 arch/alpha/include/uapi/asm/errno.h  |   2 +
 arch/mips/include/uapi/asm/errno.h   |   2 +
 arch/parisc/include/uapi/asm/errno.h |   2 +
 arch/sparc/include/uapi/asm/errno.h  |   2 +
 fs/cifs/cifsacl.c                    |   8 +-
 fs/cifs/cifsfs.c                     |   2 +-
 fs/cifs/cifsglob.h                   |  18 +++-
 fs/cifs/cifsproto.h                  |   8 +-
 fs/cifs/cifssmb.c                    |  50 ++++++-----
 fs/cifs/dir.c                        |  16 ++--
 fs/cifs/file.c                       |  25 ++++--
 fs/cifs/inode.c                      |  21 ++---
 fs/cifs/link.c                       |  25 ++----
 fs/cifs/netmisc.c                    |   2 +-
 fs/cifs/readdir.c                    |   5 +-
 fs/cifs/smb1ops.c                    |  16 ++--
 fs/cifs/smb2file.c                   |  10 +--
 fs/cifs/smb2inode.c                  |   4 +-
 fs/cifs/smb2maperror.c               |   2 +-
 fs/cifs/smb2ops.c                    |  10 ++-
 fs/cifs/smb2pdu.c                    |   6 +-
 fs/cifs/smb2proto.h                  |  14 +--
 fs/fcntl.c                           |   5 +-
 fs/locks.c                           | 160 ++++++++++++++++++++++++++++++++---
 fs/namei.c                           |  56 +++++++++++-
 fs/nfs/dir.c                         |   4 +
 fs/nfs/internal.h                    |   3 +-
 fs/nfs/nfs4file.c                    |   4 +
 fs/nfs/nfs4proc.c                    |   4 +-
 fs/nfs/nfs4super.c                   |   9 +-
 fs/nfs/nfs4xdr.c                     |  21 ++++-
 fs/nfs/super.c                       |   6 +-
 fs/nfsd/nfs4state.c                  |  46 +++++++++-
 fs/nfsd/nfsproc.c                    |   1 +
 fs/proc_namespace.c                  |   1 +
 include/linux/fs.h                   |  14 +++
 include/uapi/asm-generic/errno.h     |   2 +
 include/uapi/asm-generic/fcntl.h     |  12 +++
 include/uapi/linux/fs.h              |   1 +
 39 files changed, 464 insertions(+), 135 deletions(-)

-- 
1.8.1.5

