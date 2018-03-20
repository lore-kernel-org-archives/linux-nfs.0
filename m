Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:34683 "EHLO
        mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751018AbeCTUno (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Mar 2018 16:43:44 -0400
Received: by mail-io0-f170.google.com with SMTP id r18so4023732ioa.1
        for <linux-nfs@vger.kernel.org>; Tue, 20 Mar 2018 13:43:44 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/8] NFSv4: Fix nfs4_return_incompatible_delegation
Date: Tue, 20 Mar 2018 16:43:13 -0400
Message-Id: <20180320204320.93656-2-trond.myklebust@primarydata.com>
In-Reply-To: <20180320204320.93656-1-trond.myklebust@primarydata.com>
References: <20180320204320.93656-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The 'fmode' argument can take an FMODE_EXEC value, which we want to
filter out before comparing to the delegation type.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 47f3c273245e..75b8ea08e6f7 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1669,6 +1669,7 @@ static void nfs4_return_incompatible_delegation(struct inode *inode, fmode_t fmo
 {
 	struct nfs_delegation *delegation;
 
+	fmode &= FMODE_READ|FMODE_WRITE;
 	rcu_read_lock();
 	delegation = rcu_dereference(NFS_I(inode)->delegation);
 	if (delegation == NULL || (delegation->type & fmode) == fmode) {
-- 
2.14.3

