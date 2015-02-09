Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f170.google.com ([209.85.213.170]:36780 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933766AbbBIWsc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Feb 2015 17:48:32 -0500
Received: by mail-ig0-f170.google.com with SMTP id l13so18293045iga.1
        for <linux-nfs@vger.kernel.org>; Mon, 09 Feb 2015 14:48:31 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 14/15] SUNRPC: Define xs_tcp_fin_timeout only if CONFIG_SUNRPC_DEBUG
Date: Mon,  9 Feb 2015 17:48:10 -0500
Message-Id: <1423522091-35365-15-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1423522091-35365-14-git-send-email-trond.myklebust@primarydata.com>
References: <1423522091-35365-1-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-2-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-3-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-4-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-5-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-6-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-7-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-8-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-9-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-10-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-11-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-12-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-13-git-send-email-trond.myklebust@primarydata.com>
 <1423522091-35365-14-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that the linger code is gone, the xs_tcp_fin_timeout variable has
no real function. Keep it for now, since it is part of the /proc
interface, but only define it if that /proc interface is enabled.

Suggested-by: Anna Schumaker <Anna.Schumaker@netapp.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprtsock.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 540d542d85e5..8ab02262c761 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -63,6 +63,8 @@ static unsigned int xprt_max_tcp_slot_table_entries = RPC_MAX_SLOT_TABLE;
 static unsigned int xprt_min_resvport = RPC_DEF_MIN_RESVPORT;
 static unsigned int xprt_max_resvport = RPC_DEF_MAX_RESVPORT;
 
+#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
+
 #define XS_TCP_LINGER_TO	(15U * HZ)
 static unsigned int xs_tcp_fin_timeout __read_mostly = XS_TCP_LINGER_TO;
 
@@ -75,8 +77,6 @@ static unsigned int xs_tcp_fin_timeout __read_mostly = XS_TCP_LINGER_TO;
  * someone else's file names!
  */
 
-#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
-
 static unsigned int min_slot_table_size = RPC_MIN_SLOT_TABLE;
 static unsigned int max_slot_table_size = RPC_MAX_SLOT_TABLE;
 static unsigned int max_tcp_slot_table_limit = RPC_MAX_SLOT_TABLE_LIMIT;
-- 
2.1.0

