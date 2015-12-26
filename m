Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:35168 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753476AbbLZXVp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 26 Dec 2015 18:21:45 -0500
Received: by mail-io0-f171.google.com with SMTP id q126so279966429iof.2
        for <linux-nfs@vger.kernel.org>; Sat, 26 Dec 2015 15:21:45 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 08/14] pnfs/flexfiles: do not mark delay-like status as DS failure
Date: Sat, 26 Dec 2015 18:20:54 -0500
Message-Id: <1451172060-28238-8-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1451172060-28238-7-git-send-email-trond.myklebust@primarydata.com>
References: <1451172060-28238-1-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-2-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-3-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-4-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-5-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-6-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-7-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

We just need to delay and retry in these cases.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 57e4010e3cde..b392156e6743 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1188,6 +1188,14 @@ static void ff_layout_io_track_ds_error(struct pnfs_layout_segment *lseg,
 		}
 	}
 
+	switch (status) {
+	case NFS4ERR_DELAY:
+	case NFS4ERR_GRACE:
+		return;
+	default:
+		break;
+	}
+
 	mirror = FF_LAYOUT_COMP(lseg, idx);
 	err = ff_layout_track_ds_error(FF_LAYOUT_FROM_HDR(lseg->pls_layout),
 				       mirror, offset, length, status, opnum,
@@ -1399,7 +1407,6 @@ static int ff_layout_write_done_cb(struct rpc_task *task,
 		ff_layout_reset_write(hdr, false);
 		return task->tk_status;
 	case -EAGAIN:
-		rpc_restart_call_prepare(task);
 		return -EAGAIN;
 	}
 
-- 
2.5.0

