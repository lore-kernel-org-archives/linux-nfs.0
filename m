Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f43.google.com ([209.85.219.43]:38948 "EHLO
	mail-oa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752677Ab3GXQ2V (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Jul 2013 12:28:21 -0400
Received: by mail-oa0-f43.google.com with SMTP id i7so1498197oag.2
        for <linux-nfs@vger.kernel.org>; Wed, 24 Jul 2013 09:28:21 -0700 (PDT)
Subject: [PATCH 0/2] Two fixes for machine cred handling
To: trond.myklebust@netapp.com
From: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Date: Wed, 24 Jul 2013 12:28:19 -0400
Message-ID: <20130724162632.53792.30516.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

Here are updated versions of patches that address machine cred handling
issues.  Hoping we are under less time pressure this time around.

---

Chuck Lever (2):
      NFS: Use root's credential for lease management when keytab is missing
      NFS: Never use user credentials for lease renewal


 fs/nfs/nfs4_fs.h     |    4 +--
 fs/nfs/nfs4proc.c    |    6 +---
 fs/nfs/nfs4session.c |    2 +
 fs/nfs/nfs4state.c   |   76 +++++++++++++++++---------------------------------
 4 files changed, 29 insertions(+), 59 deletions(-)

-- 
Chuck Lever
