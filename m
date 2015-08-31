Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35124 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752311AbbHaCxm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 30 Aug 2015 22:53:42 -0400
Received: by pacdd16 with SMTP id dd16so122918305pac.2
        for <linux-nfs@vger.kernel.org>; Sun, 30 Aug 2015 19:53:42 -0700 (PDT)
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH 1/2] nfs: Fix truncated client owner id without proto type
Message-ID: <55E3C1AD.10800@gmail.com>
Date: Mon, 31 Aug 2015 10:53:33 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The length of "Linux NFSv4.0 " is 14, not 10.

Without this patch, I get a truncated client owner id as, 
"Linux NFSv4.0 ::1/::1"

With this patch, 
"Linux NFSv4.0 ::1/::1 tcp"

Fixex: a319268891 ("nfs: make nfs4_init_nonuniform_client_string use a dynamically allocated buffer")
Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/nfs4proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3acb1eb..b7d1bc0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4984,7 +4984,7 @@ nfs4_init_nonuniform_client_string(struct nfs_client *clp)
 		return 0;
 retry:
 	rcu_read_lock();
-	len = 10 + strlen(clp->cl_ipaddr) + 1 +
+	len = 14 + strlen(clp->cl_ipaddr) + 1 +
 		strlen(rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_ADDR)) +
 		1 +
 		strlen(rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_PROTO)) +
-- 
2.4.3

