Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35543 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751982AbbHZNKH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Aug 2015 09:10:07 -0400
Received: by pacdd16 with SMTP id dd16so160558394pac.2
        for <linux-nfs@vger.kernel.org>; Wed, 26 Aug 2015 06:10:07 -0700 (PDT)
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: =?UTF-8?Q?[PATCH_0/5_v3]_Some_updates_and_exclcreat_supports?=
 =?UTF-8?B?4oCL?=
Message-ID: <55DDBA9E.1040008@gmail.com>
Date: Wed, 26 Aug 2015 21:09:50 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The first one is a bugfix, second is an update,
the last 3 are for supporting exclcreat.

v3, 
Drop the first two patches that have be committed by Trond.
Fix the bad using of error value in nfs_setattr.

Kinglong Mee (5):
  NFS: Check size by inode_newsize_ok in nfs_setattr
  NFS: Make opened as optional argument in _nfs4_do_open
  NFS: Update NFS4_BITMAP_SIZE
  NFS: Get suppattr_exclcreat when getting server, capabilities
  NFS: Send attributes in OPEN request for NFS4_CREATE_EXCLUSIVE4_1

 fs/nfs/inode.c            | 18 ++++++++--------
 fs/nfs/nfs4file.c         |  3 +--
 fs/nfs/nfs4proc.c         | 37 +++++++++++++++++++++++++--------
 fs/nfs/nfs4xdr.c          | 52 +++++++++++++++++++++++++++++++++++------------
 include/linux/nfs_fs_sb.h |  5 +++++
 include/linux/nfs_xdr.h   |  4 +++-
 include/uapi/linux/nfs4.h |  2 +-
 7 files changed, 88 insertions(+), 33 deletions(-)

-- 
2.4.3

