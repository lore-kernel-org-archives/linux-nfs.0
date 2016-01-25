Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:37643 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932095AbcAYOJx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Jan 2016 09:09:53 -0500
Received: by mail-ig0-f181.google.com with SMTP id h5so30812988igh.0
        for <linux-nfs@vger.kernel.org>; Mon, 25 Jan 2016 06:09:52 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/5] NFSv4.x: CB_SEQUENCE should return NFS4ERR_DELAY if still executing
Date: Mon, 25 Jan 2016 09:09:13 -0500
Message-Id: <1453730956-5325-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1453730956-5325-2-git-send-email-trond.myklebust@primarydata.com>
References: <1453730956-5325-1-git-send-email-trond.myklebust@primarydata.com>
 <1453730956-5325-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

See RFC5661 Section 2.10.6.2: if retrying a request, and the old one is
still in progress, we must return NFS4ERR_DELAY as the reply to sequence.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/callback_proc.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 83a66a8f40f2..e0844fdbd9ac 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -375,6 +375,8 @@ validate_seqid(struct nfs4_slot_table *tbl, struct cb_sequenceargs * args)
 	if (args->csa_sequenceid == slot->seq_nr) {
 		dprintk("%s seqid %u is a replay\n",
 			__func__, args->csa_sequenceid);
+		if (tbl->highest_used_slotid != NFS4_NO_SLOT)
+			return htonl(NFS4ERR_DELAY);
 		/* Signal process_op to set this error on next op */
 		if (args->csa_cachethis == 0)
 			return htonl(NFS4ERR_RETRY_UNCACHED_REP);
-- 
2.5.0

