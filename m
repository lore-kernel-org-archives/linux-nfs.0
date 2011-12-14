Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:29619 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755283Ab1LNNyx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Dec 2011 08:54:53 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id pBEDsrhd025780
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 14 Dec 2011 08:54:53 -0500
Received: from dantu.rdu.redhat.com (dantu.rdu.redhat.com [10.11.228.66])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id pBEDspPj026219
	for <linux-nfs@vger.kernel.org>; Wed, 14 Dec 2011 08:54:52 -0500
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/5] sunrpc: create nfsd dir in rpc_pipefs
Date: Wed, 14 Dec 2011 08:54:48 -0500
Message-Id: <1323870891-3124-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1323870891-3124-1-git-send-email-jlayton@redhat.com>
References: <1323870891-3124-1-git-send-email-jlayton@redhat.com>
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

