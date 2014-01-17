Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f177.google.com ([209.85.217.177]:54602 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751788AbaAQKH2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Jan 2014 05:07:28 -0500
From: Pavel Shilovsky <piastry@etersoft.ru>
To: linux-kernel@vger.kernel.org
Cc: linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, wine-devel@winehq.org
Subject: [PATCH v7 0/7] Add O_DENY* support for VFS and CIFS/NFS
Date: Fri, 17 Jan 2014 14:07:05 +0400
Message-Id: <1389953232-9428-1-git-send-email-piastry@etersoft.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patchset adds support of O_DENY* flags for Linux fs layer. These flags can be used by any application that needs share reservations to organize a file access. VFS already has some sort of this capability - now it's done through flock/LOCK_MAND mechanis, but that approach is non-atomic. This patchset build new capabilities on top of the existing one but doesn't bring any changes into the flock call semantic.

These flags can be used by NFS (built-in-kernel) and CIFS (Samba) servers and Wine applications through VFS (for local filesystems) or CIFS/NFS modules. This will help when e.g. Samba and NFS server share the same directory for Windows and Linux users or Wine applications use Samba/NFS share to access the same data from different clients.

According to the previous discussions the most problematic question is how to prevent situations like DoS attacks where e.g /lib/liba.so file can be open with DENYREAD, or smth like this. That's why extra mount option 'sharelock' is added for switching on/off O_DENY* flags processing. It allows to avoid use of these flags on critical places (like /, /lib) and turn them on if we really want it proccessed that way.

So, we have 3 new flags:
O_DENYREAD - to prevent other opens with read access,
O_DENYWRITE - to prevent other opens with write access,
O_DENYDELETE - to prevent delete operations

The patchset avoids data races problem on newely created files: open with O_CREAT can return the -ESHAREDENIED error for a successfully created file if this files was locked with a sharelock by another task. Also, it turns flock/LOCK_MAND capability off for mounts with 'sharelock' option. This lets not mix one share reservation approach with another.

Patches #1, #2 and #3 add O_DENY* flags to fcntl and implement VFS part. A patch #4 is related to CIFS client changes, #5 -- NFSD, #6 and #7 describe NFSv4 client parts.

The preliminary patch for Samba that replaces the existing use of flock/LOCK_MAND mechanism with O_DENY* flags:
http://git.etersoft.ru/people/piastry/packages/?p=samba.git;a=commitdiff;h=173070262b7f29134ad6b2e49a760017c11aec4a

The future part of open man page patch:

-----
O_DENYREAD, O_DENYWRIYE, O_DENYDELETE - used to inforce a mandatory share reservation scheme of the file access. If these flag is passed, the open fails with -ESHAREDENIED in following cases:
1) if O_DENYREAD flag is specified and there is another open with READ access to the file;
2) if O_DENYWRITE flag is specified and there is another open with WRITE access to the file;
3) if READ access is requested and there is another open with O_DENYREAD flags;
4) if WRITE access is requested and there is another open with O_DENYWRITE flags.

If O_DENYDELETE flag is specified and the open succeded, any further unlink operation will fail with -ESHAREDENIED untill this open is closed. Now this flag is processed by VFS and CIFS filesystem. NFS returns -EINVAL for opens with this flag.

This mechanism is done through flocks. If O_DENY* flags are specified, flock syscall is processed after the open. The share modes are translated into flock according the following rules:
1) !O_DENYREAD   -> LOCK_READ   | LOCK_MAND
2) !O_DENYWRITE  -> LOCK_WRITE  | LOCK_MAND
3) !O_DENYDELETE -> LOCK_DELETE | LOCK_MAND
-----

Pavel Shilovsky (7):
  VFS: Introduce new O_DENY* open flags
  VFS: Add O_DENYDELETE support for VFS
  locks: Disable LOCK_MAND support for MS_SHARELOCK mounts
  CIFS: Add O_DENY* open flags support
  NFSD: Pass share reservations flags to VFS
  NFSv4: Add deny state handling for nfs4_state struct
  NFSv4: Add O_DENY* open flags support

 arch/alpha/include/uapi/asm/errno.h  |    2 +
 arch/alpha/include/uapi/asm/fcntl.h  |    3 +
 arch/mips/include/uapi/asm/errno.h   |    2 +
 arch/parisc/include/uapi/asm/errno.h |    2 +
 arch/parisc/include/uapi/asm/fcntl.h |    3 +
 arch/sparc/include/uapi/asm/errno.h  |    2 +
 arch/sparc/include/uapi/asm/fcntl.h  |    3 +
 fs/cifs/cifsacl.c                    |    2 +
 fs/cifs/cifsfs.c                     |    2 +-
 fs/cifs/cifsglob.h                   |   17 +-
 fs/cifs/cifssmb.c                    |    2 +-
 fs/cifs/dir.c                        |    6 +
 fs/cifs/file.c                       |   20 ++-
 fs/cifs/inode.c                      |   12 +-
 fs/cifs/link.c                       |    2 +
 fs/cifs/netmisc.c                    |    2 +-
 fs/cifs/smb1ops.c                    |    3 +
 fs/cifs/smb2inode.c                  |    1 +
 fs/cifs/smb2maperror.c               |    2 +-
 fs/cifs/smb2ops.c                    |    6 +
 fs/cifs/smb2pdu.c                    |    2 +-
 fs/fcntl.c                           |    5 +-
 fs/locks.c                           |  161 ++++++++++++++++--
 fs/namei.c                           |   56 +++++-
 fs/nfs/dir.c                         |   39 ++++-
 fs/nfs/inode.c                       |    8 +-
 fs/nfs/internal.h                    |    3 +-
 fs/nfs/nfs4_fs.h                     |   83 ++++++++-
 fs/nfs/nfs4file.c                    |    8 +-
 fs/nfs/nfs4proc.c                    |  310 +++++++++++++++++++++++-----------
 fs/nfs/nfs4state.c                   |   65 ++++---
 fs/nfs/nfs4super.c                   |    9 +-
 fs/nfs/nfs4xdr.c                     |   21 ++-
 fs/nfs/super.c                       |    7 +-
 fs/nfsd/nfs4state.c                  |   46 ++++-
 fs/nfsd/nfsproc.c                    |    1 +
 fs/proc_namespace.c                  |    1 +
 include/linux/fs.h                   |   15 ++
 include/linux/nfs_fs.h               |    5 +-
 include/linux/nfs_xdr.h              |    1 +
 include/uapi/asm-generic/errno.h     |    2 +
 include/uapi/asm-generic/fcntl.h     |   12 ++
 include/uapi/linux/fs.h              |    1 +
 43 files changed, 789 insertions(+), 166 deletions(-)

-- 
1.7.10.4

