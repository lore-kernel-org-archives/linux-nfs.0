Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:51230 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753046Ab1AUDFC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Jan 2011 22:05:02 -0500
Received: by vws16 with SMTP id 16so612009vws.19
        for <linux-nfs@vger.kernel.org>; Thu, 20 Jan 2011 19:05:01 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/4] 2.6.38 bug fixes
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 20 Jan 2011 22:04:55 -0500
Message-ID: <20110121030314.1056.96774.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hey-

Here are four patches that address recent issues discovered in 2.6.38.
They should be ready for inclusion upstream.  I say that because that
guarantees you will find bugs in them.

---

Chuck Lever (4):
      NFS: Prevent memory allocation failure in nfsacl_encode()
      NFS: nfsacl_{encode,decode} should return signed integer
      NFS: Fix "kernel BUG at fs/nfs/nfs3xdr.c:1338!"
      NFS: Fix "kernel BUG at fs/aio.c:554!"


 fs/nfs/direct.c           |   30 +++++++++++++------------
 fs/nfs/nfs3acl.c          |    4 ++-
 fs/nfs/nfs3xdr.c          |    5 +++-
 fs/nfs_common/nfsacl.c    |   54 ++++++++++++++++++++++++++++++++++-----------
 fs/posix_acl.c            |   17 +++++++++++---
 include/linux/nfsacl.h    |    4 ++-
 include/linux/posix_acl.h |    1 +
 7 files changed, 79 insertions(+), 36 deletions(-)

-- 
Chuck Lever
