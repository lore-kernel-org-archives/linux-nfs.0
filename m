Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:10864 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752864Ab3HVA0a (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Aug 2013 20:26:30 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
CC: Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 4/6] NFSv4: Deal with a sparse warning in nfs_idmap_get_key()
Date: Wed, 21 Aug 2013 20:26:24 -0400
Message-ID: <1377131186-40249-4-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1377131186-40249-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1377131186-40249-1-git-send-email-Trond.Myklebust@netapp.com>
 <1377131186-40249-2-git-send-email-Trond.Myklebust@netapp.com>
 <1377131186-40249-3-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/idmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index c2c4163..65c7d91 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -310,7 +310,7 @@ static ssize_t nfs_idmap_get_key(const char *name, size_t namelen,
 	if (ret < 0)
 		goto out_up;
 
-	payload = rcu_dereference(rkey->payload.data);
+	payload = rcu_dereference(rkey->payload.rcudata);
 	if (IS_ERR_OR_NULL(payload)) {
 		ret = PTR_ERR(payload);
 		goto out_up;
-- 
1.8.3.1

