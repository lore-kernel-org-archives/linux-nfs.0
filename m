Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:33259 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751135AbdEBQiW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 2 May 2017 12:38:22 -0400
Received: by mail-io0-f193.google.com with SMTP id o22so7015949iod.0
        for <linux-nfs@vger.kernel.org>; Tue, 02 May 2017 09:38:22 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC PATCH 4/5] pNFS: Allow multiple connections to the DS
Date: Tue,  2 May 2017 12:38:11 -0400
Message-Id: <20170502163812.6211-8-trond.myklebust@primarydata.com>
In-Reply-To: <20170502163812.6211-7-trond.myklebust@primarydata.com>
References: <20170502163812.6211-1-trond.myklebust@primarydata.com>
 <20170502163812.6211-2-trond.myklebust@primarydata.com>
 <20170502163812.6211-3-trond.myklebust@primarydata.com>
 <20170502163812.6211-4-trond.myklebust@primarydata.com>
 <20170502163812.6211-5-trond.myklebust@primarydata.com>
 <20170502163812.6211-6-trond.myklebust@primarydata.com>
 <20170502163812.6211-7-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the user specifies -onconn=<number> mount option, and the transport
protocol is TCP, then set up <number> connections to the pNFS data server
as well. The connections will all go to the same IP address.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs3client.c | 3 +++
 fs/nfs/nfs4client.c | 3 +++
 2 files changed, 6 insertions(+)

diff --git a/fs/nfs/nfs3client.c b/fs/nfs/nfs3client.c
index 7879f2a0fcfd..8c624c74ddbe 100644
--- a/fs/nfs/nfs3client.c
+++ b/fs/nfs/nfs3client.c
@@ -100,6 +100,9 @@ struct nfs_client *nfs3_set_ds_client(struct nfs_server *mds_srv,
 		return ERR_PTR(-EINVAL);
 	cl_init.hostname = buf;
 
+	if (mds_clp->cl_nconnect > 1 && ds_proto == XPRT_TRANSPORT_TCP)
+		cl_init.nconnect = mds_clp->cl_nconnect;
+
 	if (mds_srv->flags & NFS_MOUNT_NORESVPORT)
 		set_bit(NFS_CS_NORESVPORT, &cl_init.init_flags);
 
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index c9b10b7829f0..bfea1b232dd2 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -912,6 +912,9 @@ struct nfs_client *nfs4_set_ds_client(struct nfs_server *mds_srv,
 		return ERR_PTR(-EINVAL);
 	cl_init.hostname = buf;
 
+	if (mds_clp->cl_nconnect > 1 && ds_proto == XPRT_TRANSPORT_TCP)
+		cl_init.nconnect = mds_clp->cl_nconnect;
+
 	if (mds_srv->flags & NFS_MOUNT_NORESVPORT)
 		__set_bit(NFS_CS_NORESVPORT, &cl_init.init_flags);
 
-- 
2.9.3

