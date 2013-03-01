Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:49591 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750985Ab3CAAZE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Feb 2013 19:25:04 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org, andros@netapp.com
Subject: [PATCH] NFSv4: Fix another open/open_recovery deadlock
Date: Thu, 28 Feb 2013 16:24:58 -0800
Message-Id: <1362097498-32641-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we don't release the open seqid before we wait for state recovery,
then we may end up deadlocking the state recovery thread.
This patch addresses a new deadlock that was introduced by
commit c21443c2c792cd9b463646d982b0fe48aa6feb0f (NFSv4: Fix a reboot
recovery race when opening a file)

Reported-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 655237f..37eb385 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1158,6 +1158,7 @@ _nfs4_opendata_to_nfs4_state(struct nfs4_opendata *data)
 			data->o_arg.fmode);
 	iput(inode);
 out:
+	nfs_release_seqid(data->o_arg.seqid);
 	return state;
 err_put_inode:
 	iput(inode);
-- 
1.8.1.2

