Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f173.google.com ([209.85.216.173]:35953 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755065AbaDOMvz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Apr 2014 08:51:55 -0400
Received: by mail-qc0-f173.google.com with SMTP id r5so10386262qcx.32
        for <linux-nfs@vger.kernel.org>; Tue, 15 Apr 2014 05:51:54 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: set timeparms.to_maxval in setup_callback_client
Date: Tue, 15 Apr 2014 08:51:48 -0400
Message-Id: <1397566308-16871-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...otherwise the logic in the timeout handling doesn't work correctly.

Spotted-by: Trond Myklebust <trond.myklebust@primarydata.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4callback.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 39c8ef875f91..2c73cae9899d 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -654,9 +654,11 @@ static struct rpc_clnt *create_backchannel_client(struct rpc_create_args *args)
 
 static int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *conn, struct nfsd4_session *ses)
 {
+	int maxtime = max_cb_time(clp->net);
 	struct rpc_timeout	timeparms = {
-		.to_initval	= max_cb_time(clp->net),
+		.to_initval	= maxtime,
 		.to_retries	= 0,
+		.to_maxval	= maxtime,
 	};
 	struct rpc_create_args args = {
 		.net		= clp->net,
-- 
1.9.0

