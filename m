Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:36630 "EHLO
	mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753438AbbLZXVo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 26 Dec 2015 18:21:44 -0500
Received: by mail-io0-f176.google.com with SMTP id o67so280020138iof.3
        for <linux-nfs@vger.kernel.org>; Sat, 26 Dec 2015 15:21:44 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 07/14] NFS41: map NFS4ERR_LAYOUTUNAVAILABLE to ENODATA
Date: Sat, 26 Dec 2015 18:20:53 -0500
Message-Id: <1451172060-28238-7-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1451172060-28238-6-git-send-email-trond.myklebust@primarydata.com>
References: <1451172060-28238-1-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-2-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-3-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-4-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-5-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-6-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

Instead of mapping it to EIO that is a fatal error and
fails application. We'll go inband after getting
NFS4ERR_LAYOUTUNAVAILABLE.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 18d862db15b6..0065bbdc53c3 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7795,6 +7795,15 @@ static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
 	switch (task->tk_status) {
 	case 0:
 		goto out;
+
+	/*
+	 * NFS4ERR_LAYOUTUNAVAILABLE means we are not supposed to use pnfs
+	 * on the file. set tk_status to -ENODATA to tell upper layer to
+	 * retry go inband.
+	 */
+	case -NFS4ERR_LAYOUTUNAVAILABLE:
+		task->tk_status = -ENODATA;
+		goto out;
 	/*
 	 * NFS4ERR_BADLAYOUT means the MDS cannot return a layout of
 	 * length lgp->args.minlength != 0 (see RFC5661 section 18.43.3).
-- 
2.5.0

