Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35176 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751437AbdATIub (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Jan 2017 03:50:31 -0500
Received: by mail-pg0-f67.google.com with SMTP id 204so6416546pge.2
        for <linux-nfs@vger.kernel.org>; Fri, 20 Jan 2017 00:48:50 -0800 (PST)
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH] SUNRPC: cleanup ida information when removing sunrpc module
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Cc: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <cba6d0d9-dff9-b096-dd70-91e092a3e829@gmail.com>
Date: Fri, 20 Jan 2017 16:48:39 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

After removing sunrpc module, I get many kmemleak information as,
unreferenced object 0xffff88003316b1e0 (size 544):
  comm "gssproxy", pid 2148, jiffies 4294794465 (age 4200.081s)
  hex dump (first 32 bytes):
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
  backtrace:
    [<ffffffffb0cfb58a>] kmemleak_alloc+0x4a/0xa0
    [<ffffffffb03507fe>] kmem_cache_alloc+0x15e/0x1f0
    [<ffffffffb0639baa>] ida_pre_get+0xaa/0x150
    [<ffffffffb0639cfd>] ida_simple_get+0xad/0x180
    [<ffffffffc06054fb>] nlmsvc_lookup_host+0x4ab/0x7f0 [lockd]
    [<ffffffffc0605e1d>] lockd+0x4d/0x270 [lockd]
    [<ffffffffc06061e5>] param_set_timeout+0x55/0x100 [lockd]
    [<ffffffffc06cba24>] svc_defer+0x114/0x3f0 [sunrpc]
    [<ffffffffc06cbbe7>] svc_defer+0x2d7/0x3f0 [sunrpc]
    [<ffffffffc06c71da>] rpc_show_info+0x8a/0x110 [sunrpc]
    [<ffffffffb044a33f>] proc_reg_write+0x7f/0xc0
    [<ffffffffb038e41f>] __vfs_write+0xdf/0x3c0
    [<ffffffffb0390f1f>] vfs_write+0xef/0x240
    [<ffffffffb0392fbd>] SyS_write+0xad/0x130
    [<ffffffffb0d06c37>] entry_SYSCALL_64_fastpath+0x1a/0xa9
    [<ffffffffffffffff>] 0xffffffffffffffff

I found, the ida information (dynamic memory) isn't cleanup.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 include/linux/sunrpc/clnt.h | 1 +
 net/sunrpc/clnt.c           | 5 +++++
 net/sunrpc/sunrpc_syms.c    | 1 +
 3 files changed, 7 insertions(+)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 85cc819..333ad11 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -216,5 +216,6 @@ void rpc_clnt_xprt_switch_put(struct rpc_clnt *);
 void rpc_clnt_xprt_switch_add_xprt(struct rpc_clnt *, struct rpc_xprt *);
 bool rpc_clnt_xprt_switch_has_addr(struct rpc_clnt *clnt,
 			const struct sockaddr *sap);
+void rpc_cleanup_clids(void);
 #endif /* __KERNEL__ */
 #endif /* _LINUX_SUNRPC_CLNT_H */
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 1efbe48..1dc9f3b 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -336,6 +336,11 @@ static int rpc_client_register(struct rpc_clnt *clnt,
 
 static DEFINE_IDA(rpc_clids);
 
+void rpc_cleanup_clids(void)
+{
+	ida_destroy(&rpc_clids);
+}
+
 static int rpc_alloc_clid(struct rpc_clnt *clnt)
 {
 	int clid;
diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
index d1c330a..c73de18 100644
--- a/net/sunrpc/sunrpc_syms.c
+++ b/net/sunrpc/sunrpc_syms.c
@@ -119,6 +119,7 @@ init_sunrpc(void)
 static void __exit
 cleanup_sunrpc(void)
 {
+	rpc_cleanup_clids();
 	rpcauth_remove_module();
 	cleanup_socket_xprt();
 	svc_cleanup_xprt_sock();
-- 
2.9.3

