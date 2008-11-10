From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 74/85] nfs41: Client indicates presence of NFSv4.1 callback channel.
Date: Mon, 10 Nov 2008 22:31:26 +0200
Message-ID: <1226349086-9703-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:60068 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752668AbYKJUbc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:31:32 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ricardo Labiaga <ricardo.labiaga@netapp.com>

Set the SESSION4_BACK_CHAN flag to indicate the client supports a backchannel.

Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 28c3cf8..f6a9894 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4679,7 +4679,7 @@ static int _nfs4_proc_create_session(struct nfs4_session *session)
 	int status;
 
 	nfs4_init_channel_attrs(clp, &args.fc_attrs, &args.bc_attrs);
-	args.flags = (SESSION4_PERSIST);
+	args.flags = (SESSION4_PERSIST | SESSION4_BACK_CHAN);
 
 	status = rpc_call_sync(session->clnt, &msg, 0);
 
-- 
1.6.0.2

