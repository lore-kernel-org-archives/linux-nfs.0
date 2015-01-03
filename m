Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f181.google.com ([209.85.223.181]:56894 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752496AbbACTpg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 3 Jan 2015 14:45:36 -0500
Received: by mail-ie0-f181.google.com with SMTP id rl12so16125357iec.40
        for <linux-nfs@vger.kernel.org>; Sat, 03 Jan 2015 11:45:35 -0800 (PST)
Subject: [PATCH] NFS: Ignore transport protocol when detecting server
 trunking
From: Chuck Lever <chuck.lever@oracle.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Date: Sat, 03 Jan 2015 14:45:33 -0500
Message-ID: <20150103193753.3418.77888.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Detect server trunking across transport protocols. Otherwise, an
RDMA mount and a TCP mount of the same server will end up with
separate nfs_clients using the same clientid4.

Reported-by: Dai Ngo <dai.ngo@oracle.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
Re: yesterday's discussion of "[PATCH] NFSv4.1: Fix client id
trunking on Linux". This patch seems to address the behavior I
mentioned.

 fs/nfs/nfs4client.c |    6 ------
 1 file changed, 6 deletions(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index c0fe338..c7bc38e 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -540,9 +540,6 @@ int nfs40_walk_client_list(struct nfs_client *new,
 		if (pos->rpc_ops != new->rpc_ops)
 			continue;
 
-		if (pos->cl_proto != new->cl_proto)
-			continue;
-
 		if (pos->cl_minorversion != new->cl_minorversion)
 			continue;
 
@@ -675,9 +672,6 @@ int nfs41_walk_client_list(struct nfs_client *new,
 		if (pos->rpc_ops != new->rpc_ops)
 			continue;
 
-		if (pos->cl_proto != new->cl_proto)
-			continue;
-
 		if (pos->cl_minorversion != new->cl_minorversion)
 			continue;
 

