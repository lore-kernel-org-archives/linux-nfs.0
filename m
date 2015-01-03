Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f182.google.com ([209.85.213.182]:34994 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751422AbbACVKD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 3 Jan 2015 16:10:03 -0500
Received: by mail-ig0-f182.google.com with SMTP id hn15so906099igb.15
        for <linux-nfs@vger.kernel.org>; Sat, 03 Jan 2015 13:10:03 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v2 4/4] NFSv4: Ignore netid in trunking detection code
Date: Sat,  3 Jan 2015 16:09:57 -0500
Message-Id: <1420319397-37704-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1420319397-37704-3-git-send-email-trond.myklebust@primarydata.com>
References: <1420319397-37704-1-git-send-email-trond.myklebust@primarydata.com>
 <1420319397-37704-2-git-send-email-trond.myklebust@primarydata.com>
 <1420319397-37704-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The only thing a server cares about when deciding whether or not it is
talking to the same client in a setclientid or exchange_id, is the value
of the client owner id field. In particular, it does not distinguish
between setclientid/exchange_id calls on different types of transport.
When doing trunking detection, the client must therefore also ensure
it does not discriminate between connections on different transports.

Reported-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4client.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index b1024bcc65c8..953daa44a282 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -492,9 +492,6 @@ int nfs40_walk_client_list(struct nfs_client *new,
 		if (pos->rpc_ops != new->rpc_ops)
 			continue;
 
-		if (pos->cl_proto != new->cl_proto)
-			continue;
-
 		if (pos->cl_minorversion != new->cl_minorversion)
 			continue;
 
@@ -627,9 +624,6 @@ int nfs41_walk_client_list(struct nfs_client *new,
 		if (pos->rpc_ops != new->rpc_ops)
 			continue;
 
-		if (pos->cl_proto != new->cl_proto)
-			continue;
-
 		if (pos->cl_minorversion != new->cl_minorversion)
 			continue;
 
-- 
2.1.0

