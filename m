Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:26767 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753667Ab3IZTjo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Sep 2013 15:39:44 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
CC: <andros@netapp.com>, <jlayton@redhat.com>
Subject: [PATCH 3/3] NFSv4.1: Ensure memory ordering between nfs4_ds_connect and nfs4_fl_prepare_ds
Date: Thu, 26 Sep 2013 15:39:27 -0400
Message-ID: <1380224367-10939-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1380224367-10939-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1380224367-10939-1-git-send-email-Trond.Myklebust@netapp.com>
 <1380224367-10939-2-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We need to ensure that the initialisation of the data server nfs_client
structure in nfs4_ds_connect is correctly ordered w.r.t. the read of
ds->ds_clp in nfs4_fl_prepare_ds.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4filelayoutdev.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index ea2b2bf..6456fc4 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -185,6 +185,7 @@ nfs4_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
 	if (status)
 		goto out_put;
 
+	smp_wmb();
 	ds->ds_clp = clp;
 	dprintk("%s [new] addr: %s\n", __func__, ds->ds_remotestr);
 out:
@@ -812,6 +813,7 @@ nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx)
 		filelayout_mark_devid_invalid(devid);
 		goto out;
 	}
+	smp_rmb();
 	if (ds->ds_clp)
 		goto out;
 
-- 
1.8.3.1

