From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 55/69] rpc: remove unnecessary assignment
Date: Tue, 23 Dec 2008 18:02:22 -0500
Message-ID: <20081223230222.13743.20831.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63750 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752752AbYLWXYq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:24:46 -0500
Received: from sacrsexc1-prd.hq.netapp.com ([10.99.115.27])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNOc0f006400
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:24:41 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: \"J. Bruce Fields\" <bfields@citi.umich.edu>

We're just about to kfree() gss_auth, so there's no point to setting any
of its fields.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/auth_gss/auth_gss.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)


diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index cb19c9d..ea4567f 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -650,7 +650,6 @@ static void
 gss_free(struct gss_auth *gss_auth)
 {
 	rpc_unlink(gss_auth->dentry);
-	gss_auth->dentry = NULL;
 	gss_mech_put(gss_auth->mech);
 
 	kfree(gss_auth);

