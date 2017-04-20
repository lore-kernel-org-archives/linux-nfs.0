Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35398 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S945615AbdDTSmF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Apr 2017 14:42:05 -0400
Received: by mail-io0-f193.google.com with SMTP id d203so19401005iof.2
        for <linux-nfs@vger.kernel.org>; Thu, 20 Apr 2017 11:42:04 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: Fix a hang in OPEN related to server reboot
Date: Thu, 20 Apr 2017 14:41:59 -0400
Message-Id: <20170420184159.125268-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the server fails to return the attributes as part of an OPEN
reply, and then reboots, we can end up hanging. The reason is that
the client attempts to send a GETATTR in order to pick up the
missing OPEN call, but fails to release the slot first, causing
reboot recovery to deadlock.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Fixes: 2e80dbe7ac51a ("NFSv4.1: Close callback races for OPEN, LAYOUTGET...")
Cc: stable@vger.kernel.org # v4.8+
---
 fs/nfs/nfs4proc.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4e52ac773d1f..6e9ff2d9a5bf 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2300,8 +2300,10 @@ static int _nfs4_proc_open(struct nfs4_opendata *data)
 		if (status != 0)
 			return status;
 	}
-	if (!(o_res->f_attr->valid & NFS_ATTR_FATTR))
+	if (!(o_res->f_attr->valid & NFS_ATTR_FATTR)) {
+		nfs4_sequence_free_slot(&o_res->seq_res);
 		nfs4_proc_getattr(server, &o_res->fh, o_res->f_attr, o_res->f_label);
+	}
 	return 0;
 }
 
-- 
2.9.3

