Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35157 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752622AbbIXMyP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Sep 2015 08:54:15 -0400
Received: by pacfv12 with SMTP id fv12so73843103pac.2
        for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2015 05:54:15 -0700 (PDT)
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH 0/8] Some cleanups and bugfixes for nfs client callback
Message-ID: <5603F269.9060102@gmail.com>
Date: Thu, 24 Sep 2015 20:54:01 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The first five are cleanups, and last three are bugfixes
for nfs client callback.

Kinglong Mee (8):
  NFS: Get rid of the unneeded addr stored in callback arguments
  NFS: Remove the left global variable nfs_callback_tcpport
  NFS: Remove the left function defines in callback.h
  NFS: Remove unneeded NFS_DEBUG checking before define NFSDBG_FACILITY
  NFS: Use NFS4_MAX_SESSIONID_LEN directly for decode/encode sessionid
  NFS: Fix bad defines of callback response maxsize
  NFS: Fix bad checking of max taglen in callback request
  NFS: Return directly if encode_sessionid fail

 fs/nfs/callback.h      | 12 ------------
 fs/nfs/callback_proc.c |  2 --
 fs/nfs/callback_xdr.c  | 39 ++++++++++++++++++---------------------
 fs/nfs/mount_clnt.c    |  4 +---
 fs/nfs/super.c         |  2 --
 5 files changed, 19 insertions(+), 40 deletions(-)

-- 
2.5.0

