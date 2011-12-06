Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gx0-f174.google.com ([209.85.161.174]:61297 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753267Ab1LFVNd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Dec 2011 16:13:33 -0500
Received: by ggnr5 with SMTP id r5so6750605ggn.19
        for <linux-nfs@vger.kernel.org>; Tue, 06 Dec 2011 13:13:32 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/2] Cache state owners [take 2]
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 06 Dec 2011 16:13:30 -0500
Message-ID: <20111206210723.5969.85159.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This has seen some light testing.  Changes since version 1:

  o Inclusion of additional nfs4_find_state_owners_locked() clean up
  o Follow Bruce's suggestion to set ->destroy in common setup function
  o Use time_in_range() instead of time_before() to check for expiry
  o Discard state owners immediately in certain cases

---

Chuck Lever (2):
      NFS: Cache state owners after files are closed
      NFS: Clean up nfs4_find_state_owners_locked()


 fs/nfs/client.c           |    8 ++++
 fs/nfs/nfs4_fs.h          |    3 +
 fs/nfs/nfs4state.c        |  102 ++++++++++++++++++++++++++++++++++++---------
 include/linux/nfs_fs_sb.h |    1 
 4 files changed, 94 insertions(+), 20 deletions(-)

-- 
Chuck Lever
