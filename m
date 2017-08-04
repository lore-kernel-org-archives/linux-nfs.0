Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:24827 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751921AbdHDOtm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 4 Aug 2017 10:49:42 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <linux-fsdevel@vger.kernel.org>, <linux-nfs@vger.kernel.org>
Subject: [RFC v2 0/3] VFS/NFS support to destroy FS credentials
Date: Fri, 4 Aug 2017 10:49:36 -0400
Message-ID: <20170804144939.25374-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow a user to call into the file system and ask to destroy FS
credentials. For instance, when the user logs out after using
a kerberized NFS share, he destroys Kerberos credentials but NFS
credentials remain valid until the gss context expires. Allow
the user (or things like pam) to trigger destruction of such
credentials.

A userland application would do:

fd = open("/mnt", O_DIRECTORY|O_RDONLY);
syscall(_NR_destroy_creds, fd);

v2: fixing a hasty IS_DIR check, definition of __NR_destroy_creds
and order of the patches
 
Olga Kornievskaia (3):
  VFS adding destroy_creds call
  SUNRPC mark user credentials destroyed
  NFS define vfs destroy_creds functions

 arch/x86/entry/syscalls/syscall_32.tbl |  1 +
 arch/x86/entry/syscalls/syscall_64.tbl |  1 +
 fs/nfs/dir.c                           |  8 ++++++++
 fs/read_write.c                        | 22 ++++++++++++++++++++++
 include/linux/fs.h                     |  2 ++
 include/linux/sunrpc/auth.h            |  5 +++++
 include/linux/syscalls.h               |  2 +-
 include/uapi/asm-generic/unistd.h      |  4 +++-
 kernel/sys_ni.c                        |  1 +
 net/sunrpc/auth.c                      |  9 +++++++++
 net/sunrpc/auth_generic.c              | 15 +++++++++++++++
 net/sunrpc/auth_gss/auth_gss.c         |  3 +++
 12 files changed, 71 insertions(+), 2 deletions(-)

-- 
1.8.3.1

