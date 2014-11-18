Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.web.de ([212.227.17.12]:49925 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754025AbaKRNLC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Nov 2014 08:11:02 -0500
Message-ID: <546B4553.5040404@users.sourceforge.net>
Date: Tue, 18 Nov 2014 14:10:43 +0100
From: SF Markus Elfring <elfring@users.sourceforge.net>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
CC: LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org,
        Coccinelle <cocci@systeme.lip6.fr>
Subject: [PATCH 1/1] NFS: Deletion of unnecessary checks before the function
 call "nfs_put_client"
References: <5307CAA2.8060406@users.sourceforge.net> <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6> <530A086E.8010901@users.sourceforge.net> <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6> <530A72AA.3000601@users.sourceforge.net> <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6> <530B5FB6.6010207@users.sourceforge.net> <alpine.DEB.2.10.1402241710370.2074@hadrien> <530C5E18.1020800@users.sourceforge.net> <alpine.DEB.2.10.1402251014170.2080@hadrien> <530CD2C4.4050903@users.sourceforge.net> <alpine.DEB.2.10.1402251840450.7035@hadrien> <530CF8FF.8080600@users.sourceforge.net> <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6> <530DD06F.4090703@users.sourceforge.net> <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6> <5317A59D.4@users.sourceforge.net>
In-Reply-To: <5317A59D.4@users.sourceforge.net>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 18 Nov 2014 13:23:43 +0100

The nfs_put_client() function tests whether its argument is NULL and then
returns immediately. Thus the test around the call is not needed.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 fs/nfs/filelayout/filelayoutdev.c |  3 +--
 fs/nfs/nfs4client.c               | 15 +++++----------
 2 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/filelayout/filelayoutdev.c b/fs/nfs/filelayout/filelayoutdev.c
index 8540516..cc5e7d6 100644
--- a/fs/nfs/filelayout/filelayoutdev.c
+++ b/fs/nfs/filelayout/filelayoutdev.c
@@ -204,8 +204,7 @@ destroy_ds(struct nfs4_pnfs_ds *ds)
 	ifdebug(FACILITY)
 		print_ds(ds);
 
-	if (ds->ds_clp)
-		nfs_put_client(ds->ds_clp);
+	nfs_put_client(ds->ds_clp);
 
 	while (!list_empty(&ds->ds_addrs)) {
 		da = list_first_entry(&ds->ds_addrs,
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index ffdb28d..5f07a0e 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -498,8 +498,7 @@ int nfs40_walk_client_list(struct nfs_client *new,
 			atomic_inc(&pos->cl_count);
 			spin_unlock(&nn->nfs_client_lock);
 
-			if (prev)
-				nfs_put_client(prev);
+			nfs_put_client(prev);
 			prev = pos;
 
 			status = nfs_wait_client_init_complete(pos);
@@ -517,8 +516,7 @@ int nfs40_walk_client_list(struct nfs_client *new,
 		atomic_inc(&pos->cl_count);
 		spin_unlock(&nn->nfs_client_lock);
 
-		if (prev)
-			nfs_put_client(prev);
+		nfs_put_client(prev);
 		prev = pos;
 
 		status = nfs4_proc_setclientid_confirm(pos, &clid, cred);
@@ -549,8 +547,7 @@ int nfs40_walk_client_list(struct nfs_client *new,
 
 	/* No match found. The server lost our clientid */
 out:
-	if (prev)
-		nfs_put_client(prev);
+	nfs_put_client(prev);
 	dprintk("NFS: <-- %s status = %d\n", __func__, status);
 	return status;
 }
@@ -641,8 +638,7 @@ int nfs41_walk_client_list(struct nfs_client *new,
 			atomic_inc(&pos->cl_count);
 			spin_unlock(&nn->nfs_client_lock);
 
-			if (prev)
-				nfs_put_client(prev);
+			nfs_put_client(prev);
 			prev = pos;
 
 			status = nfs_wait_client_init_complete(pos);
@@ -675,8 +671,7 @@ int nfs41_walk_client_list(struct nfs_client *new,
 	/* No matching nfs_client found. */
 	spin_unlock(&nn->nfs_client_lock);
 	dprintk("NFS: <-- %s status = %d\n", __func__, status);
-	if (prev)
-		nfs_put_client(prev);
+	nfs_put_client(prev);
 	return status;
 }
 #endif	/* CONFIG_NFS_V4_1 */
-- 
2.1.3

