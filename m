Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:32788 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751427AbbG3Njj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jul 2015 09:39:39 -0400
Received: by padck2 with SMTP id ck2so23903848pad.0
        for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2015 06:39:39 -0700 (PDT)
Message-ID: <55BA290B.2020704@gmail.com>
Date: Thu, 30 Jul 2015 21:39:23 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: [PATCH 0/7 v2]  Some bugfixes and exclcreat supports
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The first 3 are some bugfixes, the 4th is an update.
The last 3 is for supporting exclcreat.

Kinglong Mee (7):
  NFS: Remove duplicate svc_xprt_put from nfs41_callback_up
  NFS: Error out when register_shrinker fail in register_nfs_fs
  NFS: Check size by inode_newsize_ok in nfs_setattr
  NFS: Make opened as optional argument in _nfs4_do_open
  NFS: Update NFS4_BITMAP_SIZE
  NFS: Get suppattr_exclcreat when getting server capabilities
  NFS: Send attributes in OPEN request for NFS4_CREATE_EXCLUSIVE4_1

 fs/nfs/callback.c         |  4 ----
 fs/nfs/inode.c            | 11 +++++-----
 fs/nfs/nfs4file.c         |  3 +--
 fs/nfs/nfs4proc.c         | 37 +++++++++++++++++++++++++--------
 fs/nfs/nfs4xdr.c          | 52 +++++++++++++++++++++++++++++++++++------------
 fs/nfs/super.c            |  7 +++++--
 include/linux/nfs_fs_sb.h |  5 +++++
 include/linux/nfs_xdr.h   |  4 +++-
 include/uapi/linux/nfs4.h |  2 +-
 9 files changed, 88 insertions(+), 37 deletions(-)

-- 
2.4.3

