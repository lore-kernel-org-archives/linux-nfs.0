Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f49.google.com ([209.85.215.49]:36517 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755777Ab3DZL7x (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Apr 2013 07:59:53 -0400
From: Pavel Shilovsky <piastry@etersoft.ru>
To: linux-kernel@vger.kernel.org
Cc: linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, wine-devel@winehq.org
Subject: [PATCH v6 0/7] Add O_DENY* support for VFS and CIFS/NFS
Date: Fri, 26 Apr 2013 16:04:14 +0400
Message-Id: <1366977861-27678-1-git-send-email-piastry@etersoft.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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

This patchset adds support of O_DENY* flags for Linux fs layer. These flags can be used by any application that needs share reservations to organize a file access. VFS already has some sort of this capability - now it's done through flock/LOCK_MAND mechanis, but that approach is non-atomic. This patchset build new capabilities on top of the existing one but doesn't bring any changes into the flock call semantic.

These flags can be used by NFS (built-in-kernel) and CIFS (Samba) servers and Wine applications through VFS (for local filesystems) or CIFS/NFS modules. This will help when e.g. Samba and NFS server share the same directory for Windows and Linux users or Wine applications use Samba/NFS share to access the same data from different clients.

According to the previous discussions the most problematic question is how to prevent situations like DoS attacks where e.g /lib/liba.so file can be open with DENYREAD, or smth like this. That's why extra mount option 'sharelock' is added for switching on/off O_DENY* flags processing. It allows us to avoid use of these flags on critical places (like /, /lib) and turn them on if we really want it proccessed that way.

So, we have 3 new flags:
O_DENYREAD - to prevent other opens with read access,
O_DENYWRITE - to prevent other opens with write access,
O_DENYDELETE - to prevent delete operations (this flag is not implemented in VFS and NFS part and only suitable for CIFS module),

The patchset avoid data races problem on newely created files: open with O_CREAT can return the -ETXTBSY error for a successfully created file if this files was locked with a sharelock by another task. Also, it turns flock/LOCK_MAND capability off for mounts with 'sharelock' option. This lets us not mix one share reservation approach with another.

The #1 patch adds flags to fcntl and implements VFS part. The patches #3, #4, #5 are related to CIFS-specific changes, #6 and #7 describe NFS and NFSD parts.

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
-----

Pavel Shilovsky (7):
  VFS: Introduce new O_DENY* open flags
  VFS: Add O_DENYDELETE support for VFS
  CIFS: Add share_access parm to open request
  CIFS: Add O_DENY* open flags support
  NFSv4: Add O_DENY* open flags support
  NFSD: Pass share reservations flags to VFS
  locks: Disable LOCK_MAND support for MS_SHARELOCK mounts

 fs/cifs/cifsacl.c                |   8 +-
 fs/cifs/cifsfs.c                 |   2 +-
 fs/cifs/cifsglob.h               |  18 ++++-
 fs/cifs/cifsproto.h              |   8 +-
 fs/cifs/cifssmb.c                |  50 +++++++------
 fs/cifs/dir.c                    |  16 ++--
 fs/cifs/file.c                   |  25 +++++--
 fs/cifs/inode.c                  |  21 +++---
 fs/cifs/link.c                   |  25 ++-----
 fs/cifs/netmisc.c                |   2 +-
 fs/cifs/readdir.c                |   5 +-
 fs/cifs/smb1ops.c                |  16 ++--
 fs/cifs/smb2file.c               |  10 +--
 fs/cifs/smb2inode.c              |   4 +-
 fs/cifs/smb2maperror.c           |   2 +-
 fs/cifs/smb2ops.c                |  10 ++-
 fs/cifs/smb2pdu.c                |   6 +-
 fs/cifs/smb2proto.h              |  14 ++--
 fs/fcntl.c                       |   5 +-
 fs/locks.c                       | 158 ++++++++++++++++++++++++++++++++++++---
 fs/namei.c                       |  48 +++++++++++-
 fs/nfs/dir.c                     |   4 +
 fs/nfs/internal.h                |   3 +-
 fs/nfs/nfs4file.c                |   4 +
 fs/nfs/nfs4proc.c                |   4 +-
 fs/nfs/nfs4super.c               |   9 ++-
 fs/nfs/nfs4xdr.c                 |  21 +++++-
 fs/nfs/super.c                   |   7 +-
 fs/nfsd/nfs4state.c              |  46 +++++++++++-
 fs/nfsd/nfsproc.c                |   1 +
 fs/proc_namespace.c              |   1 +
 include/linux/fs.h               |  14 ++++
 include/uapi/asm-generic/errno.h |   2 +
 include/uapi/asm-generic/fcntl.h |  12 +++
 include/uapi/linux/fs.h          |   1 +
 35 files changed, 443 insertions(+), 139 deletions(-)

-- 
1.8.1.5

