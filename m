Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40318 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966728Ab0GSUux (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Jul 2010 16:50:53 -0400
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 4/5] nfsd: shut down NFSv4 state when nfsd_svc encounters an error
Date: Mon, 19 Jul 2010 16:50:07 -0400
Message-Id: <1279572608-7234-5-git-send-email-jlayton@redhat.com>
In-Reply-To: <1279572608-7234-1-git-send-email-jlayton@redhat.com>
References: <1279572608-7234-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Currently, it's left up in some situations. That could cause the grace
period to be shorter than it should be (along with other problems).

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfssvc.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 06b2a26..a06ea99 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -402,9 +402,9 @@ nfsd_svc(unsigned short port, int nrservs)
 	nfsd_reset_versions();
 
 	error = nfsd_create_serv();
-
 	if (error)
-		goto out;
+		goto shutdown_state;
+
 	error = nfsd_init_socks(port);
 	if (error)
 		goto failure;
@@ -416,9 +416,12 @@ nfsd_svc(unsigned short port, int nrservs)
 		 * so subtract 1
 		 */
 		error = nfsd_serv->sv_nrthreads - 1;
- failure:
+failure:
 	svc_destroy(nfsd_serv);		/* Release server */
- out:
+shutdown_state:
+	if (error < 0)
+		nfs4_state_shutdown();
+out:
 	mutex_unlock(&nfsd_mutex);
 	return error;
 }
-- 
1.5.5.6

