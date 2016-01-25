Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:35703 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932090AbcAYOJw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Jan 2016 09:09:52 -0500
Received: by mail-ig0-f171.google.com with SMTP id t15so35969060igr.0
        for <linux-nfs@vger.kernel.org>; Mon, 25 Jan 2016 06:09:51 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/5] NFSv4.x: Remove hard coded slotids in callback channel
Date: Mon, 25 Jan 2016 09:09:12 -0500
Message-Id: <1453730956-5325-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1453730956-5325-1-git-send-email-trond.myklebust@primarydata.com>
References: <1453730956-5325-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead, use the values encoded in the slot table itself.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/callback_proc.c | 6 +++---
 fs/nfs/nfs4proc.c      | 2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index f0939d097406..83a66a8f40f2 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -361,7 +361,7 @@ validate_seqid(struct nfs4_slot_table *tbl, struct cb_sequenceargs * args)
 	dprintk("%s enter. slotid %u seqid %u\n",
 		__func__, args->csa_slotid, args->csa_sequenceid);
 
-	if (args->csa_slotid >= NFS41_BC_MAX_CALLBACKS)
+	if (args->csa_slotid > tbl->server_highest_slotid)
 		return htonl(NFS4ERR_BADSLOT);
 
 	slot = tbl->slots + args->csa_slotid;
@@ -489,8 +489,8 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
 	       sizeof(res->csr_sessionid));
 	res->csr_sequenceid = args->csa_sequenceid;
 	res->csr_slotid = args->csa_slotid;
-	res->csr_highestslotid = NFS41_BC_MAX_CALLBACKS - 1;
-	res->csr_target_highestslotid = NFS41_BC_MAX_CALLBACKS - 1;
+	res->csr_highestslotid = tbl->server_highest_slotid;
+	res->csr_target_highestslotid = tbl->target_highest_slotid;
 
 	status = validate_seqid(tbl, args);
 	if (status)
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4bfc33ad0563..be685e236bd5 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7319,7 +7319,7 @@ static void nfs4_init_channel_attrs(struct nfs41_create_session_args *args)
 	args->bc_attrs.max_resp_sz = PAGE_SIZE;
 	args->bc_attrs.max_resp_sz_cached = 0;
 	args->bc_attrs.max_ops = NFS4_MAX_BACK_CHANNEL_OPS;
-	args->bc_attrs.max_reqs = 1;
+	args->bc_attrs.max_reqs = NFS41_BC_MAX_CALLBACKS;
 
 	dprintk("%s: Back Channel : max_rqst_sz=%u max_resp_sz=%u "
 		"max_resp_sz_cached=%u max_ops=%u max_reqs=%u\n",
-- 
2.5.0

