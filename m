Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f51.google.com ([209.85.220.51]:43945 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752540AbaGHDqq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Jul 2014 23:46:46 -0400
Received: by mail-pa0-f51.google.com with SMTP id hz1so6594360pad.10
        for <linux-nfs@vger.kernel.org>; Mon, 07 Jul 2014 20:46:46 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH 1/2] nfsv4: set hostname when creating nfsv4 ds connection
Date: Tue,  8 Jul 2014 11:45:47 +0800
Message-Id: <1404791148-10202-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We reference cl_hostname in many places for debugging purpose.
So make it useful by setting hostname when calling nfs_get_client.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/nfs4client.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 9940037..ff8cba2 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -856,6 +856,11 @@ struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
 	};
 	struct rpc_timeout ds_timeout;
 	struct nfs_client *clp;
+	char buf[INET6_ADDRSTRLEN + 1];
+
+	if (rpc_ntop(ds_addr, buf, sizeof(buf)) <= 0)
+		return ERR_PTR(-EINVAL);
+	cl_init.hostname = buf;
 
 	/*
 	 * Set an authflavor equual to the MDS value. Use the MDS nfs_client
-- 
1.9.1

