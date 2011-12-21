Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:36111 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751958Ab1LUUe6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Dec 2011 15:34:58 -0500
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org, steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 2/5] sunrpc: create nfsd dir in rpc_pipefs
Date: Wed, 21 Dec 2011 15:34:53 -0500
Message-Id: <1324499696-10318-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1324499696-10318-1-git-send-email-jlayton@redhat.com>
References: <1324499696-10318-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a new top-level dir in rpc_pipefs to hold the pipe for the clientid
upcall.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/rpc_pipe.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index bfddd68..7cb8ab7 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -987,6 +987,7 @@ enum {
 	RPCAUTH_statd,
 	RPCAUTH_nfsd4_cb,
 	RPCAUTH_cache,
+	RPCAUTH_nfsd,
 	RPCAUTH_RootEOF
 };
 
@@ -1019,6 +1020,10 @@ static const struct rpc_filelist files[] = {
 		.name = "cache",
 		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
 	},
+	[RPCAUTH_nfsd] = {
+		.name = "nfsd",
+		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
+	},
 };
 
 static int
-- 
1.7.1

