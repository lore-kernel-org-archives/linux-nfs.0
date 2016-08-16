Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35242 "EHLO
	mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932343AbcHPPTD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Aug 2016 11:19:03 -0400
Received: by mail-it0-f68.google.com with SMTP id f6so5432929ith.2
        for <linux-nfs@vger.kernel.org>; Tue, 16 Aug 2016 08:19:02 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] pNFS/flexfiles: Set reasonable default retrans values for the data channel
Date: Tue, 16 Aug 2016 11:18:23 -0400
Message-Id: <1471360703-40804-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1471360703-40804-1-git-send-email-trond.myklebust@primarydata.com>
References: <1471360703-40804-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Prior to this patch, the retrans value was set at 5, meaning that we
could see a maximum retransmission timeout value of more than 6 minutes.
That's a tad high for NFSv3 where the protocol does allow the server to
drop requests at any time.

Since this is a data channel, let's just set retrans to 0, and the default
timeout to 60s. The user can continue to adjust these defaults using the
dataserver_retrans and dataserver_timeo module parameters.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 0aa36be71fce..970efba05ae1 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -17,8 +17,8 @@
 
 #define NFSDBG_FACILITY		NFSDBG_PNFS_LD
 
-static unsigned int dataserver_timeo = NFS4_DEF_DS_TIMEO;
-static unsigned int dataserver_retrans = NFS4_DEF_DS_RETRANS;
+static unsigned int dataserver_timeo = NFS_DEF_TCP_RETRANS;
+static unsigned int dataserver_retrans;
 
 void nfs4_ff_layout_put_deviceid(struct nfs4_ff_layout_ds *mirror_ds)
 {
-- 
2.7.4

