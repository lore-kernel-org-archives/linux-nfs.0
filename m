Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:45939 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932123Ab2GCQYt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Jul 2012 12:24:49 -0400
Subject: [PATCH v3 10/11] NFS: add debug messages to callback down function
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Tue, 03 Jul 2012 20:20:36 +0400
Message-ID: <20120703162036.11911.60789.stgit@localhost.localdomain>
In-Reply-To: <20120703161844.11911.92996.stgit@localhost.localdomain>
References: <20120703161844.11911.92996.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfs/callback.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 35ccd2a..b4e76e9 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -422,7 +422,9 @@ void nfs_callback_down(int minorversion, struct net *net)
 	cb_info->users--;
 	if (cb_info->users == 0 && cb_info->task != NULL) {
 		kthread_stop(cb_info->task);
+		dprintk("nfs_callback_down: service stopped\n");
 		svc_exit_thread(cb_info->rqst);
+		dprintk("nfs_callback_down: service destroyed\n");
 		cb_info->serv = NULL;
 		cb_info->rqst = NULL;
 		cb_info->task = NULL;

