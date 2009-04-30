From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 21/39] nfs41: Client indicates presence of NFSv4.1 callback channel.
Date: Fri,  1 May 2009 02:22:42 +0300
Message-ID: <1241133762-989-1-git-send-email-bhalevy@panasas.com>
References: <49FA3180.5030404@panasas.com>
Cc: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>,
	Ricardo Labiaga <ricardo.labiaga@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:20040 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757476AbZD3XWt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 19:22:49 -0400
In-Reply-To: <49FA3180.5030404@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Set the SESSION4_BACK_CHAN flag to indicate the client supports a backchannel.

Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 530ebb1..aab69f0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4601,7 +4601,7 @@ static int _nfs4_proc_create_session(struct nfs_client *clp)
 	int status;
 
 	nfs4_init_channel_attrs(&args);
-	args.flags = (SESSION4_PERSIST);
+	args.flags = (SESSION4_PERSIST | SESSION4_BACK_CHAN);
 
 	status = rpc_call_sync(session->clp->cl_rpcclient, &msg, 0);
 
-- 
1.6.2.1

