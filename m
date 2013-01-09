Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:9853 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757584Ab3AIJiV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Jan 2013 04:38:21 -0500
Subject: [PATCH] nfsd: fix unused "nn" variable warning in free_client()
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: toralf.foerster@gmx.de, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Wed, 09 Jan 2013 12:38:34 +0300
Message-ID: <20130109093834.13789.270.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If CONFIG_LOCKDEP is disabled, then there would be a warning like this:

  CC [M]  fs/nfsd/nfs4state.o
fs/nfsd/nfs4state.c: In function ‘free_client’:
fs/nfsd/nfs4state.c:1051:19: warning: unused variable ‘nn’ [-Wunused-variable]

So, let's add "maybe_unused" tag to this variable.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/nfs4state.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 8f7362c..739a6c2 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1048,7 +1048,7 @@ static struct nfs4_client *alloc_client(struct xdr_netobj name)
 static inline void
 free_client(struct nfs4_client *clp)
 {
-	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
+	struct nfsd_net __maybe_unused *nn = net_generic(clp->net, nfsd_net_id);
 
 	lockdep_assert_held(&nn->client_lock);
 	while (!list_empty(&clp->cl_sessions)) {

