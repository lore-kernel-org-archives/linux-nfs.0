Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35404 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750795AbdEITxi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 May 2017 15:53:38 -0400
Received: by mail-it0-f65.google.com with SMTP id 67so1339337itx.2
        for <linux-nfs@vger.kernel.org>; Tue, 09 May 2017 12:53:38 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4.1: Work around a Linux server bug...
Date: Tue,  9 May 2017 15:53:35 -0400
Message-Id: <20170509195335.114163-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It turns out the Linux server has a bug in its implementation of
supattr_exclcreat; it returns the set of all attributes, whether
or not they are supported by minor version 1.
In order to avoid a regression, we therefore apply the supported_attrs
as a mask on top of whatever the server sent us.

Reported-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f48dfb7f3691..c08c46a3b8cd 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3268,6 +3268,7 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
 		.rpc_resp = &res,
 	};
 	int status;
+	int i;
 
 	bitmask[0] = FATTR4_WORD0_SUPPORTED_ATTRS |
 		     FATTR4_WORD0_FH_EXPIRE_TYPE |
@@ -3333,8 +3334,13 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
 		server->cache_consistency_bitmask[0] &= FATTR4_WORD0_CHANGE|FATTR4_WORD0_SIZE;
 		server->cache_consistency_bitmask[1] &= FATTR4_WORD1_TIME_METADATA|FATTR4_WORD1_TIME_MODIFY;
 		server->cache_consistency_bitmask[2] = 0;
+
+		/* Avoid a regression due to buggy server */
+		for (i = 0; i < ARRAY_SIZE(res.exclcreat_bitmask); i++)
+			res.exclcreat_bitmask[i] &= res.attr_bitmask[i];
 		memcpy(server->exclcreat_bitmask, res.exclcreat_bitmask,
 			sizeof(server->exclcreat_bitmask));
+
 		server->acl_bitmask = res.acl_bitmask;
 		server->fh_expire_type = res.fh_expire_type;
 	}
-- 
2.9.3

