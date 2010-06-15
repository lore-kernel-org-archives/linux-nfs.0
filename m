From: andros@netapp.com
Subject: [PATCH 1/1] NFSv4.1 set NFS4_MAX_SLOT_TABLE in _nfs41_proc_sequence
Date: Tue, 15 Jun 2010 18:31:29 -0400
Message-ID: <1276641089-6867-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.212.112.111]:46947 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753474Ab0FOWjF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jun 2010 18:39:05 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

_nfs41_proc_sequence() kmallocs the calldata but does not set
calldata->res.slotid to NFS4_MAX_SLOT_TABLE, so nfs41_sequence_prepare() calls
nfs41_setup_sequence() with the res.sr_slotid set to a random value.
If nfs41_setup_sequence() sees res.sr_slotid as not set to NFS4_MAX_SLOT_TABLE,
it returns without actually setting up the sequence.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 04eff86..243d6c7 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5142,6 +5142,7 @@ static struct rpc_task *_nfs41_proc_sequence(struct nfs_client *clp, struct rpc_
 		nfs_put_client(clp);
 		return ERR_PTR(-ENOMEM);
 	}
+	calldata->res.sr_slotid = NFS4_MAX_SLOT_TABLE;
 	msg.rpc_argp = &calldata->args;
 	msg.rpc_resp = &calldata->res;
 	calldata->clp = clp;
-- 
1.6.6

