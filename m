Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shutemov.name ([188.40.19.243]:46270 "EHLO shutemov.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752043Ab0LPN0H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Dec 2010 08:26:07 -0500
From: "Kirill A. Shutsemov" <kirill@shutemov.name>
To: "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [PATCH] nfsd: declare several functions of nfs4callback as static
Date: Thu, 16 Dec 2010 15:25:54 +0200
Message-Id: <1292505954-26290-1-git-send-email-kirill@shutemov.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Kirill A. Shutemov <kirill@shutemov.name>

setup_callback_client(), nfsd4_release_cb() and nfsd4_process_cb_update()
do not have users outside the translation unit. Let's declare it as
static.

Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
---
 fs/nfsd/nfs4callback.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index a95150d..515a9b1 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -474,7 +474,8 @@ static int max_cb_time(void)
 /* Reference counting, callback cleanup, etc., all look racy as heck.
  * And why is cl_cb_set an atomic? */
 
-int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *conn)
+static int setup_callback_client(struct nfs4_client *clp,
+		struct nfs4_cb_conn *conn)
 {
 	struct rpc_timeout	timeparms = {
 		.to_initval	= max_cb_time(),
@@ -750,13 +751,13 @@ void nfsd4_shutdown_callback(struct nfs4_client *clp)
 	flush_workqueue(callback_wq);
 }
 
-void nfsd4_release_cb(struct nfsd4_callback *cb)
+static void nfsd4_release_cb(struct nfsd4_callback *cb)
 {
 	if (cb->cb_ops->rpc_release)
 		cb->cb_ops->rpc_release(cb);
 }
 
-void nfsd4_process_cb_update(struct nfsd4_callback *cb)
+static void nfsd4_process_cb_update(struct nfsd4_callback *cb)
 {
 	struct nfs4_cb_conn conn;
 	struct nfs4_client *clp = cb->cb_clp;
-- 
1.7.3.3

