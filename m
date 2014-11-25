Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f177.google.com ([209.85.216.177]:39658 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751144AbaKYTBL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Nov 2014 14:01:11 -0500
Received: by mail-qc0-f177.google.com with SMTP id x3so914598qcv.8
        for <linux-nfs@vger.kernel.org>; Tue, 25 Nov 2014 11:01:11 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>, bfields@redhat.com,
        linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/4] lockd: eliminate LOCKD_DEBUG
Date: Tue, 25 Nov 2014 14:00:57 -0500
Message-Id: <1416942060-6724-2-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1416942060-6724-1-git-send-email-jlayton@primarydata.com>
References: <1414520695-1701-1-git-send-email-jlayton@primarydata.com>
 <1416942060-6724-1-git-send-email-jlayton@primarydata.com>
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

