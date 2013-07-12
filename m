Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f53.google.com ([209.85.213.53]:38252 "EHLO
	mail-yh0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964992Ab3GLQbr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Jul 2013 12:31:47 -0400
Received: by mail-yh0-f53.google.com with SMTP id a41so3818470yho.12
        for <linux-nfs@vger.kernel.org>; Fri, 12 Jul 2013 09:31:46 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe93:815b])
        by mx.google.com with ESMTPSA id m63sm69009810yhb.10.2013.07.12.09.31.45
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 12 Jul 2013 09:31:45 -0700 (PDT)
Subject: [PATCH v1 02/19] NFS: Fix return type of nfs4_end_drain_session()
 stub
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 12 Jul 2013 12:31:45 -0400
Message-ID: <20130712163145.1444.8783.stgit@seurat.1015granger.net>
In-Reply-To: <20130712155303.1444.62697.stgit@seurat.1015granger.net>
References: <20130712155303.1444.62697.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: when NFSv4.1 support is compiled out,
nfs4_end_drain_session() becomes a stub.  Make the synopsis of the
stub match the synopsis of the real version of the function.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4state.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 15fde8c..71fc85d 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -2087,7 +2087,7 @@ static int nfs4_bind_conn_to_session(struct nfs_client *clp)
 }
 #else /* CONFIG_NFS_V4_1 */
 static int nfs4_reset_session(struct nfs_client *clp) { return 0; }
-static int nfs4_end_drain_session(struct nfs_client *clp) { return 0; }
+static void nfs4_end_drain_session(struct nfs_client *clp) { }
 
 static int nfs4_bind_conn_to_session(struct nfs_client *clp)
 {

