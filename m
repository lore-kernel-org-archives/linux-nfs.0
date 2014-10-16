Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f181.google.com ([209.85.213.181]:37466 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751887AbaJPTk1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Oct 2014 15:40:27 -0400
Received: by mail-ig0-f181.google.com with SMTP id r10so255688igi.14
        for <linux-nfs@vger.kernel.org>; Thu, 16 Oct 2014 12:40:26 -0700 (PDT)
Received: from manet.1015granger.net ([2604:8800:100:81fc:82ee:73ff:fe43:d64f])
        by mx.google.com with ESMTPSA id y64sm3296730iod.0.2014.10.16.12.40.25
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Oct 2014 12:40:26 -0700 (PDT)
Subject: [PATCH v1 16/16] NFS: Disable SESSION4_BACK_CHAN when a backchannel
 sidecar is to be used
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Thu, 16 Oct 2014 15:40:24 -0400
Message-ID: <20141016194024.13414.22106.stgit@manet.1015granger.net>
In-Reply-To: <20141016192919.13414.3151.stgit@manet.1015granger.net>
References: <20141016192919.13414.3151.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A CREATE_SESSION operation with SESSION4_BACK_CHAN cleared is sent
to force the server to report SEQ4_STATUS_CB_PATH_DOWN.  The client
recovers by setting up a sidecar backchannel connection.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4proc.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 2eaf7ec..e0bcc30 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7187,6 +7187,7 @@ static int _nfs4_proc_create_session(struct nfs_client *clp,
 	struct nfs41_create_session_args args = {
 		.client = clp,
 		.cb_program = NFS4_CALLBACK,
+		.flags = SESSION4_PERSIST,
 	};
 	struct nfs41_create_session_res res = {
 		.client = clp,
@@ -7200,7 +7201,8 @@ static int _nfs4_proc_create_session(struct nfs_client *clp,
 	int status;
 
 	nfs4_init_channel_attrs(&args);
-	args.flags = (SESSION4_PERSIST | SESSION4_BACK_CHAN);
+	if (!clp->cl_bc_rpcclient)
+		args.flags |= SESSION4_BACK_CHAN;
 
 	status = rpc_call_sync(session->clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
 	trace_nfs4_create_session(clp, status);

