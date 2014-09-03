Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:27693 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750992AbaICSPq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Sep 2014 14:15:46 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFS: Clear up state owner lock usage
Date: Wed, 3 Sep 2014 14:15:40 -0400
Message-ID: <1409768140-3826-2-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1409768140-3826-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1409768140-3826-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

can_open_cached() reads values out of the state structure, meaning that
we need the so_lock to have a correct return value.  As a bonus, this
helps clear up some potentially confusing code.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4proc.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7dd8aca..18eb31c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1307,15 +1307,13 @@ static struct nfs4_state *nfs4_try_open_cached(struct nfs4_opendata *opendata)
 	int ret = -EAGAIN;
 
 	for (;;) {
+		spin_lock(&state->owner->so_lock);
 		if (can_open_cached(state, fmode, open_mode)) {
-			spin_lock(&state->owner->so_lock);
-			if (can_open_cached(state, fmode, open_mode)) {
-				update_open_stateflags(state, fmode);
-				spin_unlock(&state->owner->so_lock);
-				goto out_return_state;
-			}
+			update_open_stateflags(state, fmode);
 			spin_unlock(&state->owner->so_lock);
+			goto out_return_state;
 		}
+		spin_unlock(&state->owner->so_lock);
 		rcu_read_lock();
 		delegation = rcu_dereference(nfsi->delegation);
 		if (!can_open_delegated(delegation, fmode)) {
-- 
2.1.0

