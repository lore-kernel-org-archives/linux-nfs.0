Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:40861 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727418AbeHKS1j (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 11 Aug 2018 14:27:39 -0400
Received: by mail-it0-f66.google.com with SMTP id h23-v6so6949172ita.5
        for <linux-nfs@vger.kernel.org>; Sat, 11 Aug 2018 08:53:03 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: Fix a typo in nfs4_init_channel_attrs()
Date: Sat, 11 Aug 2018 11:52:39 -0400
Message-Id: <20180811155239.81855-2-trond.myklebust@hammerspace.com>
In-Reply-To: <20180811155239.81855-1-trond.myklebust@hammerspace.com>
References: <20180811155239.81855-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The back channel size is allowed to be 1 or greater.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 217cefc51d47..9a349587d077 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8215,7 +8215,7 @@ static void nfs4_init_channel_attrs(struct nfs41_create_session_args *args,
 	args->bc_attrs.max_resp_sz = max_bc_payload;
 	args->bc_attrs.max_resp_sz_cached = 0;
 	args->bc_attrs.max_ops = NFS4_MAX_BACK_CHANNEL_OPS;
-	args->bc_attrs.max_reqs = min_t(unsigned short, max_session_cb_slots, 1);
+	args->bc_attrs.max_reqs = max_t(unsigned short, max_session_cb_slots, 1);
 
 	dprintk("%s: Back Channel : max_rqst_sz=%u max_resp_sz=%u "
 		"max_resp_sz_cached=%u max_ops=%u max_reqs=%u\n",
-- 
2.17.1
