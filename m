Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f53.google.com ([209.85.216.53]:64784 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756244AbaGPKwb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jul 2014 06:52:31 -0400
Received: by mail-qa0-f53.google.com with SMTP id v10so536377qac.12
        for <linux-nfs@vger.kernel.org>; Wed, 16 Jul 2014 03:52:30 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: bfields@fieldses.org, hch@infradead.org, linux-nfs@vger.kernel.org,
        Arnd Bergmann <arnd@arndb.de>,
        Paul McKenney <paulmck@linux.vnet.ibm.com>
Subject: [PATCH v2 1/5] sunrpc: remove __rcu annotation from struct gss_cl_ctx->gc_gss_ctx
Date: Wed, 16 Jul 2014 06:52:18 -0400
Message-Id: <1405507942-12256-2-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405507942-12256-1-git-send-email-jlayton@primarydata.com>
References: <1405303064-9102-1-git-send-email-jlayton@primarydata.com>
 <1405507942-12256-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 5b22216e11f7 (nfs: __rcu annotations) added a __rcu annotation to
the gc_gss_ctx field. I see no rationale for adding that though, as that
field does not seem to be managed via RCU at all.

Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Paul McKenney <paulmck@linux.vnet.ibm.com>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 include/linux/sunrpc/auth_gss.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/sunrpc/auth_gss.h b/include/linux/sunrpc/auth_gss.h
index cbc6875fb9cf..36eebc451b41 100644
--- a/include/linux/sunrpc/auth_gss.h
+++ b/include/linux/sunrpc/auth_gss.h
@@ -69,7 +69,7 @@ struct gss_cl_ctx {
 	enum rpc_gss_proc	gc_proc;
 	u32			gc_seq;
 	spinlock_t		gc_seq_lock;
-	struct gss_ctx __rcu	*gc_gss_ctx;
+	struct gss_ctx		*gc_gss_ctx;
 	struct xdr_netobj	gc_wire_ctx;
 	struct xdr_netobj	gc_acceptor;
 	u32			gc_win;
-- 
1.9.3

