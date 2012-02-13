Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qy0-f174.google.com ([209.85.216.174]:61147 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752013Ab2BMPPy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Feb 2012 10:15:54 -0500
Received: by mail-qy0-f174.google.com with SMTP id w6so2987323qcq.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Feb 2012 07:15:53 -0800 (PST)
MIME-Version: 1.0
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v6 2/5] sunrpc: create nfsd dir in rpc_pipefs
Date: Mon, 13 Feb 2012 10:15:42 -0500
Message-Id: <1329146145-7602-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1329146145-7602-1-git-send-email-jlayton@redhat.com>
References: <1329146145-7602-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a new top-level dir in rpc_pipefs to hold the pipe for the clientid
upcall.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/rpc_pipe.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 58e1dd1..46d5279 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -988,6 +988,7 @@ enum {
 	RPCAUTH_statd,
 	RPCAUTH_nfsd4_cb,
 	RPCAUTH_cache,
+	RPCAUTH_nfsd,
 	RPCAUTH_RootEOF
 };
 
@@ -1020,6 +1021,10 @@ static const struct rpc_filelist files[] = {
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
1.7.7.6

