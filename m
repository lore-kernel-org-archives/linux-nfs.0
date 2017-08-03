Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:2372 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751251AbdHCSfL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 3 Aug 2017 14:35:11 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <linux-fsdevel@vger.kernel.org>, <linux-nfs@vger.kernel.org>
Subject: [RFC 0/3] VFS/NFS support to destroy FS credentials
Date: Thu, 3 Aug 2017 14:35:05 -0400
Message-ID: <20170803183508.24565-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It was suggested to propose a generic system call for credential
destruction that other file systems can use instead of doing an
NFS specific destruction. So here's an attempt at that.

Allow a user to call into the file system and ask to destroy FS
credentials. For instance, when the user logs out after using
a kerberized NFS share, he destroys Kerberos credentials but NFS
credentials remain valid until the gss context expires. Allow
the user (or things like pam) to trigger destruction of such
credentials.

A userland application would do:

fd = open("/mnt", O_DIRECTORY|O_RDONLY);
syscall(_NR_destroy_creds, fd);

Olga Kornievskaia (3):
  VFS adding destroy_creds call
  NFS define vfs destroy_creds functions
  SUNRPC mark user credentials destroyed

 arch/x86/entry/syscalls/syscall_32.tbl |  1 +
 arch/x86/entry/syscalls/syscall_64.tbl |  1 +
 fs/nfs/dir.c                           |  8 ++++++++
 fs/read_write.c                        | 20 ++++++++++++++++++++
 include/linux/fs.h                     |  2 ++
 include/linux/sunrpc/auth.h            |  5 +++++
 include/linux/syscalls.h               |  2 +-
 include/uapi/asm-generic/unistd.h      |  4 +++-
 kernel/sys_ni.c                        |  1 +
 net/sunrpc/auth.c                      |  9 +++++++++
 net/sunrpc/auth_generic.c              | 15 +++++++++++++++
 net/sunrpc/auth_gss/auth_gss.c         |  3 +++
 12 files changed, 69 insertions(+), 2 deletions(-)

-- 
1.8.3.1

