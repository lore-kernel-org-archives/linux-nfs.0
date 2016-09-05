Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35123 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932294AbcIENqx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Sep 2016 09:46:53 -0400
Received: by mail-it0-f66.google.com with SMTP id c198so8886985ith.2
        for <linux-nfs@vger.kernel.org>; Mon, 05 Sep 2016 06:46:52 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/4] pNFS: Ensure LAYOUTGET and LAYOUTRETURN are properly serialised
Date: Mon,  5 Sep 2016 09:45:59 -0400
Message-Id: <1473083162-4697-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1473083162-4697-1-git-send-email-trond.myklebust@primarydata.com>
References: <1473083162-4697-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

According to RFC5661, the client is responsible for serialising
LAYOUTGET and LAYOUTRETURN to avoid ambiguity. Consider the case
where we send both in parallel.

Client					Server
======					======
LAYOUTGET(seqid=X)
LAYOUTRETURN(seqid=X)
					LAYOUTGET return seqid=X+1
					LAYOUTRETURN return seqid=X+2
Process LAYOUTRETURN
          Forget layout stateid
Process LAYOUTGET
          Set seqid=X+1

The client processes the layoutget/layoutreturn in the wrong order,
and since the result of the layoutreturn was to clear the only
existing layout segment, the client forgets the layout stateid.

When the LAYOUTGET comes in, it is treated as having a completely
new stateid, and so the client sets the wrong sequence id...

Fix is to check if there are outstanding LAYOUTGET requests
before we send the LAYOUTRETURN (note that LAYOUGET will already
wait if it sees an outstanding LAYOUTRETURN).

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: stable@vger.kernel.org # v4.5+
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 6daf034645c8..519ad320f5cd 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -899,6 +899,9 @@ pnfs_prepare_layoutreturn(struct pnfs_layout_hdr *lo,
 		nfs4_stateid *stateid,
 		enum pnfs_iomode *iomode)
 {
+	/* Serialise LAYOUTGET/LAYOUTRETURN */
+	if (atomic_read(&lo->plh_outstanding) != 0)
+		return false;
 	if (test_and_set_bit(NFS_LAYOUT_RETURN, &lo->plh_flags))
 		return false;
 	pnfs_get_layout_hdr(lo);
-- 
2.7.4

