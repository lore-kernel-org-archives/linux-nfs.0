Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qy0-f174.google.com ([209.85.216.174]:52081 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753803Ab2AWUBl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jan 2012 15:01:41 -0500
Received: by qcsf13 with SMTP id f13so1753141qcs.19
        for <linux-nfs@vger.kernel.org>; Mon, 23 Jan 2012 12:01:40 -0800 (PST)
MIME-Version: 1.0
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 2/6] sunrpc: create nfsd dir in rpc_pipefs
Date: Mon, 23 Jan 2012 15:01:03 -0500
Message-Id: <1327348867-699-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1327348867-699-1-git-send-email-jlayton@redhat.com>
References: <1327348867-699-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a new top-level dir in rpc_pipefs to hold the pipe for the clientid
upcall.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/rpc_pipe.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 63a7a7a..3dc2c6e 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -986,6 +986,7 @@ enum {
 	RPCAUTH_statd,
 	RPCAUTH_nfsd4_cb,
 	RPCAUTH_cache,
+	RPCAUTH_nfsd,
 	RPCAUTH_RootEOF
 };
 
@@ -1018,6 +1019,10 @@ static const struct rpc_filelist files[] = {
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
1.7.7.5

