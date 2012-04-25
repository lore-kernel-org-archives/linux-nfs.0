Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:25436 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759319Ab2DYOXR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Apr 2012 10:23:17 -0400
Subject: [PATCH 4/6] LockD: move global usage counter manipulation from error
 path
To: bfields@fieldses.org, Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Wed, 25 Apr 2012 18:23:02 +0400
Message-ID: <20120425142301.22909.31119.stgit@localhost6.localdomain6>
In-Reply-To: <20120425141934.22909.53047.stgit@localhost6.localdomain6>
References: <20120425141934.22909.53047.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/lockd/svc.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index ad11ea7..53cd69e 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -329,7 +329,7 @@ static struct svc_serv *lockd_create_svc(void)
 int lockd_up(struct net *net)
 {
 	struct svc_serv *serv;
-	int		error = 0;
+	int error;
 
 	mutex_lock(&nlmsvc_mutex);
 
@@ -370,14 +370,13 @@ int lockd_up(struct net *net)
 		goto err_start;
 	}
 
+	nlmsvc_users++;
 	/*
 	 * Note: svc_serv structures have an initial use count of 1,
 	 * so we exit through here on both success and failure.
 	 */
 err_net:
 	svc_destroy(serv);
-	if (!error)
-		nlmsvc_users++;
 err_create:
 	mutex_unlock(&nlmsvc_mutex);
 	return error;

