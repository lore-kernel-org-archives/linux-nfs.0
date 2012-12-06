Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:23662 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423892Ab2LFPee (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Dec 2012 10:34:34 -0500
Subject: [PATCH 6/6] nfsd: enable NFSv4 state in containers
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Thu, 06 Dec 2012 18:35:07 +0300
Message-ID: <20121206153507.30693.72204.stgit@localhost.localdomain>
In-Reply-To: <20121206153204.30693.11408.stgit@localhost.localdomain>
References: <20121206153204.30693.11408.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, NFSd is ready to operate in network namespace based containers.
So let's drop check for "init_net" and make it able to fly.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/nfs4state.c |   10 ----------
 1 files changed, 0 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 39605c1..b3b6daa 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4866,16 +4866,6 @@ nfs4_state_start_net(struct net *net)
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 	int ret;
 
-	/*
-	 * FIXME: For now, we hang most of the pernet global stuff off of
-	 * init_net until nfsd is fully containerized. Eventually, we'll
-	 * need to pass a net pointer into this function, take a reference
-	 * to that instead and then do most of the rest of this on a per-net
-	 * basis.
-	 */
-	if (net != &init_net)
-		return -EINVAL;
-
 	ret = nfs4_state_create_net(net);
 	if (ret)
 		return ret;

