Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:54067 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751923Ab1IUA1f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Sep 2011 20:27:35 -0400
Received: from /spool/local
	by us.ibm.com with XMail ESMTP
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Tue, 20 Sep 2011 20:27:34 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8L0RFTK933952
	for <linux-nfs@vger.kernel.org>; Tue, 20 Sep 2011 20:27:15 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8L0RF5R007295
	for <linux-nfs@vger.kernel.org>; Tue, 20 Sep 2011 21:27:15 -0300
Date: Tue, 20 Sep 2011 17:27:14 -0700
From: Malahal Naineni <malahal@us.ibm.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Check validity of cl_rpcclient in nfs_server_list_show
Message-ID: <20110921002714.GA31689@us.ibm.com>
References: <1315965305-23757-1-git-send-email-malahal@us.ibm.com>
 <20110919153429.GA16725@us.ibm.com>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B35626A@SACMVEXC2-PRD.hq.netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B35626A@SACMVEXC2-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Myklebust, Trond [Trond.Myklebust@netapp.com] wrote:
> Shouldn't we just skip all nfs_client structures that don't have
> cl_cons_state set to NFS_CS_READY? I see no reason to display their
> properties even if they have got far enough as to create an rpc client.
> 
> Cheers
>   Trond

Sounds good to me. Here is a tested patch.


As soon as the nfs_client gets created, its cl_rpcclient is set to
ERR_PTR(-EINVAL). The rpc client structure is allocated later. Check
if the client is ready before using the cl_rpcclient pointer.

Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
---
 fs/nfs/client.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 5833fbb..a54c45e 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1867,6 +1867,10 @@ static int nfs_server_list_show(struct seq_file *m, void *v)
 	/* display one transport per line on subsequent lines */
 	clp = list_entry(v, struct nfs_client, cl_share_link);
 
+	/* Check if the client is initialized */
+	if (clp->cl_cons_state != NFS_CS_READY)
+		return 0;
+
 	seq_printf(m, "v%u %s %s %3d %s\n",
 		   clp->rpc_ops->version,
 		   rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_HEX_ADDR),
-- 
1.7.0.4

