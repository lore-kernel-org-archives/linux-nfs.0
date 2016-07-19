Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35247 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751742AbcGSUe1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Jul 2016 16:34:27 -0400
Received: by mail-io0-f196.google.com with SMTP id q83so2174570iod.2
        for <linux-nfs@vger.kernel.org>; Tue, 19 Jul 2016 13:34:27 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/4] Fix the v4.7 LAYOUTGET regressions
Date: Tue, 19 Jul 2016 16:33:53 -0400
Message-Id: <1468960437-21449-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v2:
The first patch in the series needs to return on fatal errors. (Thanks
Ben Coddington)

Trond Myklebust (4):
  pNFS: Fix post-layoutget error handling in pnfs_update_layout()
  pNFS: Separate handling of NFS4ERR_LAYOUTTRYLATER and RECALLCONFLICT
  pNFS: Handle NFS4ERR_RECALLCONFLICT correctly in LAYOUTGET
  pNFS: Fix LAYOUTGET handling of NFS4ERR_BAD_STATEID and
    NFS4ERR_EXPIRED

 fs/nfs/nfs4proc.c | 57 ++++++++++++++++++++++++++++---------------------------
 fs/nfs/pnfs.c     | 35 ++++++++++++++++++++++------------
 2 files changed, 52 insertions(+), 40 deletions(-)

-- 
2.7.4

