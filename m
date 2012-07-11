Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f52.google.com ([209.85.213.52]:34087 "EHLO
	mail-yw0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932350Ab2GKUan (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Jul 2012 16:30:43 -0400
Received: by mail-yw0-f52.google.com with SMTP id p61so1948409yhp.11
        for <linux-nfs@vger.kernel.org>; Wed, 11 Jul 2012 13:30:43 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/15] NFS: When state recovery fails,
 waiting tasks should exit
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 11 Jul 2012 16:30:41 -0400
Message-ID: <20120711203040.3767.81860.stgit@degas.1015granger.net>
In-Reply-To: <20120711201718.3767.66867.stgit@degas.1015granger.net>
References: <20120711201718.3767.66867.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFSv4 state recovery is not always successful.  Failure is signalled
by setting the nfs_client.cl_cons_state to a negative (errno) value,
then waking waiters.

Currently this can happen only during mount processing.  I'm about to
add an explicit case where state recovery failure during normal
operation should force all NFS requests waiting on that state recovery
to exit.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4proc.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6444d27..997080d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -259,7 +259,12 @@ static int nfs4_wait_clnt_recover(struct nfs_client *clp)
 
 	res = wait_on_bit(&clp->cl_state, NFS4CLNT_MANAGER_RUNNING,
 			nfs_wait_bit_killable, TASK_KILLABLE);
-	return res;
+	if (res)
+		return res;
+
+	if (clp->cl_cons_state < 0)
+		return clp->cl_cons_state;
+	return 0;
 }
 
 static int nfs4_delay(struct rpc_clnt *clnt, long *timeout)

