Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:56341 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752069Ab2CUNwS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Mar 2012 09:52:18 -0400
Received: by yhmm54 with SMTP id m54so910854yhm.19
        for <linux-nfs@vger.kernel.org>; Wed, 21 Mar 2012 06:52:18 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v10 3/8] sunrpc: create nfsd dir in rpc_pipefs
Date: Wed, 21 Mar 2012 09:52:04 -0400
Message-Id: <1332337929-18580-4-git-send-email-jlayton@redhat.com>
In-Reply-To: <1332337929-18580-1-git-send-email-jlayton@redhat.com>
References: <1332337929-18580-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a new top-level dir in rpc_pipefs to hold the pipe for the clientid
upcall.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/rpc_pipe.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 8584ec0..e651e1b 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -1014,6 +1014,7 @@ enum {
 	RPCAUTH_statd,
 	RPCAUTH_nfsd4_cb,
 	RPCAUTH_cache,
+	RPCAUTH_nfsd,
 	RPCAUTH_RootEOF
 };
 
@@ -1046,6 +1047,10 @@ static const struct rpc_filelist files[] = {
 		.name = "cache",
 		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
 	},
+	[RPCAUTH_nfsd] = {
+		.name = "nfsd",
+		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
+	},
 };
 
 /*
-- 
1.7.7.6

