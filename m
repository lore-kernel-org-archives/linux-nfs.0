Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:40154 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755166Ab2KZMTw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 07:19:52 -0500
Subject: [PATCH 2/5] nfsd: make delegations shutdown network namespace aware
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Mon, 26 Nov 2012 15:22:03 +0300
Message-ID: <20121126122203.955.90909.stgit@localhost.localdomain>
In-Reply-To: <20121126121907.955.25349.stgit@localhost.localdomain>
References: <20121126121907.955.25349.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFSv4 delegations are stored in global list. But they are nfs4_client
dependent, which is network namespace aware already.
State shutdown and laundromat are done per network namespace as well.
So, delegations unhash have to be done in network namespace context.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/nfs4state.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index bf6edeb..149f7b1 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3230,6 +3230,8 @@ nfs4_laundromat(struct nfsd_net *nn)
 	spin_lock(&recall_lock);
 	list_for_each_safe(pos, next, &del_recall_lru) {
 		dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
+		if (net_generic(dp->dl_stid.sc_client->net, nfsd_net_id) != nn)
+			continue;
 		if (time_after((unsigned long)dp->dl_time, (unsigned long)cutoff)) {
 			u = dp->dl_time - cutoff;
 			if (test_val > u)
@@ -4918,6 +4920,8 @@ __nfs4_state_shutdown(struct net *net)
 	spin_lock(&recall_lock);
 	list_for_each_safe(pos, next, &del_recall_lru) {
 		dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
+		if (dp->dl_stid.sc_client->net != net)
+			continue;
 		list_move(&dp->dl_recall_lru, &reaplist);
 	}
 	spin_unlock(&recall_lock);

