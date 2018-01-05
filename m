Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:43021 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751268AbeAEHjQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Jan 2018 02:39:16 -0500
Date: Fri, 5 Jan 2018 08:39:12 +0100
From: Jan Chochol <jan@chochol.info>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: Do not convert nfs_idmap_cache_timeout to jiffies
Message-ID: <20180105073910.GA1357@t540p>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since commit 57e62324e469 ("NFS: Store the legacy idmapper result in the
keyring") nfs_idmap_cache_timeout changed units from jiffies to seconds.
Unfortunately sysctl interface was not updated accordingly.

As a effect updating /proc/sys/fs/nfs/idmap_cache_timeout with some
value will incorrectly multiply this value by HZ.
Also reading /proc/sys/fs/nfs/idmap_cache_timeout will show real value
divided by HZ.

Fixes: 57e62324e469 ("NFS: Store the legacy idmapper result in the keyring")
Signed-off-by: Jan Chochol <jan@chochol.info>
---
 fs/nfs/nfs4sysctl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4sysctl.c b/fs/nfs/nfs4sysctl.c
index 0d91d84e5822..c394e4447100 100644
--- a/fs/nfs/nfs4sysctl.c
+++ b/fs/nfs/nfs4sysctl.c
@@ -32,7 +32,7 @@ static struct ctl_table nfs4_cb_sysctls[] = {
 		.data = &nfs_idmap_cache_timeout,
 		.maxlen = sizeof(int),
 		.mode = 0644,
-		.proc_handler = proc_dointvec_jiffies,
+		.proc_handler = proc_dointvec,
 	},
 	{ }
 };
-- 
2.14.2

