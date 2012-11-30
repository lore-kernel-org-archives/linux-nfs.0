Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:36556 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753656Ab2K3SJz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Nov 2012 13:09:55 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] SUNRPC: release clear_bit memory barrier
Date: Fri, 30 Nov 2012 13:09:45 -0500
Message-Id: <1354298985-2344-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
A cleanup patch.

 net/sunrpc/auth.c              |    1 +
 net/sunrpc/auth_gss/auth_gss.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index b5c067b..8b76753 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -225,6 +225,7 @@ rpcauth_unhash_cred_locked(struct rpc_cred *cred)
 	hlist_del_rcu(&cred->cr_hash);
 	smp_mb__before_clear_bit();
 	clear_bit(RPCAUTH_CRED_HASHED, &cred->cr_flags);
+	smp_mb__after_clear_bit();
 }
 
 static int
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 909dc0c..92a7d6d 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -126,6 +126,7 @@ gss_cred_set_ctx(struct rpc_cred *cred, struct gss_cl_ctx *ctx)
 	set_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
 	smp_mb__before_clear_bit();
 	clear_bit(RPCAUTH_CRED_NEW, &cred->cr_flags);
+	smp_mb__after_clear_bit();
 }
 
 static const void *
-- 
1.7.7.6

