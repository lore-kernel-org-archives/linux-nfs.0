Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52500 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755939Ab2ACW4Z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Jan 2012 17:56:25 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/4] svcrpc: don't revert to SVC_POOL_DEFAULT on nfsd shutdown
Date: Tue,  3 Jan 2012 17:56:21 -0500
Message-Id: <1325631381-9231-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1325631381-9231-1-git-send-email-bfields@redhat.com>
References: <1325631381-9231-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

This was unexpected behavior (at least for me)--why would you want
configuration settings automatically lost on nfsd restart?

In practice this won't affect distributions, which likely set everything
on every startup.  But I'd expect the behavior to be less confusing to
someone manually restarting nfsd for testing.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/svc.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 1dd5fd0..9701798 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -286,7 +286,6 @@ svc_pool_map_put(void)
 	mutex_lock(&svc_pool_map_mutex);
 
 	if (!--m->count) {
-		m->mode = SVC_POOL_DEFAULT;
 		kfree(m->to_pool);
 		m->to_pool = NULL;
 		kfree(m->pool_to);
-- 
1.7.5.4

