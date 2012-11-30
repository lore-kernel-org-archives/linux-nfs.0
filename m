Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f46.google.com ([209.85.215.46]:33410 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932554Ab2K3KUw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Nov 2012 05:20:52 -0500
From: Pavel Shilovsky <piastry@etersoft.ru>
To: linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [PATCH 0/3] Add O_DENY* flags to fcntl and cifs
Date: Fri, 30 Nov 2012 14:20:37 +0400
Message-Id: <1354270840-7272-1-git-send-email-piastry@etersoft.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Network filesystems CIFS, SMB2.0, SMB3.0 and NFSv4 have such flags - this change can benefit cifs and nfs modules. While this change is ok for network filesystems, itsn't not targeted for local filesystems due security problems (e.g. when a user process can deny root to delete a file).

Share flags are used by Windows applications and WINE have to deal with them too. While WINE can process open share flags itself on local filesystems, it can't do it if a file stored on a network share and is used by several clients. This patchset makes it possible for CIFS/SMB2.0/SMB3.0.

Pavel Shilovsky (3):
  fcntl: Introduce new O_DENY* open flags for network filesystems
  CIFS: Add O_DENY* open flags support
  CIFS: Use NT_CREATE_ANDX command for forcemand mounts

 fs/cifs/cifsacl.c                |   10 ++++----
 fs/cifs/cifsglob.h               |   11 ++++++++-
 fs/cifs/cifsproto.h              |    9 ++++----
 fs/cifs/cifssmb.c                |   47 ++++++++++++++++++++------------------
 fs/cifs/dir.c                    |   14 ++++++++----
 fs/cifs/file.c                   |   18 ++++++++++-----
 fs/cifs/inode.c                  |   11 +++++----
 fs/cifs/link.c                   |   10 ++++----
 fs/cifs/readdir.c                |    2 +-
 fs/cifs/smb1ops.c                |   15 ++++++------
 fs/cifs/smb2file.c               |   10 ++++----
 fs/cifs/smb2inode.c              |    4 ++--
 fs/cifs/smb2ops.c                |   10 ++++----
 fs/cifs/smb2pdu.c                |    6 ++---
 fs/cifs/smb2proto.h              |   14 +++++++-----
 fs/fcntl.c                       |    5 ++--
 include/uapi/asm-generic/fcntl.h |   11 +++++++++
 17 files changed, 125 insertions(+), 82 deletions(-)

-- 
1.7.10.4

