Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f48.google.com ([209.85.192.48]:51345 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750870AbaKZToy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Nov 2014 14:44:54 -0500
Received: by mail-qg0-f48.google.com with SMTP id q107so2525548qgd.7
        for <linux-nfs@vger.kernel.org>; Wed, 26 Nov 2014 11:44:53 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Subject: [PATCH v3 1/5] lockd: eliminate LOCKD_DEBUG
Date: Wed, 26 Nov 2014 14:44:40 -0500
Message-Id: <1417031084-17576-2-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1417031084-17576-1-git-send-email-jlayton@primarydata.com>
References: <1416942060-6724-1-git-send-email-jlayton@primarydata.com>
 <1417031084-17576-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

LOCKD_DEBUG is always the same value as CONFIG_SUNRPC_DEBUG, so we can
just use it instead.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/lockd/svclock.c          | 2 +-
 include/linux/lockd/debug.h | 6 +-----
 2 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index 13db95f54176..56598742dde4 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -53,7 +53,7 @@ static const struct rpc_call_ops nlmsvc_grant_ops;
 static LIST_HEAD(nlm_blocked);
 static DEFINE_SPINLOCK(nlm_blocked_lock);
 
-#ifdef LOCKD_DEBUG
+#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 static const char *nlmdbg_cookie2a(const struct nlm_cookie *cookie)
 {
 	/*
diff --git a/include/linux/lockd/debug.h b/include/linux/lockd/debug.h
index 257d3779f2ab..0ca8109934e4 100644
--- a/include/linux/lockd/debug.h
+++ b/include/linux/lockd/debug.h
@@ -17,12 +17,8 @@
  * Enable lockd debugging.
  * Requires RPC_DEBUG.
  */
-#ifdef RPC_DEBUG
-# define LOCKD_DEBUG		1
-#endif
-
 #undef ifdebug
-#if defined(RPC_DEBUG) && defined(LOCKD_DEBUG)
+#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 # define ifdebug(flag)		if (unlikely(nlm_debug & NLMDBG_##flag))
 #else
 # define ifdebug(flag)		if (0)
-- 
2.1.0

