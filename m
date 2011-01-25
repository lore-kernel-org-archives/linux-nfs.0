Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:24153 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752596Ab1AYPhm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Jan 2011 10:37:42 -0500
From: andros@netapp.com
To: trond.myklebuse@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 2/3] NFS fix cb_sequence error processing
Date: Tue, 25 Jan 2011 10:38:02 -0500
Message-Id: <1295969883-2100-2-git-send-email-andros@netapp.com>
In-Reply-To: <1295969883-2100-1-git-send-email-andros@netapp.com>
References: <1295969883-2100-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Always assign the cb_process_state nfs_client pointer so a processing error
in cb_sequence after the nfs_client is found and referenced returns
a non-NULL cb_process_state nfs_client and the matching nfs_put_client in
nfs4_callback_compound dereferences the client.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/callback_proc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 829f406..8958757 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -408,9 +408,9 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
 	res->csr_highestslotid = NFS41_BC_MAX_CALLBACKS - 1;
 	res->csr_target_highestslotid = NFS41_BC_MAX_CALLBACKS - 1;
 	nfs4_cb_take_slot(clp);
-	cps->clp = clp; /* put in nfs4_callback_compound */
 
 out:
+	cps->clp = clp; /* put in nfs4_callback_compound */
 	for (i = 0; i < args->csa_nrclists; i++)
 		kfree(args->csa_rclists[i].rcl_refcalls);
 	kfree(args->csa_rclists);
-- 
1.6.6

