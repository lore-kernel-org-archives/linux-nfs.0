Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga11.intel.com ([192.55.52.93]:21516 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750758Ab3AOHmH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jan 2013 02:42:07 -0500
From: Mika Westerberg <mika.westerberg@linux.intel.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David S. Miller" <davem@davemloft.net>,
        Mika Westerberg <mika.westerberg@linux.intel.com>,
        linux-kernel@vger.kernel.org
Subject: [PATCH 2/2] nfsd: fix compile warning about unused variable 'nn'
Date: Tue, 15 Jan 2013 09:43:07 +0200
Message-Id: <1358235787-17292-2-git-send-email-mika.westerberg@linux.intel.com>
In-Reply-To: <1358235787-17292-1-git-send-email-mika.westerberg@linux.intel.com>
References: <1358235787-17292-1-git-send-email-mika.westerberg@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit c9a4962881 (nfsd: make client_lock per net) added
lockdep_assert_held() call to function free_client(). However, if lockdep
is disabled we get following compiler warning:

fs/nfsd/nfs4state.c: In function ‘free_client’:
fs/nfsd/nfs4state.c:1051:19: warning: unused variable ‘nn’ [-Wunused-variable]

Fix this by marking the 'nn' with __maybe_unused.

Signed-off-by: Mika Westerberg <mika.westerberg@linux.intel.com>
---
 fs/nfsd/nfs4state.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ac8ed96..2d3011c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1048,7 +1048,7 @@ static struct nfs4_client *alloc_client(struct xdr_netobj name)
 static inline void
 free_client(struct nfs4_client *clp)
 {
-	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
+	struct nfsd_net *nn __maybe_unused = net_generic(clp->net, nfsd_net_id);
 
 	lockdep_assert_held(&nn->client_lock);
 	while (!list_empty(&clp->cl_sessions)) {
-- 
1.7.10.4

