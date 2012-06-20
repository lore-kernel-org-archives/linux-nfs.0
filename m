Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56213 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753790Ab2FTN1j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Jun 2012 09:27:39 -0400
Date: Wed, 20 Jun 2012 09:27:38 -0400
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: stable@vger.kernel.org, linux-nfs@vger.kernel.org,
        Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: [PATCH 4/3] lockd: hard-code init_net in lockd case as well
Message-ID: <20120620132738.GA30742@fieldses.org>
References: <1340050049-12880-1-git-send-email-bfields@redhat.com>
 <1340050049-12880-4-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1340050049-12880-4-git-send-email-bfields@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

The previous patch missed lockd_down, which has the same problem.
Symptoms were crashes on unmount or reboot.

Note this was fixed in a different way upstream.

Acked-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/lockd/svc.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index f1b3cce..c933df4 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -300,7 +300,7 @@ int lockd_up(void)
 {
 	struct svc_serv *serv;
 	int		error = 0;
-	struct net *net = current->nsproxy->net_ns;
+	struct net *net = &init_net;
 	struct lockd_net *ln = net_generic(net, lockd_net_id);
 
 	mutex_lock(&nlmsvc_mutex);
@@ -391,7 +391,7 @@ void
 lockd_down(void)
 {
 	mutex_lock(&nlmsvc_mutex);
-	lockd_down_net(current->nsproxy->net_ns);
+	lockd_down_net(&init_net);
 	if (nlmsvc_users) {
 		if (--nlmsvc_users)
 			goto out;
-- 
1.7.9.5

